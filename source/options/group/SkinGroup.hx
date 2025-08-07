package options.group;

class SkinGroup extends OptionCata
{
	var noteSkinOption:Option;
	var splashSkinOption:Option;
	var noteSkins:Array<String>;
	var splashSkins:Array<String>;

	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);

		var option:Option = new Option(this,
			'Skin',
			TITLE
		);
		addOption(option);

		var option:Option = new Option(this,
			'Note Skins',
			TEXT
		);
		addOption(option);

		noteSkins = addSkins('noteSkins');
		splashSkins = (ClientPrefs.data.useRGB ? addSkins('noteSplashes') : addSkins('noteSplashSkins'));
		if (ClientPrefs.data.useRGB) splashSkins.insert(0, 'Psych');
		else splashSkins.insert(0, ClientPrefs.defaultData.splashSkin);

		var option:Option = new Option(this,
			'use RGB Shader',
			'If checked, Notes will be use RBG Shader\n(THIS OPTION DISABLES THE OLD NOTE COLOR SCREEN)',
			'useRGB',
			BOOL
		);
		option.onChange = () -> onChangeRGBShader();
		addOption(option);

		noteSkins.insert(0, ClientPrefs.defaultData.noteSkin);

		noteSkinOption = new Option(this,
			'Note Skin',
			'Choose your Note Skin!',
			'noteSkin',
			STRING,
			noteSkins
		);
		addOption(noteSkinOption, true);

		var option:Option = new Option(this,
			'Open Note Color Picker',
			'Basically, Allows the change Note Colors',
			BUTTON
		);
		option.onChange = () -> openNotesSubState();
		addOption(option);

		splashSkinOption = new Option(this,
			'Note Splash Skin',
			'Choose your Note Splash Skin!',
			'splashSkin',
			STRING,
			splashSkins
		);
		addOption(splashSkinOption, true);

		changeHeight(0); //初始化真正的height
	}

	function addSkins(Path:String):Array<String> {
		var output:Array<String> = [];
		if (ClientPrefs.data.useRGB || Path == 'noteSplashSkins' || Path == 'noteSplashes') {
			if (Mods.mergeAllTextsNamed('images/${Path}/list.txt', 'shared').length > 0)
				output = Mods.mergeAllTextsNamed('images/${Path}/list.txt');
			else
				output = CoolUtil.coolTextFile(Paths.getSharedPath('images/${Path}/list.txt'));
		}
		else {
			if (Mods.mergeAllTextsNamed('images/NoteSkin/DataSet/noteSkinList.txt', 'shared').length > 0)
				output = Mods.mergeAllTextsNamed('images/NoteSkin/DataSet/noteSkinList.txt');
			else
				output = CoolUtil.coolTextFile(Paths.getSharedPath('images/NoteSkin/DataSet/noteSkinList.txt'));
		}
		return output;
	}

	function openNotesSubState() {
		if (ClientPrefs.data.useRGB) return OptionsState.instance.openSubState(new NotesColorSubState());
		else return OptionsState.instance.openSubState(new NotesSubState());
	}

	function onChangeRGBShader() {
		ClientPrefs.saveSettings();

		/* Note Skins */
		noteSkins = addSkins('noteSkins');
		noteSkins.insert(0, ClientPrefs.defaultData.noteSkin); //I forgot to add this, cuz I'm a idiot
		updateOption(noteSkinOption, noteSkins, ClientPrefs.data.noteSkin);

		/* Note Splash Skins */
		splashSkins = (ClientPrefs.data.useRGB ? addSkins('noteSplashes') : addSkins('noteSplashSkins'));
		if (ClientPrefs.data.useRGB) splashSkins.insert(0, 'Psych');
		else splashSkins.insert(0, ClientPrefs.defaultData.splashSkin);
		updateOption(splashSkinOption, splashSkins, ClientPrefs.data.splashSkin);
	}

	function updateOption(option:Option, array:Array<String>, variable:Dynamic) {
		if(option.stringRect.isOpend) option.stringRect.change(); //close the old String Thing
		option.strGroup = array; //Change between Psych Extended and Psych's Skin Folders (`.options` changed with `.strGroup`)
		option.select.options = array; //change selector too
		option.reloadStringSelection(); //Reload Selection Screen

		if(!array.contains(variable))
		{
			option.defaultValue = option.strGroup[0]; //Reset to default if saved skin couldnt be found in between folders

			//update text
			option.setValue(option.strGroup[0]);
			option.updateDisText();
			option.change();
		}
	}
}