package backend;

// 필수 임포트 목록
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.transition.FlxTransitionableState; // 서브스테이트 처리를 위해 필요할 수 있음
import backend.Paths; // 프나펑 에셋 경로 관리를 위해 필수

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var leftDoor:FlxSprite;
	var rightDoor:FlxSprite;
	
	var duration:Float;
	public function new(duration:Float, isTransIn:Bool)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		super();
	}

	override function create()
	{
    	cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
    	var fullWidth:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
    	var fullHeight:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));
    	var width:Int = Std.int(fullWidth / 2) + 4;

    	leftDoor = new FlxSprite();
    	leftDoor.loadGraphic(Paths.image('fade/leftDoor'));
    	leftDoor.updateHitbox();
    	leftDoor.scrollFactor.set();
    	leftDoor.y = (fullHeight / 2) - (leftDoor.height / 2);
    	add(leftDoor);

    	rightDoor = new FlxSprite();
    	rightDoor.loadGraphic(Paths.image('fade/rightDoor'));
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

	// Don't delete this
	override function close():Void
	{
		super.close();

		if(finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}
}
