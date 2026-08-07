package options;

import flixel.input.keyboard.FlxKey;
import objects.CheckboxThingie;
import objects.AttachedText;
import options.Option;
import backend.InputFormatter;

class BaseOptionsMenu extends MusicBeatSubstate
{
	private var curOption:Option = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<Option>;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedText>;

	private var descBox:FlxSprite;
	private var descText:FlxText;

	public var title:String;
	public var rpcTitle:String;

	public function new()
	{
		super();

		if(title == null) title = 'Options';
		if(rpcTitle == null) rpcTitle = 'Options Menu';
		
		#if DISCORD_ALLOWED
		DiscordClient.changePresence(rpcTitle, null);
		#end

		var targetCam = OptionsSubState.instance != null ? OptionsSubState.instance.optionCam : null;

		grpOptions = new FlxTypedGroup<Alphabet>();
		if(targetCam != null) grpOptions.cameras = [targetCam];
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		if(targetCam != null) grpTexts.cameras = [targetCam];
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		if(targetCam != null) checkboxGroup.cameras = [targetCam];
		add(checkboxGroup);

		descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.6;
		if(targetCam != null) descBox.cameras = [targetCam];
		add(descBox);

		var titleText:Alphabet = new Alphabet(20, 12.5, title, true);
		titleText.setScale(0.55);
		titleText.alpha = 0.8;
		if(targetCam != null) titleText.cameras = [targetCam];

		descText = new FlxText(40, 440, 720, "", 22);
		descText.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.0;
		if(targetCam != null) descText.cameras = [targetCam];

		// 초기 생성 시 위치 설정
		var initTextX:Float = 140;     // 옵션 텍스트 기본 X 위치
		var initCenterY:Float = 180;   // 기준 Y 위치
		var initSpacingY:Float = 55;   // 항목 간 세로 간격

		for (i in 0...optionsArray.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, optionsArray[i].name, true);
			optionText.isMenuItem = false;
			optionText.alignment = LEFT;
			optionText.setScale(0.55); 
			optionText.targetY = i;
			grpOptions.add(optionText);

			optionText.x = initTextX;
			optionText.y = initCenterY + (i * initSpacingY);

			if(optionsArray[i].type == BOOL)
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(0, 0, Std.string(optionsArray[i].getValue()) == 'true');
				checkbox.scale.set(0.55, 0.55); 
				checkbox.updateHitbox();
				checkbox.sprTracker = null; 
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
				
				checkbox.x = optionText.x - 65;
				checkbox.y = optionText.y - 10;
			}
			else
			{
				var valueText:AttachedText = new AttachedText('' + optionsArray[i].getValue(), 0);
				valueText.alignment = LEFT;
				valueText.setScale(0.55);
				valueText.sprTracker = null; 
				valueText.copyAlpha = true;
				valueText.ID = i;
				valueText.x = optionText.x + optionText.width + 20;
				valueText.y = optionText.y;
				grpTexts.add(valueText);
				optionsArray[i].child = valueText;
			}
			
