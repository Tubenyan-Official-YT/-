package objects;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import flixel.FlxG;
import states.PlayState;

class GlobalOverlay extends Sprite
{
	public static var instance:GlobalOverlay;
	public var topBitmap:Bitmap;
	public var downBitmap:Bitmap;

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
	}
}
