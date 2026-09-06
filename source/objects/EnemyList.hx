package objects;

class EnemyList extends Window {
	var image:FlxSprite;

	public function new(paths:String) {
		super("enemyListWin", 30, true, false);

		image = new FlxSprite(0, 0).loadGraphic(Paths.currentTrackedAssets.get(paths));
		addItem("screenCenter", image);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this)) {
			close();
		}
	}

	public function close() {
		destroyCam();
		if (FlxG.state != null) FlxG.state.remove(this, true);
		destroy();
	}
}
