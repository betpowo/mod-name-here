public var luis = null;
public var bodrio = null;
public var iconP3 = new HealthIcon();

function create() {
    iconArray.push(iconP3);
}

function postCreate() {
    luis = strumLines.members[0].characters[1];
    strumLines.members[0].characters.remove(luis, true); // dont make camera account for him
    remove(luis);
    insert(members.indexOf(dad), luis);

    bodrio = strumLines.members[0].characters[1];
    strumLines.members[0].characters.remove(bodrio, true); // dont make camera account for him
    remove(bodrio, true);
    insert(members.indexOf(gf), bodrio);

    bodrio.setPosition(gf.x, gf.y);

    luis.x += 266;

    /*var shad = new CustomShader('adjustColor');
    shad.hue = 180;
    shad.saturation = 0;
    shad.brightness = 0;
    shad.contrast = ((9.5 / 6) / 3) * -1000;

    luis.shader = shad;
    luis.skew.x = -20;*/

    iconP3.setIcon(luis.getIcon());
    iconP3.extraOffsets.x -= 7 * iconP3.defaultScale;

    remove(iconP3, true);
    insert(members.indexOf(iconP2) + 1, iconP3);
    iconP3.camera = camHUD;

    var og = updateIconPositions;
    var padding = 26;
    updateIconPositions = () -> {
        og();
        if (!iconP3.isPlayer) {
            iconP3.x = iconP2.x - iconP3.width + padding;
            iconP3.health = iconP2.health;
        } else {
            iconP3.x = iconP1.x + iconP1.width - padding;
            iconP3.health = iconP1.health;
        }
    };

    iconP3.y = healthBar.y - (iconP3.height * 0.5);
}

function onNoteHit(e) {
    var ogc = e.characters.copy();
    switch(e.note.noteType) {
        case 'luis': e.characters = [luis];
        case '+luis': e.characters.push(luis);
    }
    e.note.strumLine.characters = ogc;
}

function onPlayerMiss(e) {
    var ogc = e.characters.copy();
    switch(e.note.noteType) {
        case 'luis': e.characters = [luis];
        case '+luis': e.characters.push(luis);
    }
    e.note.strumLine.characters = ogc;
}