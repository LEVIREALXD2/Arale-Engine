package options.group;

class SkinGroup extends OptionCata
{
	var noteSkinOption:Option;
	var noteSkins:Array<String>;
	var noteSplashSkins:Array<String>;
	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);

		var option:Option = new Option(this,
			'Skin',
			TITLE
		);
		addOption(option);

		var option:Option = new Option(this,
			'Note',
			TEXT
		);
		addOption(option);

		noteSkins = addSkins('noteSkins');
		noteSplashSkins = addSkins('noteSplashSkins');

		if (noteSkins.length > 0)
		{
			noteSkins.insert(0, ClientPrefs.defaultData.noteSkin);

			noteSkinOption = new Option(this,
				'Note Skin',
				'Choose your Note Skin!',
				'noteSkin',
				STRING,
				noteSkins
			);
			addOption(noteSkinOption);
		}

		var option:Option = new Option(this,
			'use RGB Shader',
			'If checked, Notes will be use RBG Shader\n(THIS OPTION DISABLES THE OLD NOTE COLOR SCREEN)',
			'useRGB',
			BOOL
		);
		option.onChange = () -> onChangeRGBShader();
		addOption(option, true);

		var option:Option = new Option(this,
			'Open Note Color Picker',
			'Basically, Allows the change Note Colors',
			BUTTON
		);
		option.onChange = () -> openNotesSubState();
		addOption(option);

		if (noteSplashSkins.length > 0)
		{
			noteSplashSkins.insert(0, ClientPrefs.defaultData.noteSplashSkin);

			var option:Option = new Option(this,
				'Note Splash Skin',
				'Choose your Note Splash Skin!',
				'noteSplashSkin',
				STRING,
				noteSplashSkins
			);
			addOption(option, true);
		}

		changeHeight(0); //初始化真正的height
	}

	function addSkins(Path:String):Array<String> {
		var output:Array<String> = [];
		if (ClientPrefs.data.useRGB || Path == 'noteSplashSkins') {
			if (Mods.mergeAllTextsNamed('images/${Path}/list.txt', 'shared').length > 0)
				output = Mods.mergeAllTextsNamed('images/${Path}/list.txt');
			else
				output = CoolUtil.coolTextFile(Paths.getPreloadPath('images/${Path}/list.txt'));
		}
		else {
			if (Mods.mergeAllTextsNamed('images/NoteSkin/DataSet/noteSkinList.txt', 'shared').length > 0)
				output = Mods.mergeAllTextsNamed('images/NoteSkin/DataSet/noteSkinList.txt');
			else
				output = CoolUtil.coolTextFile(Paths.getPreloadPath('images/NoteSkin/DataSet/noteSkinList.txt'));
		}
		return output;
	}

	function openNotesSubState() {
		if (ClientPrefs.data.useRGB) return OptionsState.instance.openSubState(new NotesColorSubState());
		else return OptionsState.instance.openSubState(new NotesSubState());
	}

	function onChangeRGBShader() {
		ClientPrefs.saveSettings();
		noteSkins = addSkins('noteSkins');
		noteSkins.insert(0, ClientPrefs.defaultData.noteSkin); //I forgot to add this, cuz I'm a idiot
		if(noteSkinOption.stringRect.isOpend) noteSkinOption.stringRect.change(); //close the old String Thing
		noteSkinOption.strGroup = noteSkins; //Change between NF's and Psych's Note Skin Folders (`.options` changed with `.strGroup`)
		noteSkinOption.select.options = noteSkins;
		noteSkinOption.reloadStringSelection();

		if(!noteSkins.contains(ClientPrefs.data.noteSkin))
		{
			noteSkinOption.defaultValue = noteSkinOption.strGroup[0]; //Reset to default if saved noteskin couldnt be found in between folders

			//update text
			noteSkinOption.setValue(noteSkinOption.strGroup[0]);
			noteSkinOption.updateDisText();
			noteSkinOption.change();
		}
	}
}