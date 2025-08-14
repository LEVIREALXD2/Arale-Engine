import options.NovaFlareOptionsObjects.Option;
import options.NovaFlareOptionsObjects.OptionType;

function create() {
	var option:Option = new Option(this,
		'HScript Option',
		null, //HScript not setting these automatically, so you need add these manually
		null,
		OptionType.TITLE //Classic HScript Thing, you need to use `OptionType` for accessing it
	);
	addOption(option);

	var option:Option = new Option(this,
		'Shitty Things',
		null,
		null,
		OptionType.TEXT
	);
	addOption(option);

	var option:Option = new Option(this,
		'VSlice Control',
		'From source code',
		'VSliceControl', //this variable exist on ClientPrefs, you can access it normally
		OptionType.BOOL
	);
	addOption(option);

	var option:Option = new Option(this,
		'TestThing',
		'Variable',
		'TestThing', //this variable doesn't exist on ClientPrefs, so you need to acces it with FlxG.save.data.TestThing
		OptionType.BOOL
	);
	addOption(option);
}