package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

enum Alignment
{
	LEFT;
	CENTERED;
	RIGHT;
}

class Alphabet extends FlxSpriteGroup
{
	public var text(default, set):String;

	public var bold:Bool = false;
	public var letters:Array<FlxSprite> = [];

	public var isMenuItem:Bool = false;
	public var targetY:Float = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;

	public var alignment(default, set):Alignment = LEFT;
	public var scaleX(default, set):Float = 1;
	public var scaleY(default, set):Float = 1;

	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0);

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = true)
	{
		super(x, y);

		this.startPosition.x = x;
		this.startPosition.y = y;
		this.bold = bold;

		this.text = text;
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var lerpVal:Float = FlxMath.bound(elapsed * 9.6, 0, 1);
			if (changeX)
				x = FlxMath.lerp(x, (targetY * distancePerItem.x) + startPosition.x, lerpVal);
			if (changeY)
				y = FlxMath.lerp(y, (targetY * 1.3 * distancePerItem.y) + startPosition.y, lerpVal);
		}

		super.update(elapsed);
	}

	public function snapToPosition()
	{
		if (isMenuItem)
		{
			if (changeX)
				x = (targetY * distancePerItem.x) + startPosition.x;
			if (changeY)
				y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
		}
	}

	private function set_text(newText:String):String
	{
		newText = backend.Language.getPhrase(newText, newText);
		text = newText;
		clearLetters();
		createLetters(newText);
		return text;
	}

	public function clearLetters()
	{
		for (letter in letters)
		{
			remove(letter);
			letter.destroy();
		}
		letters = [];
	}

	private function createLetters(newText:String)
	{
		var xPos:Float = 0;
		var yPos:Float = 0;
		
		// alphabet.xml의 높이 실측치 기반 추출 (Bold: 64, Normal: 40)
		var fontSize:Int = bold ? 64 : 40;
		var fontName:String = Paths.font("vcr.ttf"); 

		var splitText:Array<String> = newText.split("");
		
		for (char in splitText)
		{
			if (char == "\n")
			{
				xPos = 0;
				yPos += bold ? 80 : 50;
				continue;
			}

			if (char == " ")
			{
				xPos += bold ? 28 : 20;
				continue;
			}

			var letter:FlxText = new FlxText(xPos, yPos, 0, char);
			letter.setFormat(fontName, fontSize, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			letter.borderSize = bold ? 5 : 2;
			letter.updateHitbox();

			letter.scale.set(scaleX, scaleY);
			
			add(letter);
			letters.push(letter);

			xPos += letter.width + (bold ? 4 : 2);
		}

		updateAlignment();
	}

	public function changeText(newText:String)
	{
		this.text = newText;
	}

	private function set_alignment(value:Alignment):Alignment
	{
		alignment = value;
		updateAlignment();
		return alignment;
	}

	private function updateAlignment()
	{
		if (letters.length == 0) return;

		var minX:Float = 999999;
		var maxX:Float = -999999;
		for (letter in letters)
		{
			if (letter.x < minX) minX = letter.x;
			if (letter.x + letter.width > maxX) maxX = letter.x + letter.width;
		}
		var totalWidth:Float = maxX - minX;

		for (letter in letters)
		{
			switch (alignment)
			{
				case CENTERED:
					letter.offset.x = totalWidth / 2;
				case RIGHT:
					letter.offset.x = totalWidth;
				default:
					letter.offset.x = 0;
			}
		}
	}

	private function set_scaleX(value:Float):Float
	{
		scaleX = value;
		for (letter in letters)
		{
			letter.scale.x = scaleX;
			letter.updateHitbox();
		}
		updateAlignment();
		return scaleX;
	}

	private function set_scaleY(value:Float):Float
	{
		scaleY = value;
		for (letter in letters)
		{
			letter.scale.y = scaleY;
			letter.updateHitbox();
		}
		return scaleY;
	}
	
	public function setAlignmentFromString(align:String)
	{
		switch(align.toLowerCase().trim())
		{
			case 'right':
				alignment = RIGHT;
			case 'center' | 'centered':
				alignment = CENTERED;
			default:
				alignment = LEFT;
		}
	}
}
