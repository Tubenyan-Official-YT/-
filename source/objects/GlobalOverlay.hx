package objects;

import flixel.FlxCamera;
import flixel.FlxG;

/**
 * 화면 위/아래를 CROP_SIZE만큼 잘라내는 카메라.
 * 풀스크린 보조 카메라(camHUD, camOther 등)를 새로 만들 때 `new FlxCamera()` 대신
 * 이걸 쓰면 자동으로 위/아래가 잘린 뷰포트를 가지게 됨.
 * (기본 카메라 크롭은 MusicBeatState.initPsychCamera()에서 cropOverlay 플래그로 처리)
 */
class GlobalOverlay extends FlxCamera
{
	public static inline var CROP_SIZE:Float = 60;

	public function new(X:Int = 0, Y:Int = 0, Width:Int = 0, Height:Int = 0, Zoom:Float = 0)
	{
		var w:Int = (Width > 0) ? Width : FlxG.width;
		var h:Int = (Height > 0) ? Height : FlxG.height;
		super(X, Y + Std.int(CROP_SIZE), w, Std.int(h - CROP_SIZE * 2), Zoom);
	}
}
