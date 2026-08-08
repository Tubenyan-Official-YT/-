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

	// 레이아웃 고정 좌표 상수
	private inline var COMMON_TEXT_X:Float = 90;
	private inline var VALUE_TEXT_X:Float = 230;
	private inline var CHECKBOX_X:Float = 45;
	private inline var INIT_CENTER_Y:Float = 130;
	private inline var INIT_SPACING_Y:Float = 38;

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
		titleText.setScale(0.5);
		titleText.alpha = 0.8;
		if(targetCam != null) titleText.cameras = [targetCam];

		descText = new FlxText(40, 440, 720, "", 22);
		descText.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.0;
		if(targetCam != null) descText.cameras = [targetCam];

		for (i in 0...optionsArray.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, optionsArray[i].name, true);
			optionText.isMenuItem = false;
			optionText.changeX = false;
			optionText.changeY = false;
			optionText.distancePerItem.set(0, 0);
			optionText.setScale(0.38); 
			optionText.targetY = i;
			grpOptions.add(optionText);

			optionText.x = COMMON_TEXT_X;
			optionText.y = INIT_CENTER_Y + (i * INIT_SPACING_Y);

			if(optionsArray[i].type == BOOL)
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(0, 0, Std.string(optionsArray[i].getValue()) == 'true');
				checkbox.scale.set(0.38, 0.38); 
				checkbox.updateHitbox();
				checkbox.sprTracker = null; 
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
				
				checkbox.x = CHECKBOX_X;
				checkbox.y = optionText.y - 6;
			}
			else
			{
				var valueText:AttachedText = new AttachedText('' + optionsArray[i].getValue(), 0);
				valueText.isMenuItem = false;
				valueText.changeX = false;
				valueText.changeY = false;
				valueText.distancePerItem.set(0, 0);
				valueText.setScale(0.38);
				valueText.sprTracker = null; 
				valueText.copyAlpha = true;
				valueText.ID = i;
				valueText.x = VALUE_TEXT_X;
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

		for (i in 0...grpOptions.members.length)
		{
			var item = grpOptions.members[i];
			item.isMenuItem = false;
			item.changeX = false;
			item.changeY = false;
			item.distancePerItem.set(0, 0);
			item.x = COMMON_TEXT_X;
			
			// 고정 목록 레이아웃: 항목 i는 고정된 Y 위치로 수평 보정
			var targetYPos:Float = INIT_CENTER_Y + (i * INIT_SPACING_Y);
			item.y = flixel.math.FlxMath.lerp(item.y, targetYPos, lerpVal);

			for (checkbox in checkboxGroup.members)
			{
				if (checkbox.ID == i)
				{
					// offset.set(0, 0)을 삭제하여 내부 프레임 오프셋을 유지
					checkbox.x = CHECKBOX_X;
					checkbox.y = item.y - 6;
				}
			}

			for (text in grpTexts.members)
			{
				if (text.ID == i)
				{
					text.isMenuItem = false;
					text.changeX = false;
					text.changeY = false;
					text.distancePerItem.set(0, 0);
					text.x = VALUE_TEXT_X;
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
		attach.isMenuItem = false;
		attach.changeX = false;
		attach.changeY = false;
		attach.distancePerItem.set(0, 0);
		attach.sprTracker = null;
		attach.copyAlpha = true;
		attach.ID = bind.ID;
		
		attach.setScale(0.38);
		attach.x = VALUE_TEXT_X;
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

		// 절대 인덱스(num) 기준으로 투명도만 조정하고 Y 위치는 고정 유지
		for (num => item in grpOptions.members)
		{
			item.targetY = num;
			item.alpha = 0.6;
			if (num == curSelected) item.alpha = 1;
		}
		for (text in grpTexts)
		{
			text.alpha = 0.6;
			if(text.ID == curSelected) text.alpha = 1;
		}
		for (checkbox in checkboxGroup)
		{
			checkbox.alpha = 0.6;
			if(checkbox.ID == curSelected) checkbox.alpha = 1;
		}

		descBox.setPosition(descText.x - 10, descText.y - 5);
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 10));
		descBox.updateHitbox();

		curOption = optionsArray[curSelected];
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadCheckboxes()
	{
		for (checkbox in checkboxGroup)
		{
			checkbox.daValue = Std.string(optionsArray[checkbox.ID].getValue()) == 'true';
			// 애니메이션 오프셋 보전을 위해 offset.set(0, 0) 구문 제거
		}
	}
}
