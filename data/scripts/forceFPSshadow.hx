import funkin.backend.system.framerate.Framerate;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

var fpsBG:Bitmap;

function create() {
	fpsBG = new Bitmap(Framerate.__bitmap);
	fpsBG.alpha = 0.5;
	Framerate.instance.addChildAt(fpsBG, 0);
}

function destroy() {
	Framerate.instance.removeChild(fpsBG);
}

function draw() {
	fpsBG.x = Framerate.instance.bgSprite.x;
	fpsBG.y = Framerate.instance.bgSprite.y;
	fpsBG.scaleX = Framerate.instance.bgSprite.scaleX;
	fpsBG.scaleY = Framerate.instance.bgSprite.scaleY;
	fpsBG.alpha = (1 - Framerate.instance.debugAlpha) * 0.5;
}

function update() {
	// bandaid fix
	if (FlxG.keys.justPressed.F5)
		Framerate.instance.removeChild(fpsBG);
}
