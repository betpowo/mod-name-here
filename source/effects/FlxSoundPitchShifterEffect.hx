import FlxSoundFilter;

class FlxSoundPitchShifterEffect extends FlxSoundBaseEffect
{
	public var coarseTune:Int = 0;
	public var fineTune:Int = 0;

	override private function updateEffect()
	{
		#if lime_openal
		AL.effecti(_effect, ALVars.EFFECT_TYPE, ALVars.EFFECT_PITCH_SHIFTER);

		AL.effecti(_effect, ALVars.PITCH_SHIFTER_COARSE_TUNE, coarseTune);
		AL.effecti(_effect, ALVars.PITCH_SHIFTER_FINE_TUNE, fineTune);

		#end

		super.updateEffect();
	}
}