import flixel.util.FlxSignal1;
class CustomGroup extends flixel.FlxSprite {
    var length(get, null):Int;
    function get_length():Int return members.length;

    public var memberAdded:FlxSignal1 = new FlxSignal1();
    public var memberRemoved:FlxSignal1 = new FlxSignal1();

	public var members = [];
	public function add(a)       { members.push(a); a.ID = length - 1; memberAdded.dispatch(a);   }
	public function insert(x, a) {                                     memberRemoved.dispatch(a);               members.insert(x, a); }
	public function remove(a, s) {                                     memberRemoved.dispatch(a);               members.remove(a, s); }
	public function new(t, d, objects) {
		super();
		for(i in objects) {
			i.x = 0;
			add(i);
		}
	}
	public override function update(elapsed) {
		var elapsed = elapsed;
		super.update(elapsed);
		forEachAlive((bleh) -> { bleh.update(elapsed); });
	}
	public override function draw() {
		forEachAlive((bleh) -> { if (bleh.visible) bleh.draw(); });
	}

	public function forEach(f) {
		for (i in members) {
			if (i != null) f(i);
		}
	}
	public function forEachAlive(f) {
		for (i in members) {
			if (i == null || !i.alive || !i.exists) continue;
			f(i);
		}
	}
    public override function set_x(v:Float):Float {
        var d = v - x;
        forEachAlive((a) -> {a.x += d;});
        return x = v;
    }
    public override function set_y(v:Float):Float {
        var d = v - y;
        forEachAlive((a) -> {a.y += d;});
        return y = v;
    }
    override function destroy() {
		while (members.length > 0) {
			members[0].kill();
			members.remove(members[0], true);
			members[0].destroy();
		}
		super.destroy();
	}
}
