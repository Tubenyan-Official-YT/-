package objects;
import backend.EasyJson;
import haxe.DynamicAccess;
class EnemyListCharacter extends FlxSprite {
	var charName:String;
	public function new(characterName:String) {
		super();
		charName = characterName;
		var charJson = new EasyJson(Paths.getPath('characters/$charName.json', TEXT));
		var animations:Array<DynamicAccess<Dynamic>> = charJson.get('animations');
		var idleAnim:DynamicAccess<Dynamic> = Lambda.find(animations, a -> a['anim'] == 'idle');
		if (idleAnim == null && animations.length > 0) idleAnim = animations[0];
		this.frames = Paths.getSparrowAtlas(charJson.get('image'));
		this.animation.addByPrefix("idle", "idle", idleAnim['fps'], idleAnim['loop']);
		this.animation.play("idle");
		this.setGraphicSize(80, 80);
		this.updateHitbox();
	}
}
