package states;
 
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.utils.Assets;

class CharacterSelectState extends MusicBeatState
{

    public static var selectedSongGroup:String = "bf_songs";
    // 위의 항목은 캐릭터선택임
    var charData:Map<String, Array<String>> = new Map<String, Array<String>>();
    var charList:Array<String> = [];
    var curSelected:Int = 0;
    var isTransitioning:Bool = false;

    // 화면 요소
    var bg:FlxSprite;
    var charSprite:FlxSprite;
    var nameSprite:FlxSprite; // 텍스트 대신 사용할 이름 이미지

    override function create()
    {
        // 1. 배경 (초기화)
        bg = new FlxSprite().loadGraphic(Paths.image('charSelectBG'));
        add(bg);

        // 2. 캐릭터 스프라이트
        charSprite = new FlxSprite();
        add(charSprite);

        // 3. 이름 이미지 스프라이트 (하단 배치용)
        nameSprite = new FlxSprite(0, 600);
        add(nameSprite);

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
        // 파일을 읽어온 뒤, 혹시 모를 공백이나 유령 문자를 trim()으로 완전히 잘라냅니다.
            var rawJson:String = sys.io.File.getContent(path).trim();
        
        // 가져온 텍스트가 제대로 열리고 닫혔는지 검사합니다.
            if (rawJson.startsWith('{') && rawJson.endsWith('}')) {
                var parsed:Dynamic = Json.parse(rawJson);
                for (field in Reflect.fields(parsed)) {
                // 내부 배열 데이터를 안전하게 String 배열로 캐스팅하여 맵에 넣습니다.
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

        // 이미지 적용
        bg.loadGraphic(Paths.image(data[1])); 
        charSprite.loadGraphic(Paths.image('charSelect/' + name));
        charSprite.screenCenter();

        // 이름 이미지 적용 (shared/images/charNames/ 폴더 활용)
        nameSprite.loadGraphic(Paths.image('charNames/' + name));
        nameSprite.screenCenter(X);
    }

    function selectCharacter()
    {
        isTransitioning = true;
        var name:String = charList[curSelected];
    
        var data:Array<String> = charData.get(name);
        if (data != null && data.length > 0) {
        // 선택한 캐릭터의 주차 그룹명을 세이브 데이터에 직접 쓰고 물리 저장
            FlxG.save.data.selectedSongGroup = data[0]; 
            FlxG.save.data.flush();
        }
    
        FlxG.sound.play(Paths.sound('charSelect/' + name));
        charSprite.loadGraphic(Paths.image('charSelect/' + name + 'go'));
        charSprite.screenCenter();

        new FlxTimer().start(1.5, function(tmr:FlxTimer) {
            MusicBeatState.switchState(new FreeplayState());
        });
    }
}
