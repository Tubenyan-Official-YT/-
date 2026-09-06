package objects;

class EnemyList extends Window {
	var image:FlxSprite;
	var list:EnemyListGroup;
	public function new(name:String) {
		super("enemyListWin", 30, true, false);
		
		list = new EnemyListGroup(name, 90);
		addItem("screenCenter", list);
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
