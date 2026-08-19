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

        // 2. 캐릭터 스프라이트 (스패로우 시트용)
        charSprite = new FlxSprite();
        add(charSprite);

        // 3. 이름 이미지 스프라이트
        nameSprite = new FlxSprite(0, 600);
        add(nameSprite);

        // 4. 왼쪽/오른쪽 화살표
        leftArrow = new FlxSprite(100, 0).loadGraphic(Paths.image('charSelect/arrowLeft'));
        leftArrow.screenCenter(Y);
        add(leftArrow);

        rightArrow = new FlxSprite(FlxG.width - 200, 0).loadGraphic(Paths.image('charSelect/arrowRight'));
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

        var name:String = charList[curSelected];
        var data:Array<String> = charData.get(name); // [노래폴더, 배경이미지]

        // 배경 적용
        bg.loadGraphic(Paths.image(data[1])); 

        // 캐릭터 스패로우 시트 로드 및 idle 애니메이션 재생
        charSprite.frames = Paths.getSparrowAtlas('charSelect/' + name);
        charSprite.animation.addByPrefix('idle', 'idle', 24, true);
        charSprite.animation.addByPrefix('select', 'select', 24, false);
        charSprite.animation.play('idle');
        charSprite.screenCenter();

        // 이름 이미지 적용
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

        // 선택 애니메이션 재생
        if (charSprite.animation.getByName('select') != null) {
            charSprite.animation.play('select');
        }
        charSprite.screenCenter();

        backend.WeekData.weeksList = [];
        backend.WeekData.weeksLoaded.clear();

        new FlxTimer().start(1.5, function(tmr:FlxTimer) {
            MusicBeatState.switchState(new FreeplayState());
        });
    }
}
