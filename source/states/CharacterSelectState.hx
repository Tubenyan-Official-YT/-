package states;
 
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.utils.Assets;

class CharacterSelectState extends MusicBeatState
{
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
        var rawJson:String = Assets.getText(Paths.json('characterSelect'));
        var parsed:Dynamic = Json.parse(rawJson);
        for (field in Reflect.fields(parsed)) {
            charData.set(field, Reflect.field(parsed, field));
            charList.push(field);
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
        
        FlxG.sound.play(Paths.sound('charSelect/' + name));
        charSprite.loadGraphic(Paths.image('charSelect/' + name + 'go'));
        charSprite.screenCenter();

        new FlxTimer().start(1.5, function(tmr:FlxTimer) {
            MusicBeatState.switchState(new FreeplayState());
        });
    }
}
