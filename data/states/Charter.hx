// metadata only works for "variants" now  . but i use difficulties instead in here so uhm
import funkin.backend.chart.Chart;
import funkin.editors.charter.Charter;

var enabled = false;
var amazingText = new FunkinText();

function postCreate() {
	amazingText.size = 32;
	amazingText.alignment = 'center';
	add(amazingText);
	amazingText.camera = uiCamera;

	if (!enabled)
		return;
	var lastBPM = Conductor.bpmChangeMap[0].bpm;
	chart.meta = Chart.loadChartMeta(Charter.__song, Charter.__variant, Charter.__diff);
	// trace(chart.meta);
	Conductor.setupSong(PlayState.SONG);
	var diff = Conductor.bpmChangeMap[0].bpm / lastBPM;
	for (n in notesGroup.members) {
		// trace(diff);
		n.updatePos(n.step * diff, n.id, n.susLength * diff, n.type, n.strumLine);
	}
	var me = FlxPoint.get(0, 0);
	for (i in [leftEventsGroup, rightEventsGroup]) {
		for (e in i.members) {
			// trace(diff);
			e.step *= diff;
			e.handleDrag(me);
		}
	}
	refreshBPMSensitive();
	__applyPlaytestInfo();
}

function postUpdate(elapsed) {
	var ev = chart.events.copy();
	ev.reverse();

	var event = null;
	for (k => i in ev) {
		if (i.name != 'Lyrics')
			continue;
		if (i.time <= Conductor.songPosition) {
			event = i;
			break;
		}
	}
	var maxWidth = FlxG.width * 0.9;
	var curText = '';
	if (event != null && event.params[0] != '') {
		amazingText.alpha = FlxG.sound.music.playing ? 1 : 0.33;
		amazingText.fieldWidth = -1;
		curText = event.params[0];
		if (amazingText.width > maxWidth) {
			amazingText.fieldWidth = maxWidth;
		}
		amazingText.size = event.params[1] ?? 32;
		amazingText.color = event.params[2] ?? 0xffffff;
	}
	if (amazingText.text != curText) {
		amazingText.text = curText;
		amazingText.updateHitbox();
		amazingText.screenCenter();
		amazingText.y = FlxG.height - 50 - amazingText.height;
		amazingText.x = Std.int(amazingText.x);
	}
}
