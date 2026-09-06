package objects;

import backend.EasyJson;

class EnemyListCharacter extends FlxSprite {
	var charName:String;

	public function new(characterName:String) {
		super();
		charName = characterName;

		var charJson = new EasyJson(Paths.getPath('characters/$charName.json', TEXT));
		var animations:Array<Map<String, Dynamic>> = charJson.get('animations');
		var idleAnim:Map<String, Dynamic> = Lambda.find(animations, a -> a['anim'] == 'idle');

		this.frames = Paths.getSparrowAtlas(charJson.get('image'));
		this.animation.addByPrefix("idle", "idle", idleAnim['fps'], idleAnim['loop']);
		this.animation.play("idle");
		this.setGraphicSize(80, 80);
		this.updateHitbox();
	}
}
