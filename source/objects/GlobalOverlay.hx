package objects;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import flixel.FlxG;
import sys.io.File;
import sys.FileSystem;
import states.TitleState;
import states.PlayState;

class GlobalOverlay extends Sprite
{
	public static var instance:GlobalOverlay;
	public var topBitmap:Bitmap;
	public var downBitmap:Bitmap;

	var lastScale:Float = 1;


	static function logMsg(msg:String)
	{
		try
		{
			File.append("globaloverlay_log.txt", true).writeString('[GlobalOverlay] $msg\n');
		}
		catch (e:Dynamic) {}
	}

	public function new()
	{
		super();
		instance = this;
		try { if (FileSystem.exists("globaloverlay_log.txt")) FileSystem.deleteFile("globaloverlay_log.txt"); } catch (e:Dynamic) {}
		logMsg('constructor start');

		// 디버그용: 이미지 로딩 문제인지 렌더링/z-order 문제인지 구분하려고 강제로 그리는 테스트 사각형
		graphics.beginFill(0xFFFF00FF, 1);
		graphics.drawRect(0, 0, FlxG.width, 40);
		graphics.endFill();
		logMsg('debug rect drawn: ' + FlxG.width + 'x40');

		var topGraphic = Paths.image('overlay/topOverlay');
		logMsg('topGraphic = ' + topGraphic);
		if (topGraphic != null)
		{
			addChild(topBitmap = new Bitmap(topGraphic.bitmap));
			logMsg('topBitmap size = ' + topBitmap.width + 'x' + topBitmap.height);
		}

		var downGraphic = Paths.image('overlay/downOverlay');
		logMsg('downGraphic = ' + downGraphic);
		if (downGraphic != null)
		{
			addChild(downBitmap = new Bitmap(downGraphic.bitmap));
			downBitmap.y = FlxG.height - downBitmap.height;
			logMsg('downBitmap size = ' + downBitmap.width + 'x' + downBitmap.height + ', y=' + downBitmap.y);
		}

		logMsg('FlxG.game = ' + FlxG.game + ', FlxG.stage = ' + FlxG.stage);
		// Main.hx에서 addChild로 직접 붙여줌 (FlxG.game 안이 아니라 Main의 sibling으로 — fpsVar와 동일한 방식)

		if (FlxG.stage != null)
			FlxG.stage.addEventListener(Event.RESIZE, onResize);
		else
			logMsg('ERROR: FlxG.stage is null!');

		addEventListener(Event.ENTER_FRAME, update);
		onResize(null);
		logMsg('constructor end, visible = ' + visible + ', x=' + x + ', y=' + y + ', scaleX=' + scaleX);
	}

	var frameCount:Int = 0;

	function update(e:Event)
	{
		// 발전과제 팝업 원리: 매 프레임 현재 스테이트 체크해서 타이틀/플레이스테이트만 제외하고 표시
		visible = !(Std.isOfType(FlxG.state, TitleState) || Std.isOfType(FlxG.state, PlayState));
	}

	function onResize(e:Event)
	{
		lastScale = FlxG.stage.stageHeight / FlxG.height;
		scaleX = lastScale;
		scaleY = lastScale;
		x = (FlxG.stage.stageWidth - (FlxG.width * lastScale)) / 2;
		y = 0;
	}

	public function destroy()
	{
		if (parent != null)
			parent.removeChild(this);
		FlxG.stage.removeEventListener(Event.RESIZE, onResize);
		removeEventListener(Event.ENTER_FRAME, update);
	}
}
