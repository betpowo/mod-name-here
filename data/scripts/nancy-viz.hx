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
final graphWidth = Math.floor(PlayState.instance.inst.length / msGap);
vizSprite.makeGraphic(vizWidth, vizHeight, FlxColor.BLACK, true, 'spectogram');
vizSprite.updateHitbox();