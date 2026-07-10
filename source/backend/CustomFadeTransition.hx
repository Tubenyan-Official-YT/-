package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.transition.FlxTransitionableState;
import backend.Paths;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var leftDoor:FlxSprite;
	var rightDoor:FlxSprite;
	
	var duration:Float;
	var transCamera:FlxCamera; // 트랜지션 전용 카메라 변수 추가

	public function new(duration:Float, isTransIn:Bool)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		super();
	}

	override function create()
	{
		// 1. 기존 카메라를 가져오지 않고, 항상 최상단에 그려질 독립 카메라를 새로 생성하여 추가합니다.
		transCamera = new FlxCamera();
		transCamera.bgColor = FlxColor.TRANSPARENT; // 배경은 투명하게 설정
		FlxG.cameras.add(transCamera, false);
		cameras = [transCamera];

		var fullWidth:Int = Std.int(FlxG.width / Math.max(transCamera.zoom, 0.001));
		var fullHeight:Int = Std.int(FlxG.height / Math.max(transCamera.zoom, 0.001));
		var width:Int = Std.int(fullWidth / 2) + 4;

		leftDoor = new FlxSprite();
		leftDoor.loadGraphic(Paths.image('fade/leftDoor'));
		leftDoor.setGraphicSize(width, fullHeight); // 정확한 픽셀 크기 조절
		leftDoor.updateHitbox();
		leftDoor.scrollFactor.set();
		leftDoor.y = (fullHeight / 2) - (leftDoor.height / 2);
		add(leftDoor);

		rightDoor = new FlxSprite();
		rightDoor.loadGraphic(Paths.image('fade/rightDoor'));
		rightDoor.setGraphicSize(width, fullHeight); // 정확한 픽셀 크기 조절
		rightDoor.updateHitbox();
		rightDoor.scrollFactor.set();
		rightDoor.y = (fullHeight / 2) - (rightDoor.height / 2);
		add(rightDoor);

		if (isTransIn) {
			leftDoor.x = fullWidth / 2 - leftDoor.width;
			rightDoor.x = fullWidth / 2;
			FlxTween.tween(leftDoor, {x: -leftDoor.width}, duration, {ease: FlxEase.quadInOut});
			FlxTween.tween(rightDoor, {x: fullWidth}, duration, {ease: FlxEase.quadInOut, onComplete: function(_) close()});
		}
		else {
			leftDoor.x = -leftDoor.width;
			rightDoor.x = fullWidth;
			FlxTween.tween(leftDoor, {x: fullWidth / 2 - leftDoor.width}, duration, {ease: FlxEase.quadInOut});
			FlxTween.tween(rightDoor, {x: fullWidth / 2}, duration, {ease: FlxEase.quadInOut, onComplete: function(_) close()});
		}
		super.create();
	}

	override function close():Void
	{
		super.close();

		if(finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}

	// 2. 메모리 누수 및 새 스테이트에서 카메라가 무한히 쌓이는 현상을 막기 위해 destroy를 오버라이드합니다.
	override function destroy()
	{
		super.destroy();
		if (transCamera != null) {
			FlxG.cameras.remove(transCamera); // 사용이 끝난 트랜지션 카메라 제거
		}
	}
}
