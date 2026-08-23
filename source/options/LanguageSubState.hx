package options;

import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class LanguageSubState extends MusicBeatSubstate
{
	#if TRANSLATIONS_ALLOWED
	var grpLanguages:FlxSpriteGroup = new FlxSpriteGroup();
	var languages:Array<String> = [];
	var displayLanguages:Map<String, String> = [];
	var curSelected:Int = 0;
	
	public function new()
	{
		super();
		
		var targetCam = OptionsSubState.instance != null ? OptionsSubState.instance.optionCam : null;
		if(targetCam != null) grpLanguages.cameras = [targetCam];
		
		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
		add(grpLanguages);

		languages.push(ClientPrefs.defaultData.language); //English (US)
		displayLanguages.set(ClientPrefs.defaultData.language, Language.defaultLangName);
		var directories:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'data/');
		for (directory in directories)
		{
			for (file in FileSystem.readDirectory(directory))
			{
				if(file.toLowerCase().endsWith('.lang'))
				{
					var langFile:String = file.substring(0, file.length - '.lang'.length).trim();
					if(!languages.contains(langFile))
						languages.push(langFile);

					if(!displayLanguages.exists(langFile))
						displayLanguages.set(langFile, langFile);
				}
			}
		}

		languages.sort(function(a:String, b:String)
		{
			a = (displayLanguages.exists(a) ? displayLanguages.get(a) : a).toLowerCase();
			b = (displayLanguages.exists(b) ? displayLanguages.get(b) : b).toLowerCase();
			if (a < b) return -1;
			else if (a > b) return 1;
			return 0;
		});

		curSelected = languages.indexOf(ClientPrefs.data.language);
		if(curSelected < 0)
		{
			ClientPrefs.data.language = ClientPrefs.defaultData.language;
			curSelected = Std.int(Math.max(0, languages.indexOf(ClientPrefs.data.language)));
		}

		for (num => lang in languages)
		{
			var name:String = displayLanguages.get(lang);
			if(name == null) name = lang;

			var text:FlxSprite = new FlxSprite().loadGraphic(Paths.image(name));
			text.scale.set(0.55, 0.55); // 글자 크기 축소
			grpLanguages.add(text);
		}
		changeSelected();
	}

	var changedLanguage:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var lerpVal:Float = flixel.math.FlxMath.bound(elapsed * 9.6, 0, 1);
		for (num => item in grpLanguages.members)
		{
			if (item == null) continue;
			item.scale.set(0.55, 0.55);
			item.x = 150; // 좌측 시작점 고정
			
			// 개별 스프라이트에 변수를 저장하지 않고, 현재 순번(num)과 선택된 값의 차이로 targetY를 계산합니다.
			var itemTargetY:Float = num - curSelected;
			var targetYPos:Float = 140 + (itemTargetY * 70); // 작은 창 규격에 맞춘 간격
			item.y = flixel.math.FlxMath.lerp(item.y, targetYPos, lerpVal);
		}
		
		var mult:Int = (FlxG.keys.pressed.SHIFT) ? 4 : 1;
		if(controls.UI_UP_P)
			changeSelected(-1 * mult);
		if(controls.UI_DOWN_P)
			changeSelected(1 * mult);
		if(FlxG.mouse.wheel != 0)
			changeSelected(FlxG.mouse.wheel * mult);

		if(controls.BACK)
		{
			if(changedLanguage)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.resetState();
			}
			else close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if(controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
			ClientPrefs.data.language = languages[curSelected];
			ClientPrefs.saveSettings();
			Language.reloadPhrases();
			changedLanguage = true;
		}
	}

	function changeSelected(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, languages.length-1);
		for (num => lang in grpLanguages.members)
		{
			if (lang == null) continue;
			lang.alpha = 0.6;
			if(num == curSelected) lang.alpha = 1;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
	}
	#end
}
