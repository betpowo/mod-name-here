function generateIcon() {
	if (inMenu) {
		if (event.params != null) {
			var icon = getIconFromStrumline(event.params[0]);
			if (icon != null) {
				return icon;
			}
		}
		return generateDefaultIcon(event.name);
	}
	var group = new EventIconGroup();
	var doDefault = true;
			// camera movement, use health icon
	if (event.params != null && !event.params[1]) {
		var icon = getIconFromStrumline(event.params[0]);
		if (icon != null) {
			group.add(icon);

			//???????
			icon.x -= 8;
			icon.y -= 8;

			doDefault = false;
		}
	}
	if (doDefault) group.add(generateDefaultIcon(event.name));
	if (event.params[4] == 'Instant') {
		group.add(getEventComponent("end-plus", 7, 9));
	}
	else if (event.params[4] == 'Tweened') generateEventIconDurationArrow(group, event.params[5]);

	return group;
}