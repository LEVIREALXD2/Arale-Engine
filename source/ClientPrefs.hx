package;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import TitleState;

// Add a variable here and it will get automatically saved
@:structInit class SaveVariables {
	public var customIntOptions:Map<String, Int> = [];
	public var customBoolOptions:Map<String, Bool> = [];

	/* Mobile */
	public var wideScreen:Bool = false;
	#if android public var storageType:String = "EXTERNAL_DATA"; #end

	/* Mobile Controls */
	#if TOUCH_CONTROLS
	/* Bool Options */
	public var pauseButton:Bool = true;
	public var hitboxhint:Bool = false;
	public var coloredvpad:Bool = true;

	/* Int/Float Options */
	public var extraKeys:Int = 2;
	public var hitboxalpha:Float = #if mobile 0.7 #else 0 #end;
	public var mobilePadAlpha:Float = #if mobile 0.6 #else 0 #end;

	/* String Options */
	public var hitboxtype:String = 'Gradient';
	public var hitboxLocation:String = 'Bottom';
	public var mobilePadSkin:String = 'original';
	public var hitboxmode:String = 'Normal (New)';
	public var mobilePadTexture:String = "VirtualPad";

	public var extraKeyReturn1:String = 'SHIFT';
	public var extraKeyReturn2:String = 'SPACE';
	public var extraKeyReturn3:String = 'Q';
	public var extraKeyReturn4:String = 'E';
	public var extraKeyReturn5:String = 'W';
	public var extraKeyReturn6:String = 'A';
	public var extraKeyReturn7:String = 'S';
	public var extraKeyReturn8:String = 'D';
	#end

	/* Psych Extended */
	public var useRGB:Bool = false;
	public var betterSync:Bool = false;
	public var KeyboardFixes:Bool = false;
	public var realResolution:String = '1280/720';
	public var UseNewCamSystem:Bool = false;
	public var chartEditor:String = '0.4-0.7x';
	public var hscriptversion:String = 'HScript Old';
	#if MODPACK_ALLOWED
	public var currentModPack:String = null; //it's more easier than using .txt shit
	#end

	/* Codename Engine */
	#if HSC_ALLOWED
	public var codenameFunctions:Bool = false; //experimental
	#end
	/* Codename Mod Compability Things */
	public var codenameCamAngle:Bool = false;

	/* V-Slice */
	public var VSliceControl:Bool = false;

	/* NovaFlare Engine */
	public var uiScale:Float = 1;
	public var memoryType:Int = 0;
	public var rainbowFPS:Bool = true;
	#if EXTRA_PAUSE public var PauseMenuStyle:String = 'Psych'; #end
	#if EXTRA_FREEPLAY public var FreeplayMenu:String = 'Psych'; #end
	#if EXTRA_FPSCOUNTER public var FPSCounter:String = 'Psych'; #end
	#if EXTRA_MAINMENU public var MainMenuStyle:String = 'Psych'; #end
	#if EXTRA_TRANSITIONS public var TransitionStyle:String = 'Psych'; #end

	/* Psych Engine 0.7x */
	public var discordRPC:Bool = true;
	public var noteSkin:String = 'Default';
	public var splashSkin:String = 'Default';
	public var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]];
	public var arrowRGBPixel:Array<Array<FlxColor>> = [
		[0xFFE276FF, 0xFFFFF9FF, 0xFF60008D],
		[0xFF3DCAFF, 0xFFF4FFFF, 0xFF003060],
		[0xFF71E300, 0xFFF6FFE6, 0xFF003100],
		[0xFFFF884E, 0xFFFFFAF5, 0xFF6C0000]];

	/* Psych Engine 0.6.3 */
	public var downScroll:Bool = false;
	public var marvelousRating:Bool = true;
	public var marvelousSprite:Bool = true;
	public var marvelousWindow:Int = 15;
	public var middleScroll:Bool = false;
	public var opponentStrums:Bool = true;
	public var showFPS:Bool = true;
	public var flashing:Bool = true;
	public var antialiasing:Bool = true;
	public var noteSplashes:Bool = true;
	public var lowQuality:Bool = false;
	public var shaders:Bool = true;
	public var framerate:Int = 60;
	public var cursing:Bool = true;
	public var violence:Bool = true;
	public var camZooms:Bool = true;
	public var hideHud:Bool = false;
	public var noteOffset:Int = 0;
	public var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public var vibration:Bool = false;
	public var ghostTapping:Bool = true;
	public var timeBarType:String = 'Time Left';
	public var scoreZoom:Bool = true;
	public var noReset:Bool = false;
	public var healthBarAlpha:Float = 1;
	public var controllerMode:Bool = #if mobile true #else false #end;
	public var hitsoundVolume:Float = 0;
	public var pauseMusic:String = 'Tea Time';
	public var checkForUpdates:Bool = true;
	public var comboStacking:Bool = true;
	public var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative', 
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		// -kade
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'clearcache' => true,
		'opponentplay' => false
	];

	public var comboOffset:Array<Int> = [0, 0, 0, 0];
	public var ratingOffset:Int = 0;
	public var sickWindow:Int = 45;
	public var goodWindow:Int = 90;
	public var badWindow:Int = 135;
	public var safeFrames:Float = 10;
}

