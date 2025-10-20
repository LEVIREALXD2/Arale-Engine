package options.packages;

import openfl.filters.GlowFilter;
import flixel.graphics.frames.FlxFilterFrames;
import options.packages.Objects.OptionType;
import options.ShapeEX.Rect;

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
	
	COLOR;
}

class Option extends FlxSpriteGroup
{
	public var onChange:Void->Void = null;
	public var type:OptionType = BOOL;

	//STRING
	public var strGroup:Array<String> = null;

	//INT FLOAT PERCENT;
	public var minValue:Float = 0;
	public var maxValue:Float = 0;
	public var decimals:Int = 0; //数据需要精确到小数点几位
	public var extraDisplay:String = '';

	public var variable:String = null; // Variable from ClientPrefs.hx
	public var defaultValue:Dynamic = null; //获取出来的数值
	public var resetValue:Dynamic = null; //重置时候赋予的数值（脚本专用）
	public var description:String = ''; //简短的描述
	public var tips:String; //真正的解释

	public var saveHeight:Float = 0; //仅仅用作最开始设置的时候使用
	public var inter:Float = 10; //设置与设置间的y轴间隔

	public var follow:OptionCata;
	public var modsData:Map<String, Dynamic> = []; //mod数据
	public var modAdd:Bool;

	/////////////////////////////////////////////

	function getVariableProperty() {
		if(Reflect.getProperty(ClientPrefs.data, variable) != null) return Reflect.getProperty(ClientPrefs.data, variable);
		else return Reflect.getProperty(FlxG.save.data, variable);
	}

