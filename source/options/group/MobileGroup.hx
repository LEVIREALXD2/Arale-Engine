package options.group;

class MobileGroup extends OptionCata
{
	#if android
	var storageTypes:Array<String> = ["EXTERNAL_DATA", "EXTERNAL", "EXTERNAL_EX", "EXTERNAL_NF", "EXTERNAL_OBB", "EXTERNAL_MEDIA", "EXTERNAL_ONLINE"];
	var externalPaths:Array<String> = StorageUtil.checkExternalPaths(true);
	#end

	var HitboxTypes:Array<String>;
	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);
		#if android storageTypes = storageTypes.concat(externalPaths); #end //SD Card
		HitboxTypes = Mods.mergeAllTextsNamed('mobile/Hitbox/HitboxModes/hitboxModeList.txt');

		var option:Option = new Option(this,
			'Mobile',
			'Mobile',
			TITLE
		);
		addOption(option);

		///////////////////////////////

		var option:Option = new Option(this,
			'Open Keybind Changer',
			'Change Your Note/Menu Keybinds',
			BUTTON,
		);
		addOption(option);
		option.onChange = () -> OptionsState.instance.openSubState(new ControlsSubState());

		#if TOUCH_CONTROLS
		var option:Option = new Option(this,
			'Open Mobile Control Selector',
			'Select Your In-game Control (MobilePad Controls will be removed soon for better modding)',
			BUTTON,
		);
		addOption(option);
		option.onChange = () -> OptionsState.instance.openSubState(new MobileControlSelectSubState());

		var option:Option = new Option(this,
			'Open Extra Control Key Selector',
			"Select the custom returns for keys",
			BUTTON,
		);
		addOption(option);
		option.onChange = () -> OptionsState.instance.openSubState(new MobileExtraControl());

		var option:Option = new Option(this,
			'Keyboard & Mouse Fixes for Editors',
			'Basically Turns off MobilePad in Editors\n(Don\'t Enable That If You Want To Use Editors With MobilePad)',
			'KeyboardFixes',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'MobilePad Alpha',
			'Changes MobilePad Alpha',
			'mobilePadAlpha',
			PERCENT,
			[0, 1, 1]
		);
		addOption(option);

		var option:Option = new Option(this,
			'Extra Controls',
			'Allow Extra Controls',
			'extraKeys',
			INT,
			[0, 4]
		);
		addOption(option);

		var option:Option = new Option(this,
			'Extra Control Location',
			'Choose Extra Control Location',
			'hitboxLocation',
			STRING,
			['Bottom', 'Top', 'Middle']
		);
		addOption(option);

		//HitboxTypes.insert(0, "New");
		HitboxTypes.insert(0, "Classic");
		var option:Option = new Option(this,
			'Hitbox Mode',
			'Choose your Hitbox Style!',
			'hitboxmode',
			STRING,
			HitboxTypes
		);
		addOption(option);

		var option:Option = new Option(this,
			'Hitbox Design',
			'Choose how your hitbox should look like.',
			'hitboxtype',
			STRING,
			['Gradient', 'No Gradient' , 'No Gradient (Old)']
		);
		addOption(option);

		var option:Option = new Option(this,
			'Hitbox Hint',
			'Hitbox Hint',
			'hitboxhint',
			BOOL
		);
		addOption(option);

		var option:Option = new Option(this,
			'Hitbox Opacity',
			'Changes hitbox opacity',
			'hitboxalpha',
			FLOAT,
			[0.0, 1, 1]
		);
		addOption(option);
		#end

		var option:Option = new Option(this,
			'Wide Screen Mode',
			'If checked, The game will stetch to fill your whole screen. (WARNING: Can result in bad visuals & break some mods that resizes the game/cameras)',
			'wideScreen',
			BOOL
		);
		addOption(option);
		option.onChange = () -> FlxG.scaleMode = new MobileScaleMode();

		#if android
		var option:Option = new Option(this,
			'Storage Type',
			'Which folder Psych Engine should use?',
			'storageType',
			STRING,
			storageTypes
		);
		addOption(option);
		#end

		var autoCheck:Bool = true;
		var option:Option = new Option(this,
			'Check Files',
			'autoCheck: ' + (autoCheck ? 'Enabled' : 'Disabled') + ')',
			'CopyState',
			STATE,
			'CopyState'
		);
		addOption(option);

		changeHeight(0);
	}

	static function onChangeCwd() {
		Sys.setCwd(StorageUtil.getStorageDirectory());
	}
}