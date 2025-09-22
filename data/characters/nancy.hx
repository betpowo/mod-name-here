import funkin.backend.utils.AudioAnalyzer;

var self = this;
var speakers = new FlxSprite();
var speakerBacking = new FlxSprite();
var viz = new FlxSprite();
var megaphones = [new FlxSprite(), new FlxSprite()];
var vizShader = new FunkinShader('
    #pragma header

	uniform sampler2D vizBitmap;
	uniform sampler2D vizColor;
	uniform float vizColorWidth;
	uniform float widthRatio;
	uniform float vizOffset;

	vec4 getAmpColor(float val) {
		vec4 res = vec4(0.0, 0.0, 0.0, clamp(val * vizColorWidth, 0.0, 1.0));
        res.rgb = mix(  flixel_texture2D(vizColor, vec2(floor(val * vizColorWidth) / vizColorWidth, 0.5)),
                        flixel_texture2D(vizColor, vec2(ceil(val * vizColorWidth) / vizColorWidth, 0.5)),
                        smoothstep(0.0, 0.9, fract(val * vizColorWidth))).rgb * res.a;
		return res;
	}

    void main() {
        vec2 uv = getCamPos(openfl_TextureCoordv);

        vec4 ogColor = textureCam(bitmap, uv);  
        vec4 color = ogColor;

		float o = abs(uv.x - 0.5) * 2.0;
		float burp = (mix(((uv.x-0.5)*0.9)+0.5, uv.x, o*o) + vizOffset) * widthRatio;
		float uvy = uv.y;
		float __uvy = uvy;
		uvy -= 0.5;
		uvy *= 1.1;
		uvy += 0.5;
		uvy = mix(__uvy, uvy, o * o * o);
		if (burp != clamp(burp, 0.0, 1.0)) {
			gl_FragColor = vec4(0.0);
			return;
		}

		gl_FragColor = flixel_texture2D(vizBitmap, vec2(burp, uvy));
		gl_FragColor = getAmpColor(gl_FragColor.b);
		gl_FragColor *= color.a;
    }
');

function postCreate() {
	var abotFrames = Paths.getFrames('characters/abot-speakers');

	speakers.frames = abotFrames;
	speakers.animation.addByPrefix('bump', 'speakers', 24, false);
	speakers.animation.play('bump', true);
	speakers.antialiasing = self.antialiasing;
	speakers.updateHitbox();
	speakers.offset.set(10, -15);

	speakerBacking.makeSolid(500, 300, 0xFF1a5762);
	speakerBacking.updateHitbox();

	for (idx => i in megaphones) {
		i.frames = abotFrames;
		i.animation.addByPrefix('idle', 'megaphone', 24, true);
		i.animation.play('idle', true);
		i.antialiasing = self.antialiasing;
		i.ID = idx;
		i.updateHitbox();
		i.origin.x += -10;
		i.origin.y += 25;

		if (idx == 1)
			i.angle = 20;
	}

	importScript('data/scripts/nancy-viz');

	viz.frames = abotFrames;
	viz.animation.addByPrefix('idle', 'viz', 24, true);
	viz.animation.play('idle', true);
	viz.antialiasing = self.antialiasing;
	viz.updateHitbox();

	vizShader.widthRatio = vizWidth / vizSprite.width;

	var vizb = Assets.getBitmapData(Paths.image('characters/abot-viz-map'));
	vizShader.data.vizBitmap.input = vizSprite.pixels;
	vizShader.data.vizColor.input = vizb;
	vizShader.vizColorWidth = vizb.width;
	vizShader.vizOffset = 0;

	// trace(vizShader.levels);

	viz.shader = vizShader;
}

var toAdd:Bool = true; // Using this just to make sure

function update(elapsed) {
	if (PlayState.instance == null)
		return;

	if (toAdd) {
		toAdd = false;
		var index = PlayState.instance.members.indexOf(self);

		// from top to bottom!
		for (i in megaphones) {
			PlayState.instance.insert(index, i);
		}

		PlayState.instance.insert(index, speakers);
		PlayState.instance.insert(index, viz);
		// PlayState.instance.insert(index, vizSprites);
		PlayState.instance.insert(index, speakerBacking);

		// disableScript();
	}
	speakers.setPosition(self.getMidpoint().x - speakers.width * 0.5, self.y + self.height + self.globalOffset.y - 50);
	speakers.scrollFactor.set(self.scrollFactor.x, self.scrollFactor.y);

	speakerBacking.setPosition(speakers.x + 175, speakers.y + 50);
	speakerBacking.scrollFactor.set(speakers.scrollFactor.x, speakers.scrollFactor.y);

	for (i in megaphones) {
		i.setPosition(speakers.x + 740, speakers.y + 74);

		if (i.ID == 1) {
			i.x += 10;
			i.y += 150;
		}

		i.scrollFactor.set(speakers.scrollFactor.x, speakers.scrollFactor.y);

		i.colorTransform = self.colorTransform;

		i.blend = self.blend;
	}

	// vizSprites.setPosition(speakers.x + 212, speakers.y + 100);
	// vizSprites.scrollFactor.set(speakers.scrollFactor.x, speakers.scrollFactor.y);

	viz.setPosition(speakers.x + 212, speakers.y + 100);
	viz.scrollFactor.set(speakers.scrollFactor.x, speakers.scrollFactor.y);
	speakerBacking.colorTransform = viz.colorTransform = speakers.colorTransform = self.colorTransform;
	speakerBacking.blend = viz.blend = speakers.blend = self.blend;
	speakerBacking.alpha = viz.alpha = speakers.alpha = self.alpha;
	speakerBacking.color = viz.color = speakers.color = self.color;

	updateViz(Conductor.songPosition);

	var game = PlayState.instance;
	var h = game.health;

	if (!game.canDie)
		h = 1;
	if (game.canDadDie)
		h = 2 - h;

	// trace(h);

	animation._animations.get('prepare').flipX = game.canDadDie;

	if (h <= 0.5 && getAnimName() == 'idle') {
		playAnim('prepare', true);
	} else if (h > 0.5 && getAnimName() == 'prepare') {
		playAnim('cancel', true);
	}

	FlxG.camera.targetOffset.y = (getAnimName() == 'prepare' && h > 0) ? -150 : 0;
}

function beatHit() {
	speakers.animation.play('bump', true);
}

function updateViz(time) {
	for (i in megaphones) {
		var sc = FlxMath.lerp(1, 1.1, PlayState.instance.inst.amplitude ?? 0);
		i.scale.set(sc, sc);
	}

	var o = 1 / PlayState.instance.inst.length;
	vizShader.vizOffset = ((1 / vizShader.widthRatio) * (Conductor.songPosition / PlayState.instance.inst.length)) - 1;
	vizShader.vizOffset = Math.floor(vizShader.vizOffset * vizWidth) / vizWidth;
}
