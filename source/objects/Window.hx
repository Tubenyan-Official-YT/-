package objects;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;

/**
 * 재사용 가능한 "창" 객체.
 * 배경 이미지를 불러오고, 화면 중앙에 배치한 뒤,
 * 창 넓이 그대로(위쪽 오프셋만 뺀 만큼) 잘라 보여주는 전용 카메라를 자동 생성/정리해준다.
 *
 * 사용 예:
 *   var win = new Window('optionBG', 120); // 위쪽 120px만 오프셋으로 뺌
 *   add(win);
 *   win.content.add(someButton); // 창 내부에 넣을 것들은 content에 추가
 *   someOtherSubstate.cameras = [win.cam];
 *   ...
 *   win.destroyCam(); // 서브스테이트/스테이트 destroy 시 호출
 */
class Window extends FlxSpriteGroup
{
	/** 창 배경 스프라이트 */
	public var background:FlxSprite;

	/** 창 내부에 넣을 컨텐츠 그룹 (버튼, 텍스트 등) */
	public var content:FlxSpriteGroup;

	/** 창 내부(위쪽 오프셋 아래)만 잘라 보여주는 전용 카메라 */
	public var cam:FlxCamera;

	// 위쪽 오프셋값 (생성 시 넘긴 값 저장, 나중에 재계산할 때 사용)
	var topOffset:Float;

	/**
	 * @param imageKey     Paths.image()로 불러올 배경 이미지 키 (예: 'optionBG')
	 * @param topOffset    카메라 위쪽에서 뺄 여백 (창 제목/여백 등 가리고 싶은 만큼)
	 * @param autoCenter   true면 생성 시 화면 중앙으로 자동 정렬
	 */
	public function new(imageKey:String, topOffset:Float = 0, autoCenter:Bool = true)
	{
		super();

		this.topOffset = topOffset;

		background = new FlxSprite(0, 0).loadGraphic(Paths.image(imageKey));
		background.antialiasing = ClientPrefs.data.antialiasing;
		background.updateHitbox();
		add(background);

		content = new FlxSpriteGroup();
		add(content);

		if (autoCenter)
			screenCenter();

		createCam();
	}

	/**
	 * 현재 창 위치/크기 기준으로 전용 카메라를 (재)생성한다.
	 * 창을 이동시킨 뒤 카메라 위치를 다시 맞추고 싶을 때 호출.
	 * 카메라는 창 넓이 그대로, 위쪽만 topOffset만큼 뺀 영역을 잘라 보여준다.
	 */
	public function createCam()
	{
		destroyCam(); // 기존 카메라 있으면 정리하고 새로 만듦

		var camX:Int = Std.int(x);
		var camY:Int = Std.int(y + topOffset);
		var camW:Int = Std.int(background.width);
		var camH:Int = Std.int(background.height - topOffset);

		cam = new FlxCamera(camX, camY, camW, camH);
		cam.bgColor = 0x00000000; // 창 배경이 그대로 보이도록 투명 처리
		FlxG.cameras.add(cam, false);
	}

	/**
	 * 창을 옮긴 뒤(예: screenCenter 재호출) 카메라 위치를 다시 맞추고 싶을 때 호출.
	 * createCam()을 다시 부르는 것과 동일하지만 의미가 더 명확함.
	 */
	public function refreshCam()
	{
		createCam();
	}

	/**
	 * 이 창이 쓰던 전용 카메라를 제거한다.
	 * 옵션 서브스테이트처럼 destroy() 시점에 반드시 호출해줘야 카메라가 계속 쌓이지 않음.
	 */
	public function destroyCam()
	{
		if (cam != null)
		{
			FlxG.cameras.remove(cam, true);
			cam = null;
		}
	}

	override function destroy()
	{
		destroyCam();
		super.destroy();
	}
}
