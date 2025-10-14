package options.group;

class GraphicsGroup extends OptionCata
{
	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);

		var option:Option = new Option(this,
			'Graphics',
			'Graphics',
			TITLE,
		);
		addOption(option);

		///////////////////////////////

		#if CUSTOM_RESOLUTION_ALLOWED
		var Resolutions:Array<String> = Mods.mergeAllTextsNamed('game/Resolutions.txt');
		Resolutions.insert(0, "1280/720");
		var option:Option = new Option(this,
			'Resolution',
			"This option allows to change Resolution without using project.xml\nIf you don't know what are you doing, don't touch this",
			'realResolution',
			STRING,
			Resolutions
		);
		addOption(option);
		#end

		var option:Option = new Option(this,
			'Low Quality',
			'If checked, disables some background details,\ndecreases loading times and improves performance.',
			'lowQuality',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'antialiasing',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Shaders',
			'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.',
			'shaders',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Framerate',
			"Pretty self explanatory, isn't it?",
			'framerate',
			INT,
			[60, 240, ' FPS']
		);
		addOption(option);
		option.onChange = () -> onChangeFramerate(option.defaultValue);

		changeHeight(0);
	}

	function onChangeFramerate(value:String)
	{
		var intValue:Int = Std.parseInt(value);
		trace('Int Value is: ${intValue}');
		FlxG.gameFramerate = intValue;
	}
}