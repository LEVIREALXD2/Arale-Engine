package options;

import MainMenuState;
import FreeplayState;
#if TOUCH_CONTROLS
import mobile.substates.MobileControlSelectSubState;
import mobile.substates.MobileExtraControl;
#end
import mobile.states.CopyState;
import ClientPrefs;
import StageData;
import options.NovaFlareOptionsObjects.Option;

class OptionsState extends MusicBeatState
{
	public static var instance:OptionsState;
	#if android final lastStorageType:String = ClientPrefs.data.storageType; #end

	var filePath:String = 'menuExtend/OptionsState/';

	var naviArray = [];

	////////////////////////////////////////////////////////////////////////////////////////////

	public var baseColor = 0x302E3A;
	public var mainColor = 0x24232C;


	////////////////////////////////////////////////////////////////////////////////////////////

	public var mouseEvent:MouseEvent;

	var naviBG:RoundRect;
	var naviSpriteGroup:Array<NaviSprite> = [];

	var cataGroup:Array<OptionCata> = [];
	public var cataMove:MouseMove;
	public var cataCount:Array<StringRect> = []; //string开启的检测

	var downBG:Rect;
	var tipButton:TipButton;
	var specButton:FuncButton;

	var specBG:Rect;
	var searchButton:SearchButton;
	var resetButton:ResetButton;

	var backButton:GeneralBack;

	override function create()
	{
		persistentUpdate = persistentDraw = true;
		instance = this;
		FlxG.mouse.visible = true;
		Main.fpsVar.visible = false;
		Main.fpsVarNova.visible = false;

		naviArray = [
			'Graphics',
			'Visual & UI',
			'Note Skins',
			'Gameplay',
			'Controls'
		];

		mouseEvent = new MouseEvent();
		add(mouseEvent);

		var bg = new Rect(0, 0, FlxG.width, FlxG.height, 0, 0, baseColor);
		add(bg);

		naviBG = new RoundRect(0, 0, UIScale.adjust(FlxG.width * 0.2), FlxG.height, 0, LEFT_CENTER,  mainColor);
		add(naviBG);

		for (i in 0...naviArray.length)
		{
			var naviSprite = new NaviSprite(UIScale.adjust(FlxG.width * 0.005), UIScale.adjust(FlxG.height * 0.005) + i * UIScale.adjust(FlxG.height * 0.1), UIScale.adjust(FlxG.width * 0.19), UIScale.adjust(FlxG.height * 0.09), naviArray[i], i, false);
			naviSprite.antialiasing = ClientPrefs.data.antialiasing;
			add(naviSprite);
			naviSpriteGroup.push(naviSprite);
		}

		/////////////////////////////////////////////////////////////////

		for (i in 0...naviArray.length) {
			addCata(naviArray[i]);
		}

		var moveHeight:Float = 100;
		for (num in cataGroup) {
			if (num != cataGroup[cataGroup.length - 1]) {
				moveHeight -= num.bg.realHeight;
				moveHeight -= UIScale.adjust(FlxG.width * (0.8 / 40));
			} else {
				moveHeight -= cataGroup[cataGroup.length - 1].bg.realHeight - UIScale.adjust(FlxG.height * 0.8);
				moveHeight -= UIScale.adjust(FlxG.width * (0.8 / 40)) * 2;
			}
		}
		cataMove = new MouseMove(OptionsState, 'cataPosiData', 
								[moveHeight, 100],
								[ 
									[UIScale.adjust(FlxG.width * 0.2), FlxG.width], 
									[0, FlxG.height - Std.int(UIScale.adjust(FlxG.height * 0.1))]
								],
								cataMoveEvent);
		add(cataMove);
		cataMoveEvent(true);
			
		/////////////////////////////////////////////////////////////

		downBG = new Rect(0, FlxG.height - Std.int(UIScale.adjust(FlxG.height * 0.1)), FlxG.width, Std.int(UIScale.adjust(FlxG.height * 0.1)), 0, 0, mainColor, 0.75);
		add(downBG);

		tipButton = new TipButton(
			UIScale.adjust(FlxG.width * 0.2) + UIScale.adjust(FlxG.height * 0.01), 
			downBG.y + Std.int(UIScale.adjust(FlxG.height * 0.01)),
			FlxG.width - UIScale.adjust(FlxG.width * 0.2) - UIScale.adjust(FlxG.height * 0.01) - Std.int(UIScale.adjust(FlxG.width * 0.15)) - Std.int(UIScale.adjust(FlxG.height * 0.01) * 2), 
			Std.int(UIScale.adjust(FlxG.height * 0.08))
		);
		add(tipButton);

		specButton = new FuncButton(
			FlxG.width - Std.int(UIScale.adjust(FlxG.width * 0.15)) - Std.int(UIScale.adjust(FlxG.height * 0.01)), 
			downBG.y + Std.int(UIScale.adjust(FlxG.height * 0.01)),
			Std.int(UIScale.adjust(FlxG.width * 0.15)), 
			Std.int(UIScale.adjust(FlxG.height * 0.08)),
			specChange
		);
		specButton.alpha = 0.5;
		add(specButton);

		//////////////////////////////////////////////////////////////////////

		specBG = new Rect(UIScale.adjust(FlxG.width * 0.2), 0, FlxG.width - UIScale.adjust(FlxG.width * 0.2), Std.int(UIScale.adjust(FlxG.height * 0.1)), 0, 0, mainColor, 0.75);
		add(specBG);

		searchButton = new SearchButton(specBG.x + specBG.height * 0.2, specBG.height * 0.2, specBG.width * 0.5, specBG.height * 0.6);
		add(searchButton);

		resetButton = new ResetButton(specBG.x + specBG.height * 0.2 * 2 + searchButton.width, specBG.height * 0.2, specBG.width - (specBG.height * 0.2 * 3 + searchButton.width), specBG.height * 0.6);
		add(resetButton);

		backButton = new GeneralBack(0, 720 - 72, UIScale.adjust(FlxG.width * 0.2), UIScale.adjust(FlxG.height * 0.1), 'Back', EngineSet.mainColor, backMenu);
		add(backButton);

		super.create();
	}