class ClientPrefs {
	public static var data:SaveVariables = {};
	public static var defaultData:SaveVariables = {};

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],

		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],

		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],

		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],

		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		//trace(defaultKeys);
	}

	public static function saveSettings() {
		for (key in Reflect.fields(data))
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));

		#if ACHIEVEMENTS_ALLOWED Achievements.save(); #end
		FlxG.save.flush();

		//Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', CoolUtil.getSavePath());
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		for (key in Reflect.fields(data))
			if (key != 'gameplaySettings' && Reflect.hasField(FlxG.save.data, key))
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));

		#if PsychExtended_ExtraFPSCounters
		if(Main.fpsVarNova != null && ClientPrefs.data.FPSCounter == 'NovaFlare')
			Main.fpsVarNova.visible = data.showFPS;
		if(Main.fpsVarNF != null && ClientPrefs.data.FPSCounter == 'NF')
			Main.fpsVarNF.visible = data.showFPS;
		#end
		if(Main.fpsVar != null #if PsychExtended_ExtraFPSCounters && ClientPrefs.data.FPSCounter == 'Psych' #end)
			Main.fpsVar.visible = data.showFPS;

		if(FlxG.save.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
				data.gameplaySettings.set(name, value);
		}

		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		#if DISCORD_ALLOWED
		DiscordClient.check();
		#end

		// controls on a separate save file
		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', CoolUtil.getSavePath());
		if(save != null && save.data.customControls != null) {
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic = null, ?customDefaultValue:Bool = false):Dynamic
	{
		if(!customDefaultValue) defaultValue = defaultData.gameplaySettings.get(name);
		return /*PlayState.isStoryMode ? defaultValue : */ (data.gameplaySettings.exists(name) ? data.gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadVolumeKeys()
	{
		TitleState.muteKeys = keyBinds.get('volume_mute').copy();
		TitleState.volumeDownKeys = keyBinds.get('volume_down').copy();
		TitleState.volumeUpKeys = keyBinds.get('volume_up').copy();
		toggleVolumeKeys(true);
	}
	public static function toggleVolumeKeys(?turnOn:Bool = true)
	{
		final emptyArray = [];
		FlxG.sound.muteKeys = turnOn ? TitleState.muteKeys : emptyArray;
		FlxG.sound.volumeDownKeys = turnOn ? TitleState.volumeDownKeys : emptyArray;
		FlxG.sound.volumeUpKeys = turnOn ? TitleState.volumeUpKeys : emptyArray;
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;
		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}