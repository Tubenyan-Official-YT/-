package objects;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import states.PlayState;

class GlobalOverlay extends FlxBasic
{
	public static var instance:GlobalOverlay;
	public var sprite:FlxSprite;
	public var downSprite:FlxSprite;

	public function new()
	{
		super();
		instance = this;

		// 표시할 오브젝트 생성 및 설정
		sprite = new FlxSprite(0, 0).loadGraphic(Paths.image('overlay/topOverlay')); // 원하는 이미지 경로 지정
		sprite.scrollFactor.set(0, 0); // 화면 고정

		downSprite = new FlxSprite(0,0).loadGraphic(Paths.image('overlay/downOverlay'));
		downSprite.y = FlxG.height - downSprite.height;
		downsprite.scrollFactor.set(0, 0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (sprite != null && sprite.active)
			sprite.update(elapsed);
	}

	override public function draw()
	{
		super.draw();
		// 현재 스테이트가 PlayState가 아닐 때만 화면에 출력
		if (sprite != null && sprite.visible && !(FlxG.state is PlayState))
		{
			sprite.draw();
		}
	}
}
