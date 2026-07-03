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
    

    function selectCharacter()
    {
        isTransitioning = true;
        var name:String = charList[curSelected];
        
        // 엔터 친 캐릭터의 데이터 배열 [곡 그룹, 배경] 가져오기
        var data:Array<String> = charData.get(name);
        if (data != null && data.length > 0) {
            selectedSongGroup = data[0]; // "bf_songs" 등의 그룹명이 전역 변수에 저장됨
        }
        
        FlxG.sound.play(Paths.sound('charSelect/' + name));
        charSprite.loadGraphic(Paths.image('charSelect/' + name + 'go'));
        charSprite.screenCenter();

        new FlxTimer().start(1.5, function(tmr:FlxTimer) {
            MusicBeatState.switchState(new FreeplayState());
        });
    }

    function selectCharacter()
    {
        isTransitioning = true;
        var name:String = charList[curSelected];
        
        FlxG.sound.play(Paths.sound('charSelect/' + name));
        charSprite.loadGraphic(Paths.image('charSelect/' + name + 'go'));
        charSprite.screenCenter();

        new FlxTimer().start(1.5, function(tmr:FlxTimer) {
            MusicBeatState.switchState(new FreeplayState());
        });
    }
}