	public var ignoreCheck:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (cataCount.length > 0) cataMove.inputAllow = false;
		else cataMove.inputAllow = true;

		var posi:Int = -1;
		for (cata in 0...cataGroup.length - 1) {
			if (cataGroup[cata].y < FlxG.height / 2 && cataGroup[cata].y + cataGroup[cata].bg.realHeight > FlxG.height / 2) {
				posi = cata;
				break;
			}
		}

		for (spr in 0...naviSpriteGroup.length -1) {
			if (spr == posi) naviSpriteGroup[spr].cataChoose = true;
			else naviSpriteGroup[spr].cataChoose = false;
		}
	}

	//Apply Automatically
	override function openSubState(SubState:flixel.FlxSubState) {
		super.openSubState(SubState);
		persistentUpdate = false;
	}

	override function closeSubState()
	{
		super.closeSubState();
		persistentUpdate = true;
	}

	public function startSearch(text:String, time = 0.6) {
		for (cata in cataGroup) {
			cata.startSearch(text, time);
		}
	}

	public function changeCata(sort:Int) {
		if (cataCount.length > 0) return;
		var outputData:Float = 100;
		for (cata in 0...sort) {
			outputData -= cataGroup[cata].bg.realHeight;
			outputData -= UIScale.adjust(FlxG.width * (0.8 / 40));
		}
		cataMove.lerpData = outputData;
	}

	public function changeTip(str:String) {
		tipButton.changeText(str);
	}

	public function addCata(type:String) {
		var obj:OptionCata = null;

		var outputX:Float = naviBG.width + UIScale.adjust(FlxG.width * (0.8 / 40)); //已被初始化
		var outputWidth:Float = UIScale.adjust(FlxG.width * (0.8 - (0.8 / 40 * 2))); //已被初始化
		var outputY:Float = 100; //等待被初始化
		var outputHeight:Float = 200; //等待被初始化

		switch (type) 
		{
			case 'Graphics':
				obj = new GraphicsGroup(outputX, outputY, outputWidth, outputHeight);
			case 'Visual & UI':
				obj = new UIGroup(outputX, outputY, outputWidth, outputHeight);
			case 'Note Skins':
				obj = new SkinGroup(outputX, outputY, outputWidth, outputHeight);
			case 'Gameplay':
				obj = new GameplayGroup(outputX, outputY, outputWidth, outputHeight);
			case 'Controls':
				obj = new MobileGroup(outputX, outputY, outputWidth, outputHeight);
			default:
				//nothing lol
		}
		cataGroup.push(obj);
		add(obj);
	}

	public function addMove(tar:MouseMove) {
		add(tar);
	}

	public function removeMove(tar:MouseMove) {
		remove(tar);
	}

	static public var cataPosiData:Float = 100;
	public function cataMoveEvent(init:Bool = false){
		for (i in 0...cataGroup.length) {
			if (i == 0) cataGroup[i].y = cataPosiData;
			else cataGroup[i].y = cataGroup[i - 1].y + cataGroup[i - 1].bg.realHeight + UIScale.adjust(FlxG.width * (0.8 / 40));
		}
	}

	static public var naviPosiData:Float = 0;

	var specOpen:Bool = false;
	var specTween:Array<FlxTween> = [];
	var specTime = 0.6;
	public function specChange() {
		for (tween in specTween) {
			if (tween != null) tween.cancel();
		}

		var newPoint:Float = 0;
		if (!specOpen) {
			newPoint = FlxG.width;
			cataMove.moveLimit[1] = 30;
		} else {
			newPoint = UIScale.adjust(FlxG.width * 0.2);
			cataMove.moveLimit[1] = 100;
		}

		var tween = FlxTween.tween(specBG, {x: newPoint}, specTime, {ease: FlxEase.expoInOut});
		specTween.push(tween);
		var tween = FlxTween.tween(searchButton, {x: newPoint + specBG.height * 0.2}, specTime, {ease: FlxEase.expoInOut});
		specTween.push(tween);
		var tween = FlxTween.tween(resetButton, {x: newPoint + specBG.height * 0.2 + searchButton.width + specBG.height * 0.2}, specTime, {ease: FlxEase.expoInOut});
		specTween.push(tween);

		specOpen = !specOpen;
	}

	public function moveState(type:Int)
	{
		switch (type)
		{
			case 1: // NoteOffsetState
				LoadingState.loadAndSwitchState(new NoteOffsetState());
			case 2: // NotesSubState
				persistentUpdate = false;
				openSubState(new NotesSubState());
			case 3: // ControlsSubState
				persistentUpdate = false;
				openSubState(new ControlsSubState());
			#if TOUCH_CONTROLS
			case 4: // MobileControlSelectSubState
				persistentUpdate = false;
				openSubState(new MobileControlSelectSubState());
			case 5: // MobileExtraControl
				persistentUpdate = false;
				openSubState(new MobileExtraControl());
			#end
			case 6: // CopyStates
				LoadingState.loadAndSwitchState(new CopyState());
		}
	}

	public function resetData()
	{
		for (spr in 0...naviSpriteGroup.length) {
			if (naviSpriteGroup[spr].cataChoose == true) {
				cataGroup[spr].resetData();
				break;
			}
		}
	}

	public static var stateType:Int = 0; //检测到底退回到哪个界面
	var backCheck:Bool = false;
	function backMenu()
	{
		if (!backCheck)
		{
			backCheck = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			#if android
			if (ClientPrefs.data.storageType != lastStorageType) {
				File.saveContent(lime.system.System.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.data.storageType);
				ClientPrefs.saveSettings();
				CoolUtil.showPopUp('Storage Type has been changed and you needed restart the game!!\nPress OK to close the game.', 'Notice!');
				lime.system.System.exit(0);
			}
			else
			#end
				ClientPrefs.saveSettings();
			#if EXTRA_FPSCOUNTER onChangeFPSCounterShit(); #end
			switch (stateType)
			{
				case 0:
					MusicBeatState.switchState(new MainMenuState());
					FlxG.mouse.visible = false;
				case 1:
						CustomSwitchState.switchMenus('Freeplay');
				case 2:
					MusicBeatState.switchState(new PlayState());
					FlxG.mouse.visible = false;
			}
			stateType = 0;
		}
	}

	#if EXTRA_FPSCOUNTER
	public static function onChangeFPSCounterShit()
	{
		Main.fpsVar.visible = false;
		Main.fpsVarNova.visible = false;

		if (ClientPrefs.data.FPSCounter == 'NovaFlare')
			Main.fpsVarNova.visible = ClientPrefs.data.showFPS;
		else if (ClientPrefs.data.FPSCounter == 'Psych')
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}
	#end
}