import FlxSoundFilter;

class FlxSoundReverbEffect extends FlxSoundBaseEffect
{
	public var density:Float = 1.0;
	public var diffusion:Float = 1.0;
	public var gain:Float = 0.32;
	public var gainHF:Float = 0.89;
	public var decayTime:Float = 1.49;
	public var decayHFRatio:Float = 0.83;
	public var reflectionsGain:Float = 0.05;
	public var reflectionsDelay:Float = 0.007;
	public var lateGain:Float = 1.26;
	public var lateDelay:Float = 0.011;
	public var airAbsorptionGainHF:Float = 0.994;
	public var roomRolloff:Float = 0.0;
	public var decayHFLimit:Int = 1; // 0 or 1

	override private function updateEffect()
	{
		#if lime_openal
		AL.effecti(_effect, ALVars.EFFECT_TYPE, ALVars.EFFECT_REVERB);

		AL.effectf(_effect, ALVars.REVERB_DENSITY, density);
		AL.effectf(_effect, ALVars.REVERB_DIFFUSION, diffusion);
		AL.effectf(_effect, ALVars.REVERB_GAIN, gain);
		AL.effectf(_effect, ALVars.REVERB_GAINHF, gainHF);
		AL.effectf(_effect, ALVars.REVERB_DECAY_TIME, decayTime);
		AL.effectf(_effect, ALVars.REVERB_DECAY_HFRATIO, decayHFRatio);
		AL.effectf(_effect, ALVars.REVERB_REFLECTIONS_GAIN, reflectionsGain);
		AL.effectf(_effect, ALVars.REVERB_REFLECTIONS_DELAY, reflectionsDelay);
		AL.effectf(_effect, ALVars.REVERB_LATE_REVERB_GAIN, lateGain);
		AL.effectf(_effect, ALVars.REVERB_LATE_REVERB_DELAY, lateDelay);
		AL.effectf(_effect, ALVars.REVERB_AIR_ABSORPTION_GAINHF, airAbsorptionGainHF);
		AL.effectf(_effect, ALVars.REVERB_ROOM_ROLLOFF_FACTOR, roomRolloff);
		AL.effecti(_effect, ALVars.REVERB_DECAY_HFLIMIT, decayHFLimit);

		#end

		super.updateEffect();
	}
}