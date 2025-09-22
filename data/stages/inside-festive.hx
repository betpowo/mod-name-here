import Type;
import flixel.addons.display.FlxBackdrop;

var rgb:CustomShader = new CustomShader('rgbPalette');

function create() {
    camGame.bgColor = 0xFFff9c8f;

    rgb.mult = 1;
    rgb.r = getRGB(0x330033);
    rgb.g = getRGB(0x330033);
    rgb.b = getRGB(0x660066);
}
function postCreate() {
    for (i in [floor, ceiling]) {
        i.scrollFactor.set(0, 0.7);
    }

    var ceillights = new FlxBackdrop();
    ceillights.antialiasing = true;
    ceillights.frames = Paths.getFrames('main/secret/christmas/christmasBGAssets');
    ceillights.animation.addByPrefix('idle', 'ceiling light', 0, true);
    ceillights.animation.play('idle', true);
    ceillights.repeatAxes = 0x01;
    ceillights.scrollFactor.set(0.7, ceiling.scrollFactor.y);
    ceillights.spacing.x = -2;
    insert(1, ceillights);

    ceillights.shader = lights.shader = rgb;
}
function measureHit(m) {
    var lightColors:Array<Int> = [
        0xff3366,
        0xff6633,
        0xffcc66,
        0x66ff66,
        0x6699ff,
        0x6633ff
    ];

    rgb.r = getRGB(rand(lightColors));
    rgb.g = getRGB(FlxColor.add(rand(lightColors), 0xFF555555));
}
function rand(a) {
    return a[FlxG.random.int(1, a.length) - 1];
}
function destroy() {
    camGame.bgColor = 0;
}
function red(col) { return (col >> 16) & 0xff; }
function green(col) { return (col >> 8) & 0xff; }
function blue(col) { return col & 0xff; }

function redf(col) { return red(col) / 255; }
function greenf(col) { return green(col) / 255; }
function bluef(col) { return blue(col) / 255; }

function getRGB(col) {
    return [redf(col), greenf(col), bluef(col)];
}