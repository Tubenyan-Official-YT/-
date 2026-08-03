package states;

import objects.AttachedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import StringTools;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<FlxText>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	// 좌우 분할 레이아웃을 위한 UI 변수
	var creditsCam:FlxCamera;          // 우측 리스트 전용 뷰포트 카메라 (자동 클리핑)
	var leftIcon:FlxSprite;            // 좌측 상단 이미지 표시 영역
	var categoryText:FlxText;          // 좌측 중간 상위 카테고리 텍스트
	var itemPositions:Array<Float> = []; // 각 항목의 절대 고정 Y 좌표 배열

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:FlxColor;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;
	var moveTween:FlxTween = null;
	var colorTween:FlxTween = null;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("크레딧 보는 중", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('Credits'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		// 1. 우측 크레딧 리스트 영역 전용 카메라 (지정 영역 외 자동 클리핑)
		creditsCam = new FlxCamera(600, 50, 630, 620);
		creditsCam.bgColor = 0xFF242424; // 도면의 회색 배경 박스 역할
		FlxG.cameras.add(creditsCam, false); // false 설정으로 기본 UI 오버랩 차단

		grpOptions = new FlxTypedGroup<FlxText>();
		grpOptions.cameras = [creditsCam];
		add(grpOptions);

		// 2. 좌측 고정 UI 요소 생성 (기본 메인 카메라 사용)
		leftIcon = new FlxSprite(100, 60);
		add(leftIcon);

		categoryText = new FlxText(50, 380, 500, "", 40);
		categoryText.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER);
		add(categoryText);

		#if MODS_ALLOWED
		for (mod in Mods.parseList().enabled) pushModCreditsToList(mod);
		#end

		var defaultList:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			["Psych Engine Team"],
			["Shadow Mario",		"shadowmario",		"Main Programmer and Head of Psych Engine",					"https://ko-fi.com/shadowmario",	"444444"],
			["Riveren",				"riveren",			"Main Artist/Animator of Psych Engine",						"https://x.com/riverennn",			"14967B"],
			[""],
			["Former Engine Members"],
			["bb-panzu",			"bb",				"Ex-Programmer of Psych Engine",							"https://x.com/bbsub3",				"3E813A"],
			[""],
			["Engine Contributors"],
			["crowplexus",			"crowplexus",	"Linux Support, HScript Iris, Input System v3, and Other PRs",	"https://twitter.com/IamMorwen",	"CFCFCF"],
			["Kamizeta",			"kamizeta",			"Creator of Pessy, Psych Engine's mascot.",				"https://www.instagram.com/cewweey/",	"D21C11"],
			["MaxNeton",			"maxneton",			"Loading Screen Easter Egg Artist/Animator.",	"https://bsky.app/profile/maxneton.bsky.social","3C2E4E"],
			["Keoiki",				"keoiki",			"Note Splash Animations and Latin Alphabet",				"https://x.com/Keoiki_",			"D2D2D2"],
			["SqirraRNG",			"sqirra",			"Crash Handler and Base code for\nChart Editor's Waveform",	"https://x.com/gedehari",			"E1843A"],
			["EliteMasterEric",		"mastereric",		"Runtime Shaders support and Other PRs",					"https://x.com/EliteMasterEric",	"FFBD40"],
			["MAJigsaw77",			"majigsaw",			".MP4 Video Loader Library (hxvlc)",						"https://x.com/MAJigsaw77",			"5F5F5F"],
			["iFlicky",				"flicky",			"Composer of Psync and Tea Time\nAnd some sound effects",	"https://x.com/flicky_i",			"9E29CF"],
			["KadeDev",				"kade",				"Fixed some issues on Chart Editor and Other PRs",			"https://x.com/kade0912",			"64A250"],
			["superpowers04",		"superpowers04",	"LUA JIT Fork",												"https://x.com/superpowers04",		"B957ED"],
			["CheemsAndFriends",	"cheems",			"Creator of FlxAnimate",									"https://x.com/CheemsnFriendos",	"E1E1E1"],
			[""],
			["Funkin' Crew"],
			["ninjamuffin99",		"ninjamuffin99",	"Programmer of Friday Night Funkin'",						"https://x.com/ninja_muffin99",		"CF2D2D"],
			["PhantomArcade",		"phantomarcade",	"Animator of Friday Night Funkin'",							"https://x.com/PhantomArcade3K",	"FADC45"],
			["evilsk8r",			"evilsk8r",			"Artist of Friday Night Funkin'",							"https://x.com/evilsk8r",			"5ABD4B"],
			["kawaisprite",			"kawaisprite",		"Composer of Friday Night Funkin'",							"https://x.com/kawaisprite",		"378FC7"],
			[""],
			
			["Psych Engine Discord"],
			["Join the Psych Ward!", "discord", "", "https://discord.gg/2ka77eMXDv", "5165F6"],
			[""],
			["SD Card Team"],
			["Tubenyan",            "tubenyan",         "Make Menu to Korean and did All this mod tasks",           "https://youtube.com/@tubenyan",     "41c0ff"],
			["NyangBab",            "nb",               'Test',                                                                                    "https://discord.gg/uwbTRBDJsb",     'FFFFFF'],
			["RTX 6090",            "6090",             'Nothing. He do not play FNF.',                                                            "https://discord.gg/zdfQhkVYTD",     '89C5CB'],
			["2dles",               "2dles",            'Nothing. He do not play FNF, too.',            "https://discord.com/channels/@me/1449048458060234874",     'FF740A'],
			["Gemini",              "gemini",           'Made haxe Source for Tubenyan',                            "https://gemini.google.com/app",     '4285F4'],
			["Claude",              "claude",           'Same with Gemini',                                         "https://claude.ai",     '4285F4'],
			[''],
			["Our DISCORD"],
			["Join SD Card Community!!", "discord", "", "https://discord.gg/4K49EHG8P3", "5165F6"],
			[""],
		];
		
		for(i in defaultList)
			creditsStuff.push(i);
	
		var currentY:Float = 20; 
		for (i => credit in creditsStuff)
		{
			itemPositions.push(currentY);

			if (credit[0] == "") {
				currentY += 40;
				continue;
			}

			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:FlxText = new FlxText(30, currentY, 450, credit[0], 32);
			optionText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
			optionText.cameras = [creditsCam];
		
			if(!isSelectable) {
				optionText.color = FlxColor.YELLOW;
			}
			grpOptions.add(optionText);

			if(isSelectable)
			{
				if(credit[5] != null) Mods.currentModDirectory = credit[5];

				var str:String = 'credits/missing_icon';
				if(credit[1] != null && credit[1].length > 0) str = 'credits/' + credit[1];

				var icon:AttachedSprite = new AttachedSprite(str);
				if(str.endsWith('-pixel')) icon.antialiasing = false;
				icon.xAdd = 20;
				icon.yAdd = -5;
				icon.sprTracker = optionText;
				icon.cameras = [creditsCam];
				iconArray.push(icon);
				add(icon);
			
				Mods.currentModDirectory = '';
				if(curSelected == -1) curSelected = i;
				currentY += 90;
			}
			else {
				currentY += 60;
			}
		}
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		descText.scrollFactor.set();
		descBox.sprTracker = descText;
		add(descText);
		
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		if (!quitting)
		{
			if (creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if (controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) 
			{
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}

		var lerpVal:Float = FlxMath.bound(elapsed * 12, 0, 1);

		// 우측 카메라 스크롤 처리
		if (itemPositions.length > 0 && curSelected >= 0) 
		{
			var targetScrollY:Float = itemPositions[curSelected] - (creditsCam.height * 0.5) + 30;
			if (targetScrollY < 0) targetScrollY = 0;
			
			creditsCam.scroll.y = FlxMath.lerp(creditsCam.scroll.y, targetScrollY, lerpVal);
		}

		// 우측 리스트 아이템 하이라이트 애니메이션
		for (num => item in grpOptions.members)
		{
			if (num == curSelected) 
			{
				item.alpha = FlxMath.lerp(item.alpha, 1.0, lerpVal);
				item.scale.set(FlxMath.lerp(item.scale.x, 1.05, lerpVal), FlxMath.lerp(item.scale.y, 1.05, lerpVal));
			} 
			else 
			{
				item.alpha = FlxMath.lerp(item.alpha, 0.4, lerpVal);
				item.scale.set(FlxMath.lerp(item.scale.x, 0.95, lerpVal), FlxMath.lerp(item.scale.y, 0.95, lerpVal));
			}
		}

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected = FlxMath.wrap(curSelected + change, 0, creditsStuff.length - 1);
		} while(unselectableCheck(curSelected));

		// 1. 역추적 연산으로 현재 항목의 최상위 카테고리 실시간 감지
		var detectedCategory:String = "";
		var checkIdx:Int = curSelected;
		while (checkIdx >= 0) 
		{
			if (unselectableCheck(checkIdx) && creditsStuff[checkIdx][0] != null && StringTools.trim(creditsStuff[checkIdx][0]).length > 0) 
			{
				detectedCategory = creditsStuff[checkIdx][0];
				break;
			}
			checkIdx--;
		}
		categoryText.text = detectedCategory;

		// 2. 좌측 상단 프로필 이미지 로드 및 중앙 보정 정렬
		var imgStr:String = 'credits/missing_icon';
		if(creditsStuff[curSelected][1] != null && creditsStuff[curSelected][1].length > 0) 
		{
			imgStr = 'credits/' + creditsStuff[curSelected][1]; 
		}
		leftIcon.loadGraphic(Paths.image(imgStr));
		leftIcon.setGraphicSize(250, 250);
		leftIcon.updateHitbox();
		leftIcon.x = 50 + (500 - leftIcon.width) / 2;

		// 3. 백그라운드 컬러 트윈 보간
		var newColor:FlxColor = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		if(newColor != intendedColor) 
		{
			if(colorTween != null) colorTween.cancel();
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {ease: FlxEase.quadOut});
		}

		// 4. 하단 설명 텍스트 창 업데이트
		descText.text = creditsStuff[curSelected][2];
		if(descText.text != null && StringTools.trim(descText.text).length > 0)
		{
			descText.visible = descBox.visible = true;
			descText.y = FlxG.height - descText.height + offsetThing - 60;
	
			if(moveTween != null) moveTween.cancel();
			moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});
	
			descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
			descBox.updateHitbox();
		}
		else descText.visible = descBox.visible = false;
	}

	#if MODS_ALLOWED
	function pushModCreditsToList(folder:String)
	{
		var creditsFile:String = Paths.mods(folder + '/data/credits.txt');
		
		#if TRANSLATIONS_ALLOWED
		var translatedCredits:String = Paths.mods(folder + '/data/credits-${ClientPrefs.data.language}.txt');
		#end

		if (#if TRANSLATIONS_ALLOWED (FileSystem.exists(translatedCredits) && (creditsFile = translatedCredits) == translatedCredits) || #end FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
	}
	#end

	private function unselectableCheck(num:Int):Bool 
	{
		return creditsStuff[num].length <= 1;
	}
}
