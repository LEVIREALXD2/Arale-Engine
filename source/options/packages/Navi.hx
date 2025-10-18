package options.packages;

class NaviData{
	public var name:String;
	public var group:Array<String>;
	public var extraPath:String;

	public function new(name:String, group:Array<String>, extraPath:String = '') {
		this.name = name;
		this.group = group;
		this.extraPath = extraPath;
	}
}

class NaviGroup extends FlxSpriteGroup
{
	var filePath:String = 'menuExtend/OptionsState/icons/';

	public var optionSort:Int;
	public var isModsAdd:Bool = false;

	public var background:Rect;
	public var icon:FlxSprite;
	public var textDis:FlxText;
	var specRect:Rect;

	public var mainWidth:Float;
	public var mainHeight:Float;

	public var mainX:Float;
	public var mainY:Float;
	public var offsetY:Float;
	public var offsetWaitY:Float;

	var name:String;

	public var parent:Array<NaviMember> = [];

	///////////////////////////////////////////////////////////////////////////////

	public function new(X:Float, Y:Float, width:Float, height:Float, naviData:NaviData, sort:Int, modsAdd:Bool = false) {
		super(X, Y);
		optionSort = sort;

		mainWidth = width;
		mainHeight = height;

		isModsAdd = modsAdd;

		this.name = naviData.name;

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

		for (num in 0...naviData.group.length){
			var member:NaviMember = new NaviMember(this, naviData.group[num], num);
			add(member);
			member.y += 15 + (num + 1) * 50;
			member.x -= member.background.width;
			parent.push(member);
		}
	}

	public var onFocus:Bool = false;
	public var cataChoose:Bool = false;
	var focusTime:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		mainX = this.x;
		mainY = this.y;

		var mouse = OptionsState.instance.mouseEvent;

		onFocus = mouse.overlaps(this.background);

		if (cataChoose) {
			if (focusTime > 0.2) {
				if (specRect.alpha < 1)  specRect.alpha += EngineSet.FPSfix(0.12);
				if (specRect.scale.y < 1) specRect.scale.y += EngineSet.FPSfix(0.12);
			} else {
				focusTime += elapsed;
			}
		} else {
			if (focusTime > 0) focusTime -= elapsed * 2;
			if (focusTime < 0) focusTime = 0;
			if (specRect.alpha > 0)  specRect.alpha -= EngineSet.FPSfix(0.12);
			if (specRect.scale.y > 0) specRect.scale.y -= EngineSet.FPSfix(0.12);
		}

		if (onFocus) {
			if (background.alpha < 0.2) background.alpha += EngineSet.FPSfix(0.015);

			if (mouse.justReleased) {
				moveParent();
			}
		} else {
			if (background.alpha > 0) background.alpha -= EngineSet.FPSfix(0.015);
		}
	}

	public var isOpened:Bool = false;
	var moveTweens:Array<FlxTween> = [];
	public function moveParent(changeTimer:Float = 0.45) {
		for (tween in moveTweens) {
			if (tween != null) tween.cancel();
		}

		for (mem in 0...parent.length) {
			var tween = FlxTween.tween(parent[mem], {x: isOpened ? -parent[mem].background.width : FlxG.width * 0.005}, changeTimer + mem * 0.025 * (isOpened ? -1 : 1), {ease: FlxEase.expoInOut});
			moveTweens.push(tween);
		}

		OptionsState.instance.changeNavi(this, isOpened, changeTimer);
		isOpened = !isOpened;
	}
}

class NaviMember extends FlxSpriteGroup
{
	public var optionSort:Int;
	public var isModsAdd:Bool = false;

	public var background:Rect;
	public var textDis:FlxText;
	var specRect:Rect;

	public var offsetX:Float;
	public var offsetY:Float;
	public var mainWidth:Float;
	public var mainHeight:Float;

	var name:String;

	var follow:NaviGroup;

	///////////////////////////////////////////////////////////////////////////////

	public function new(follow:NaviGroup, name:String, sort:Int, modsAdd:Bool = false) {
		super(0, 0);
		this.follow = follow;
		optionSort = sort;

		mainWidth = follow.mainWidth;
		mainHeight = follow.mainHeight * 0.75;

		this.name = name;

		background = new Rect(0, 0, mainWidth, mainHeight, mainHeight / 5, mainHeight / 5, EngineSet.mainColor, 0.0000001);
		add(background);

		specRect = new Rect(0, 0, 4, mainHeight * 0.6, 4, 4, EngineSet.mainColor);
		specRect.x += mainHeight * 0.34;
		specRect.y += mainHeight * 0.2;
		specRect.alpha = 1;
		specRect.scale.y = 1;
		specRect.antialiasing = ClientPrefs.data.antialiasing;
		add(specRect);

		textDis = new FlxText(0, 0, 0, name, Std.int(mainHeight * 0.15));
		textDis.setFormat(Paths.font('montserrat.ttf'), Std.int(mainHeight * 0.35), EngineSet.mainColor, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		textDis.borderStyle = NONE;
		textDis.antialiasing = ClientPrefs.data.antialiasing;
		textDis.x += mainHeight * 0.6;
		textDis.y += mainHeight * 0.5 - textDis.height * 0.5;
		add(textDis);
	}

	public var onFocus:Bool = false;
	public var cataChoose:Bool = false;
	public var allowChoose:Bool = false;
	var focusTime:Float = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var mouse = OptionsState.instance.mouseEvent;

		onFocus = mouse.overlaps(this);

		if (cataChoose) {
			if (focusTime > 0.2) {
				if (specRect.alpha < 1)  specRect.alpha += EngineSet.FPSfix(0.12);
				if (specRect.scale.y < 1) specRect.scale.y += EngineSet.FPSfix(0.12);
			} else {
				focusTime += elapsed;
			}
		} else {
			if (focusTime > 0) focusTime -= elapsed * 2;
			if (focusTime < 0) focusTime = 0;
			if (specRect.alpha > 0)  specRect.alpha -= EngineSet.FPSfix(0.12);
			if (specRect.scale.y > 0) specRect.scale.y -= EngineSet.FPSfix(0.12);
		}

		if (onFocus) {
			if (background.alpha < 0.2) background.alpha += EngineSet.FPSfix(0.015);

			if (mouse.justPressed) {
				
			}

			if (mouse.justReleased) {
				OptionsState.instance.changeCata(follow.optionSort, optionSort);
			}
		} else {
			if (background.alpha > 0) background.alpha -= EngineSet.FPSfix(0.015);
		}
	}
}