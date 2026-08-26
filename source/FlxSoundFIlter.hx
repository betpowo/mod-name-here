// written by TheZoroForce240

import flixel.util.FlxDestroyUtil;
import lime.media.openal.AL;

class FlxSoundFilterType {
	public static var NONE = 0x0000;
	public static var LOWPASS = 0x0001;
	public static var HIGHPASS = 0x0002;
	public static var BANDPASS = 0x0003;
}

class ALVars {
	public static var NONE:Int = 0;
	public static var FALSE:Int = 0;
	public static var TRUE:Int = 1;
	public static var SOURCE_RELATIVE:Int = 0x202;
	public static var CONE_INNER_ANGLE:Int = 0x1001;
	public static var CONE_OUTER_ANGLE:Int = 0x1002;
	public static var PITCH:Int = 0x1003;
	public static var POSITION:Int = 0x1004;
	public static var DIRECTION:Int = 0x1005;
	public static var VELOCITY:Int = 0x1006;
	public static var LOOPING:Int = 0x1007;
	public static var BUFFER:Int = 0x1009;
	public static var GAIN:Int = 0x100A;
	public static var MIN_GAIN:Int = 0x100D;
	public static var MAX_GAIN:Int = 0x100E;
	public static var ORIENTATION:Int = 0x100F;
	public static var SOURCE_STATE:Int = 0x1010;
	public static var INITIAL:Int = 0x1011;
	public static var PLAYING:Int = 0x1012;
	public static var PAUSED:Int = 0x1013;
	public static var STOPPED:Int = 0x1014;
	public static var BUFFERS_QUEUED:Int = 0x1015;
	public static var BUFFERS_PROCESSED:Int = 0x1016;
	public static var REFERENCE_DISTANCE:Int = 0x1020;
	public static var ROLLOFF_FACTOR:Int = 0x1021;
	public static var CONE_OUTER_GAIN:Int = 0x1022;
	public static var MAX_DISTANCE:Int = 0x1023;
	public static var SEC_OFFSET:Int = 0x1024;
	public static var SAMPLE_OFFSET:Int = 0x1025;
	public static var BYTE_OFFSET:Int = 0x1026;
	public static var SOURCE_TYPE:Int = 0x1027;
	public static var STATIC:Int = 0x1028;
	public static var STREAMING:Int = 0x1029;
	public static var UNDETERMINED:Int = 0x1030;
	public static var FORMAT_MONO8:Int = 0x1100;
	public static var FORMAT_MONO16:Int = 0x1101;
	public static var FORMAT_STEREO8:Int = 0x1102;
	public static var FORMAT_STEREO16:Int = 0x1103;
	public static var FREQUENCY:Int = 0x2001;
	public static var BITS:Int = 0x2002;
	public static var CHANNELS:Int = 0x2003;
	public static var SIZE:Int = 0x2004;
	public static var NO_ERROR:Int = 0;
	public static var INVALID_NAME:Int = 0xA001;
	public static var INVALID_ENUM:Int = 0xA002;
	public static var INVALID_VALUE:Int = 0xA003;
	public static var INVALID_OPERATION:Int = 0xA004;
	public static var OUT_OF_MEMORY:Int = 0xA005;
	public static var VENDOR:Int = 0xB001;
	public static var VERSION:Int = 0xB002;
	public static var RENDERER:Int = 0xB003;
	public static var EXTENSIONS:Int = 0xB004;
	public static var DOPPLER_FACTOR:Int = 0xC000;
	public static var SPEED_OF_SOUND:Int = 0xC003;
	public static var DOPPLER_VELOCITY:Int = 0xC001;
	public static var DISTANCE_MODEL:Int = 0xD000;
	public static var INVERSE_DISTANCE:Int = 0xD001;
	public static var INVERSE_DISTANCE_CLAMPED:Int = 0xD002;
	public static var LINEAR_DISTANCE:Int = 0xD003;
	public static var LINEAR_DISTANCE_CLAMPED:Int = 0xD004;
	public static var EXPONENT_DISTANCE:Int = 0xD005;
	public static var EXPONENT_DISTANCE_CLAMPED:Int = 0xD006;
	/* Listener properties. */
	public static var METERS_PER_UNIT:Int = 0x20004;
	/* Source properties. */
	public static var DIRECT_FILTER:Int = 0x20005;
	public static var AUXILIARY_SEND_FILTER:Int = 0x20006;
	public static var AIR_ABSORPTION_FACTOR:Int = 0x20007;
	public static var ROOM_ROLLOFF_FACTOR:Int = 0x20008;
	public static var CONE_OUTER_GAINHF:Int = 0x20009;
	public static var DIRECT_FILTER_GAINHF_AUTO:Int = 0x2000A;
	public static var AUXILIARY_SEND_FILTER_GAIN_AUTO:Int = 0x2000B;
	public static var AUXILIARY_SEND_FILTER_GAINHF_AUTO:Int = 0x2000C;
	/* Effect properties. */
	/* Reverb effect parameters */
	public static var REVERB_DENSITY:Int = 0x0001;
	public static var REVERB_DIFFUSION:Int = 0x0002;
	public static var REVERB_GAIN:Int = 0x0003;
	public static var REVERB_GAINHF:Int = 0x0004;
	public static var REVERB_DECAY_TIME:Int = 0x0005;
	public static var REVERB_DECAY_HFRATIO:Int = 0x0006;
	public static var REVERB_REFLECTIONS_GAIN:Int = 0x0007;
	public static var REVERB_REFLECTIONS_DELAY:Int = 0x0008;
	public static var REVERB_LATE_REVERB_GAIN:Int = 0x0009;
	public static var REVERB_LATE_REVERB_DELAY:Int = 0x000A;
	public static var REVERB_AIR_ABSORPTION_GAINHF:Int = 0x000B;
	public static var REVERB_ROOM_ROLLOFF_FACTOR:Int = 0x000C;
	public static var REVERB_DECAY_HFLIMIT:Int = 0x000D;
	/* EAX Reverb effect parameters */ // Windows only... ?
	public static var EAXREVERB_DENSITY:Int = 0x0001;
	public static var EAXREVERB_DIFFUSION:Int = 0x0002;
	public static var EAXREVERB_GAIN:Int = 0x0003;
	public static var EAXREVERB_GAINHF:Int = 0x0004;
	public static var EAXREVERB_GAINLF:Int = 0x0005;
	public static var EAXREVERB_DECAY_TIME:Int = 0x0006;
	public static var EAXREVERB_DECAY_HFRATIO:Int = 0x0007;
	public static var EAXREVERB_DECAY_LFRATIO:Int = 0x0008;
	public static var EAXREVERB_REFLECTIONS_GAIN:Int = 0x0009;
	public static var EAXREVERB_REFLECTIONS_DELAY:Int = 0x000A;
	public static var EAXREVERB_REFLECTIONS_PAN:Int = 0x000B;
	public static var EAXREVERB_LATE_REVERB_GAIN:Int = 0x000C;
	public static var EAXREVERB_LATE_REVERB_DELAY:Int = 0x000D;
	public static var EAXREVERB_LATE_REVERB_PAN:Int = 0x000E;
	public static var EAXREVERB_ECHO_TIME:Int = 0x000F;
	public static var EAXREVERB_ECHO_DEPTH:Int = 0x0010;
	public static var EAXREVERB_MODULATION_TIME:Int = 0x0011;
	public static var EAXREVERB_MODULATION_DEPTH:Int = 0x0012;
	public static var EAXREVERB_AIR_ABSORPTION_GAINHF:Int = 0x0013;
	public static var EAXREVERB_HFREFERENCE:Int = 0x0014;
	public static var EAXREVERB_LFREFERENCE:Int = 0x0015;
	public static var EAXREVERB_ROOM_ROLLOFF_FACTOR:Int = 0x0016;
	public static var EAXREVERB_DECAY_HFLIMIT:Int = 0x0017;
	/* Chorus effect parameters */
	public static var CHORUS_WAVEFORM:Int = 0x0001;
	public static var CHORUS_PHASE:Int = 0x0002;
	public static var CHORUS_RATE:Int = 0x0003;
	public static var CHORUS_DEPTH:Int = 0x0004;
	public static var CHORUS_FEEDBACK:Int = 0x0005;
	public static var CHORUS_DELAY:Int = 0x0006;
	/* Distortion effect parameters */
	public static var DISTORTION_EDGE:Int = 0x0001;
	public static var DISTORTION_GAIN:Int = 0x0002;
	public static var DISTORTION_LOWPASS_CUTOFF:Int = 0x0003;
	public static var DISTORTION_EQCENTER:Int = 0x0004;
	public static var DISTORTION_EQBANDWIDTH:Int = 0x0005;
	/* Echo effect parameters */
	public static var ECHO_DELAY:Int = 0x0001;
	public static var ECHO_LRDELAY:Int = 0x0002;
	public static var ECHO_DAMPING:Int = 0x0003;
	public static var ECHO_FEEDBACK:Int = 0x0004;
	public static var ECHO_SPREAD:Int = 0x0005;
	/* Flanger effect parameters */
	public static var FLANGER_WAVEFORM:Int = 0x0001;
	public static var FLANGER_PHASE:Int = 0x0002;
	public static var FLANGER_RATE:Int = 0x0003;
	public static var FLANGER_DEPTH:Int = 0x0004;
	public static var FLANGER_FEEDBACK:Int = 0x0005;
	public static var FLANGER_DELAY:Int = 0x0006;
	/* Frequency shifter effect parameters */
	public static var FREQUENCY_SHIFTER_FREQUENCY:Int = 0x0001;
	public static var FREQUENCY_SHIFTER_LEFT_DIRECTION:Int = 0x0002;
	public static var FREQUENCY_SHIFTER_RIGHT_DIRECTION:Int = 0x0003;
	/* Vocal morpher effect parameters */
	public static var VOCAL_MORPHER_PHONEMEA:Int = 0x0001;
	public static var VOCAL_MORPHER_PHONEMEA_COARSE_TUNING:Int = 0x0002;
	public static var VOCAL_MORPHER_PHONEMEB:Int = 0x0003;
	public static var VOCAL_MORPHER_PHONEMEB_COARSE_TUNING:Int = 0x0004;
	public static var VOCAL_MORPHER_WAVEFORM:Int = 0x0005;
	public static var VOCAL_MORPHER_RATE:Int = 0x0006;
	/* Pitchshifter effect parameters */
	public static var PITCH_SHIFTER_COARSE_TUNE:Int = 0x0001;
	public static var PITCH_SHIFTER_FINE_TUNE:Int = 0x0002;
	/* Ringmodulator effect parameters */
	public static var RING_MODULATOR_FREQUENCY:Int = 0x0001;
	public static var RING_MODULATOR_HIGHPASS_CUTOFF:Int = 0x0002;
	public static var RING_MODULATOR_WAVEFORM:Int = 0x0003;
	/* Autowah effect parameters */
	public static var AUTOWAH_ATTACK_TIME:Int = 0x0001;
	public static var AUTOWAH_RELEASE_TIME:Int = 0x0002;
	public static var AUTOWAH_RESONANCE:Int = 0x0003;
	public static var AUTOWAH_PEAK_GAIN:Int = 0x0004;
	/* Compressor effect parameters */
	public static var COMPRESSOR_ONOFF:Int = 0x0001;
	/* Equalizer effect parameters */
	public static var EQUALIZER_LOW_GAIN:Int = 0x0001;
	public static var EQUALIZER_LOW_CUTOFF:Int = 0x0002;
	public static var EQUALIZER_MID1_GAIN:Int = 0x0003;
	public static var EQUALIZER_MID1_CENTER:Int = 0x0004;
	public static var EQUALIZER_MID1_WIDTH:Int = 0x0005;
	public static var EQUALIZER_MID2_GAIN:Int = 0x0006;
	public static var EQUALIZER_MID2_CENTER:Int = 0x0007;
	public static var EQUALIZER_MID2_WIDTH:Int = 0x0008;
	public static var EQUALIZER_HIGH_GAIN:Int = 0x0009;
	public static var EQUALIZER_HIGH_CUTOFF:Int = 0x000A;
	/* Effect type */
	public static var EFFECT_FIRST_PARAMETER:Int = 0x0000;
	public static var EFFECT_LAST_PARAMETER:Int = 0x8000;
	public static var EFFECT_TYPE:Int = 0x8001;
	/* Effect types, used with the AL_EFFECT_TYPE property */
	public static var EFFECT_NULL:Int = 0x0000;
	public static var EFFECT_EAXREVERB:Int = 0x8000;
	public static var EFFECT_REVERB:Int = 0x0001;
	public static var EFFECT_CHORUS:Int = 0x0002;
	public static var EFFECT_DISTORTION:Int = 0x0003;
	public static var EFFECT_ECHO:Int = 0x0004;
	public static var EFFECT_FLANGER:Int = 0x0005;
	public static var EFFECT_FREQUENCY_SHIFTER:Int = 0x0006;
	public static var EFFECT_VOCAL_MORPHER:Int = 0x0007;
	public static var EFFECT_PITCH_SHIFTER:Int = 0x0008;
	public static var EFFECT_RING_MODULATOR:Int = 0x0009;
	public static var FFECT_AUTOWAH:Int = 0x000A; // TODO: deprecate and remove
	public static var EFFECT_AUTOWAH:Int = 0x000A;
	public static var EFFECT_COMPRESSOR:Int = 0x000B;
	public static var EFFECT_EQUALIZER:Int = 0x000C;
	/* Auxiliary Effect Slot properties. */
	public static var EFFECTSLOT_EFFECT:Int = 0x0001;
	public static var EFFECTSLOT_GAIN:Int = 0x0002;
	public static var EFFECTSLOT_AUXILIARY_SEND_AUTO:Int = 0x0003;
	/* NULL Auxiliary Slot ID to disable a source send. */
	// public static var EFFECTSLOT_NULL:Int = 0x0000;		//Use removeSend instead
	/* Filter properties. */
	/* Lowpass filter parameters */
	public static var LOWPASS_GAIN:Int = 0x0001; /*Not exactly a lowpass. Apparently it's a shelf*/
	public static var LOWPASS_GAINHF:Int = 0x0002;
	/* Highpass filter parameters */
	public static var HIGHPASS_GAIN:Int = 0x0001;
	public static var HIGHPASS_GAINLF:Int = 0x0002;
	/* Bandpass filter parameters */
	public static var BANDPASS_GAIN:Int = 0x0001;
	public static var BANDPASS_GAINLF:Int = 0x0002;
	public static var BANDPASS_GAINHF:Int = 0x0003;
	/* Filter type */
	public static var FILTER_FIRST_PARAMETER:Int = 0x0000; /*This is not even in the documentation*/
	public static var FILTER_LAST_PARAMETER:Int = 0x8000; /*This one neither*/
	public static var FILTER_TYPE:Int = 0x8001;
	/* Filter types, used with the AL_FILTER_TYPE property */
	public static var FILTER_NULL:Int = 0x0000;
	public static var FILTER_LOWPASS:Int = 0x0001;
	public static var FILTER_HIGHPASS:Int = 0x0002;
	public static var FILTER_BANDPASS:Int = 0x0003;
}

