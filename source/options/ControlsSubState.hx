package options;

import backend.InputFormatter;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import objects.AttachedSprite;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

class ControlsSubState extends MusicBeatSubstate
{
	var curSelected:Int = 0;
	var curAlt:Bool = false;

	//Show on gamepad - Display name - Save file key - Rebind display name
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

	var grpDisplay:FlxTypedGroup<Alphabet>;
	var grpBlacks:FlxTypedGroup<AttachedSprite>;
	var grpOptions:FlxTypedGroup<Alphabet>;
	var grpBinds:FlxTypedGroup<Alphabet>;
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

		grpDisplay = new FlxTypedGroup<Alphabet>();
		add(grpDisplay);
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);
		grpBlacks = new FlxTypedGroup<AttachedSprite>();
		add(grpBlacks);
		
		selectSpr = new AttachedSprite();
		// 줄어든 상자 크기에 맞추어 220, 70으로 수정
		selectSpr.makeGraphic(220, 70, FlxColor.WHITE);
		selectSpr.copyAlpha = false;
		selectSpr.alpha = 0.75;
		selectSpr.xAdd = 0;
		selectSpr.yAdd = 0;
		add(selectSpr);
		
		grpBinds = new FlxTypedGroup<Alphabet>();
		add(grpBinds);

		controllerSpr = new FlxSprite(50, 40).loadGraphic(Paths.image('controllertype'), true, 82, 60);
		controllerSpr.antialiasing = ClientPrefs.data.antialiasing;
		controllerSpr.animation.add('keyboard', [0], 1, false);
		controllerSpr.animation.add('gamepad', [1], 1, false);
		add(controllerSpr);

		var text:Alphabet = new Alphabet(60, 90, 'CTRL', false);
		text.alignment = CENTERED;
		text.setScale(0.4);
		add(text);

		createTexts();
	}

	var lastID:Int = 0;
	function createTexts()
	{
		curOptions = [];
		curOptionsValid = [];
		grpDisplay.forEachAlive(function(text:Alphabet) text.destroy());
		grpBlacks.forEachAlive(function(black:AttachedSprite) black.destroy());
		grpOptions.forEachAlive(function(text:Alphabet) text.destroy());
		grpBinds.forEachAlive(function(text:Alphabet) text.destroy());
		grpDisplay.clear();
		grpBlacks.clear();
		grpOptions.clear();
		grpBinds.clear();

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
					var text:Alphabet = new Alphabet(475, 300, !isDisplayKey ? Language.getPhrase('key_$keyStr', str) : Language.getPhrase('keygroup_$str', str), !isDisplayKey);
					
					text.isMenuItem = !isDisplayKey;
					text.changeX = false;
					text.distancePerItem.y = 60;
					text.targetY = myID;
					text.ID = myID;
					lastID = myID;

					if(!isDisplayKey)
					{
						text.alignment = LEFT;
						grpOptions.add(text);
						curOptions.push(i);
						curOptionsValid.push(myID);
					}
					else grpDisplay.add(text);

					if(isCentered) addCenteredText(text, option, myID);
					else addKeyText(text, option, myID);

					text.snapToPosition();
					text.y += FlxG.height * 2;
				}
				myID++;
			}
		}
		updateText();
	}

	function addCenteredText(text:Alphabet, option:Array<Dynamic>, id:Int)
	{
		text.alignment = LEFT;
		text.screenCenter(X);
		text.y -= 55;
		text.startPosition.y -= 55;
	}
	
	function addKeyText(text:Alphabet, option:Array<Dynamic>, id:Int)
	{
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

			var attach:Alphabet = new Alphabet(0, 0, key, false);
			attach.isMenuItem = true;
			attach.changeX = false;
			attach.distancePerItem.y = 60;
			attach.targetY = text.targetY;
			attach.ID = Math.floor(grpBinds.length / 2);
			attach.snapToPosition();
			attach.y += FlxG.height * 2;
			grpBinds.add(attach);

			playstationCheck(attach);
			attach.scaleX = Math.min(1, 180 / attach.width);

			var black:AttachedSprite = new AttachedSprite();
			// 상자 크기를 줄였습니다 (너비 220, 높이 70)
			black.makeGraphic(220, 70, FlxColor.BLACK);
			black.alphaMult = 0.4;
			black.sprTracker = null; 
			grpBlacks.add(black);
		}
	}

	function playstationCheck(alpha:Alphabet)
	{
		if(onKeyboardMode) return;

		var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
		var model:FlxGamepadModel = gamepad != null ? gamepad.detectedModel : UNKNOWN;
		var letter = alpha.letters[0];
		if(model == PS4)
		{
			switch(alpha.text)
			{
				case '[', ']':
					letter.image = 'alphabet_playstation';
					letter.updateHitbox();
					
					letter.offset.x += 4;
					letter.offset.y -= 5;
			}
		}
	}

	function updateBind(num:Int, text:String)
	{
		var bind:Alphabet = grpBinds.members[num];
		var parentID = bind.ID;
		var targetY = bind.targetY;
		
		var attach:Alphabet = new Alphabet(0, 0, text, false);
		attach.isMenuItem = true;
		attach.changeX = false;
		attach.distancePerItem.y = 60;
		attach.targetY = targetY;
		attach.ID = parentID;
		
		playstationCheck(attach);
		attach.scaleX = Math.min(1, 180 / attach.width);

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

					// 엔터 입력 시 글자만 숨김 처리
					var altNum:Int = curAlt ? 1 : 0;
					var bindIndex:Int = Math.floor(curSelected * 2) + altNum;
					if (grpBinds.members[bindIndex] != null) grpBinds.members[bindIndex].visible = false;
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
			var bindIndex:Int = Math.floor(curSelected * 2) + altNum;
			var curOption:Array<Dynamic> = options[curOptions[curSelected]];
			
			if(FlxG.keys.pressed.ESCAPE || FlxG.gamepads.anyPressed(B))
			{
				holdingEsc += elapsed;
				if(holdingEsc > 0.5)
				{
					if (grpBinds.members[bindIndex] != null) grpBinds.members[bindIndex].visible = true;
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
					if (grpBinds.members[bindIndex] != null) grpBinds.members[bindIndex].visible = true;
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
						updateBind(Math.floor(curSelected * 2) + n, key);
					}
					if (grpBinds.members[bindIndex] != null) grpBinds.members[bindIndex].visible = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					binding = false;
					ClientPrefs.reloadVolumeKeys();
				}
			}
		}
		super.update(elapsed);
	}

	function updateText(?change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, curOptions.length - 1);

		var optionWindow = OptionsSubState.optionWindow;
		
		var num:Int = curOptionsValid[curSelected];
		var addNum:Int = 0;
		if(num < 3) addNum = 3 - num;
		else if(num > lastID - 4) addNum = (lastID - 4) - num;

		var activeCategoryID:Int = -1;
		grpDisplay.forEachAlive(function(item:Alphabet) {
			if (item.ID <= num && item.ID > activeCategoryID) {
				activeCategoryID = item.ID;
			}
		});

		grpDisplay.forEachAlive(function(item:Alphabet) {
			item.x = optionWindow.x + (optionWindow.width - item.width) / 2;
			if (item.ID == activeCategoryID) {
				item.visible = true;
				item.y = optionWindow.y + 65; 
			} else {
				item.visible = false;
			}
		});

		// 옵션 이름을 반투명 상자 바로 왼쪽에 오도록 X 좌표 정렬
		grpOptions.forEachAlive(function(item:Alphabet)
		{
			item.targetY = item.ID - num - addNum;
			item.alpha = (item.ID - num == 0) ? 1 : 0.6;
			item.x = optionWindow.x + 150;
		});

		var i:Int = 0;
		grpBinds.forEachAlive(function(item:Alphabet)
		{
			var parent:Alphabet = grpOptions.members[item.ID];
			item.targetY = parent.targetY;
			item.alpha = parent.alpha;

			var n:Int = i % 2;
			
			// 이름 오른쪽에 상자들이 자연스럽게 오도록 시작점 계산
			var boxStartX:Float = optionWindow.x + 450 + (n * 260);
			
			var black:AttachedSprite = grpBlacks.members[i];
			if(black != null) {
				black.x = boxStartX;
				black.y = item.y + (item.height / 2) - (black.height / 2);
				black.alpha = item.alpha * 0.4;
			}

			// 바인딩 글자가 줄어든 반투명 상자(너비 220)의 정확한 정중앙에 위치하도록 배치
			item.x = boxStartX + (220 / 2) - (item.width / 2);
			i++;
		});

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
		var targetBlack = grpBlacks.members[Math.floor(curSelected * 2) + (curAlt ? 1 : 0)];
		selectSpr.sprTracker = targetBlack;
		selectSpr.visible = (targetBlack != null);
	}
}
