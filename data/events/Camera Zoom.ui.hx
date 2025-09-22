function generateIcon() {
	if (event.params == null || inMenu) return generateDefaultIcon(event.name);
	var group = new EventIconGroup();
	var def = generateDefaultIcon(event.name);
	group.add(def);
	if (event.params[3] == 'Instant') {
		def.shader = new CustomShader('adjustColor');
		def.shader.hue = 111;
	}
	else if (event.params[3] == 'Tweened') generateEventIconDurationArrow(group, event.params[4]);

	if (event.params[0] != 1) {
		group.members[0].y -= 2;
		generateEventIconNumbers(group, event.params[0]);
	}
	if (event.params[1]) group.add(getEventComponent("end-plus", 7, 8 - ((event.params[0] != 1) ? 2 : 0)));
	return group;
}