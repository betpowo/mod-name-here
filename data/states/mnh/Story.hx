import funkin.backend.chart.Chart;
import openfl.ui.Mouse;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import Xml;

var weeks = [];

function create() {
	loadXMLs();
	CoolUtil.playMenuSong();
	//FlxG.camera.bgColor = 0xffcc0033;
	FlxG.camera.bgColor = 0x0;
	
	var shit = new FlxBackdrop(FlxGridOverlay.createGrid(1, 1, 2, 2, true, 0x00ffffff, 0x09ffffff));
	shit.scale.set(60, 60);
	shit.updateHitbox();
	shit.screenCenter();
	shit.blend = 0;
	shit.scrollFactor.set(0.4, 0.4);
	shit.velocity.y = 16;
	//add(shit);

	var dumpTxt = new FunkinText();
	dumpTxt.font = Paths.font('sillyfont.ttf');
	dumpTxt.borderSize = 4;
	dumpTxt.color = 0xffffcccc;
	dumpTxt.borderColor = 0xff330033;
	dumpTxt.size = 72;
	dumpTxt.text = "i'll work on it later ";

	// thank you rozebud
	dumpTxt.drawFrame(true);

	var scrollTxt = new FlxBackdrop(dumpTxt.pixels);
	scrollTxt.antialiasing = true;
	scrollTxt.velocity.set(-150, 0);
	scrollTxt.repeatAxes = 0x01;
	scrollTxt.updateHitbox();
	//add(scrollTxt);

	var songNames = [];
	for (i in weeks[0].songs) {
		if (!i.hide)
			songNames.push(Chart.loadChartMeta(i.name, 'normal').displayName.toLowerCase());
	}

	//trace(weeks);
	//trace(songNames);

	var bleh = new FunkinText(50, 250, FlxG.width - 100, songNames.join('\n'), 40);
	bleh._defaultFormat.leading = 10;
	bleh.updateDefaultFormat();
	bleh.borderSize = 4;
	bleh.borderColor = 0xffcc0033;
	bleh.color = 0xffffffcc;
	bleh.font = Paths.font('sillyfont.ttf');

	// add(bleh);
}

function update(elapsed) {
	/*if (controls.UP_P || controls.LEFT_P)
			changeSelection(-1);
		if (controls.DOWN_P || controls.RIGHT_P)
			changeSelection(1);
		var intendedCursor = FlxG.mouse.overlaps(image) ? 'button' : 'arrow';
		if (Mouse.cursor != intendedCursor)
			Mouse.cursor = intendedCursor;
		if (controls.ACCEPT || FlxG.mouse.overlaps(image) && FlxG.mouse.justPressed) {
			var data = creds[curSelected];
			if (data != null) {
				if (data.url != null) {
					Sys.command('start ' + data.url);
				}
			}
	}*/
	if (true) {
		FlxG.switchState(new MainMenuState());
		persistentUpdate = false;
		Mouse.cursor = 'arrow';
	}

	/*if (controls.LEFT)
			scrollTxt.angle -= elapsed * 36;
		if (controls.RIGHT)
			scrollTxt.angle += elapsed * 36;
		nameTxt.text = 'angle: ' + scrollTxt.angle; */
}

function loadXMLs() {
	var _weeks = [
		for (c in Paths.getFolderContent('data/weeks/weeks/', false, true))
			StringTools.replace(c, '.xml', '')
	];

	for (k => v in _weeks) {
		var week = null;
		try {
			week = Xml.parse(Assets.getText(Paths.xml('weeks/weeks/' + v))).firstElement();
		} catch (e:Dynamic) {
			trace('Error while parsing ' + v + '.xml: ' + Std.string(e));
		}
		if (week == null)
			continue;
		//////////////////////////////////////
		var songs = [];

		for (song in week.elements()) {
			trace('firstChild: ' + Reflect.fields(song.firstChild()));
			var name = StringTools.trim(song.firstChild().nodeValue);
			if (name == "") {
				trace('lol! name is empty');
				continue;
			}
			songs.push({
				name: name,
				hide: (song.get('hide') ?? 'false') == "true"
			});
		}

		var data = {
			name: v,
			displayName: week.get('name') ?? v,
			songs: songs
		};
		// ??
		if (data.name != data.displayName)
			weeks.push(data);
	}
}
