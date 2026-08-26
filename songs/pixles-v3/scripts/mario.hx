import flixel.effects.FlxFlicker;

class MarioAction {
    public var name:String;
    public function new(?n:String) { name = n; }
    public var justFinished:Bool = false;
    public var timer(default, set):Float = -1;
    public function set_timer(v:Float):Float {
        justFinished = false;
        if (v <= 0 && timer > 0) justFinished = true;
        return timer = v;
    }
    public var extra:Float = 0;
    public function start(time:Float, ?extr:Float) {
        timer = time;
        extra = extr ?? 0;
    }
    public function update(elapsed:Float) {
        timer -= elapsed;
    }
    public var active(get, null):Bool;
    public function get_active():Bool {
        return timer > 0;
    }
    public function toString():String {
        return 'MarioAction($name, $timer)';
    }
}

class Mario extends FunkinSprite {
    public var states = {
        move: new MarioAction('move'),
        crouch: new MarioAction('crouch'),
        jump: new MarioAction('jump'),
    };
    public var red(default, set):FlxColor = 0xf73910;
    public var green(default, set):FlxColor = 0xffb762;
    public var blue(default, set):FlxColor = 0x8c7318;
    public function set_red(v:FlxColor):FlxColor { shader?.r = getRGBArray(v); return red = v; }
    public function set_green(v:FlxColor):FlxColor { shader?.g = getRGBArray(v); return green = v; }
    public function set_blue(v:FlxColor):FlxColor { shader?.b = getRGBArray(v); return blue = v; }

    public var fat(default, set):Float = 800;
    public function set_fat(v:Float):Float {
        acceleration.y = v * size;
        return fat = v;
    }
    public function new(x, y) {
        super(x, y);
        loadGraphic(Paths.image('mario-rgb'), true, 16, 16);
        animation.add('idle', [0], 0, true);
        animation.add('crouch', [1], 0, true);
        animation.add('walk', [2, 3, 4], 14, true);
        animation.add('jump', [5], 0, true);
        playAnim('idle', true);
        updateHitbox();
        shader = new CustomShader('rgbPalette');
        shader.mult = 1;
        red=red;green=green;blue=blue;
        moves = true;
        size = 1;
        maxVelocity.x = 500;
        maxVelocity.y = 2000;
        drag.x = 3000;
    }
    public var size(default, set):Float = 1;
    public var floorLevel:Float = FlxG.height * 1.1;
    public function set_size(v:Float):Float {
        // half because the texture is 2x
        scale.set(v, v);
        updateHitbox();
        fat = fat;
        return size = v;
    }
    var elapsedTime:Float = -1.2;
    override public function update(elapsed) {
        super.update(elapsed);
        final sizeFactor = (size / 6);
        final jumpVel = -900;
        elapsedTime += elapsed;
        if (y + height > floorLevel) {
            y = floorLevel - height;
            velocity.y = 0;
            if (states.jump.extra != 0) {
               states.jump.extra = 0;
               if (Math.abs(velocity.x) <= 30) playAnim('idle');
            }
        }
        if (elapsedTime < 0) return;
        if (FlxG.random.bool(elapsed * 180)) {
            var action = FlxG.random.getObject([states.move, states.move, states.move, states.crouch, states.jump]);
            var duration = Math.min(action.timer, FlxG.random.float(0.1, 1.25));
            switch(action.name) {
                case 'jump':
                    if (states.jump.extra != 1) {
                        velocity.y = jumpVel * sizeFactor;
                        y += velocity.y * elapsed;
                        duration = FlxG.random.float(0.05, 0.2);
                        if (states.crouch.active) duration = elapsed;
                        playAnim('jump', true);
                        states.jump.extra = 1;
                    } else {
                        duration = states.jump.timer;
                    }
                case 'crouch': if (states.jump.active) duration = 0; else duration = FlxG.random.float(0.05, 0.5);
                case 'move': duration = 0.54;
            }
            action.start(duration, (action.name == 'move') ? FlxG.random.sign() : (action.name == 'jump' ? 1 : 0));
        }
        
        if (!states.crouch.active) {
            if (states.move.active) {
                acceleration.x = maxVelocity.x * 3.4 * states.move.extra * sizeFactor;
                if (states.jump.extra != 1) {
                    flipX = states.move.extra < 0;
                    playAnim('walk');
                }
            } else if (states.move.justFinished) {
                acceleration.x = 0;
            }
        }

        // i cant do else otherwise walking doesnt work
        if (states.crouch.active) {
            acceleration.x = 0;
            if (states.jump.extra != 1) {
                playAnim('crouch');
                if (states.move.active) {
                    flipX = states.move.extra < 0;
                }
            }
        } else if ((Math.abs(velocity.x) <= 30) && (states.jump.extra != 1)) {
            playAnim('idle');
        }
        
        if (states.jump.active) {
            velocity.y = jumpVel * sizeFactor;
        }

        states.move.update(elapsed);
        states.jump.update(elapsed);
        states.crouch.update(elapsed);
    }
}

