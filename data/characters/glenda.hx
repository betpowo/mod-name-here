var self = this;
var speakers = new FlxSprite();
function postCreate() {
	speakers.frames = Paths.getFrames('characters/speakers');
	speakers.animation.addByPrefix('bump', 'speakers', 24, false);
	speakers.animation.play('bump', true);
	speakers.antialiasing = self.antialiasing;
	speakers.updateHitbox();
	speakers.offset.set(-10, 0);
}

var toAdd:Bool = true;  // Using this just to make sure
function update(elpased) {
	if(toAdd) {
		toAdd = false;
		PlayState.instance.insert(PlayState.instance.members.indexOf(self), speakers);
		//disableScript();
	}
	speakers.setPosition(self.getMidpoint().x - speakers.width * 0.5, self.y + self.height + self.globalOffset.y - 111);
	speakers.scrollFactor.set(self.scrollFactor.x, self.scrollFactor.y);
	speakers.colorTransform = self.colorTransform;
	speakers.blend = self.blend;
	speakers.alpha = self.alpha;
	speakers.color = self.color;
}

function beatHit() {
	speakers.animation.play('bump', true);
}