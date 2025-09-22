function generateIcon() {
	if (event.params == null || inMenu) return generateDefaultIcon(event.name);
	var group = new EventIconGroup();
	group.add(generateDefaultIcon(event.name));
	var flash = getEventComponent("flash-white", 7, 0);
	group.add(flash);
	generateEventIconDurationArrow(group, event.params[2]);
	if (event.params[0]) {
		var arrow = getEventComponent("arrow-right", 2, 9);
		group.add(arrow);
		arrow.flipX = !arrow.flipX;
	}
	if (event.params[3] == 'camHUD') {
		var x = getEventComponent("cross", -3, -1);
		group.add(x);
	}
	flash.onDraw = (f) -> {
		f.setColorTransform(1, 1, 1, f.alpha, group.colorTransform.redOffset, group.colorTransform.greenOffset, group.colorTransform.blueOffset, group.colorTransform.alphaOffset);
		f.color = event.params[1];
		f.draw();
	}
	return group;
}