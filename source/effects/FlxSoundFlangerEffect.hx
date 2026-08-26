import FlxSoundFilter;

class FlxSoundFlangerEffect extends FlxSoundBaseEffect
{
	public var waveform:Int = 1;
	public var phase:Int = 0;
	public var rate:Float = 0.27;
	public var depth:Float = 1.0;
	public var feedback:Float = -0.5;
	public var delay:Float = 0.002;

	override private function updateEffect()
	{
		#if lime_openal
		AL.effecti(_effect, ALVars.EFFECT_TYPE, ALVars.EFFECT_FLANGER);

		AL.effecti(_effect, ALVars.FLANGER_WAVEFORM, waveform);
		AL.effecti(_effect, ALVars.FLANGER_PHASE, phase);
		AL.effectf(_effect, ALVars.FLANGER_RATE, rate);
		AL.effectf(_effect, ALVars.FLANGER_DEPTH, depth);
		AL.effectf(_effect, ALVars.FLANGER_FEEDBACK, feedback);
		AL.effectf(_effect, ALVars.FLANGER_DELAY, delay);
		#end

		super.updateEffect();
	}
}