// there needs to be a better way to sort brah
final backMarios = [];
final midMarios = [];
final frontMarios = [];

var fadeSprite = new FunkinSprite();
function postCreate() {
    var m = new Mario(650, -1800);
    m.size = 6;
    m.elapsedTime = -2.7;
    m.fat = 800;
    insert(members.indexOf(gf) + 1, m);
    midMarios.push(m);

    fadeSprite.zoomFactor = 0;
    fadeSprite.scrollFactor.set();

    fadeSprite.makeSolid(camGame.width, camGame.height, 0xffffffff);
    fadeSprite.updateHitbox();
    fadeSprite.color = 0x000000;
    fadeSprite.blend = BlendMode.SUBTRACT;

    fadeSprite.camera = camHUD;
}
var spawnedLuigi = false;
function spawnMario() {
    var m = new Mario(FlxG.random.int(20, FlxG.width + 100), -1000);
    m.elapsedTime = -1.2;
    m.size = FlxMath.lerp(2, 12, Math.pow(FlxG.random.float(0, 1), 2.0));
    m.fat = 800;
    if (spawnedLuigi != (spawnedLuigi = true)) {
        m.size = 6;
        m.red = 0xeeeeee;
        m.blue = 0x1a912e;
    } else {
        m.red = FlxColor.fromHSB(FlxG.random.int(0, 360), FlxG.random.float(0.4, 0.9), FlxG.random.float(0.1, 0.8));
        m.green = FlxColor.fromHSB(FlxG.random.int(0, 360) + 180, FlxG.random.float(0.0, 0.3), FlxG.random.float(0.9, 1.0));
        m.blue = FlxColor.fromHSB(FlxG.random.int(0, 360), FlxG.random.float(0.7, 1.0), FlxG.random.float(0.2, 1.0));

        m.fat *= (m.size / 6) * FlxG.random.float(0.5, 2);
    }
    m.zoomFactor = m.size / 6;
    m.scrollFactor.set(m.zoomFactor, m.zoomFactor);
    m.floorLevel *= m.zoomFactor;
    
    var array = if (m.zoomFactor < 0.96) backMarios
                else if (m.zoomFactor < 1.1) midMarios
                else frontMarios;

    array.push(m);
    array.sort((a, b) -> {
        return a.zoomFactor - b.zoomFactor;
    });

    for (x => i in array) {
        remove(i);
        if (array == backMarios) insert(x, i);
        else if (array == midMarios) insert(members.indexOf(gf) + 1 + x, i);
        else insert(members.indexOf(boyfriend) + 1 + x, i);
    }

    if (Options.flashingMenu) FlxFlicker.flicker(m, 1, 0.05, true);
}

function fadeOut() {
    insert(0, fadeSprite);
    FlxTween.tween(fadeSprite.colorTransform, {greenMultiplier: 0.5, blueMultiplier: 0.5}, 0.5, {ease: FlxEase.sineIn})
            .then(FlxTween.tween(fadeSprite.colorTransform, {redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1}, 1));
}