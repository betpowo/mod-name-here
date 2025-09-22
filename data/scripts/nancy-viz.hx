// we have to use PlayState.instance since this is gonna be parented to nancy, not playstate
import funkin.backend.utils.AudioAnalyzer;
import flixel.util.FlxSpriteUtil;
import funkin.backend.system.Logs;

var analyzer:AudioAnalyzer;
var lastTime:Float;
var cache:Array<Float>;
public var vizWidth:Int = 40;
public var vizHeight:Int = 20;
public var msGap = 100;
public var vizSprite = new FunkinSprite();
analyzer = new AudioAnalyzer(PlayState.instance.inst, 512);
var levels = [];
final graphWidth = Math.floor(PlayState.instance.inst.length / msGap);
vizSprite.makeGraphic(graphWidth, vizHeight, FlxColor.BLACK, 'spectogram');
for (i in 0...graphWidth) {
	var o = [];
	levels.push(analyzer.getLevels(i * msGap, 1, vizHeight, o, CoolUtil.getFPSRatio(0.1), -80, -20, 10, 24000));
	for (j => v in o) {
		FlxSpriteUtil.drawRect(vizSprite, i, j, 1, 1, FlxColor.fromRGBFloat(v, v, v));
	}
}
vizSprite.updateHitbox();
