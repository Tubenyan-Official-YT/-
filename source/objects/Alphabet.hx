package objects;

import haxe.Json;
import openfl.utils.Assets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

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
	public var letters:Array<Dynamic> = []; // 기존 코드 호환용 빈 배열 유지

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

	// 전체 렌더링을 담당할 고정 FlxText 컴포넌트
	private var nativeText:FlxText = null;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = true)
	{
		super(x, y);

		this.startPosition.x = x;
		this.startPosition.y = y;
		this.bold = bold;
		this.text = text;
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
		
		// 기존에 생성되어 있던 컴포넌트 정리
		if (nativeText != null) {
			remove(nativeText);
			nativeText.destroy();
			nativeText = null;
		}

		if (text.length == 0) return text;

		// 영문/다국어 구분 없이 무조건 FlxText 컴포넌트 생성 후 폰트 자동 일괄 적용
		nativeText = new FlxText(0, 0, 0, text);
		
		// shared 통합 폰트 에셋 로드 (mods/fonts/font.ttf)
		var fontName:String = Paths.font("font.ttf");
		var fontSize:Int = bold ? 56 : 36;
		
		nativeText.setFormat(fontName, fontSize, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		nativeText.borderSize = bold ? 5 : 3;
		nativeText.antialiasing = ClientPrefs.data.antialiasing;
		
		add(nativeText);
		updateAlignment();

		// 행(Row) 수 계산
		rows = text.split('\n').length;

		return text;
	}

	private function updateAlignment()
	{
		if (nativeText == null) return;

		// 텍스트 정렬 기준에 맞춘 상대 좌표 오프셋 설정
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
