package options.group;

class GameplayGroup extends OptionCata
{
	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);

		var option:Option = new Option(this,
			'Gameplay',
			'Gameplay',
			TITLE
		);
		addOption(option);

		var option:Option = new Option(this,
			'Controller Mode',
			'Check this if you want to play with\na controller instead of using your Keyboard.',
			'controllerMode',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Use Experimental (0.7x) Cameras',
			"If checked, game uses 0.7x's Camera System instead of 0.6x's.\n(If you have a any camera issue, enable or disable this)",
			'UseNewCamSystem',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Use CNE\'s Camera Angle',
			"If checked, camera angle works like in Codename Engine\nThis is useful for some CNE mods like Cyber Sensation",
			'codenameCamAngle',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Better Sync',
			"If checked, game continues where it freezes",
			'betterSync',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'HScript Version',
			'If You Have A Any Problem With Mods Change This',
			'hscriptversion',
			STRING,
			['HScript Old', 'HScript New', 'SScript']
		);
		addOption(option);

		#if HSC_ALLOWED
		var option:Option = new Option(this,
			'Codename Like Functions',
			'If checked, you can use some functions like in Codename Engine, simple enough.\n(THIS THING ONLY HAS A COUNTDOWN FOR NOW)',
			'codenameFunctions',
			BOOL
		);
		addOption(option);
		#end

		var option:Option = new Option(this,
			'Downscroll',
			'If checked, notes go Down instead of Up, simple enough.',
			'downScroll',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Middlescroll',
			'If checked, your notes get centered.',
			'middleScroll',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Opponent Notes',
			'If unchecked, opponent notes get hidden.',
			'opponentStrums',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Disable Reset Button',
			"If checked, pressing Reset won't do anything.",
			'noReset',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Set Note Offset',
			'Select Your Note Offset Thing or whatever',
			BUTTON,
		);
		addOption(option);
		option.onChange = () -> LoadingState.loadAndSwitchState(new NoteOffsetState());

		///////////////////////////////

		var option:Option = new Option(this,
			'Hitsound Volume',
			'Funny notes does \"Tick!\" when you hit them."',
			'hitsoundVolume',
			PERCENT,
			[0.0, 1, 1]
		);
		addOption(option);
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option(this,
			'Rating Offset',
			'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset',
			INT,
			[-30, 30, ' MS']
		);
		addOption(option);

		var option:Option = new Option(this,
			'Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
			'sickWindow',
			INT,
			[15, 45, ' MS']
		);
		addOption(option);

		var option:Option = new Option(this,
			'Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
			'goodWindow',
			INT,
			[15, 90, ' MS']
		);
		addOption(option);

		var option:Option = new Option(this,
			'Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
			'badWindow',
			INT,
			[15, 135, ' MS']
		);
		addOption(option);

		var option:Option = new Option(this,
			'Safe Frames',
			'Changes how many frames you have for\nhitting a note earlier or late.',
			'safeFrames',
			FLOAT,
			[2, 10, 1]
		);
		addOption(option);

		changeHeight(0);
	}

	static function onChangeHitsoundVolume()
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);
}