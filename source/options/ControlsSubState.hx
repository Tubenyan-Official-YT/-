package options;

import backend.InputFormatter;
import backend.MusicBeatSubstate;
import objects.AttachedSprite;
import objects.Alphabet;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

class ControlsSubState extends MusicBeatSubstate
{
	var curSelected:Int = 0;
	var curAlt:Bool = false;

	var options:Array<Dynamic> = [
		[true, 'NOTES'],
		[true, 'Left', 'note_left', 'Note Left'],
		[true, 'Down', 'note_down', 'Note Down'],
		[true, 'Up', 'note_up', 'Note Up'],
		[true, 'Right', 'note_right', 'Note Right'],
		[true],
		[true, 'UI'],
		[true, 'Left', 'ui_left', 'UI Left'],
		[true, 'Down', 'ui_down', 'UI Down'],
		[true, 'Up', 'ui_up', 'UI Up'],
		[true, 'Right', 'ui_right', 'UI Right'],
		[true],
		[true, 'Reset', 'reset', 'Reset'],
		[true, 'Accept', 'accept', 'Accept'],
		[true, 'Back', 'back', 'Back'],
		[true, 'Pause', 'pause', 'Pause'],
		[false],
		[false, 'VOLUME'],
		[false, 'Mute', 'volume_mute', 'Volume Mute'],
		[false, 'Up', 'volume_up', 'Volume Up'],
		[false, 'Down', 'volume_down', 'Volume Down'],
		[false],
		[false, 'DEBUG'],
		[false, 'Key 1', 'debug_1', 'Debug Key #1'],
		[false, 'Key 2', 'debug_2', 'Debug Key #2']
	];
	var curOptions:Array<Int>;
	var curOptionsValid:Array<Int>;
	static var defaultKey:String = 'Reset to Default Keys';

	var grpDisplay:FlxTypedGroup<FlxText>;
	var grpBlacks:FlxTypedGroup<AttachedSprite>;
	var grpOptions:FlxTypedGroup<FlxText>;
	var grpBinds:FlxTypedGroup<FlxText>;
	var selectSpr:AttachedSprite;

	var gamepadColor:FlxColor = 0xfffd7194;
	var keyboardColor:FlxColor = 0xff7192fd;
	var onKeyboardMode:Bool = true;
	
	var controllerSpr:FlxSprite;
	
	public function new()
	{
		super();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Controls Menu", null);
		#end

		options.push([true]);
		options.push([true]);
		options.push([true, defaultKey]);

		var optionWindow = OptionsSubState.optionWindow;

		grpDisplay = new FlxTypedGroup<FlxText>();
		add(grpDisplay);
		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);
		grpBlacks = new FlxTypedGroup<AttachedSprite>();
		add(grpBlacks);
		
		selectSpr = new AttachedSprite();
		selectSpr.makeGraphic(220, 70, FlxColor.WHITE);
		selectSpr.copyAlpha = false;
		selectSpr.alpha = 0.4;
		if(optionWindow != null) {
			selectSpr.cameras = optionWindow.cameras;
			selectSpr.scrollFactor.set(optionWindow.scrollFactor.x, optionWindow.scrollFactor.y);
		}
		add(selectSpr);
		
		grpBinds = new FlxTypedGroup<FlxText>();
		add(grpBinds);

		controllerSpr = new FlxSprite(50, 40).loadGraphic(Paths.image('controllertype'), true, 82, 60);
		controllerSpr.antialiasing = ClientPrefs.data.antialiasing;
		controllerSpr.animation.add('keyboard', [0], 1, false);
		controllerSpr.animation.add('gamepad', [1], 1, false);
		if(optionWindow != null) {
			controllerSpr.cameras = optionWindow.cameras;
			controllerSpr.scrollFactor.set(optionWindow.scrollFactor.x, optionWindow.scrollFactor.y);
		}

