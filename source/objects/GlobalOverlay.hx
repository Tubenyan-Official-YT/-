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
		logMsg('constructor start');

		var topGraphic = Paths.image('overlay/topOverlay');
		logMsg('topGraphic = ' + topGraphic);
		if (topGraphic != null)
			addChild(topBitmap = new Bitmap(topGraphic.bitmap));

		var downGraphic = Paths.image('overlay/downOverlay');
		logMsg('downGraphic = ' + downGraphic);
		if (downGraphic != null)
		{
			addChild(downBitmap = new Bitmap(downGraphic.bitmap));
			downBitmap.y = FlxG.height - downBitmap.height;
		}

		logMsg('FlxG.game = ' + FlxG.game + ', FlxG.stage = ' + FlxG.stage);

		if (FlxG.game != null)
			FlxG.game.addChild(this);
		else
			logMsg('ERROR: FlxG.game is null!');

		if (FlxG.stage != null)
			FlxG.stage.addEventListener(Event.RESIZE, onResize);
		else
			logMsg('ERROR: FlxG.stage is null!');

		addEventListener(Event.ENTER_FRAME, update);
		onResize(null);
		logMsg('constructor end, visible = ' + visible + ', x=' + x + ', y=' + y + ', scaleX=' + scaleX);
	}

	function update(e:Event)
	{
		// 발전과제 팝업 원리: 매 프레임 현재 스테이트 체크해서 타이틀/플레이스테이트만 제외하고 표시
		visible = !(Std.isOfType(FlxG.state, TitleState) || Std.isOfType(FlxG.state, PlayState));

		// Flixel이 내부적으로 추가하는 캔버스/카메라 자식들에 가려지지 않도록 매 프레임 맨 위로 유지
		if (FlxG.game != null && FlxG.game.numChildren > 0 && FlxG.game.getChildIndex(this) != FlxG.game.numChildren - 1)
			FlxG.game.setChildIndex(this, FlxG.game.numChildren - 1);
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
		if (FlxG.game.contains(this))
			FlxG.game.removeChild(this);
		FlxG.stage.removeEventListener(Event.RESIZE, onResize);
		removeEventListener(Event.ENTER_FRAME, update);
	}
}