class FlxSoundBaseEffect extends FlxBasic
{
	#if lime_openal
	private var _auxSlot:ALAuxiliaryEffectSlot;
	private var _effect:ALEffect;
	#end
	public var bypass = false;

	public function new()
	{
		super();
		#if lime_openal
		_auxSlot = AL.createAux();
		_effect = AL.createEffect();
		#end
	}
	
	public function updateEffect()
	{
		#if lime_openal
		AL.auxi(_auxSlot, ALVars.EFFECTSLOT_EFFECT, _effect);
		#end
	}

	override public function destroy()
	{
		#if lime_openal
		_auxSlot = null;
		_effect = null;
		#end
	}
}

class FlxSoundFilter extends FlxBasic {

	public var filterType:FlxSoundFilterType = FlxSoundFilterType.NONE;

    /**
	 * Adjusts the gain/volume of the sound. (0.0 - 1.0)
	 * Used with any `filterType` besides for `NONE`
	 */
	public var gain:Float = 1.0;

	/**
	 * Adjusts the gain/volume of high frequency sounds. (0.0 - 1.0)
	 * Used with `filterType` `LOWPASS` and `BANDPASS`.
	 */
	public var gainHF:Float = 1.0;

	/**
	 * Adjusts the gain/volume of low frequency sounds. (0.0 - 1.0)
	 * Used with `filterType` `HIGHPASS` and `BANDPASS`.
	 */
	public var gainLF:Float = 1.0;

