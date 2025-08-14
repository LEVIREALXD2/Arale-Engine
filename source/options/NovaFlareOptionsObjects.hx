package options;

import openfl.filters.GlowFilter;
import flixel.graphics.frames.FlxFilterFrames;
import options.NovaFlareOptionsObjects.OptionType;

enum OptionType
{
	BOOL;

	INT;
	FLOAT;
	PERCENT;

	STRING;

	STATE;
	BUTTON;

	TITLE;
	TEXT;

	//特殊化处理
	NOTE;
	SPLASH;
}

class Option extends FlxSpriteGroup
{
	public var onChange:Void->Void = null;
	public var type:OptionType = BOOL;

	public var saveHeight:Float = 0; //仅仅用作最开始设置的时候使用
	public var inter:Float = 10; //设置与设置间的y轴间隔

	public var variable:String = null; // Variable from ClientPrefs.hx
	public var defaultValue:Dynamic = null; //获取出来的数值
	public var description:String = ''; //简短的描述
	public var tips:String; //真正的解释

	//STRING
	public var strGroup:Array<String> = null;

	//INT FLOAT PERCENT;
	public var minValue:Float = 0;
	public var maxValue:Float = 0;
	public var decimals:Int = 0; //数据需要精确到小数点几位
	public var extraDisplay:String = '';

	public var follow:OptionCata;

	/////////////////////////////////////////////

	function getVariableProperty() {
		//createMissingVariable();
		if(Reflect.getProperty(ClientPrefs.data, variable) != null) return Reflect.getProperty(ClientPrefs.data, variable);
		else return Reflect.getProperty(FlxG.save.data, variable);

		/* maybe later
		else if (ClientPrefs.data.customIntOptions.exists(variable) && this.type == INT)
			return ClientPrefs.data.customIntOptions.get(variable);
		else if (ClientPrefs.data.customBoolOptions.exists(variable) && this.type == BOOL)
			return ClientPrefs.data.customBoolOptions.get(variable);
		*/
	}
	
	function createMissingVariable() {
		if (!Reflect.hasField(ClientPrefs.data, variable) && !ClientPrefs.data.customIntOptions.exists(variable) && this.type == INT)
			ClientPrefs.data.customIntOptions.set(variable, 0);
		else if (!Reflect.hasField(ClientPrefs.data, variable) && !ClientPrefs.data.customBoolOptions.exists(variable) && this.type == BOOL)
			ClientPrefs.data.customBoolOptions.set(variable, false);
	}

	function setVariableProperty(value:Dynamic) {
		if(Reflect.getProperty(ClientPrefs.data, variable) != null) return Reflect.setProperty(ClientPrefs.data, variable, value);
		else Reflect.setProperty(FlxG.save.data, variable, value);

		/* maybe later
		else if (ClientPrefs.data.customIntOptions.exists(variable) && this.type == INT)
			return ClientPrefs.data.customIntOptions.set(variable, value);
		else if (ClientPrefs.data.customBoolOptions.exists(variable) && this.type == BOOL)
			return ClientPrefs.data.customBoolOptions.set(variable, value);
		*/
	}

	public function new(follow:OptionCata, description:String = '', tips:String = '', variable:String = '', type:OptionType = BOOL, ?data:Dynamic)
	{
		super();
		if (type == BUTTON) type = STATE;

		this.follow = follow;

		this.variable = variable;
		this.type = type;
		this.description = description;
		this.tips = tips;

		///////////////////////////////////////////////////////////////////////////////////////////////////

		if (this.type != STATE && variable != '')
			this.defaultValue = getVariableProperty();

		switch (type)
		{
			case BOOL:
				if (defaultValue == null)
					defaultValue = false;
			case INT, FLOAT, PERCENT:
				if (defaultValue == null)
					defaultValue = 0;
			case STRING:
				strGroup = data;
				if (strGroup.indexOf(defaultValue) == -1) {
					if (data.length > 0)
						defaultValue = data[0];
					if (defaultValue == null)
						defaultValue = '';
				}
			default:
		}

		///////////////////////////////////////////////////////////////////////////////////////////////////

		switch (type)
		{
			case BOOL:
				//bool没有特殊需要加的

			case INT:
				this.minValue = data[0];
				this.maxValue = data[1];
				if (data[2] != null) this.extraDisplay = data[2];

			case FLOAT:
				this.minValue = data[0];
				this.maxValue = data[1];
				this.decimals = data[2];
				if (data[3] != null) this.extraDisplay = data[3];

			case PERCENT:
				this.minValue = data[0];
				this.maxValue = data[1];
				this.decimals = data[2];
				this.extraDisplay = '%';

			case STRING:
				this.strGroup = data;
			default:
		}

		///////////////////////////////////////////////////////////////////////////////////////////////////

		switch (type)
		{
			case BOOL:
				addBool();
			case INT, FLOAT, PERCENT:
				addNum();
			case STRING:
				addString();
			case TEXT:
				addTip();
			case TITLE:
				addTitle();
			case STATE:
				addState();
			default:
		}
	}

