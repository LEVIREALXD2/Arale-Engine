package;

#if SCRIPTING_ALLOWED
import funkin.backend.scripting.HScript;
#end
import editors.ChartingState;
import editors.ChartingStateNew;

class CustomSwitchState
{
	public function switchMenusNew(StatePrefix:String, ?useLoadandSwitch:Bool = false)
	{
		#if SCRIPTING_ALLOWED
		loadScript('classes/CustomSwitchState');
		#end

		call("switchMenus", [StatePrefix]);

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
					if (CP.chartEditor == '1.0x') switchState(new ChartingStateNew());
					else if(useLoadandSwitch && CP.chartEditor == '1.0x') loadAndSwitchState(new ChartingStateNew(), false);
					else if(useLoadandSwitch) loadAndSwitchState(new ChartingState());
					else switchState(new ChartingState());
				case 'Freeplay':
					#if EXTRA_FREEPLAY if (CP.FreeplayMenu == 'NovaFlare') switchState(new FreeplayStateNOVA());
					else #end switchState(new FreeplayState());
				case 'MainMenu':
					#if EXTRA_MAINMENU if (CP.MainMenuStyle == 'NovaFlare') switchState(new MainMenuStateNOVA());
					else #end switchState(new MainMenuState());
			}

		call("switchMenusPost", [StatePrefix]);

		destroy(); //destroy HScript Later switching
	}

	//Automatic Instance Creator
	public static function switchMenus(StatePrefix:String, ?useLoadandSwitch:Bool = false)
	{
		var createInstance:CustomSwitchState = new CustomSwitchState();
		createInstance.switchMenusNew(StatePrefix, useLoadandSwitch);
	}

	public function destroy() {
		call("destroy");
		#if SCRIPTING_ALLOWED
		stateScripts = FlxDestroyUtil.destroy(stateScripts);
		#end
	}

	/**
	 * SCRIPTING STUFF
	 */
	#if SCRIPTING_ALLOWED
	public var scriptsAllowed:Bool = true;

	/**
	 * Current injected script attached to the state. To add one, create a file at path "data/states/stateName" (ex: data/states/FreeplayState)
	 */
	public var stateScripts:ScriptPack;

	public static var lastScriptName:String = null;
	public static var lastStateName:String = null;

	public var scriptName:String = null;

	public function new(scriptsAllowed:Bool = true, ?scriptName:String) {
		if(lastStateName != (lastStateName = Type.getClassName(Type.getClass(this)))) {
			lastScriptName = null;
		}
		this.scriptName = scriptName != null ? scriptName : lastScriptName;
		lastScriptName = this.scriptName;
	}

	function loadScript(?customPath:String) {
		var className = Type.getClassName(Type.getClass(this));
		if (stateScripts == null)
			(stateScripts = new ScriptPack(className)).setParent(this);
		if (scriptsAllowed) {
			if (stateScripts.scripts.length == 0) {
				var scriptName = this.scriptName != null ? this.scriptName : className.substr(className.lastIndexOf(".")+1);
				var filePath:String = "classes/" + scriptName;
				if (customPath != null)
					filePath = customPath;

				var path = Paths.script('data/${filePath}');
				trace('CustomSwitchPath: $path');
				var script = Script.create(path);
				script.remappedNames.set(script.fileName, '${script.fileName}');
				stateScripts.add(script);
				script.load();
				call('create');
			}
			else stateScripts.reload();
		}
	}
	#else
	public function new() {}
	#end

	public function call(name:String, ?args:Array<Dynamic>, ?defaultVal:Dynamic):Dynamic {
		// calls the function on the assigned script
		#if SCRIPTING_ALLOWED
		if(stateScripts != null)
			return stateScripts.call(name, args);
		#end
		return defaultVal;
	}

	public function event<T:CancellableEvent>(name:String, event:T):T {
		#if SCRIPTING_ALLOWED
		if(stateScripts != null)
			stateScripts.call(name, [event]);
		#end
		return event;
	}
}