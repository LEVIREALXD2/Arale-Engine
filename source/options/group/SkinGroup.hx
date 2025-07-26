package options.group;

class SkinGroup extends OptionCata
{
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

		var noteSkins:Array<String> = addNoteSkins();

		if (noteSkins.length > 0)
		{
			noteSkins.insert(0, ClientPrefs.defaultData.noteSkin);

			var option:Option = new Option(this,
				'Note Skin',
				'Choose your Note Skin!',
				'noteSkin',
				STRING,
				noteSkins
			);
			addOption(option);
		}

		var option:Option = new Option(this,
			'use RGB Shader',
			'If checked, Notes will be use RBG Shader\n(THIS OPTION DISABLES THE OLD NOTE COLOR SCREEN)',
			'useRGB',
			BOOL
		);
		if (noteSkins.length > 0)
		{
			addOption(option, true);
		} else {
			addOption(option, true);
		}

		var option:Option = new Option(this,
			'Open Note SubState',
			'Basically, Allows the change Note Colors',
			BUTTON
		);
		option.onChange = () -> OptionsState.instance.openSubState(new NotesSubState());
		addOption(option);

		changeHeight(0); //初始化真正的height
	}

	function addNoteSkins():Array<String> {
		var output:Array<String> = [];
		if (Mods.mergeAllTextsNamed('images/noteSkins/list.txt', 'shared').length > 0)
			output = Mods.mergeAllTextsNamed('images/noteSkins/list.txt');
		else
			output = CoolUtil.coolTextFile(Paths.getPreloadPath('images/noteSkins/list.txt'));
		return output;
	}
}