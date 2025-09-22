function onPostStartCountdown() {
    startTimer.time *= 2;
    Conductor.songPosition = (Conductor.crochet * introLength - Conductor.songOffset) * -2;
}