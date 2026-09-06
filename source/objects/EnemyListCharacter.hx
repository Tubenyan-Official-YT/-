package objects;

class EnemyListCharacter extends FlxSprite {
	var charName:String;

	public function new(characterName:String) {
		super();
		charName = characterName;

		var charJson = new EasyJson(Paths.getPath('characters/$charName.json', TEXT));
		var idleAnim:Dynamic = Lambda.find(charJson.get('animations'), a -> a['anim'] == 'idle');

		this.frames = Paths.getSparrowAtlas(charJson.get('image'));
		this.animation.addByPrefix("idle", "idle", idleAnim['fps'], idleAnim['loop']);
		this.animation.play("idle");
		this.setGraphicSize(80, 80);
		this.updateHitbox();
	}
}
