package objects;
import backend.EasyJson;

class Window extends FlxSpriteGroup {
	// 변수들임.
	var mainWin:FlxSprite;
	var contents:FlxSpriteGroup;
	var offset:Float;
	var dimBG:FlxSprite;
	var cam:FlxCamera;

	var doAutoMove:Bool = false;

	var posMap:EasyJson;

	public function new(winImage:String, offsetF:Float, autoMove:Bool, hasDim:Bool) {
		super();

		this.offset = offsetF;
		
		mainWin = new FlxSprite(0,0).loadGraphic(Paths.image(winImage));
		mainWin.antialiasing = ClientPrefs.data.antialiasing;
		mainWin.updateHitbox();
		add(mainWin);
		
		posMap = new EasyJson('${winImage}Set');

		if (hasDim) {
			//반투명배경
			dimBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			dimBG.alpha = 0.5;
			dimBG.cameras = [FlxG.camera];
			add(dimBG);
		}
		
		contents = new FlxSpriteGroup();
		add(contents);

		if (autoMove) { 
			doAutoMove = true;
			screenCenter();
		}
		refreshCam();
	}

	public function refreshWin() {
		if (doAutoMove) {
			screenCenter();
			contents.x = mainWin.x + mainWin.width - contents.width;
			contents.y = mainWin.y + offset;
		}
	}
	public function refreshCam() {
		if (cam != null) {
			cam.x = mainWin.x;
			cam.y = mainWin.y + offset;
			cam.width = mainWin.width;
			cam.height = mainWin.height - offset;
		}
		else {
			cam = new FlxCamera(mainWin.x, mainWin.y + offset, mainWin.width, mainWin.height - offset);
			cam.bgColor = 0x00000000; // 창 배경이 그대로 보이도록 투명 처리
			FlxG.cameras.add(cam, false);
		}
	}
	
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
	
	public function addItem(name:String, sprite:FlxSprite) {
		contents.add(sprite);
		var pos:Dynamic = posMap.get(name);
		sprite.x = pos[0];
		sprite.y = pos[1];
	}
}
