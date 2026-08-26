import funkin.backend.system.Control;
import funkin.backend.TurboControls;
import funkin.backend.TurboBasic;
import funkin.options.type.OptionType;
import funkin.options.ITreeOption;
import funkin.options.ITreeFloatOption;
import funkin.options.PlayerSettings;
import flixel.input.FlxPointer;
import flixel.util.FlxSignal0;
import flixel.util.FlxSignal1;
import funkin.options.type.Separator;
// heh
class CustomTreeScreen extends flixel.FlxSprite {
    public var inputEnabled = false;
    // kms
    var leftTurboControl:TurboControls = new TurboControls([Control.LEFT]);
	var rightTurboControl:TurboControls = new TurboControls([Control.RIGHT]);
	var upTurboControl:TurboControls = new TurboControls([Control.UP]);
	var downTurboControl:TurboControls = new TurboControls([Control.DOWN]);
	var turboBasics:Array<TurboBasic> = [leftTurboControl, rightTurboControl, upTurboControl, downTurboControl];
    var curOption:ITreeOption;
	var curFloatOption:ITreeFloatOption;
    var length(get, null):Int;
    var curSelected:Int = 0;
    function get_length():Int return members.length;
	public var controls(get, never):Controls;
	inline function get_controls():Controls return PlayerSettings.solo.controls;
	public var playSound = true;
	public function changeSelection(change:Int, force:Bool = false) {
		if (length == 0 || (change == 0 && !force)) return;

		var prevSelect = curSelected = FlxMath.wrap(curSelected + change, 0, members.length - 1);
		while (members[curSelected] is Separator)
			if ((curSelected = FlxMath.wrap(curSelected + (change > 0 ? 1 : -1), 0, members.length - 1)) == prevSelect) break;

		if (curOption != null) curOption.selected = false;
		if (members[curSelected] is ITreeOption) {
			(curOption = cast members[curSelected]).selected = true;
			if (curOption is ITreeFloatOption) curFloatOption = cast curOption;
			else curFloatOption = null;
		}
		else {
			curOption = null;
			curFloatOption = null;
		}

		if (playSound) CoolUtil.playMenuSFX(0);

		onChangeSelection.dispatch();
	}
	/**
	 * The prefix to add to the translations ids.
	**/
	public var prefix:String = "";

	public function reloadStrings() {
		for (object in members) if (object != null) {
			try {
				object.reloadStrings();
			} catch(e:Dynamic) {}
			//trace(object.te xt);
		}
	}
    var __firstFrame:Bool = true;
    public function menuUpdate(elapsed) {
        if (__firstFrame) {
			__firstFrame = false;
			if (members[curSelected] is ITreeOption) {
				(curOption = cast members[curSelected]).selected = true;
				if (curOption is ITreeFloatOption) curFloatOption = cast curOption;
			}
			updateItems(true);
			return;
		}
        if (inputEnabled) {
			for (basic in turboBasics) basic.update(elapsed);

			var change = (upTurboControl.activated ? -1 : 0) + (downTurboControl.activated ? 1 : 0) - FlxG.mouse.wheel, mouseControl = false;
			if (FlxG.mouse.justPressed) {
				for (i in CoolUtil.maxInt(curSelected - 3, 0)...CoolUtil.minInt(curSelected + 4, length))
					if (i != curSelected && members[i] != null && mouseOverlaps(members[i])) {
						change = i - curSelected;
						mouseControl = true;
						break;
					}
			}
			changeSelection(change);

			if (length > 0 && curOption != null) {
				if (controls.ACCEPT || (!mouseControl && FlxG.mouse.justPressed && mouseOverlaps(members[curSelected]))) curOption.select();
				if (curFloatOption != null) {
					if (controls.LEFT) curFloatOption.changeValue(-elapsed);
					if (controls.RIGHT) curFloatOption.changeValue(elapsed);
				}
				else {
					if (leftTurboControl.activated) curOption.changeSelection(-1);
					if (rightTurboControl.activated) curOption.changeSelection(1);
				}
			}

			if (controls.BACK || (FlxG.mouse.justPressedRight && Main.timeSinceFocus > 0.3)) close();
		}
        updateItems();
    }
    public var updateItems = function(force = false) {
		var r = force ? 1 : 0.25, initY = FlxG.height * 0.5;
		var i = curSelected, y = initY, object:FlxSprite = null, itemHeight:Float = 0;

		inline function updateItem() {
			object.y = CoolUtil.fpsLerp(object.y, y - itemHeight * 0.5, r);
			object.x = x + 100 - Math.pow(Math.abs((object.y - (FlxG.height - itemHeight) * 0.5) / itemHeight / FlxG.height * FlxG.initialHeight), 1.6) * 15;
		}

		while (i < length) if ((object = members[i++]) != null) {
			itemHeight = object.height;
			updateItem();
			y += itemHeight;
		}

		y = initY;
		i = curSelected;
		while (i-- > 0) if ((object = members[i]) != null) {
			y -= (itemHeight = object.height);
			updateItem();
		}
	}
    public function close() {
        onClose.dispatch();

        if (curOption != null) curOption.selected = false;

		CoolUtil.playMenuSFX(2);

        destroy();
    }
    function mouseOverlaps(sprite:FlxSprite):Bool
		return sprite.overlapsPoint(FlxG.mouse.getPosition(@:privateAccess FlxPointer._cachedPoint), true);

    public var onClose:FlxSignal0 = new FlxSignal0();
	public var onChangeSelection:FlxSignal0 = new FlxSignal0();

    ////////////////////////////////////////////////////////////////////////////

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
        menuUpdate(elapsed);
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
		super.destroy();
		for (basic in turboBasics) basic.destroy();
	}
}
