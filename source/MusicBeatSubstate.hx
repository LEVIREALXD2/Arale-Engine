package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.input.actions.FlxActionInput;

#if SCRIPTING_ALLOWED
import funkin.backend.scripting.HScript;
#end

class MusicBeatSubstate extends FlxSubState
{
	public static var instance:MusicBeatSubstate;
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	public var curStepFloat:Float;
	public var curBeatFloat:Float;
	public static var stepsPerBeat:Float = 4;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	#if TOUCH_CONTROLS
	public var mobilePad:MobilePad;
	public var mobilec:IMobileControls;

	public function addMobilePad(?DPad:String, ?Action:String) {
		mobilePad = new MobilePad(DPad, Action);
		add(mobilePad);
		mobilePad.alpha = ClientPrefs.data.mobilePadAlpha;
	}

	public function addMobileControls(?customControllerValue:Int, ?mode:String) {
		//Put this here bc control system is changed
		if (ClientPrefs.data.hitboxhint){
			var hitbox_hint:FlxSprite = new FlxSprite(0, (ClientPrefs.data.hitboxLocation == 'Bottom' && ClientPrefs.data.extraKeys != 0) ? -150 : 0).loadGraphic(Paths.image('mobile/Hitbox/hitbox_hint'));
			add(hitbox_hint);
		}

		if(ClientPrefs.data.hitboxmode == 'Classic') {
			mobilec = new HitboxOld();
		} else {
			if (mode != null || mode != "NONE") mobilec = new Hitbox(mode);
			else mobilec = new Hitbox();
		}

		var camcontrol = new flixel.FlxCamera();
		FlxG.cameras.add(camcontrol, false);
		camcontrol.bgColor.alpha = 0;
		mobilec.instance.cameras = [camcontrol];

		add(mobilec.instance);
	}

	public function removeMobilePad() {
		if (mobilePad != null)
			remove(mobilePad);
	}

	//removes mobilePad & clears the trackedButtons
	public function removeMobilePadUnsafe() {
		if (mobilePad != null)
			remove(mobilePad);
		mobilePad.instance.trackedButtons.clear();
	}

	public function reAddMobilePad(?DPad:String, ?Action:String) {
		removeMobilePad();
		addMobilePad(DPad, Action);
		addMobilePadCamera();
	}

	public function addMobilePadCamera() {
		var camcontrol = new flixel.FlxCamera();
		camcontrol.bgColor.alpha = 0;
		FlxG.cameras.add(camcontrol, false);
		mobilePad.cameras = [camcontrol];
	}

	override function destroy() {
		super.destroy();
		call("destroy");
		stateScripts = FlxDestroyUtil.destroy(stateScripts);

		if (mobilePad != null)
			mobilePad = FlxDestroyUtil.destroy(mobilePad);
			
		if (mobilec != null)
			mobilec.instance = FlxDestroyUtil.destroy(mobilec.instance);
	}
	#end

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurFloats();
		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		call("update", [elapsed]);
		super.update(elapsed);
	}

	public static function getSubState():MusicBeatSubstate {
		var curSubState:Dynamic = FlxG.state.subState;
		var leState:MusicBeatSubstate = curSubState;
		return leState;
	}

	//Gets the second substate (FlxG.state.subState.subState)
	public static function getExtraSubState():MusicBeatSubstate {
		if (FlxG.state.subState != null) {
			if (FlxG.state.subState.subState != null) {
				var curSubState:Dynamic = FlxG.state.subState.subState;
				var leState:MusicBeatSubstate = curSubState;
				return leState;
			}
			else
				return null;
		}
		else
			return null;
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;
		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}
		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	private function updateCurFloats():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);
		curStepFloat = lastChange.stepTime + ((Conductor.songPosition - lastChange.songTime) / lastChange.stepCrochet);
		curBeatFloat = curStepFloat / stepsPerBeat;
	}

	public function stepHit():Void
	{
		call("stepHit", [curStep]);
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		call("beatHit", [curBeat]);
		//do literally nothing dumbass
	}

	public function sectionHit():Void
	{
		call("measureHit", [curSection]); //Its same as the sectionHit I guess
		//yep, you guessed it, nothing again, dumbass
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}

	/**
	 * SCRIPTING STUFF
	 */
	#if SCRIPTING_ALLOWED

	/**
	 * Current injected script attached to the state. To add one, create a file at path "data/states/stateName" (ex: "data/states/PauseMenuSubstate.hx")
	 */
	public var stateScripts:ScriptPack;

	public var scriptsAllowed:Bool = true;

	public var scriptName:String = null;

	public function new(scriptsAllowed:Bool = true, ?scriptName:String) {
		instance = this;
		super();
		this.scriptName = scriptName;
	}

	function loadScript(?customPath:String) {
		var className = Type.getClassName(Type.getClass(this));
		if (stateScripts == null)
			(stateScripts = new ScriptPack(className)).setParent(this);
		if (scriptsAllowed) {
			if (stateScripts.scripts.length == 0) {
				var scriptName = this.scriptName != null ? this.scriptName : className.substr(className.lastIndexOf(".")+1);
				var filePath:String = "substates/" + scriptName;
				if (customPath != null)
					filePath = customPath;
				var path = Paths.script('data/' + filePath);
				var script = Script.create(path);
				script.remappedNames.set(script.fileName, '${script.fileName}');
				stateScripts.add(script);
				script.load();
				call('create');
			}
			else stateScripts.reload();
		}
	}

	override function create()
	{
		loadScript();
		super.create();
	}
	#end

	public override function tryUpdate(elapsed:Float):Void
	{
		if (persistentUpdate || subState == null) {
			call("preUpdate", [elapsed]);
			update(elapsed);
			call("postUpdate", [elapsed]);
		}

		if (_requestSubStateReset)
		{
			_requestSubStateReset = false;
			resetSubState();
		}
		if (subState != null)
		{
			subState.tryUpdate(elapsed);
		}
	}

	override function close() {
		var event = event("onClose", new CancellableEvent());
		if (!event.cancelled) {
			super.close();
			call("onClosePost");
		}
	}

	public override function createPost() {
		super.createPost();
		trace("Function should call postCreate");
		call("postCreate");
	}

	public function call(name:String, ?args:Array<Dynamic>, ?defaultVal:Dynamic):Dynamic {
		// calls the function on the assigned script
		#if SCRIPTING_ALLOWED
		if(stateScripts != null)
			return stateScripts.call(name, args);
		else
			trace("stateScripts is a null");
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

	public override function onFocus() {
		super.onFocus();
		call("onFocus");
	}

	public override function onFocusLost() {
		super.onFocusLost();
		call("onFocusLost");
	}
}
