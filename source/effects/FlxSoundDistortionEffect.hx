import FlxSoundFilter;

class FlxSoundDistortionEffect extends FlxSoundBaseEffect
{
	public var edge:Float = 0.2;
	public var gain:Float = 0.05;
	public var lowpassCutoff:Float = 8000.0;
	public var eqCenter:Float = 3600.0;
	public var eqBandwidth:Float = 3600.0;

	override private function updateEffect()
	{
		#if lime_openal
		AL.effecti(_effect, ALVars.EFFECT_TYPE, ALVars.EFFECT_DISTORTION);

		AL.effectf(_effect, ALVars.DISTORTION_EDGE, edge);
		AL.effectf(_effect, ALVars.DISTORTION_GAIN, gain);
		AL.effectf(_effect, ALVars.DISTORTION_LOWPASS_CUTOFF, lowpassCutoff);
		AL.effectf(_effect, ALVars.DISTORTION_EQCENTER, eqCenter);
		AL.effectf(_effect, ALVars.DISTORTION_EQBANDWIDTH, eqBandwidth);
		#end

		super.updateEffect();
	}
}