package options;

import sys.FileSystem;
import sys.io.File;

class OptionsHelpers
{
	public static function colorArray(data:String):FlxColor
	{
		switch (data)
		{
			case 'BLACK':
				return FlxColor.BLACK;
			case 'WHITE':
				return FlxColor.WHITE;
			case 'GRAY':
				return FlxColor.GRAY;
			case 'RED':
				return FlxColor.RED;
			case 'GREEN':
				return FlxColor.GREEN;
			case 'BLUE':
				return FlxColor.BLUE;
			case 'YELLOW':
				return FlxColor.YELLOW;
			case 'PINK':
				return FlxColor.PINK;
			case 'ORANGE':
				return FlxColor.ORANGE;
			case 'PURPLE':
				return FlxColor.PURPLE;
			case 'BROWN':
				return FlxColor.BROWN;
			case 'CYAN':
				return FlxColor.CYAN;
		}
		return FlxColor.WHITE;
	}
	/*
		BOOL://

		var option:Option = new Option(this, 'name', 'description', 'value', BOOL);
		addOption(option);


		INT://

		var option:Option = new Option(this, 'name', 'description', 'value', INT, [min, max, '单位']);
		addOption(option);


		FLOAT://

		var option:Option = new Option(this, 'name', 'description', 'value', FLOAT, [min, max, '小数点', '单位]);
		addOption(option);


		PERCENT://

		var option:Option = new Option(this, 'name', 'description', 'value', PERCENT, [min, max, '单位']);
		addOption(option);


		STRING://

		var option:Option = new Option(this, 'name', 'description', 'value', STRING, youArray);
		addOption(option);


		BUTTON (STATE doing same thing but this added for easier understanding)://

		var option:Option = new Option(this, 'name', 'description', BUTTON, youState);
		addOption(option);


		STATE://

		var option:Option = new Option(this, 'name', 'description', STATE, youState);
		addOption(option);


		SubState://

		var option:Option = new Option(this, 'name', 'description', SubState, youSubState);
		addOption(option);


		TITLE://

		var option:Option = new Option(this, 'name', 'description', TITLE);
		addOption(option);


		TEXT://

		var option:Option = new Option(this, 'name', 'description', TEXT);
		addOption(option);


		NOTE://

		var option:Option = new Option(this, 'name', 'description', NOTE);
		addOption(option);


		SPLASH://

		var option:Option = new Option(this, 'name', 'description', SPLASH);
		addOption(option);
	*/
}