    #if lime_openal
	private var _filter:ALFilter;
	#end
	private var _effects:Array<Dynamic> = [];
	private var _dirtyEffectsCount:Int = -1;

	private var _targetSound:FlxSound = null;
    
    override public function new(targetSound:FlxSound) {
        #if lime_openal
		_filter = AL.createFilter();
		#end
		_targetSound = targetSound;
		super();
    }

	override public function update(elapsed) {
		super.update(elapsed);

		if (_targetSound != null && _targetSound.playing) {
			applyFilter(_targetSound);
		}
	}

    public function applyFilter(sound:FlxSound) {
        #if lime_openal
		var soundSource:ALSource = getSoundSource(sound);
		if (soundSource == null || _filter == null) return;

		if (_dirtyEffectsCount != -1)
		{
			//need to remove first because the amount of effects has lowered
			for (i in 0..._dirtyEffectsCount)
			{
				AL.removeSend(soundSource, i);
			}
			_dirtyEffectsCount = -1;
		}

		AL.filteri(_filter, ALVars.FILTER_TYPE, filterType);
		switch(filterType)
		{
			case FlxSoundFilterType.NONE:
			case FlxSoundFilterType.LOWPASS:
				AL.filterf(_filter, ALVars.LOWPASS_GAIN, gain);
				AL.filterf(_filter, ALVars.LOWPASS_GAINHF, gainHF);
			case FlxSoundFilterType.HIGHPASS:
				AL.filterf(_filter, ALVars.HIGHPASS_GAIN, gain);
				AL.filterf(_filter, ALVars.HIGHPASS_GAINLF, gainLF);
			case FlxSoundFilterType.BANDPASS:
				AL.filterf(_filter, ALVars.BANDPASS_GAIN, gain);
				AL.filterf(_filter, ALVars.BANDPASS_GAINLF, gainLF);
				AL.filterf(_filter, ALVars.BANDPASS_GAINHF, gainHF);
		}
		AL.sourcei(soundSource, ALVars.DIRECT_FILTER, _filter);

        for (i in 0..._effects.length)
		{
			if (_effects[i].bypass) continue;
			_effects[i].updateEffect();
			AL.source3i(soundSource, ALVars.AUXILIARY_SEND_FILTER, _effects[i]._auxSlot, i, ALVars.EFFECT_NULL);
		}
		#end
    }

