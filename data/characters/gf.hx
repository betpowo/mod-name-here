// midpoint use to not exist on atlases. so were not using it here
function onGetCamPos(e) {
	if (isAnimate) {
		e.x = this.x + globalOffset.x + cameraOffset.x + (isPlayer ? -100 : 150);
		e.y = this.y + globalOffset.y + cameraOffset.y - 100;
	}
}