		var text:FlxText = new FlxText(90, 90, 0, 'CTRL');
		text.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.borderSize = 2.5;
		text.scale.set(0.5, 0.5);
		text.updateHitbox();
		if(optionWindow != null) {
			text.cameras = optionWindow.cameras;
			text.scrollFactor.set(optionWindow.scrollFactor.x, optionWindow.scrollFactor.y);
		}

		createTexts();
	}

	var lastID:Int = 0;
	function createTexts()
	{
		curOptions = [];
		curOptionsValid = [];
		grpDisplay.forEachAlive(function(text:FlxText) text.destroy());
		grpBlacks.forEachAlive(function(black:AttachedSprite) black.destroy());
		grpOptions.forEachAlive(function(text:FlxText) text.destroy());
		grpBinds.forEachAlive(function(text:FlxText) text.destroy());
		grpDisplay.clear();
		grpBlacks.clear();
		grpOptions.clear();
		grpBinds.clear();

		var optionWindow = OptionsSubState.optionWindow;
		var myID:Int = 0;
		
		for (i => option in options)
		{
			if(onKeyboardMode || option[0])
			{
				if(option.length > 1)
				{
					var isCentered:Bool = (option.length < 3);
					var isDefaultKey:Bool = (option[1] == defaultKey);
					var isDisplayKey:Bool = (isCentered && !isDefaultKey);

					var str:String = option[1];
					var keyStr:String = option[2];
					if(isDefaultKey) str = Language.getPhrase(str);
					
					var textStr:String = !isDisplayKey ? Language.getPhrase('key_$keyStr', str) : Language.getPhrase('keygroup_$str', str);
					
					// 기본 폰트 크기를 42로 확장하여 가시성을 확보
					var text:FlxText = new FlxText(0, 0, 0, textStr);
					text.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					text.borderSize = 2.5;
					text.scale.set(0.75, 0.75);
					text.updateHitbox();
					text.ID = myID;
					lastID = myID;

					if(optionWindow != null) {
						text.cameras = optionWindow.cameras;
						text.scrollFactor.set(optionWindow.scrollFactor.x, optionWindow.scrollFactor.y);
					}

					if(!isDisplayKey)
					{
						grpOptions.add(text);
						curOptions.push(i);
						curOptionsValid.push(myID);
					}
					else grpDisplay.add(text);

					if(!isCentered) addKeyText(text, option, myID);
				}
				myID++;
			}
		}
		updateText();
	}

	function addKeyText(text:FlxText, option:Array<Dynamic>, id:Int)
	{
		var optionWindow = OptionsSubState.optionWindow;
		var keys:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get(option[2]);
		if(keys == null && onKeyboardMode)
			keys = ClientPrefs.defaultKeys.get(option[2]).copy();

		var gmpds:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(option[2]);
		if(gmpds == null && !onKeyboardMode)
			gmpds = ClientPrefs.defaultButtons.get(option[2]).copy();

		for (n in 0...2)
		{
			var key:String = null;
			if(onKeyboardMode)
				key = InputFormatter.getKeyName((keys[n] != null) ? keys[n] : NONE);
			else
				key = InputFormatter.getGamepadName((gmpds[n] != null) ? gmpds[n] : NONE);

			// 바인딩 폰트 크기를 34로 상향 조정
			var attach:FlxText = new FlxText(0, 0, 0, key);
			attach.setFormat(Paths.font("vcr.ttf"), 34, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			attach.borderSize = 2;
			attach.scale.set(0.65, 0.65);
			attach.updateHitbox();
			attach.ID = text.ID;
			
			if(optionWindow != null) {
				attach.cameras = optionWindow.cameras;
				attach.scrollFactor.set(optionWindow.scrollFactor.x, optionWindow.scrollFactor.y);
			}
			grpBinds.add(attach);

			var black:AttachedSprite = new AttachedSprite();
			black.makeGraphic(220, 70, FlxColor.BLACK);
			black.alphaMult = 0.4;
			black.sprTracker = null; 
			if(optionWindow != null) {
				black.cameras = optionWindow.cameras;
				black.scrollFactor.set(optionWindow.scrollFactor.x, optionWindow.scrollFactor.y);
			}
			grpBlacks.add(black);
		}
	}

	function updateBind(num:Int, text:String)
	{
		var optionWindow = OptionsSubState.optionWindow;
		var bind:FlxText = grpBinds.members[num];
		var parentID = bind.ID;
		
		var attach:FlxText = new FlxText(0, 0, 0, text);
		attach.setFormat(Paths.font("vcr.ttf"), 34, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		attach.borderSize = 2;
		attach.scale.set(0.65, 0.65);
		attach.updateHitbox();
		attach.ID = parentID;
		
		if(optionWindow != null) {
			attach.cameras = optionWindow.cameras;
			attach.scrollFactor.set(optionWindow.scrollFactor.x, optionWindow.scrollFactor.y);
		}

		bind.kill();
		grpBinds.remove(bind);
		grpBinds.insert(num, attach);
		bind.destroy();
	}

	var binding:Bool = false;
	var holdingEsc:Float = 0;
	var timeForMoving:Float = 0.1;

	override function update(elapsed:Float)
	{
		if(timeForMoving > 0)
		{
			timeForMoving = Math.max(0, timeForMoving - elapsed);
			super.update(elapsed);
			return;
		}

		var optionWindow = OptionsSubState.optionWindow;
		var boxX:Float = (optionWindow != null) ? optionWindow.x : 50;
		var boxY:Float = (optionWindow != null) ? optionWindow.y : 140;
		var boxWidth:Float = (optionWindow != null) ? optionWindow.width : 680;
		var boxHeight:Float = (optionWindow != null) ? optionWindow.height : 540;
		var centerY:Float = boxY + (boxHeight / 2);

		if(!binding)
		{
			if(FlxG.keys.justPressed.ESCAPE || FlxG.gamepads.anyJustPressed(B))
			{
				close();
				return;
			}
			if(FlxG.keys.justPressed.CONTROL || FlxG.gamepads.anyJustPressed(LEFT_SHOULDER) || FlxG.gamepads.anyJustPressed(RIGHT_SHOULDER)) swapMode();

			if(FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT || FlxG.gamepads.anyJustPressed(DPAD_LEFT) || FlxG.gamepads.anyJustPressed(DPAD_RIGHT) ||
				FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_LEFT) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_RIGHT)) updateAlt(true);

			if(FlxG.keys.justPressed.UP || FlxG.gamepads.anyJustPressed(DPAD_UP) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_UP)) updateText(-1);
			else if(FlxG.keys.justPressed.DOWN || FlxG.gamepads.anyJustPressed(DPAD_DOWN) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_DOWN)) updateText(1);

			if(FlxG.keys.justPressed.ENTER || FlxG.gamepads.anyJustPressed(START) || FlxG.gamepads.anyJustPressed(A))
			{
				if(options[curOptions[curSelected]][1] != defaultKey)
				{
					binding = true;
					holdingEsc = 0;
					ClientPrefs.toggleVolumeKeys(false);
					FlxG.sound.play(Paths.sound('scrollMenu'));

					var altNum:Int = curAlt ? 1 : 0;
					var bindIndex:Int = -1;
					var findCount:Int = 0;
					for (i in 0...grpBinds.members.length) {
						var b = grpBinds.members[i];
						if (b != null && b.ID == curOptionsValid[curSelected]) {
							if (findCount == altNum) { bindIndex = i; break; }
							findCount++;
						}
					}
					if (bindIndex != -1 && grpBinds.members[bindIndex] != null) grpBinds.members[bindIndex].visible = false;
				}
				else
				{
					ClientPrefs.resetKeys(!onKeyboardMode);
					ClientPrefs.reloadVolumeKeys();
					var lastSel:Int = curSelected;
					createTexts();
					curSelected = lastSel;
					updateText();
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
			}
		}
		else
		{
			var altNum:Int = curAlt ? 1 : 0;
			var curOption:Array<Dynamic> = options[curOptions[curSelected]];
			
			var bindIndex:Int = -1;
			var findCount:Int = 0;
			for (i in 0...grpBinds.members.length) {
				var b = grpBinds.members[i];
				if (b != null && b.ID == curOptionsValid[curSelected]) {
					if (findCount == altNum) { bindIndex = i; break; }
					findCount++;
				}
			}
			
			if(FlxG.keys.pressed.ESCAPE || FlxG.gamepads.anyPressed(B))
			{
				holdingEsc += elapsed;
				if(holdingEsc > 0.5)
				{
					if (bindIndex != -1 && grpBinds.members[bindIndex] != null) grpBinds.members[bindIndex].visible = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					binding = false;
					ClientPrefs.reloadVolumeKeys();
				}
			}
			else if (FlxG.keys.pressed.BACKSPACE || FlxG.gamepads.anyPressed(BACK))
			{
				holdingEsc += elapsed;
				if(holdingEsc > 0.5)
				{
					if (onKeyboardMode)
						ClientPrefs.keyBinds.get(curOption[2])[altNum] = NONE;
					else
						ClientPrefs.gamepadBinds.get(curOption[2])[altNum] = NONE;
					ClientPrefs.clearInvalidKeys(curOption[2]);
					updateBind(bindIndex, onKeyboardMode ? InputFormatter.getKeyName(NONE) : InputFormatter.getGamepadName(NONE));
					if (bindIndex != -1 && grpBinds.members[bindIndex] != null) grpBinds.members[bindIndex].visible = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					binding = false;
					ClientPrefs.reloadVolumeKeys();
				}
			}
			else
			{
				holdingEsc = 0;
				var changed:Bool = false;
				var curKeys:Array<FlxKey> = ClientPrefs.keyBinds.get(curOption[2]);
				var curButtons:Array<FlxGamepadInputID> = ClientPrefs.gamepadBinds.get(curOption[2]);

				if(onKeyboardMode)
				{
					if(FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY)
					{
						var keyPressed:Int = FlxG.keys.firstJustPressed();
						var keyReleased:Int = FlxG.keys.firstJustReleased();
						if (keyPressed > -1 && keyPressed != FlxKey.ESCAPE && keyPressed != FlxKey.BACKSPACE)
						{
							curKeys[altNum] = keyPressed;
							changed = true;
						}
						else if (keyReleased > -1 && (keyReleased == FlxKey.ESCAPE || keyReleased == FlxKey.BACKSPACE))
						{
							curKeys[altNum] = keyReleased;
							changed = true;
						}
					}
				}
				else if(FlxG.gamepads.anyJustPressed(ANY) || FlxG.gamepads.anyJustPressed(LEFT_TRIGGER) || FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER) || FlxG.gamepads.anyJustReleased(ANY))
				{
					var keyPressed:Null<FlxGamepadInputID> = NONE;
					var keyReleased:Null<FlxGamepadInputID> = NONE;
					if(FlxG.gamepads.anyJustPressed(LEFT_TRIGGER)) keyPressed = LEFT_TRIGGER;
					else if(FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER)) keyPressed = RIGHT_TRIGGER;
					else
					{
						for (i in 0...FlxG.gamepads.numActiveGamepads)
						{
							var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
							if(gamepad != null)
							{
								keyPressed = gamepad.firstJustPressedID();
								keyReleased = gamepad.firstJustReleasedID();

								if(keyPressed == null) keyPressed = NONE;
								if(keyReleased == null) keyReleased = NONE;
								if(keyPressed != NONE || keyReleased != NONE) break;
							}
						}
					}

					if (keyPressed != NONE && keyPressed != FlxGamepadInputID.BACK && keyPressed != FlxGamepadInputID.B)
					{
						curButtons[altNum] = keyPressed;
						changed = true;
					}
					else if (keyReleased != NONE && (keyReleased == FlxGamepadInputID.BACK || keyReleased == FlxGamepadInputID.B))
					{
						curButtons[altNum] = keyReleased;
						changed = true;
					}
				}

				if(changed)
				{
					if (onKeyboardMode)
					{
						if(curKeys[altNum] == curKeys[1 - altNum])
							curKeys[1 - altNum] = FlxKey.NONE;
					}
					else
					{
						if(curButtons[altNum] == curButtons[1 - altNum])
							curButtons[1 - altNum] = FlxGamepadInputID.NONE;
					}

					var option:String = options[curOptions[curSelected]][2];
					ClientPrefs.clearInvalidKeys(option);
					
					var optBindsIndices:Array<Int> = [];
					for (i in 0...grpBinds.members.length) {
						var b = grpBinds.members[i];
						if (b != null && b.ID == curOptionsValid[curSelected]) optBindsIndices.push(i);
					}

					for (n in 0...2)
					{
						var key:String = null;
						if(onKeyboardMode)
						{
							var savKey:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get(option);
							key = InputFormatter.getKeyName(savKey[n] != null ? savKey[n] : NONE);
						}
						else
						{
							var savKey:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(option);
							key = InputFormatter.getGamepadName(savKey[n] != null ? savKey[n] : NONE);
						}
						if(optBindsIndices.length > n) updateBind(optBindsIndices[n], key);
					}
					if (bindIndex != -1 && grpBinds.members[bindIndex] != null) grpBinds.members[bindIndex].visible = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					binding = false;
					ClientPrefs.reloadVolumeKeys();
				}
			}
		}

		grpDisplay.forEachAlive(function(item:FlxText) {
			item.x = boxX + (boxWidth / 2) - (item.width / 2);
			item.y = FlxMath.lerp(item.y, boxY + 30, FlxMath.bound(elapsed * 12, 0, 1));
		});

		// 상단 헤더 차폐 및 하단 여백 감지 패딩 변수 선언
		var paddingHeader:Float = 75;
		var paddingBottom:Float = 35;
		var spacing:Float = 90; // 늘어난 글자 크기에 맞춰 배치 간격 최적화

		grpOptions.forEachAlive(function(item:FlxText) {
			var displayIdx:Int = curOptionsValid.indexOf(item.ID);
			if (displayIdx != -1) {
				var delta:Int = displayIdx - curSelected;
				var itemTargetY:Float = centerY + (delta * spacing) - (item.height / 2);
				
				item.y = FlxMath.lerp(item.y, itemTargetY, FlxMath.bound(elapsed * 12, 0, 1));
				
				// 크기 변경 후 가로 충돌을 방지하기 위한 자동 스케일 다운 프로세스
				item.scale.set(0.75, 0.75);
				item.updateHitbox();

				if (options[curOptions[displayIdx]][1] == defaultKey) 
				{
					item.x = boxX + (boxWidth / 2) - (item.width / 2);
					var maxWidth:Float = boxWidth - 40;
					if (item.width > maxWidth) {
						var factor:Float = maxWidth / item.width;
						item.scale.set(0.75 * factor, 0.75 * factor);
						item.updateHitbox();
						item.x = boxX + (boxWidth / 2) - (item.width / 2);
					}
				}
				else 
				{
					item.x = boxX + 40;
					// 첫 번째 바인드 박스 시작 전까지의 가로 한계폭 제한 (오버랩 방지)
					var maxWidth:Float = 160; 
					if (item.width > maxWidth) {
						var factor:Float = maxWidth / item.width;
						item.scale.set(0.75 * factor, 0.75 * factor);
						item.updateHitbox();
					}
				}
				
				item.alpha = (delta == 0) ? 1 : 0.6;

				// 세로 렌더링 범위 제한 조건 (박스 밖으로 탈출 시 비가시화)
				var isInside:Bool = (item.y > boxY + paddingHeader && item.y + item.height < boxY + boxHeight - paddingBottom);
				item.visible = isInside;
			}
		});

		grpBinds.forEachAlive(function(item:FlxText) {
			var actualIdx:Int = grpBinds.members.indexOf(item);
			var parent:FlxText = null;
			for (opt in grpOptions.members) {
				if (opt != null && opt.ID == item.ID) {
					parent = opt;
					break;
				}
			}
			
			if(parent != null && actualIdx != -1) {
				var optBindsIndices:Array<Int> = [];
				for (i in 0...grpBinds.members.length) {
					var b = grpBinds.members[i];
					if (b != null && b.ID == item.ID) optBindsIndices.push(i);
				}
				var n:Int = optBindsIndices.indexOf(actualIdx);
				if (n == -1) n = 0;

				var boxStartX:Float = boxX + 210 + (n * 230);
				
				var black:AttachedSprite = grpBlacks.members[actualIdx];
				if(black != null) {
					black.x = boxStartX;
					black.y = parent.y + (parent.height / 2) - (black.height / 2);
					black.alpha = parent.alpha * 0.4;
				}
				
				// 긴 키 명칭(예: BACKSPACE 등)이 블랙 박스를 뚫고 나가지 않도록 오토 스케일
				item.scale.set(0.65, 0.65);
				item.updateHitbox();
				
				var maxBindWidth:Float = 200;
				if (item.width > maxBindWidth) {
					var factor:Float = maxBindWidth / item.width;
					item.scale.set(0.65 * factor, 0.65 * factor);
					item.updateHitbox();
				}
				
				item.x = boxStartX + (220 / 2) - (item.width / 2);
				item.y = parent.y + (parent.height / 2) - (item.height / 2);
				item.alpha = parent.alpha;
				
				// 부모 텍스트의 스크롤 상태(가시성)에 링크하여 바인드 스프라이트 일괄 차단
				if (!parent.visible) {
					item.visible = false;
					if (black != null) black.visible = false;
				} else {
					if (black != null) black.visible = true;
					
					// 키 바인딩 중인 단일 인스턴스에 대한 예외 컴포넌트 유지 처리
					var altNum:Int = curAlt ? 1 : 0;
					var findCount:Int = 0;
					var isCurrentBinding:Bool = false;
					if (binding && curOptionsValid[curSelected] == item.ID) {
						for (i in 0...grpBinds.members.length) {
							var b = grpBinds.members[i];
							if (b != null && b.ID == item.ID) {
								if (findCount == altNum && i == actualIdx) {
									isCurrentBinding = true;
									break;
								}
								findCount++;
							}
						}
					}
					item.visible = !isCurrentBinding;
				}
			}
		});

		// 선택 사각형(포커스 이펙트)도 트래킹 대상 스프라이트가 화면 밖으로 나가면 가시성을 즉시 동기화
		if (selectSpr != null && selectSpr.sprTracker != null) {
			selectSpr.visible = selectSpr.sprTracker.visible;
		}

		super.update(elapsed);
	}

	function updateText(?change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, curOptions.length - 1);
		updateAlt();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function swapMode()
	{
		var optionWindow = OptionsSubState.optionWindow;
		if(optionWindow != null)
		{
			FlxTween.cancelTweensOf(optionWindow);
			FlxTween.color(optionWindow, 0.5, optionWindow.color, onKeyboardMode ? gamepadColor : keyboardColor, {ease: FlxEase.linear});
		}
		onKeyboardMode = !onKeyboardMode;

		curSelected = 0;
		curAlt = false;
		controllerSpr.animation.play(onKeyboardMode ? 'keyboard' : 'gamepad');
		createTexts();
	}

	function updateAlt(?doSwap:Bool = false)
	{
		if(doSwap)
		{
			curAlt = !curAlt;
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		
		var altNum:Int = curAlt ? 1 : 0;
		var targetBlack:AttachedSprite = null;
		var findCount:Int = 0;
		
		for (i in 0...grpBinds.members.length) {
			var b = grpBinds.members[i];
			if (b != null && b.ID == curOptionsValid[curSelected]) {
				if (findCount == altNum) {
					targetBlack = grpBlacks.members[i];
					break;
				}
				findCount++;
			}
		}
		
		selectSpr.sprTracker = targetBlack;
		selectSpr.visible = (targetBlack != null && targetBlack.visible);
	}
}
