package;

import editors.ChartingState;
import editors.ChartingStateNew;

class CustomSwitchState
{
	function new() {} //Haxe Needs This

	public function switchMenusNew(StatePrefix:String, ?useLoadandSwitch:Bool = false)
	{
		//for easy readability
		var CP = ClientPrefs.data;
		var switchState = MusicBeatState.switchState;
		var loadAndSwitchState = LoadingState.loadAndSwitchState;

		//Actual Code
		//OMG Rewrited? EDIT: It's still sucks but better than first version, EDIT AGAIN: That's definitely better than oldest one
			switch (StatePrefix)
			{
				case 'Charting':
					//1.0 Chart Editor Support, Let's fucking gooooo
					if (CP.chartLoadSystem == '1.0x') switchState(new ChartingStateNew());
					else if(useLoadandSwitch && CP.chartLoadSystem == '1.0x') loadAndSwitchState(new ChartingStateNew(), false);
					else if(useLoadandSwitch) loadAndSwitchState(new ChartingState());
					else switchState(new ChartingState());
				case 'Freeplay':
					#if EXTRA_FREEPLAY if (CP.FreeplayMenu == 'NovaFlare') switchState(new FreeplayStateNOVA());
					else #end switchState(new FreeplayState());
				case 'MainMenu':
					#if EXTRA_MAINMENU if (CP.MainMenuStyle == 'NovaFlare') switchState(new MainMenuStateNOVA());
					else #end switchState(new MainMenuState());
			}
	}

	//Automatic Instance Creator
	public static function switchMenus(StatePrefix:String, ?useLoadandSwitch:Bool = false)
	{
		var createInstance:CustomSwitchState = new CustomSwitchState();
		createInstance.switchMenusNew(StatePrefix, useLoadandSwitch);
	}
}