	function setVariableProperty(value:Dynamic) {
		if(Reflect.getProperty(ClientPrefs.data, variable) != null) return Reflect.setProperty(ClientPrefs.data, variable, value);
		else Reflect.setProperty(FlxG.save.data, variable, value);
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

		defaultDataCheck();

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

	///////////////////////////////////////////////

	public function change()
	{
		if (onChange != null)
			onChange();
	}

	dynamic public function getValue():Dynamic
	{
		var value;
		value = getVariableProperty();
		return value;
	}

	dynamic public function setValue(value:Dynamic)
	{
		defaultValue = value;
		return setVariableProperty(value);
	}

	public function resetData()
	{
		if (variable == '' || type == STATE ||  type == TEXT || type == TITLE)
			return;
		try {
			if(Reflect.getProperty(ClientPrefs.data, variable) != null) {
				Reflect.setProperty(ClientPrefs.data, variable, Reflect.getProperty(ClientPrefs.defaultData, variable));
				defaultValue = Reflect.getProperty(ClientPrefs.defaultData, variable);
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

	function defaultDataCheck() {
		switch (type)
		{
			case BOOL:
				if (defaultValue == null)
					defaultValue = false;
			case INT, FLOAT, PERCENT:
				if (defaultValue == null)
					defaultValue = minValue;
			case STRING:
				if (strGroup.indexOf(defaultValue) == -1) {
					if (strGroup.length > 0)
						defaultValue = strGroup[0];
					if (defaultValue == null)
						defaultValue = '';
				}
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
		if (type == PERCENT) valueText.text = Std.string(defaultValue * 100) + ' ' + extraDisplay;
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
		tipsLight = new Rect(0, 0,  data / 6, data, data / 4, data / 4, EngineSet.mainColor);
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
		titleLight = new Rect(follow.bg.mainRound, 0,  data / 6, data, data / 4, data / 4, EngineSet.mainColor);
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

		baseTar = new FlxText(0, 0, 0, 'Target' + ': ' + variable, Std.int(baseBG.width / 20 / mult));
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

	public function startSearch(text:String):Bool {
		if (variable.indexOf(text) != -1) return true;
		if (description.indexOf(text) != -1) return true;
		if (tips.indexOf(text) != -1) return true;
		return false;
	}



	/////////////////////////////////////////////////////////////////////////////////////////////

	public var followX:Float = 0;  //optioncata位置
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

	public var followY:Float = 0;  //optioncata在主体的位置
	public var innerY:Float = 0; //optioncata内部位置
	public var yOff:Float = 0; //用于图形在cata内部位移
	public var waitYOff:Float = 0; //用于图形在cata内部位移
	public var sameY:Bool = false; //用于string展开兼容
	public var yTween:FlxTween = null;
	public function changeOffY(data:Float, time:Float) {
		waitYOff += data;

		if (yTween != null) yTween.cancel();
		yTween = FlxTween.num(yOff, waitYOff, time, {ease: FlxEase.expoInOut}, function(v){this.y = followY + innerY + yOff; yOff = v;});
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

class OptionCata extends FlxSpriteGroup
{
	public var mainX:Float;
	public var mainY:Float;

	public var heightSet:Float = 0;
	public var heightSetOffset:Float = 0; //用于特殊的高度处理

	public var modAdd:Bool = false;
	public var modsName:String;

	public var optionArray:Array<Option> = [];
	public var saveArray:Array<Option> = []; //用于保存最初所有的option

	public var bg:RoundRect;
	public var follow:NaviGroup;
	public var mem:NaviMember;

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

		
		if (checkPoint()) {
			mem.cataChoose = true;
		} else {
			mem.cataChoose = false;
		}
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

	public function optionAdjust(str:Option, outputData:Float, time:Float = 0.45) {
		var start:Int = -1;
		for (op in 0...optionArray.length) {
			if (str == optionArray[op]) {
				start = op;
				if (start != (optionArray.length - 1) && str.type == STRING && !str.sameY && optionArray[start + 1].sameY)
					start++;
			}

			if (start != -1 && op > start) { 
				optionArray[op].changeOffY(outputData, time);
			}
		}
		heightSetOffset += outputData;

		changeHeight(time);
		OptionsState.instance.cataMoveChange();
	}

	public function peerCheck(str:Option):Bool {
		for (op in 0...optionArray.length) {
			if (str == optionArray[op]) {
				if (optionArray[op].sameY) {
					if (optionArray[op - 1].type == STRING && optionArray[op - 1].select.isOpend) {
						return false;
						break;
					}
				} else {
					if (op != optionArray.length - 1 && optionArray[op + 1].type == STRING && optionArray[op + 1].select.isOpend) {
						return false;
						break;
					}
				}
			}
		}

		return true;
	}

	public function changeHeight(time:Float = 0.6) {
		bg.changeHeight(heightSet + heightSetOffset, time, 'expoInOut');
	}

	public function checkPoint():Bool {
		if (this.y < FlxG.height / 2 && this.y + bg.realHeight > FlxG.height / 2) return true;
		return false;
	}
}

class GeneralBack extends FlxSpriteGroup
{
	var background:Rect;
	var button:FlxSprite;
	var text:FlxText;

	public var onClick:Void->Void = null;

	var saveColor:FlxColor = 0;
	var saveColor2:FlxColor = 0;

	public function new(X:Float, Y:Float, width:Float = 0, height:Float = 0, texts:String = '', color:FlxColor = FlxColor.WHITE, onClick:Void->Void = null,
			flipButton:Bool = false)
	{
		super(X, Y);

		background = new Rect(0, 0, width, height);
		background.color = color;
		add(background);

		button = new FlxSprite(0, 0).loadGraphic(Paths.image('menuExtend/Others/playButton'));
		button.scale.set(0.4, 0.4);
		button.antialiasing = ClientPrefs.data.antialiasing;
		button.y += background.height / 2 - button.height / 2;
		if (flipButton)
			button.flipX = true;
		add(button);

		text = new FlxText(40, 0, 0, texts, 25);
		text.font = Paths.font('montserrat.ttf');
		text.antialiasing = ClientPrefs.data.antialiasing;
		add(text);

		text.x += background.width / 2 - text.width / 2;
		text.y += background.height / 2 - text.height / 2;

		this.onClick = onClick;
		this.saveColor = color;
		saveColor2 = color;
		saveColor2.lightness = 0.5;
	}

	public var onFocus:Bool = false;

	var bgTween:FlxTween;
	var textTween:FlxTween;
	var focused:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		onFocus = FlxG.mouse.overlaps(this);

		if (onFocus && onClick != null && FlxG.mouse.justReleased)
			onClick();

		if (onFocus)
		{
			if (!focused)
			{
				focused = true;
				background.color = saveColor2;
			}
		}
		else
		{
			if (focused)
			{
				focused = false;
				background.color = saveColor;
			}
		}
	}
}