			updateTextFrom(optionsArray[i]);
		}

		changeSelection();
		reloadCheckboxes();
	}

	public function addOption(option:Option) {
		if(optionsArray == null || optionsArray.length < 1) optionsArray = [];
		optionsArray.push(option);
		return option;
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;

	var bindingKey:Bool = false;
	var holdingEsc:Float = 0;
	var bindingBlack:FlxSprite;
	var bindingText:Alphabet;
	var bindingText2:Alphabet;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var lerpVal:Float = flixel.math.FlxMath.bound(elapsed * 9.6, 0, 1);
		var targetCam = OptionsSubState.instance != null ? OptionsSubState.instance.optionCam : null;

		// 세팅 창 내부 레이아웃 컨트롤러
		var textBaseX:Float = 140;     // 옵션 글자 X 위치
		var centerY:Float = 180;       // 현재 선택된 항목 기준 Y 좌표
		var spacingY:Float = 55;       // 메뉴 항목 간 세로 간격

		for (i in 0...grpOptions.members.length)
		{
			var item = grpOptions.members[i];
			item.alignment = LEFT;
			item.setScale(0.55);
			item.x = textBaseX;
			
			// 선택 항목 기준 스크롤 Y 좌표 계산
			var targetYPos:Float = centerY + (item.targetY * spacingY);
			item.y = flixel.math.FlxMath.lerp(item.y, targetYPos, lerpVal);

			for (checkbox in checkboxGroup.members)
			{
				if (checkbox.ID == i)
				{
					checkbox.scale.set(0.55, 0.55);
					checkbox.x = item.x - 65;
					checkbox.y = item.y - 10;
				}
			}

			for (text in grpTexts.members)
			{
				if (text.ID == i)
				{
					text.alignment = LEFT;
					text.setScale(0.55);
					text.x = item.x + item.width + 20; 
					text.y = item.y;
				}
			}
		}

		if(bindingKey)
		{
			bindingKeyUpdate(elapsed);
			return;
		}
		
		if (controls.UI_UP_P) changeSelection(-1);
		if (controls.UI_DOWN_P) changeSelection(1);

		if (controls.BACK) {
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if(nextAccept <= 0)
		{
			switch(curOption.type)
			{
				case BOOL:
					if(controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						curOption.setValue((curOption.getValue() == true) ? false : true);
						curOption.change();
						reloadCheckboxes();
					}

				case KEYBIND:
					if(controls.ACCEPT)
					{
						bindingBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
						bindingBlack.scale.set(FlxG.width, FlxG.height);
						bindingBlack.updateHitbox();
						bindingBlack.alpha = 0;
						if(targetCam != null) bindingBlack.cameras = [targetCam];
						FlxTween.tween(bindingBlack, {alpha: 0.6}, 0.35, {ease: FlxEase.linear});
						add(bindingBlack);
	
						bindingText = new Alphabet(400, 160, Language.getPhrase('controls_rebinding', 'Rebinding {1}', [curOption.name]), false);
						bindingText.alignment = CENTERED;
						if(targetCam != null) bindingText.cameras = [targetCam];
						
						bindingText2 = new Alphabet(400, 280, Language.getPhrase('controls_rebinding2', 'Hold ESC to Cancel\nHold Backspace to Delete', []), true);
						bindingText2.alignment = CENTERED;
						if(targetCam != null) bindingText2.cameras = [targetCam];
	
						bindingKey = true;
						holdingEsc = 0;
						ClientPrefs.toggleVolumeKeys(false);
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}

				default:
					if(controls.UI_LEFT || controls.UI_RIGHT)
					{
						var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
						if(holdTime > 0.5 || pressed)
						{
							if(pressed)
							{
								var add:Dynamic = null;
								if(curOption.type != STRING)
									add = controls.UI_LEFT ? -curOption.changeValue : curOption.changeValue;
		
								switch(curOption.type)
								{
									case INT, FLOAT, PERCENT:
										holdValue = curOption.getValue() + add;
										if(holdValue < curOption.minValue) holdValue = curOption.minValue;
										else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;
		
										if(curOption.type == INT)
										{
											holdValue = Math.round(holdValue);
											curOption.setValue(holdValue);
										}
										else
										{
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											curOption.setValue(holdValue);
										}
		
									case STRING:
										var num:Int = curOption.curOption;
										if(controls.UI_LEFT_P) --num;
										else num++;
		
										if(num < 0)
											num = curOption.options.length - 1;
										else if(num >= curOption.options.length)
											num = 0;
		
										curOption.curOption = num;
										curOption.setValue(curOption.options[num]);

									default:
								}
								updateTextFrom(curOption);
								curOption.change();
								FlxG.sound.play(Paths.sound('scrollMenu'));
							}
							else if(curOption.type != STRING)
							{
								holdValue += curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1);
								if(holdValue < curOption.minValue) holdValue = curOption.minValue;
								else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;
		
								switch(curOption.type)
								{
									case INT:
										curOption.setValue(Math.round(holdValue));
									
									case PERCENT:
										curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));

									default:
								}
								updateTextFrom(curOption);
								curOption.change();
							}
						}
		
						if(curOption.type != STRING)
							holdTime += elapsed;
					}
					else if(controls.UI_LEFT_R || controls.UI_RIGHT_R)
					{
						if(holdTime > 0.5) FlxG.sound.play(Paths.sound('scrollMenu'));
						holdTime = 0;
					}
			}

			if(controls.RESET)
			{
				var leOption:Option = optionsArray[curSelected];
				if(leOption.type != KEYBIND)
				{
					leOption.setValue(leOption.defaultValue);
					if(leOption.type != BOOL)
					{
						if(leOption.type == STRING) leOption.curOption = leOption.options.indexOf(leOption.getValue());
						updateTextFrom(leOption);
					}
				}
				else
				{
					leOption.setValue(leOption.defaultKeys.keyboard);
					updateBind(leOption);
				}
				leOption.change();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
	}

	function bindingKeyUpdate(elapsed:Float)
	{
		if(FlxG.keys.pressed.ESCAPE)
		{
			holdingEsc += elapsed;
			if(holdingEsc > 0.5)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				closeBinding();
			}
		}
		else if (FlxG.keys.pressed.BACKSPACE)
		{
			holdingEsc += elapsed;
			if(holdingEsc > 0.5)
			{
				curOption.keys.keyboard = NONE;
				updateBind(InputFormatter.getKeyName(NONE));
				FlxG.sound.play(Paths.sound('cancelMenu'));
				closeBinding();
			}
		}
		else
		{
			holdingEsc = 0;
			var changed:Bool = false;
			
			if(FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY)
			{
				var keyPressed:FlxKey = cast (FlxG.keys.firstJustPressed(), FlxKey);
				var keyReleased:FlxKey = cast (FlxG.keys.firstJustReleased(), FlxKey);

				if(keyPressed != NONE && keyPressed != ESCAPE && keyPressed != BACKSPACE)
				{
					changed = true;
					curOption.keys.keyboard = keyPressed;
				}
				else if(keyReleased != NONE && (keyReleased == ESCAPE || keyReleased == BACKSPACE))
				{
					changed = true;
					curOption.keys.keyboard = keyReleased;
				}
			}

			if(changed)
			{
				var key:String = null;
				if(curOption.keys.keyboard == null) curOption.keys.keyboard = 'NONE';
				curOption.setValue(curOption.keys.keyboard);
				key = InputFormatter.getKeyName(FlxKey.fromString(curOption.keys.keyboard));
				
				updateBind(key);
				FlxG.sound.play(Paths.sound('confirmMenu'));
				closeBinding();
			}
		}
	}

	final MAX_KEYBIND_WIDTH = 320;
	function updateBind(?text:String = null, ?option:Option = null)
	{
		if(option == null) option = curOption;
		if(text == null)
		{
			text = option.getValue();
			if(text == null) text = 'NONE';
			text = InputFormatter.getKeyName(FlxKey.fromString(text));
		}

		var bind:AttachedText = cast option.child;
		var attach:AttachedText = new AttachedText(text, 0); 
		attach.sprTracker = null;
		attach.copyAlpha = true;
		attach.ID = bind.ID;
		
		attach.alignment = LEFT;
		attach.setScale(0.55);
		attach.x = bind.x;
		attach.y = bind.y;
		if(OptionsSubState.instance != null) attach.cameras = [OptionsSubState.instance.optionCam];

		option.child = attach;
		grpTexts.insert(grpTexts.members.indexOf(bind), attach);
		grpTexts.remove(bind);
		bind.destroy();
	}

	function closeBinding()
	{
		bindingKey = false;
		bindingBlack.destroy();
		remove(bindingBlack);

		bindingText.destroy();
		remove(bindingText);

		bindingText2.destroy();
		remove(bindingText2);
		ClientPrefs.toggleVolumeKeys(true);
	}

	function updateTextFrom(option:Option) {
		if(option.type == KEYBIND)
		{
			updateBind(option);
			return;
		}

		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if(option.type == PERCENT) val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);

		if(option.child != null)
		{
			option.child.text = '' + val;
		}
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, optionsArray.length - 1);

		descText.text = optionsArray[curSelected].description;

		var targetCam = OptionsSubState.instance != null ? OptionsSubState.instance.optionCam : null;
		if (targetCam != null) {
			descText.y = targetCam.height - 65;
			descText.fieldWidth = targetCam.width - 80;
			descText.x = 40;
		}

		for (num => item in grpOptions.members)
		{
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0) item.alpha = 1;
		}
		for (text in grpTexts)
		{
			text.alpha = 0.6;
			if(text.ID == curSelected) text.alpha = 1;
		}

		descBox.setPosition(descText.x - 10, descText.y - 5);
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 10));
		descBox.updateHitbox();

		curOption = optionsArray[curSelected];
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadCheckboxes()
		for (checkbox in checkboxGroup)
			checkbox.daValue = Std.string(optionsArray[checkbox.ID].getValue()) == 'true';
}