    public function removeFilter(sound:FlxSound) {
        #if lime_openal
		var soundSource:ALSource = getSoundSource(sound);
		if (soundSource == null) return;

		AL.removeDirectFilter(soundSource);
		for (i in 0..._effects.length)
		{
			AL.removeSend(soundSource, i);
		}
		#end
    }

    function getSoundSource(sound:FlxSound) {
        #if lime_openal
		var soundSource:ALSource = null;
		
		@:privateAccess
		if (sound != null) {
			soundSource = sound.source.__backend.handle;
		}			

		return soundSource;
		#else
		return null;
		#end
    }

	public function addEffect(effect:FlxSoundBaseEffect)
	{
		_effects.push(effect);
	}

	public function removeEffect(effect:FlxSoundBaseEffect)
	{
		if (_dirtyEffectsCount == -1) _dirtyEffectsCount = _effects.length;
		_effects.remove(effect);
	}

	public function clearEffects(destroy:Bool = true)
	{
		if (_dirtyEffectsCount == -1) _dirtyEffectsCount = _effects.length;
		if (destroy) FlxDestroyUtil.destroyArray(_effects);
		_effects = [];
	}

	public function getEffectAt(index:Int) 
	{ 
		return _effects[index]; 
	}

    override public function destroy() {
		if (_targetSound != null) removeFilter(_targetSound);
		_targetSound = null;
        FlxDestroyUtil.destroyArray(_effects);
        _filter = null;
        super.destroy();
    }
}