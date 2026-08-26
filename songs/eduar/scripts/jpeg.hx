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

final lowqualityShaders = [
    new CustomShader('lowquality/lowquality_0_reduce'),
    new CustomShader('lowquality/lowquality_1_sharpen'),
    new CustomShader('lowquality/lowquality_2_blockEffect'),
    new CustomShader('lowquality/lowquality_3_main'),
    new CustomShader('lowquality/lowquality_4_amplification')
];

function jpegCamGame() {
    camGame.addShader(jpeg);
    for (i in lowqualityShaders) {
        camGame.addShader(i);
        camJPEG.addShader(i);
    }
    camGame.antialiasing = false;
    playerStrums.forEach((s) -> {
        s.cameras = [camJPEG];
    });
}