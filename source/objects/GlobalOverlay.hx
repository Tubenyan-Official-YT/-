package objects;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import flixel.FlxG;
import states.TitleState;
import states.PlayState;

class GlobalOverlay extends Sprite
{
	public static var instance:GlobalOverlay;
	public var topBitmap:Bitmap;
	public var downBitmap:Bitmap;

	var lastScale:Float = 1;

	public function new()
	{
		super();
		instance = this;

		var topGraphic = Paths.image('overlay/topOverlay');
		if (topGraphic != null)
			addChild(topBitmap = new Bitmap(topGraphic.bitmap));

		var downGraphic = Paths.image('overlay/downOverlay');
		if (downGraphic != null)
		{
			addChild(downBitmap = new Bitmap(downGraphic.bitmap));
			downBitmap.y = FlxG.height - downBitmap.height;
		}

		FlxG.game.addChild(this);

		FlxG.stage.addEventListener(Event.RESIZE, onResize);
		addEventListener(Event.ENTER_FRAME, update);
		onResize(null);
	}

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
		if (FlxG.game.contains(this))
			FlxG.game.removeChild(this);
		FlxG.stage.removeEventListener(Event.RESIZE, onResize);
		removeEventListener(Event.ENTER_FRAME, update);
	}
}
