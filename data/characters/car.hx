var self = this;
var speakers = new FlxSprite();
function postCreate() {
	speakers.frames = self.frames;
	speakers.animation.addByPrefix('idle', 'car', 0, false);
	speakers.animation.play('idle', true);
	speakers.antialiasing = self.antialiasing;
	speakers.offset.set(280, -8);
}

var toAdd:Bool = true;  // Using this just to make sure
function update(elpased) {
	if(toAdd) {
		toAdd = false;
		PlayState.instance.insert(PlayState.instance.members.indexOf(self), speakers);
		//disableScript();
	}
	speakers.setPosition(self.x + self.globalOffset.x, self.y + self.globalOffset.y);
	speakers.scrollFactor.set(self.scrollFactor.x, self.scrollFactor.y);
}

function onPlayAnim(e) {
	if (e.animName == 'die') {
		speakers.visible = false;
	}
}