if (!Options.gameplayShaders) {
    disableScript();
    return;
}

var jpeg = new CustomShader('jpeg');
var camJPEG = new HudCamera();
function postCreate() {
    FlxG.cameras.insert(camJPEG, 1, false);
    camJPEG.addShader(jpeg);
    camJPEG.bgColor = 0;
    camJPEG.antialiasing = false;
    cpuStrums.forEach((s) -> {
        s.cameras = [camJPEG];
    });
}

function postDraw(e) {
    camJPEG.angle = camHUD.angle;
    camJPEG.downscroll = camHUD.downscroll;
    camJPEG.zoom = camHUD.zoom;
    camJPEG.flipX = camHUD.flipX;
    camJPEG.flipY = camHUD.flipY;
    camJPEG.visible = camHUD.visible;
    camJPEG.setPosition(camHUD.x, camHUD.y);
}

function jpegCamGame() {
    camGame.addShader(jpeg);
    camJPEG.antialiasing = false;
}