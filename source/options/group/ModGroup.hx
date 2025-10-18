package options.group;

#if SCRIPTING_ALLOWED
import funkin.backend.scripting.HScript;

class ModGroupBase extends OptionCata
{
	public function new(X:Float, Y:Float, width:Float, height:Float, scriptsAllowed:Bool = true, ?scriptName:String)
	{
		super(X, Y, width, height);

		if(lastStateName != (lastStateName = Type.getClassName(Type.getClass(this)))) {
			lastScriptName = null;
		}
		this.scriptName = scriptName != null ? scriptName : lastScriptName;
		lastScriptName = this.scriptName;

		#if SCRIPTING_ALLOWED loadScript(); #end

		changeHeight(0);
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

	function loadScript(?customPath:String) {
		var className = Type.getClassName(Type.getClass(this));
		if (stateScripts == null)
			(stateScripts = new ScriptPack(className)).setParent(this);
		if (scriptsAllowed) {
			if (stateScripts.scripts.length == 0) {
				var scriptName = this.scriptName != null ? this.scriptName : className.substr(className.lastIndexOf(".")+1);
				var filePath:String = "options/" + scriptName;
				if (customPath != null)
					filePath = customPath;
				var path = Paths.script('data/${filePath}');
				var script = Script.create(path);
				script.remappedNames.set(script.fileName, '${script.fileName}');
				stateScripts.add(script);
				script.load();
				callScripts('create');
			}
			else stateScripts.reload();
		}
	}
	#end

	public function callScripts(name:String, ?args:Array<Dynamic>, ?defaultVal:Dynamic):Dynamic {
		// calls the function on the assigned script
		#if SCRIPTING_ALLOWED
		if(stateScripts != null)
			return stateScripts.call(name, args);
		#end
		return defaultVal;
	}

	public function createPost() {
		callScripts("postCreate");
	}
}

class ModGroup extends ModGroupBase {

	/**
	* Name of HScript file in assets/data/states.
	*/
	public static var lastName:String = null;
	/**
	* Last Optional extra data.
	*/
	public static var lastData:Dynamic = null;

	/**
	* Optional extra data.
	*/
	public var data:Dynamic = null;

	/**
	* ModSubState Constructor.
	* Inherits from MusicBeatSubstate and allows the execution of an HScript from assets/data/states passed via parameters.
	*
	* @param _stateName Name or path to a HScript file from assets/data/states.
	* @param _data Optional extra Dynamic data passed from a previous state (JSON suggested).
	*/
	public function new(X:Float, Y:Float, width:Float, height:Float, _stateName:String, ?_data:Dynamic) {
		if(_stateName != null && _stateName != lastName) {
			lastName = _stateName;
			lastData = null;
		}

		if(_data != null)
			lastData = _data;

		data = lastData;
		super(X, Y, width, height, true, lastName);
	}
}
#end