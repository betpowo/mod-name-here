import flixel.util.FlxSignal1;
class CustomTrail extends FlxSprite {
    public var parent;
    public var members = [];
    public var memberAdded:FlxSignal1 = new FlxSignal1();
    public var memberRemoved:FlxSignal1 = new FlxSignal1();
    private var __intervalTimer:Float = -1;
    public var interval:Float = 0.1;
    public var alphaStep:Float = 0.2;
    public function new(parent:FlxSprite) {
        super();
        this.parent = parent;
    }
    public override function update(elapsed) {
		var elapsed = elapsed;
		super.update(elapsed);
        x = parent.x;
        y = parent.y;
        __intervalTimer -= elapsed;
        if (__intervalTimer <= 0) {
            __intervalTimer = interval;

            // cant use FunkinSprite.copyFrom , animOffsets.copy messes up point pool
            final trail = new FunkinSprite();
			trail.setPosition(parent.x, parent.y);
			trail.frame = parent.frame;
			trail.antialiasing = parent.antialiasing;
			trail.scale.set(parent.scale.x, parent.scale.y);
			trail.updateHitbox();
			trail.offset.set(parent.offset.x, parent.offset.y);
            trail.frameOffset.set(parent.frameOffset.x, parent.frameOffset.y);
            trail.scrollFactor.set(parent.scrollFactor.x, parent.scrollFactor.y);
			trail.skew.set(parent.skew.x, parent.skew.y);
			trail.zoomFactor = parent.zoomFactor;
			trail.angleFactor = parent.angleFactor;
            trail.shader = parent.shader;
			final ct = parent.colorTransform;
			trail.setColorTransform(ct.redMultiplier, ct.greenMultiplier, ct.blueMultiplier, ct.alphaMultiplier,
									ct.redOffset, ct.greenOffset, ct.blueOffset, ct.alphaOffset);
			trail.color = parent.color;
			trail.alpha = parent.alpha;
            members.push(trail);
            memberAdded.dispatch(trail);

            var i = 0;
            while (i < members.length) {
                var bleh = members[i];
                bleh.alpha -= alphaStep;
                if (bleh.alpha <= 0) {
                    memberRemoved.dispatch(bleh);
                    members.remove(bleh, true);
                    bleh.destroy();
                } else {
                    i += 1;
                }
            }
        }
		forEachAlive((bleh) -> { if (bleh.active) bleh.update(elapsed); });
	}
	public override function draw() {
		forEachAlive((bleh) -> { if (bleh.visible) bleh.draw(); });
	}
	public function forEach(f) {
		for (i in members) {
			f(i);
		}
	}
	public function forEachAlive(f) {
		for (i in members) {
			if (!i.alive || !i.exists) continue;
			f(i);
		}
	}
}