	var overlopCheck:Float;
	var alreadyShowTip:Bool = false;
	public var allowUpdate:Bool = true; //仅仅用于搜索全局禁止更新(代码作用于option的其他子类)
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		followX = follow.mainX;
		followY = follow.mainY;

		if (!allowUpdate) return;

		var mouse = FlxG.mouse;

		if (mouse.overlaps(this)) {
			overlopCheck += elapsed;
		} else {
			overlopCheck = 0;
			alreadyShowTip = false;
		}

		if (overlopCheck >= 0.2 && !alreadyShowTip) {
			OptionsState.instance.changeTip(tips);
			alreadyShowTip = true;
		}
	}

	////////////////////////////////////////////////////////

	var boolButton:BoolButton;
	function addBool()
	{
		baseBGAdd();

		var clacHeight = baseBG.height - (baseTar.height + baseLine.height) - baseBG.mainRound * 2;
		var clacWidth = baseBG.width * 0.4 - baseBG.mainRound;
		boolButton = new BoolButton(baseBG.width * 0.6, baseTar.height + baseLine.height + baseBG.mainRound, clacWidth, clacHeight, this);
		add(boolButton);
	}

	public var valueText:FlxText;
	var numButton:NumButton;
	function addNum()
	{
		baseBGAdd(true);

		valueText = new FlxText(0, 0, 0, defaultValue + ' ' + extraDisplay, Std.int(baseBG.width / 20 / 2));
		if (type == PERCENT) valueText.text = Std.string(defaultValue * 100) + ' ' + extraDisplay;
		valueText.setFormat(Paths.font('montserrat.ttf'), Std.int(baseBG.width / 30 / 2), 0xffffff, RIGHT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		valueText.antialiasing = ClientPrefs.data.antialiasing;
		valueText.borderStyle = NONE;
		valueText.x += baseBG.width - valueText.textField.textWidth - baseBG.mainRound;
		valueText.alpha = 0.3;
		//valueText.blend = ADD;
		add(valueText);


		var clacHeight = baseBG.height - (baseTar.height + baseLine.height) - baseBG.mainRound * 2;
		var clacWidth = baseBG.width * 0.5 - baseBG.mainRound * 2;
		numButton = new NumButton(baseBG.width * 0.5 + baseBG.mainRound, baseTar.height + baseLine.height + baseBG.mainRound, clacWidth, clacHeight, this);
		add(numButton);
	}

	public function updateDisText() {
		valueText.text = defaultValue + ' ' + extraDisplay;
		if (type == PERCENT) valueText.text = Std.string(defaultValue * 100) + ' ' + extraDisplay; //NovaFlare Doesn't have this right now, Idk why
		valueText.x = followX + innerX + baseBG.width - valueText.textField.textWidth - baseBG.mainRound;
	}

	public var stringRect:StringRect;
	public var select:StringSelect;
	function addString()
	{
		baseBGAdd();

		valueText = new FlxText(0, 0, 0, defaultValue + ' ' + extraDisplay, Std.int(baseBG.width / 20 / 2));
		valueText.setFormat(Paths.font('montserrat.ttf'), Std.int(baseBG.width / 30), 0xffffff, RIGHT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		valueText.antialiasing = ClientPrefs.data.antialiasing;
		valueText.borderStyle = NONE;
		valueText.x += baseBG.width - valueText.textField.textWidth - baseBG.mainRound;
		valueText.alpha = 0.3;
		//valueText.blend = ADD;
		add(valueText);

		var clacHeight = baseBG.height - (baseTar.height + baseLine.height) - baseBG.mainRound * 2;
		var clacWidth = baseBG.width * 0.4 - baseBG.mainRound;
		stringRect = new StringRect(baseBG.width * 0.6, baseTar.height + baseLine.height + baseBG.mainRound, clacWidth, clacHeight, this);
		add(stringRect);

		select = new StringSelect(0, baseBG.height + inter, follow.bg.realWidth * (1 - (1 / 2 / 50 * 2)), follow.bg.width * 0.2, this);
		select.visible = false;
		add(select);
	}

	public function reloadStringSelection() {
		var clacHeight = baseBG.height - (baseTar.height + baseLine.height) - baseBG.mainRound * 2;
		var clacWidth = baseBG.width * 0.4 - baseBG.mainRound;
		stringRect.reload(baseBG.width * 0.6, baseTar.height + baseLine.height + baseBG.mainRound, clacWidth, clacHeight, this);
		select.reload(0, baseBG.height + inter, follow.bg.realWidth * (1 - (1 / 2 / 50 * 2)), follow.bg.width * 0.2, this);
	}

	var tipsLight:Rect;
	var tipsText:FlxText;
	function addTip()
	{
		tipsText = new FlxText(0, 0, 0, description, Std.int(follow.width / 10));
		tipsText.setFormat(Paths.font('montserrat.ttf'), Std.int(follow.bg.realWidth / 45), 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		tipsText.antialiasing = ClientPrefs.data.antialiasing;
		tipsText.borderStyle = NONE;
		tipsText.active = false;
		add(tipsText);

		var data = tipsText.height * 0.5;
		tipsLight = new Rect(0, 0, data / 6, data, data / 4, data / 4, EngineSet.mainColor);
		add(tipsLight);

		tipsLight.y += (tipsText.height - tipsLight.height) / 2;

		tipsText.x += tipsLight.width * 2;

		var glowFilter:GlowFilter = new GlowFilter(EngineSet.mainColor, 0.75, tipsLight.width * 2, tipsLight.width * 2);
		var filterFrames = FlxFilterFrames.fromFrames(tipsLight.frames, Std.int(tipsLight.width * 10), Std.int(tipsLight.height), [glowFilter]);
		filterFrames.applyToSprite(tipsLight, false, true);

		saveHeight = tipsText.height + inter;
	}

	var titleLight:Rect;
	var title:FlxText;
	var titLine:Rect;
	function addTitle()
	{
		title = new FlxText(0, 0, 0, description, Std.int(follow.width / 10));
		title.setFormat(Paths.font('montserrat.ttf'), Std.int(follow.bg.realWidth / 30), 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		title.antialiasing = ClientPrefs.data.antialiasing;
		title.borderStyle = NONE;
		title.x += follow.bg.mainRound;
		title.active = false;
		add(title);

		var data = title.height * 0.5;
		titleLight = new Rect(follow.bg.mainRound, 0, data / 6, data, data / 4, data / 4, EngineSet.mainColor);
		add(titleLight);

		titleLight.x -= titleLight.width / 2;
		titleLight.y += (title.height - titleLight.height) / 2;

		title.x += titleLight.width * 2;

		var glowFilter:GlowFilter = new GlowFilter(EngineSet.mainColor, 0.75, titleLight.width * 2, titleLight.width * 2);
		var filterFrames = FlxFilterFrames.fromFrames(titleLight.frames, Std.int(titleLight.width * 10), Std.int(titleLight.height), [glowFilter]);
		filterFrames.applyToSprite(titleLight, false, true);

		titLine = new Rect(0, title.height, follow.bg.mainWidth, follow.width / 400, 0, 0, 0xFFFFFF, 0.3);
		titLine.active = false;
		add(titLine);

		saveHeight = title.height + titLine.height + inter;
	}

	var stateButton:StateButton;
	function addState()
	{
		var double = false; //还是小的比较好看

		var calcWidth:Float = 0;
		var calcHeight:Float = 0;

		if (!double) calcWidth = follow.bg.realWidth * ((1 - (1 / 2 / 50 * 3)) / 2);
		else calcWidth = follow.bg.realWidth * (1 - (1 / 2 / 50 * 2));

		var calcHeight:Float = 0;
		if (!double) calcHeight = calcWidth * 0.16;
		else calcHeight = calcWidth * 0.1;

		stateButton = new StateButton(calcWidth, calcHeight, this);
		add(stateButton);

		saveHeight = stateButton.bg.height + inter;
	}

	public var baseBG:Rect;
	var baseTar:FlxText;
	var baseLine:Rect;
	var baseDesc:FlxText;
	var mult:Float = 1; //一些数据需要保持一致
	function baseBGAdd(double:Bool = false)
	{
		if (double) mult = 2;
		else mult = 1;

		var calcWidth:Float = 0;
		if (!double) calcWidth = follow.bg.realWidth * ((1 - (1 / 2 / 50 * 3)) / 2);
		else calcWidth = follow.bg.realWidth * (1 - (1 / 2 / 50 * 2));

		var calcHeight:Float = 0;
		if (!double) calcHeight = calcWidth * 0.16;
		else calcHeight = calcWidth * 0.1;

		baseBG = new Rect(0, 0, calcWidth, calcHeight, calcWidth / 75 / mult, calcWidth / 75 / mult, 0xffffff, 0.1);
		add(baseBG);

		baseTar = new FlxText(0, 0, 0, 'Target: ' + variable, Std.int(baseBG.width / 20 / mult));
		baseTar.setFormat(Paths.font('montserrat.ttf'), Std.int(baseBG.width / 30 / mult), 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		baseTar.antialiasing = ClientPrefs.data.antialiasing;
		baseTar.borderStyle = NONE;
		baseTar.x += baseBG.mainRound;
		baseTar.alpha = 0.3;
		//baseTar.blend = ADD;
		baseTar.active = false;
		add(baseTar);

		baseLine = new Rect(0, baseTar.height, baseBG.width, baseBG.width / 400 / mult, 0, 0, 0xFFFFFF, 0.3);
		baseLine.active = false;
		add(baseLine);

		var calcWidth = baseBG.width * 0.58;
		if (double) calcWidth = baseBG.width * 0.5;
		baseDesc = new FlxText(0, baseTar.height + baseLine.height, calcWidth, description, Std.int(follow.width / 10));
		baseDesc.setFormat(Paths.font('montserrat.ttf'), Std.int(baseBG.width / 25 / mult), 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		baseDesc.antialiasing = ClientPrefs.data.antialiasing;
		baseDesc.borderStyle = NONE;
		baseDesc.active = false;

		baseDesc.y -= (baseDesc.height - baseDesc.textField.textHeight) / 2;

		var clacHeight = baseDesc.textField.textHeight / (baseBG.height - baseTar.height + baseLine.height);
		if (clacHeight > 1) baseDesc.size = Std.int(baseDesc.size / clacHeight / 1.05); //原理来讲不应该超过这个高度的，这个玩意纯粹的防止蠢人

		baseDesc.x += baseBG.mainRound;
		baseDesc.y += (baseBG.height - baseTar.height + baseLine.height - baseDesc.textField.textHeight) / 2;
		add(baseDesc);

		saveHeight = baseBG.height + inter;
	}

	///////////////////////////////////////////////

	public function change()
	{
		if (onChange != null)
			onChange();
	}

	dynamic public function getValue():Dynamic
	{
		var value = getVariableProperty();
		return value;
	}

	dynamic public function setValue(value:Dynamic)
	{
		defaultValue = value;
		return setVariableProperty(value);
	}

	public function resetData()
	{
		if (variable == '' || type == STATE || type == TEXT || type == TITLE)
			return;
		try {
			//unfortunately you can't reset the custom variables
			if(Reflect.hasField(ClientPrefs.data, variable)) {
				Reflect.setProperty(ClientPrefs.data, variable, Reflect.getProperty(ClientPrefs.defaultData, variable));
				defaultValue = Reflect.getProperty(ClientPrefs.defaultData, variable);
			} else {
				trace('Error: Custom Variables');
			}
		}
		switch (type)
		{
			case BOOL:
				boolButton.updateDisplay();
			case INT, FLOAT, PERCENT:
				numButton.initData();
				updateDisText();
			case STRING:
				updateDisText();
			default:
		}
		change();
	}

	public function startSearch(text:String):Bool {
		if (variable.indexOf(text) != -1) return true;
		if (description.indexOf(text) != -1) return true;
		if (tips.indexOf(text) != -1) return true;
		return false;
	}

	////////////////////////////////////////////////

	public var followX:Float = 0; //optioncata位置
	public var innerX:Float = 0; //这个option在optioncata内部位置
	public var xOff:Float = 0; //用于图形在cata内部位移
	var xTween:FlxTween = null;
	public function changeX(data:Float, isMain:Bool = true, time:Float = 0.6) {
		var output = isMain ? followX : xOff;
		output += data;

		if (xTween != null) xTween.cancel();
		xTween = FlxTween.tween(this, {x: followX + innerX + xOff}, time, {ease: FlxEase.expoInOut});
	}

	public function initX(data:Float, innerData:Float, ?specData:Float = 0) {
		followX = data;
		innerX = innerData;
		if (type == TITLE) return;
		this.x = followX + innerX;
		if (specData != 0) { 
			this.select.x -= specData;
			this.select.specX = specData;
		}
	}

	public var followY:Float = 0; //optioncata在主体的位置
	public var innerY:Float = 0; //optioncata内部位置
	public var yOff:Float = 0; //用于图形在cata内部位移
	public var sameY:Bool = false; //用于string展开兼容
	public var yTween:FlxTween = null;
	public function changeY(data:Float, isMain:Bool = true, time:Float = 0.6) {
		var output = isMain ? followY : yOff;
		output += data;

		if (yTween != null) yTween.cancel();
		yTween = FlxTween.tween(this, {y: followY + innerY + yOff}, time, {ease: FlxEase.expoInOut});
	}

	public function initY(data:Float, innerData:Float) {
		followY = data;
		innerY = innerData;
		this.y = followY + innerY;
	}

	////////////////////////////////////////////////////////////////////

	public var alphaTween:Array<FlxTween> = [];
	public function changeAlpha(isAdd:Bool, time:Float = 0.6) { //无敌了haxeflixel，flxspritegroup你妈炸了
		if (alphaTween.length > 0) {
			for (tween in alphaTween) {
				if (tween != null) tween.cancel();
			}
		}

		if (isAdd) {
			switch (type)
			{
				case BOOL:
					baseChangeAlpha(isAdd, time);
					var tween = FlxTween.tween(boolButton, {alpha: 1}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
				case INT, FLOAT, PERCENT:
					baseChangeAlpha(isAdd, time);
					var tween = FlxTween.tween(valueText, {alpha: 0.3}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
					var tween = FlxTween.tween(numButton.addButton, {alpha: 1}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
					var tween = FlxTween.tween(numButton.deleteButton, {alpha: 1}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
					var tween = FlxTween.tween(numButton.moveBG, {alpha: 0.4}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
					var tween = FlxTween.tween(numButton.moveDis, {alpha: 1}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
					var tween = FlxTween.tween(numButton.rod, {alpha: 1}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
				case STRING:
					baseChangeAlpha(isAdd, time);
					var tween = FlxTween.tween(valueText, {alpha: 0.3}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
					var tween = FlxTween.tween(stringRect.bg, {alpha: 0.3}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
					var tween = FlxTween.tween(stringRect.dis, {alpha: 0.3}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
					var tween = FlxTween.tween(stringRect.disText, {alpha: 0.3}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
				case STATE:
					var tween = FlxTween.tween(stateButton.bg, {alpha: 0.5}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
					var tween = FlxTween.tween(stateButton.stateName, {alpha: 0.8}, time, {ease: FlxEase.expoIn});
					alphaTween.push(tween);
				default:
			}
		} else {
			switch (type)
			{
				case BOOL:
					baseChangeAlpha(isAdd, time);
					var tween = FlxTween.tween(boolButton, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
				case INT, FLOAT, PERCENT:
					baseChangeAlpha(isAdd, time);
					var tween = FlxTween.tween(valueText, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
					var tween = FlxTween.tween(numButton.addButton, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
					var tween = FlxTween.tween(numButton.deleteButton, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
					var tween = FlxTween.tween(numButton.moveBG, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
					var tween = FlxTween.tween(numButton.moveDis, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
					var tween = FlxTween.tween(numButton.rod, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
				case STRING:
					baseChangeAlpha(isAdd, time);
					var tween = FlxTween.tween(valueText, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
					var tween = FlxTween.tween(stringRect.bg, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
					var tween = FlxTween.tween(stringRect.dis, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
					var tween = FlxTween.tween(stringRect.disText, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
				case STATE:
					var tween = FlxTween.tween(stateButton.bg, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
					var tween = FlxTween.tween(stateButton.stateName, {alpha: 0}, time, {ease: FlxEase.expoOut});
					alphaTween.push(tween);
				default:
			}
		}
	}

	public function baseChangeAlpha(isAdd:Bool, time) {
		if (isAdd) {
			var tween = FlxTween.tween(baseBG, {alpha: 0.1}, time, {ease: FlxEase.expoIn});
			alphaTween.push(tween);
			var tween = FlxTween.tween(baseTar, {alpha: 0.3}, time, {ease: FlxEase.expoIn});
			alphaTween.push(tween);
			var tween = FlxTween.tween(baseLine, {alpha: 0.3}, time, {ease: FlxEase.expoIn});
			alphaTween.push(tween);
			var tween = FlxTween.tween(baseDesc, {alpha: 1}, time, {ease: FlxEase.expoIn});
			alphaTween.push(tween);
			
		} else {
			var tween = FlxTween.tween(baseBG, {alpha: 0}, time, {ease: FlxEase.expoOut});
			alphaTween.push(tween);
			var tween = FlxTween.tween(baseTar, {alpha: 0}, time, {ease: FlxEase.expoOut});
			alphaTween.push(tween);
			var tween = FlxTween.tween(baseLine, {alpha: 0}, time, {ease: FlxEase.expoOut});
			alphaTween.push(tween);
			var tween = FlxTween.tween(baseDesc, {alpha: 0}, time, {ease: FlxEase.expoOut});
			alphaTween.push(tween);
		}
	}
}

class NaviSprite extends FlxSpriteGroup
{
	var filePath:String = 'menuExtend/OptionsState/icons/';

	public var optionSort:Int;
	public var isModsAdd:Bool = false;

	public var background:Rect;
	public var icon:FlxSprite;
	public var textDis:FlxText;
	var specRect:Rect;

	var mainWidth:Float;
	var mainHeight:Float;

	var name:String;

	///////////////////////////////////////////////////////////////////////////////

	public function new(X:Float, Y:Float, width:Float, height:Float, name:String, sort:Int, modsAdd:Bool = false) {
		super(X, Y);
		optionSort = sort;

		mainWidth = width;
		mainHeight = height;

		this.name = name;

		background = new Rect(0, 0, width, height, height / 5, height / 5, EngineSet.mainColor, 0.0000001);
		add(background);

		specRect = new Rect(0, 0, 5, height * 0.5, 5, 5, EngineSet.mainColor);
		specRect.x += height * 0.25;
		specRect.y += height * 0.25;
		specRect.alpha = 1;
		specRect.scale.y = 1;
		specRect.antialiasing = ClientPrefs.data.antialiasing;
		add(specRect);

		icon = new FlxSprite().loadGraphic(Paths.image(filePath + name));
		icon.setGraphicSize(Std.int(height * 0.8));
		icon.updateHitbox();
		icon.antialiasing = ClientPrefs.data.antialiasing;
		icon.color = EngineSet.mainColor;
		icon.x += height * 0.15;
		icon.y += height * 0.1;
		add(icon);

		textDis = new FlxText(0, 0, 0, name, Std.int(height * 0.15));
		textDis.setFormat(Paths.font('montserrat.ttf'), Std.int(height * 0.25), EngineSet.mainColor, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		textDis.borderStyle = NONE;
		textDis.antialiasing = ClientPrefs.data.antialiasing;
		textDis.x += height * (0.8 + 0.15 + 0.25);
		textDis.y += height * 0.5 - textDis.height * 0.5;
		add(textDis);
	}

	public var onFocus:Bool = false;
	public var cataChoose:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var mouse = OptionsState.instance.mouseEvent;

		if (cataChoose) {
			if (specRect.alpha < 1) specRect.alpha += EngineSet.FPSfix(0.12);
			if (specRect.scale.y < 1) specRect.scale.y += EngineSet.FPSfix(0.12);
		} else {
			if (specRect.alpha > 0) specRect.alpha -= EngineSet.FPSfix(0.12);
			if (specRect.scale.y > 0) specRect.scale.y -= EngineSet.FPSfix(0.12);
		}

		onFocus = mouse.overlaps(this);

		if (onFocus) {
			if (background.alpha < 0.2) background.alpha += EngineSet.FPSfix(0.015);

			if (mouse.justPressed) {

			}

			if (mouse.justReleased) {
				OptionsState.instance.changeCata(optionSort);
			}
		} else {
			if (background.alpha > 0) background.alpha -= EngineSet.FPSfix(0.015);
		}

		if (!mouse.pressed)
		{
			// if (this.scale.x < 1)
				// this.scale.x = this.scale.y += ((1 - this.scale.x) * (1 - this.scale.x) * 0.75);
		}
	}
}

class OptionCata extends FlxSpriteGroup
{
	public var mainX:Float;
	public var mainY:Float;

	public var heightSet:Float = 0;
	public var heightSetOffset:Float = 0; //用于特殊的高度处理

	public var optionArray:Array<Option> = [];
	public var saveArray:Array<Option> = []; //用于保存最初所有的option

	public var bg:RoundRect;

	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y);

		mainX = X;
		mainY = Y;

		bg = new RoundRect(0, 0, width, height, width / 75, LEFT_UP, OptionsState.instance.mainColor);
		bg.alpha = 1.0;
		bg.mainX = mainX;
		bg.mainY = mainY;
		add(bg);
	}

	public function addOption(tar:Option, sameY:Bool = false) {
		var putX:Float = this.width / 2 / 50;
		var putY:Float = heightSet;
		if (sameY) {
			putX += (this.width - this.width / 2 / 50) / 2;
			putY -= optionArray[optionArray.length - 1].saveHeight;
		}
		tar.sameY = sameY; //用于string展开的时候兼容
		add(tar);

		var specX:Float = 0;
		switch (tar.type)
		{
			case STRING:
				if (sameY)
					specX = (this.width - this.width / 2 / 50) / 2;
			default:
		}

		tar.initX(mainX, putX, specX);
		tar.initY(mainY, putY);

		optionArray.push(tar);
		saveArray.push(tar);

		if (!sameY) heightSet += tar.saveHeight;
	}

	override function update(elapsed:Float)
	{
		mainX = this.x;
		mainY = this.y;
		bg.mainX = mainX;
		bg.mainY = mainY;

		super.update(elapsed);
	}

	public function resetData() {
		for (option in optionArray)
			option.resetData();
	}

	var addOptions:Array<Option> = [];
	var removeOptions:Array<Option> = [];
	public function startSearch(text:String, time = 0.6) {
		addOptions = [];
		removeOptions = [];
		for (i in 0...saveArray.length) {
			addOptions.push(saveArray[i]);
		}
		if (text != "") {
			for (option in saveArray) {
				if (!option.startSearch(text)) {
					addOptions.remove(option);
					removeOptions.push(option);
				}
			}
		}
		changeOption(time);
	}

	function changeOption(time = 0.6) {
		for (option in addOptions) {
			option.allowUpdate = true;
			option.changeAlpha(true, time);
		}
		for (option in removeOptions) {
			option.allowUpdate = false;
			option.changeAlpha(false, time);
		}
	}

	public function optionAdjust(str:Option, outputData:Float, time:Float = 0.6) {
		var start:Int = -1;
		for (op in 0...optionArray.length) {
			if (str == optionArray[op]) {
				start = op;
				if (start != (optionArray.length - 1) && str.type == STRING && !str.sameY && optionArray[start + 1].sameY)
					start++;
			}

			if (start != -1 && op > start) { 
				optionArray[op].yOff += outputData;
				optionArray[op].changeY(outputData, false, time);
			}
		}
		heightSetOffset += outputData;

		changeHeight(time);
	}

	public function changeHeight(time:Float = 0.6) {
		bg.changeHeight(heightSet + heightSetOffset, time, 'expoInOut');
	}
}

class FuncButton extends FlxSpriteGroup
{
	var filePath:String = 'menuExtend/OptionsState/icons/';

	public var optionSort:Int;
	public var isModsAdd:Bool = false;

	public var background:RoundRect;
	public var icon:FlxSprite;
	public var textDis:FlxText;

	var mainWidth:Float;
	var mainHeight:Float;

	///////////////////////////////////////////////////////////////////////////////

	public var event:Void->Void = null;

	public function new(X:Float, Y:Float, width:Float, height:Float, onClick:Void->Void = null) {
		super(X, Y);

		this.event = onClick;

		mainWidth = width;
		mainHeight = height;

		background = new RoundRect(0, 0, width, height, height / 5, LEFT_UP, EngineSet.mainColor);
		background.alpha = 0.35;
		background.mainX = X;
		background.mainY = Y;
		add(background);

		icon = new FlxSprite().loadGraphic(Paths.image(filePath + 'specIcon'));
		icon.setGraphicSize(Std.int(height * 0.8));
		icon.updateHitbox();
		icon.antialiasing = ClientPrefs.data.antialiasing;
		icon.color = EngineSet.mainColor;
		icon.x += height * 0.1;
		icon.y += height * 0.1;
		add(icon);

		textDis = new FlxText(0, 0, 0, 'Special Function', Std.int(height * 0.15));
		textDis.setFormat(Paths.font('montserrat.ttf'), Std.int(height * 0.25), EngineSet.mainColor, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		textDis.borderStyle = NONE;
		textDis.antialiasing = ClientPrefs.data.antialiasing;
		textDis.x += height * 0.1 + icon.width + (width - height * 0.1 - icon.width) / 2 - textDis.width / 2 ;
		textDis.y += height * 0.5 - textDis.height * 0.5;
		add(textDis);
	}

	public var onFocus:Bool = false;
	public var onPress:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var mouse = OptionsState.instance.mouseEvent;

		onFocus = mouse.overlaps(this);

		if (onFocus) {
			if (background.alpha < 0.1) background.alpha += EngineSet.FPSfix(0.015);
		} else {
			if (background.alpha > 0) background.alpha -= EngineSet.FPSfix(0.015);
		}

		if (onFocus) {
			if (mouse.justPressed) {

			}

			if (mouse.pressed) {

			}

			if (mouse.justReleased) {
				event();
			}
		}
	}
}

class ResetButton extends FlxSpriteGroup
{
	var rect:Rect;
	var text:FlxText;

	public function new(x:Float, y:Float, width:Float, height:Float)
	{
		super(x, y);

		rect = new Rect(0, 0, width, height, height / 5, height / 5, OptionsState.instance.mainColor, 1);
		add(rect);

		text = new FlxText(0, 0, 0, 'Reset', 25);
		text.font = Paths.font('montserrat.ttf');
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.y += rect.height / 2 - text.height / 2;
		text.x += rect.width / 2 - text.width / 2;
		add(text);

	}

	public var onFocus:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var mouse = OptionsState.instance.mouseEvent;

		onFocus = mouse.overlaps(this);

		if (onFocus)
		{
			rect.color = EngineSet.mainColor;
			if (mouse.justReleased)
				OptionsState.instance.resetData();
		}
		else
		{
			rect.color = OptionsState.instance.mainColor;
		}
	}
}

class SearchButton extends FlxSpriteGroup
{
	var bg:RoundRect;
	var search:PsychUIInputText;
	var tapText:FlxText;
	var itemDis:FlxText;

	public function new(X:Float, Y:Float, width:Float = 0, height:Float = 0)
	{
		super(X, Y);

		var round = height / 5;
		bg = new RoundRect(0, 0, width, height, round, LEFT_UP, 0x000000);
		add(bg);

		search = new PsychUIInputText(round, 0, Std.int(width - round * 2), '', Std.int(height / 2));
		search.bg.visible = false;
		search.behindText.alpha = 0;
		search.textObj.font = Paths.font('montserrat.ttf');
		search.textObj.antialiasing = ClientPrefs.data.antialiasing;
		search.textObj.color = FlxColor.WHITE;
		search.caret.color = 0x727E7E7E;
		search.y += (bg.height - search.height) / 2;
		search.onChange = function(old:String, cur:String)
		{
			if (cur == '')
				tapText.visible = true;
			else
				tapText.visible = false;
			startSearch(cur);
		}
		add(search);

		tapText = new FlxText(round, 0, 0, 'Tap here to search', Std.int(height / 2));
		tapText.font = Paths.font('montserrat.ttf');
		tapText.antialiasing = ClientPrefs.data.antialiasing;
		tapText.alpha = 0.6;
		tapText.y += (bg.height - tapText.height) / 2;
		add(tapText);
	}

	override function update(e:Float)
	{
		super.update(e);
	}

	var timer:FlxTimer = null;
	public function startSearch(text:String)
	{
		if (OptionsState.instance.cataCount.length > 0) return;
		
		if (timer != null) timer.cancel();
		timer = new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			OptionsState.instance.startSearch(text);
		});
	}
}

class TipButton extends FlxSpriteGroup
{
	public var background:RoundRect;
	public var textDis:AlphaText;

	var saveHeight:Float;
	public function new(X:Float, Y:Float, width:Float, height:Float) {
		super(X, Y);

		this.saveHeight = height;

		background = new RoundRect(0, 0, width, height, height / 5, LEFT_UP, EngineSet.mainColor);
		background.alpha = 0.3;
		background.mainX = X;
		background.mainY = Y;
		//add(background);
		//background.visible = false; //也许以后会用到，但是目前看来还是删了比较好看些


		textDis = new AlphaText(0, 0, 0, 'text', Std.int(height * 0.32));
		textDis.setFormat(Paths.font('montserrat.ttf'), Std.int(height * 0.32), EngineSet.mainColor, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		textDis.antialiasing = ClientPrefs.data.antialiasing;
		add(textDis);
		var fixX = (textDis.minorText.textField.textWidth - textDis.width) + background.mainRound;
		var fixY = (textDis.minorText.textField.textHeight - textDis.height) + background.mainRound;
		textDis.mainX = X + fixX;
		textDis.mainY = Y + fixY;

		textDis.mainText.fieldWidth = width - background.mainRound * 2;
		textDis.minorText.fieldWidth = width - background.mainRound * 2;
		changeText('N/A', 0.1);
	}

	public function changeText(newText:String, ?time = 0.4) {
		textDis.changeText(newText, time * 1.2);
		//var newWidth = textDis.minorText.textField.textWidth + background.mainRound * 2;

		//background.changeWidth(newWidth, time, 'expoInOut');
		//var newHeight = textDis.minorText.textField.textHeight + background.mainRound;
		//background.changeHeight(newHeight, time, 'expoInOut');
	}
}

class AlphaText extends FlxSpriteGroup
{
	public var mainText:FlxText;
	public var minorText:FlxText;

	public var mainX:Float;
	public var mainY:Float;
	public var mainSize:Float;

	public function new(X:Float, Y:Float, boud:Float, text:String, size:Int) {
		super(X, Y);

		mainSize = size;

		mainText = new FlxText(0, 0, boud, text, size);
		mainText.antialiasing = ClientPrefs.data.antialiasing;
		add(mainText);

		minorText = new FlxText(0, 0, boud, text, size);
		minorText.alpha = 0.0000001;
		minorText.antialiasing = ClientPrefs.data.antialiasing;

		add(minorText);
	}

	public function setFormat(?Font:String = null, Size:Int = 8, Color:FlxColor = FlxColor.WHITE, ?Alignment:FlxTextAlign, ?BorderStyle:FlxTextBorderStyle,
			BorderColor:FlxColor = FlxColor.TRANSPARENT, EmbeddedFont:Bool = true) {
			if (Font == null) Font = Paths.font('montserrat.ttf');
		mainText.setFormat(Font, Size, Color, Alignment, BorderStyle, BorderColor, EmbeddedFont);
		minorText.setFormat(Font, Size, Color, Alignment, BorderStyle, BorderColor, EmbeddedFont);

		mainText.borderStyle = NONE;
		minorText.borderStyle = NONE;
	}

	var mainTween:FlxTween;
	var minorTween:FlxTween;
	var saveText:String = '';
	public function changeText(newText:String, time:Float = 0.6) {
		if (newText == saveText) return;

		saveText = newText;

		if (mainTween != null) { mainTween.cancel(); mainText.alpha = 1; }
		if (minorTween != null) { minorTween.cancel(); minorText.alpha = 0; }

		minorText.text = newText;
		minorText.scale.x = minorText.scale.y = 1;
		minorText.x = mainX;
		minorText.y = mainY;

		mainTween = FlxTween.tween(mainText, {alpha: 0}, time / 2, {
			ease: FlxEase.expoIn,
			onComplete: function(twn:FlxTween)
			{
				minorTween = FlxTween.tween(minorText, {alpha: 1}, time / 2, {
					ease: FlxEase.expoOut,
					onComplete: function(twn:FlxTween)
						{
							minorText.alpha = 0.00001;

							mainText.alpha = 1;
							mainText.text = newText;

							mainText.scale.x = mainText.scale.y = 1;
							mainText.x = mainX;
							mainText.y = mainY;
						}
				});
			}
		});
	}
}