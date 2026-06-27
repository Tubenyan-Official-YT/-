package objects;

import haxe.Json;
import openfl.utils.Assets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;

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
	public var letters:Array<Dynamic> = []; // 기존 소스 호환용 빈 배열 유지

	public var isMenuItem:Bool = false;
	public var targetY:Int = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;

	public var alignment(default, set):Alignment = LEFT;
	public var scaleX(default, set):Float = 1;
	public var scaleY(default, set):Float = 1;
	public var rows:Int = 0;

	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0);

	private var nativeText:FlxText = null;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = true)
	{
		super(x, y);

		this.startPosition.x = x;
		this.startPosition.y = y;
		this.bold = bold;
		this.text = text;
	}

	// [컴파일 에러 해결 핵심] 외부 파일에서 setScale을 호출할 때 그룹 전체 크기를 안전하게 변환합니다.
	public function setScale(setX:Float, ?setY:Null<Float> = null):Void
	{
		if (setY == null) setY = setX;
		scaleX = setX;
		scaleY = setY;
		scale.set(setX, setY);
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

	private function set_text(newText:String)
	{
		newText = newText.replace('\\n', '\n');
		text = newText;
		
		if (nativeText != null) {
			remove(nativeText);
			nativeText.destroy();
			nativeText = null;
		}

		if (text.length == 0) return text;

		nativeText = new FlxText(0, 0, 0, text);
		
		// mods/fonts/font.ttf 경로의 통합 폰트를 자동으로 적용합니다.
		var fontName:String = Paths.font("font.ttf");
		var fontSize:Int = bold ? 56 : 36;
		
		nativeText.setFormat(fontName, fontSize, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		nativeText.borderSize = bold ? 5 : 3;
		nativeText.antialiasing = ClientPrefs.data.antialiasing;
		
		add(nativeText);
		updateAlignment();

		rows = text.split('\n').length;

		return text;
	}

	private function updateAlignment()
	{
		if (nativeText == null) return;

		switch (alignment)
		{
			case CENTERED:
				nativeText.x = -nativeText.width / 2;
			case RIGHT:
				nativeText.x = -nativeText.width;
			default:
				nativeText.x = 0;
		}
	}

	private function set_alignment(value:Alignment)
	{
		alignment = value;
		updateAlignment();
		return value;
	}

	private function set_scaleX(value:Float)
	{
		scaleX = value;
		scale.x = value;
		return value;
	}

	private function set_scaleY(value:Float)
	{
		scaleY = value;
		scale.y = value;
		return value;
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, distancePerItem.y);
			var lerpVal:Float = FlxMath.bound(elapsed * 9.6, 0, 1);
			
			if (changeX) x = FlxMath.lerp(x, (targetY * distancePerItem.x) + startPosition.x, lerpVal);
			if (changeY) y = FlxMath.lerp(y, scaledY + startPosition.y, lerpVal);
		}
		super.update(elapsed);
	}
}
