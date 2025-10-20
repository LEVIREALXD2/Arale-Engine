package options.group;

class UIGroup extends OptionCata
{
	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);

		var option:Option = new Option(this,
			'Visuals & UI',
			'Visuals & UI',
			TITLE,
		);
		addOption(option);

		///////////////////////////////

		var addedOptions:Int = 0; //Fix Option Positions
		#if EXTRA_FREEPLAY
		var option:Option = new Option(this,
			'Freeplay Menu Style',
			"Choose your Freeplay Menu Style",
			'FreeplayMenu',
			STRING,
			['Psych', 'NovaFlare']
		);
		addOption(option, addedOptions % 2 == 1 ? true : false);
		addedOptions++;
		#end

		#if EXTRA_FPSCOUNTER
		var option:Option = new Option(this,
			'FPS Counter Style',
			"Choose your FPS Counter Style",
			'FPSCounter',
			STRING,
			['Psych', 'NovaFlare']
		);
		addOption(option, addedOptions % 2 == 1 ? true : false);
		//option.onChange = OptionsState.onChangeFPSCounterShit;
		addedOptions++;
		#end

		#if EXTRA_TRANSITIONS
		var option:Option = new Option(this,
			'Transition Style',
			"Choose your Transition Style",
			'TransitionStyle',
			STRING,
			['Psych', 'NovaFlare']);
		addOption(option, addedOptions % 2 == 1 ? true : false);
		addedOptions++;
		#end

		#if EXTRA_MAINMENU
		var option:Option = new Option(this,
			'Main Menu Style',
			"Choose your Main Menu Style",
			'MainMenuStyle',
			STRING,
			['Psych', 'NovaFlare']);
		addOption(option, addedOptions % 2 == 1 ? true : false);
		addedOptions++;
		#end

		#if EXTRA_PAUSE
		var option:Option = new Option(this,
			'Pause Menu Style',
			"Choose your Pause Menu Style",
			'PauseMenuStyle',
			STRING,
			['Psych', 'NovaFlare']);
		addOption(option, addedOptions % 2 == 1 ? true : false);
		addedOptions++;
		#end

		var option:Option = new Option(this,
			'Chart Editor',
			"Choose Your Chart Editor\nPsychExtended now loads the 1.0x charts automatically",
			'chartEditor',
			STRING,
			['0.4-0.7x', '1.0x']
		);
		addOption(option, addedOptions % 2 == 1 ? true : false);
		addedOptions++;

		#if DISCORD_ALLOWED
		var option:Option = new Option(this,
			'Discord Rich Presence',
			"Uncheck this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord",
			'discordRPC',
			BOOL
		);
		addOption(option);
		#end

		var option:Option = new Option(this,
			'Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Time Bar',
			'What should the Time Bar display?',
			'timeBarType',
			STRING,
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']
		);
		addOption(option);

		var option:Option = new Option(this,
			'Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Score Text Zoom on Hit',
			'If unchecked, disables the Score text zooming\neverytime you hit a note.',
			'scoreZoom',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Health Bar Transparency',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			PERCENT,
			[0, 1, 1]
		);
		addOption(option);

		var option:Option = new Option(this,
			'FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Pause Screen Song',
			'What song do you prefer for the Pause Screen?',
			'pauseMusic',
			STRING,
			['None', 'Breakfast', 'Tea Time']
		);
		addOption(option);

		#if CHECK_FOR_UPDATES
		var option:Option = new Option(this,
			'Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			BOOL
		);
		addOption(option);
		#end

		#if DISCORD_ALLOWED
		var option:Option = new Option(this,
			'Discord Rich Presence',
			"Uncheck this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord",
			'discordRPC',
			BOOL
		);
		addOption(option);
		#end

		var option:Option = new Option(this,
			'Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
			'comboStacking',
			BOOL
		);
		addOption(option);

		changeHeight(0);
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.data.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

		changedMusic = true;
	}

	/*
	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}
	*/
}