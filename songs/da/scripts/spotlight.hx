var stupidLights = new FunkinSprite();

var uglyLights = [new FunkinSprite(), new FunkinSprite()];

function postCreate() {
	importScript('data/scripts/rimlight');
	for (x in strumLines.members) {
		for (i in x.characters) {
			if (i == null) continue;
    		var shader = rimlight(i);
		}
	}

    final stageFront = stage.stageSprites['stageFront'];
    final stageCurtains = stage.stageSprites['stageCurtains'];

    stupidLights.loadSprite(Paths.image('stages/default/stagefront_lights'));
    insert(members.indexOf(stageFront) + 1, stupidLights);
    stupidLights.setPosition(stageFront.x, stageFront.y);
    stupidLights.scrollFactor.set(stageFront.scrollFactor.x, stageFront.scrollFactor.y);
    stupidLights.antialiasing = true;
    stupidLights.alpha = 0.001;


    var spo1 = new FunkinSprite(stageCurtains.x + 450, stageCurtains.y + 250);
    spo1.loadSprite(Paths.image('stages/default/stage_light'));
    spo1.scrollFactor.set(stageCurtains.scrollFactor.x * 0.9, stageCurtains.scrollFactor.y * 0.9);
    spo1.antialiasing = true;
    insert(members.indexOf(stageFront), spo1);

    var spo2 = new FunkinSprite(stageCurtains.x + 1800, stageCurtains.y + 250);
    spo2.loadSprite(Paths.image('stages/default/stage_light'));
    spo2.flipX = true;
    spo2.scrollFactor.set(stageCurtains.scrollFactor.x * 0.9, stageCurtains.scrollFactor.y * 0.9);
    spo2.antialiasing = true;
    insert(members.indexOf(stageFront), spo2);

    for (i in uglyLights) {
        i.loadSprite(Paths.image('stages/default/ugly-light'));
        i.scrollFactor.set(stageCurtains.scrollFactor.x * 0.9, stageCurtains.scrollFactor.y * 0.9);
        i.antialiasing = true;
        i.blend = BlendMode.ADD;
        i.scale.set(1.1, 1.6); // NOT updating hitbox on purpose . im lazy as shit
        insert(members.indexOf(stageFront) + 1, i);

        i.alpha = 0.001;
    }

    uglyLights[0].setPosition(spo1.x + 120, spo1.y + 280);
    uglyLights[1].setPosition(spo2.x + 120 - uglyLights[1].width - 20, spo2.y + 280);
    uglyLights[1].flipX = true;
}

// make this visually pleasing later
function doSpotlight(e) {
    camGame.flash(0xffffffcc, 0.2, null, true);
    var yes = (Std.parseInt(e) == 1);
    for (x in strumLines.members) {
        for (i in x.characters) {
            if (i == null) continue;
            setAddColorMatrix(yes ? 0xffee99 : 0, i.shader.matrixB);
            i.color = yes ? 0x666666 : -1;
        }
    }
    for (k => v in stage.stageSprites) {
        v.color = yes ? 0x666666 : -1;
    }
    stupidLights.alpha = 1;
    stupidLights.visible = yes;

    for (i in uglyLights) {
        i.alpha = 1;
        i.visible = yes;
    }
}