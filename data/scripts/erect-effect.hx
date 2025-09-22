// You gotta place values inside the character positions or sprites nodes in the stage xml before importing this script on your stage script!!  - Nex
import funkin.game.Stage.StageCharPos;

if (!Options.gameplayShaders)
{
    disableScript();
    return;
}

var __erectShaderAttNames:Array<String> = ["brightness", "hue", "contrast", "saturation", "distance", "dropColor", "threshold", "dropAngle", "aaStages", "strength"];
var tsNames:Array<String> = ["distance", "dropColor", "threshold", "dropAngle", "aaStages", "strength"];
public var erectShaderCharsAtts:Array<Array<Float>> = [];
final TO_RAD:Float = 0.017453292519943295; // Math.PI / 180;
function onStageNodeParsed(event)
{
    var sprite = event.sprite;
    var node = event.node;

    if (sprite is FlxSprite)
    {
        var atts = getErectShaderAttFromNode(node);
        if ((sprite.shader = burp(atts)) != null) {
            sprite?.animation?.onFrameChange.add((a,b,c) -> {
                updateFrameInfo(sprite.shader, sprite.frame, sprite);
            });
            sprite?.animation?.onFrameChange.dispatch('', 0, 0);
        }
    }
    else
    {
        var map = event.stage.characterPoses;

        for (char in map.keys()) if (map[char] == event.sprite)
        {
            erectShaderCharsAtts[getCharPosIndex(char)] = getErectShaderAttFromNode(node);
            break;
        }
    }
}

function create() {
    if (strumLines != null) {
        for (i => atts in erectShaderCharsAtts) {
            if(atts != null) {
                if (strumLines.members[i] == null) continue;
                for (char in strumLines.members[i].characters) {
                    if (char == null) continue;

                    if ((char.shader = burp(atts)) != null) {
                        char.animation.onFrameChange.add((a,b,c) -> {
                            updateFrameInfo(char.shader, char.frame, char);
                        });
                        char.animation.onFrameChange.dispatch('', 0, 0);
                    }
                }
            }
        }
    }
}

public function getCharPosIndex(charPos:String):Int
    return switch(charPos) { case "dad": 0; case "boyfriend": 1; default: 2; };

public function getErectShaderAttFromNode(node):Array<Float>{
    var res = [for (att in __erectShaderAttNames) getAtt(node, att)];
    //trace(res);
    return res;
}
function getAtt(node, att) {
    var res = CoolUtil.getAtt(node, att);
    if (att == 'dropColor') return CoolUtil.getColorFromDynamic(res) & 0xffffff;
    return getErectShaderAtt(res, att);
}
public function getErectShaderAtt(att:String, name:String):Float {
    return att?.length > 0 ? Std.parseFloat(att) : (name == 'strength' ? 1 : 0);
}

public function initErectShader(brightness:Float, hue:Float, contrast:Float, saturation:Float, ?drops, ?rawData):CustomShader
{
    var isDropShadow = false;
    /*if (rawData != null) {
        for (i in tsNames) {
            trace(i);
            if (rawData.indexOf(i) != -1)
                isDropShadow = true;
        }
    }*/

    if (drops[0] != 0)
        isDropShadow = true;

    //trace(isDropShadow);

    if (!isDropShadow
      && hue == 0
      && saturation == 0
      && brightness == 0
      && contrast == 0)
      return null;

    var shader = new CustomShader(isDropShadow ? 'dropShadow' : 'adjustColor');
    shader.brightness = brightness;
    shader.hue = hue;
    shader.contrast = contrast;
    shader.saturation = saturation;
    //trace(drops);
    if (isDropShadow) {
        shader.ang = drops[3] * TO_RAD;
        shader.dist = drops[0];
        shader.dropColor = c2rgbf(drops[1]);
        shader.thr = drops[2];
        shader.str = drops[5];
        shader.AA_STAGES = drops[4];
    }

    return shader;
}

function updateFrameInfo(sh, frame, spr) {
    // NOTE: uv.width is actually the right pos and uv.height is the bottom pos
    sh.uFrameBounds = [frame.uv.x, frame.uv.y, frame.uv.width, frame.uv.height];

    // if a frame is rotated the shader will look completely wrong lol
    sh.angOffset = frame.angle * TO_RAD;

    sh.scale = [spr.scale.x * (spr.flipX ? -1 : 1), spr.scale.y * (spr.flipY ? -1 : 1)];
}

function burp(atts) {
    return initErectShader(atts[0], atts[1], atts[2], atts[3], [atts[4], atts[5], atts[6], atts[7], atts[8], atts[9]], atts);
}

function c2rgbf(c) {
    //trace(c);
    var res = [
        ((c >> 16) & 0xff) / 255,
        ((c >> 08) & 0xff) / 255,
        ((c >> 00) & 0xff) / 255
    ];
    //trace(res);
    return res;
}