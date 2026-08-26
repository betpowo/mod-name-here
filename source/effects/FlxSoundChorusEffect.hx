import FlxSoundFilter;

class FlxSoundChorusEffect extends FlxSoundBaseEffect
{
	public var waveform:Int = 1;
	public var phase:Int = 0;
	public var rate:Float = 1.1;
	public var depth:Float = 0.1;
	public var feedback:Float = 0.25;
	public var delay:Float = 0.016;

	override private function updateEffect()
	{
		#if lime_openal
		AL.effecti(_effect, ALVars.EFFECT_TYPE, ALVars.EFFECT_CHORUS);

		AL.effecti(_effect, ALVars.CHORUS_WAVEFORM, waveform);
		AL.effecti(_effect, ALVars.CHORUS_PHASE, phase);
		AL.effectf(_effect, ALVars.CHORUS_RATE, rate);
		AL.effectf(_effect, ALVars.CHORUS_DEPTH, depth);
		AL.effectf(_effect, ALVars.CHORUS_FEEDBACK, feedback);
		AL.effectf(_effect, ALVars.CHORUS_DELAY, delay);
		#end

		super.updateEffect();
	}
}