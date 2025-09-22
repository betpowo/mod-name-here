import Sys;
function onEvent(e) {
	if (e.event.name != 'Set Property') return;
	Sys.exit(0);
}