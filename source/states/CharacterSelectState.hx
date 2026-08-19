package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.utils.Assets;

class CharacterSelectState extends MusicBeatState
{
    public static var selectedSongGroup:String = "bf_songs";

    var charData:Map<String, Array<String>> = new Map<String, Array<String>>();
    var charList:Array<String> = [];
    var curSelected:Int = 0;
    var isTransitioning:Bool = false;

    // 화면 요소
    var bg:FlxSprite;
    var charSprite:FlxSprite;
    var nameSprite:FlxSprite;
    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;

    override function create()
    {
        // 1. 배경
        bg = new FlxSprite().loadGraphic(Paths.image('charSelectBG'));
        add(bg);

        // 2. 캐릭터 스프라이트
        charSprite = new FlxSprite();
        add(charSprite);

        // 3. 이름 이미지 스프라이트
        nameSprite = new FlxSprite(0, 600);
        add(nameSprite);

        // 4. 왼쪽 화살표 (스패로우 시트)
        leftArrow = new FlxSprite(100, 0);
        leftArrow.frames = Paths.getSparrowAtlas('charSelect/arrowLeft');
        leftArrow.animation.addByPrefix('idle', 'idle', 24, true);
        leftArrow.animation.addByPrefix('select', 'select', 24, false);
        leftArrow.animation.play('idle');
        leftArrow.screenCenter(Y);
        add(leftArrow);

        // 5. 오른쪽 화살표 (스패로우 시트)
        rightArrow = new FlxSprite(FlxG.width - 200, 0);
        rightArrow.frames = Paths.getSparrowAtlas('charSelect/arrowRight');
        rightArrow.animation.addByPrefix('idle', 'idle', 24, true);
        rightArrow.animation.addByPrefix('select', 'select', 24, false);
        rightArrow.animation.play('idle');
        rightArrow.screenCenter(Y);
        add(rightArrow);

        loadCharacterJson();
        changeSelection(0);

        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if (isTransitioning) return;

        // select 애니메이션 재생 종료 후 idle로 복귀
        if (leftArrow.animation.curAnim != null && leftArrow.animation.curAnim.name == 'select' && leftArrow.animation.curAnim.finished) {
            leftArrow.animation.play('idle');
        }
        if (rightArrow.animation.curAnim != null && rightArrow.animation.curAnim.name == 'select' && rightArrow.animation.curAnim.finished) {
            rightArrow.animation.play('idle');
        }

        if (FlxG.keys.justPressed.LEFT) changeSelection(-1);
        if (FlxG.keys.justPressed.RIGHT) changeSelection(1);
        if (controls.ACCEPT) selectCharacter();
        if (controls.BACK) MusicBeatState.switchState(new MainMenuState());
    }

    function loadCharacterJson()
    {
        var path:String = Paths.modsJson('characterSelect');
    
        if (sys.FileSystem.exists(path)) {
            var rawJson:String = sys.io.File.getContent(path).trim();
        
            if (rawJson.startsWith('{') && rawJson.endsWith('}')) {
                var parsed:Dynamic = Json.parse(rawJson);
                for (field in Reflect.fields(parsed)) {
                    var dataArray:Array<Dynamic> = Reflect.field(parsed, field);
                    var stringArray:Array<String> = [];
                    for (item in dataArray) {
                        stringArray.push(Std.string(item));
                    }
                
                    charData.set(field, stringArray);
                    charList.push(field);
                }
            } else {
                trace("JSON 형식이 올바르지 않습니다. 중괄호 세팅을 확인하세요.");
            }
        } else {
            trace("JSON 파일을 찾을 수 없습니다: " + path);
        }
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += (change % charList.length + charList.length) % charList.length;
        curSelected %= charList.length;

        FlxG.sound.play(Paths.sound('scrollMenu'));

        // 선택 방향에 따라 화살표 애니메이션 재생
        if (change < 0) {
            leftArrow.animation.play('select', true);
        } else if (change > 0) {
            rightArrow.animation.play('select', true);
        }

        var name:String = charList[curSelected];
        var data:Array<String> = charData.get(name);

        bg.loadGraphic(Paths.image(data[1])); 

        charSprite.loadGraphic(Paths.image('charSelect/' + name));
        charSprite.screenCenter();

        nameSprite.loadGraphic(Paths.image('charNames/' + name));
        nameSprite.screenCenter(X);
    }

    function selectCharacter()
    {
        isTransitioning = true;
        var name:String = charList[curSelected];
    
        var data:Array<String> = charData.get(name);
        if (data != null && data.length > 0) {
            FlxG.save.data.selectedSongGroup = data[0];
            FlxG.save.flush();
        }
    
        FlxG.sound.play(Paths.sound('charSelect/' + name));
        charSprite.loadGraphic(Paths.image('charSelect/' + name + 'go'));
        charSprite.screenCenter();

        backend.WeekData.weeksList = [];
        backend.WeekData.weeksLoaded.clear();

        new FlxTimer().start(1.5, function(tmr:FlxTimer) {
            MusicBeatState.switchState(new FreeplayState());
        });
    }
}
