import FlxSoundFilter;

class FlxSoundEchoEffect extends FlxSoundBaseEffect
{
	public var delay:Float = 0.1;
	public var lrDelay:Float = 0.1;
	public var damping:Float = 0.5;
	public var feedback:Float = 0.5;
	public var spread:Float = -1.0;

	override private function updateEffect()
	{
		#if lime_openal
		AL.effecti(_effect, ALVars.EFFECT_TYPE, ALVars.EFFECT_ECHO);

		AL.effectf(_effect, ALVars.ECHO_DELAY, delay);
		AL.effectf(_effect, ALVars.ECHO_LRDELAY, lrDelay);
		AL.effectf(_effect, ALVars.ECHO_DAMPING, damping);
		AL.effectf(_effect, ALVars.ECHO_FEEDBACK, feedback);
		AL.effectf(_effect, ALVars.ECHO_SPREAD, spread);
		#end

		super.updateEffect();
	}
}