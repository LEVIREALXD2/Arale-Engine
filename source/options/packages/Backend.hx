package options.packages;

import openfl.display.Shape;
import openfl.display.BitmapData;
import flixel.math.FlxRect;

class BoolButton extends FlxSpriteGroup {
	var bg:Rect;
	var dis:FlxSprite;

	var follow:Option;

	var innerX:Float; //该摁键在option的x
	var innerY:Float; //该摁键在option的y

	public function new(X:Float, Y:Float, width:Float, height:Float, follow:Option) {
		super(X, Y);

		this.follow = follow;
		innerX = X;
		innerY = Y;

		bg = new Rect(0, 0, width, height, width / 20, width / 20, 0xFF6363, 0.8);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		dis = new Rect(2, 3, width / 2 - 4, height - 6, width / 20, width / 20, 0xFFFFFF, 0.8);
		dis.antialiasing = ClientPrefs.data.antialiasing;
		add(dis);

		if (follow.defaultValue == true) {
			bg.color = 0x63FF75;
			dis.x += width / 2 - 1;
		}
	}

	public var allowUpdate:Bool = true;
	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!follow.allowUpdate) return;
		
		if (!allowUpdate) return;
		
		var mouse = FlxG.mouse;

		var inputAllow:Bool = true;

		if (Math.abs(OptionsState.instance.cataMove.velocity) > 2) inputAllow = false;

		if (OptionsState.instance.mouseEvent.overlaps(OptionsState.instance.specBG) || OptionsState.instance.mouseEvent.overlaps(OptionsState.instance.downBG)) return;
		
		if (inputAllow) {
			// Check if mouse is over the button
			if (mouse.overlaps(bg)) {
				// Mouse released
				if (OptionsState.instance.mouseEvent.justReleased) {
					// Check if mouse is on left or right side
					var localX = mouse.getScreenPosition().x - this.x;
					var isRightSide = localX > bg.width / 2;
					
					// Change value based on mouse position
					change(isRightSide);
				}
			}
		}
		updateBgColor();
	}

	function change(data:Bool) {
		// Only proceed if value is actually changing
		if (follow.defaultValue == data) return;
		
		follow.defaultValue = data;
		follow.setValue(data);

		updateDisplay();
		
		follow.change();
	}

	var moveTween:FlxTween;
	public function updateDisplay()
	{
		if (moveTween != null) moveTween.cancel();
		var targetX = follow.defaultValue ? bg.width / 2 + 1 : 2;
		moveTween = FlxTween.tween(dis, { x: follow.followX + follow.innerX + innerX + targetX}, 0.2, { ease: FlxEase.quadOut });
		
		// Tween the background color
		
		//FlxTween.color(bg, 0.2, bg.color, targetColor, { ease: FlxEase.quadOut });
		//bg.color = targetColor;  //为什么几把不能用tween
	}
	
	function updateBgColor(){
		var targetColor = follow.defaultValue ? 0x63FF75 : 0xFF6363;
		bg.color = FlxColor.interpolate(bg.color, targetColor, 0.2);
	}
}

class NumButton extends FlxSpriteGroup {

	var follow:Option;

	var innerX:Float; //该摁键在option的x
	var innerY:Float; //该摁键在option的y

	public var deleteButton:FlxSprite;
	public var addButton:FlxSprite;

	public var moveBG:Rect;
	public var moveDis:Rect;
	public var rod:Rect;
	
	var max:Float;
	var min:Float;

	public function new(X:Float, Y:Float, width:Float, height:Float, follow:Option) {
		super(X, Y);

		this.follow = follow;
		this.min = follow.minValue;
		this.max = follow.maxValue;
		innerX = X;
		innerY = Y;

		deleteButton = new FlxSprite();
		deleteButton.loadGraphic(createButton(height * 0.75, 0xFF6363, '-'));
		deleteButton.antialiasing = ClientPrefs.data.antialiasing;
		deleteButton.y += (height - deleteButton.height) / 2;
		add(deleteButton);

		addButton = new FlxSprite();
		addButton.loadGraphic(createButton(height * 0.75, 0x63FF75, '+'));
		addButton.antialiasing = ClientPrefs.data.antialiasing;
		addButton.x += width - addButton.width;
		addButton.y += (height - addButton.height) / 2;
		add(addButton);

		moveBG = new Rect(deleteButton.width * 1.2, 
						 0, 
						 width - (deleteButton.width + addButton.width) * 1.2, 
						 deleteButton.height * 0.5, 
						 deleteButton.height * 0.5 * 0.5, 
						 deleteButton.height * 0.5 * 0.5,
						 0xFF000000,
						 0.4
						 );
		moveBG.y += (height - moveBG.height) / 2;
		add(moveBG);

		moveDis = new Rect(deleteButton.width * 1.2, 
						 0, 
						 width - (deleteButton.width + addButton.width) * 1.2, 
						 deleteButton.height * 0.5, 
						 deleteButton.height * 0.5 * 0.5, 
						 deleteButton.height * 0.5 * 0.5,
						 EngineSet.mainColor,
						 1.0
						 );
		moveDis.y += (height - moveDis.height) / 2;
		add(moveDis);

		rod = new Rect(deleteButton.width * 1.2, 
						0, 
						height / 10, 
						deleteButton.height, 
						height / 10, 
						height / 10, 
						0xffffff,
						1.0
						);
		rod.y += (height - rod.height) / 2;
		add(rod);

		initData();
	}

	public function initData() {
		var percent = (follow.defaultValue - min) / (max - min);
		rectUpdate(percent);
	}

	public var onFocus:Bool = false;

	var focusAdd:Bool = false;
	var addHoldTime:Float = 0;

	var focusDelete:Bool = false;
	var deleteHoldTime:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!follow.allowUpdate) return;

		if (OptionsState.instance.mouseEvent.overlaps(OptionsState.instance.specBG) || OptionsState.instance.mouseEvent.overlaps(OptionsState.instance.downBG)) return;

		var mouse = FlxG.mouse;

		if (mouse.y > rod.y && mouse.y < (rod.y + rod.height) && mouse.x > (rod.x - rod.width * 4) && mouse.x < (rod.x + rod.width * 4) && mouse.justPressed)
		{
			onFocus = true;
			lastMouseX = mouse.x;
		}

		var inputAllow:Bool = true;

		if (Math.abs(OptionsState.instance.cataMove.velocity) > 2) inputAllow = false;

		if (inputAllow) {
			if (onFocus && mouse.pressed)
				onHold();

			if (mouse.justReleased)
			{
				onFocus = false;
			}

			if (mouse.overlaps(addButton))
			{
				if (mouse.justPressed) {  
					changeData(true);
					focusAdd = true;
				}

				if (mouse.pressed && focusAdd) {  
					OptionsState.instance.cataMove.inputAllow = false;
					if (addHoldTime > 0.3) {
						addHoldTime -= 0.01;
						changeData(true);
					} else {
						addHoldTime += elapsed;
					}

					if (addButton.scale.x > 0.8)
						addButton.scale.x = addButton.scale.y -= ((addButton.scale.x - 0.8) * (addButton.scale.x - 0.8) * 0.75);
				} else {
					addHoldTime = 0;
					focusAdd = false;
				}
			} else {
				addHoldTime = 0;
				focusAdd = false;
			}

			if (mouse.overlaps(deleteButton))
			{
				if (mouse.justPressed) {  
					changeData(false);
					focusDelete = true;
				}

				if (mouse.pressed && focusDelete) {  
					OptionsState.instance.cataMove.inputAllow = false;
					if (deleteHoldTime > 0.3) {
						deleteHoldTime -= 0.01;
						changeData(false);
					} else {
						deleteHoldTime += elapsed;
					}

					if (deleteButton.scale.x > 0.8)
						deleteButton.scale.x = deleteButton.scale.y -= ((deleteButton.scale.x - 0.8) * (deleteButton.scale.x - 0.8) * 0.75);
				} else {
					deleteHoldTime = 0;
					focusDelete = false;
				}
			} else {
				deleteHoldTime = 0;
				focusDelete = false;
			}
		}

		if (addButton.scale.x < 1 && !focusAdd)
			addButton.scale.x = addButton.scale.y += ((1 - addButton.scale.x) * (1 - addButton.scale.x) * 0.5);
		if (deleteButton.scale.x < 1 && !focusDelete)
			deleteButton.scale.x = deleteButton.scale.y += ((1 - deleteButton.scale.x) * (1 - deleteButton.scale.x) * 0.5);
	}

	var lastMouseX = 0;
	function onHold()
	{
		OptionsState.instance.cataMove.inputAllow = false;
		var deltaX:Float = FlxG.mouse.x - lastMouseX;
		lastMouseX = FlxG.mouse.x;
		if (deltaX == 0) return;

		rod.x += deltaX;

		var startX = follow.followX + follow.innerX + innerX + deleteButton.width * 1.2;
		if (rod.x < startX)
			rod.x = startX;
		if (rod.x + rod.width > startX + moveBG.width)
			rod.x = startX + moveBG.width - rod.width;

		var percent = (rod.x - moveBG.x) / (moveBG.width - rod.width);
		var outputData = FlxMath.roundDecimal(min + (max - min) * percent, follow.decimals);
		rectUpdate(percent, outputData);
	}

	function changeData(isAdd:Bool)
	{
		var outputData:Float = follow.getValue();
		if (isAdd)
			outputData += Math.pow(0.1, follow.decimals);
		else
			outputData -= Math.pow(0.1, follow.decimals);

		if (outputData < min)
			outputData = min;
		if (outputData > max)
			outputData = max;

		outputData = FlxMath.roundDecimal(outputData, follow.decimals);
		var percent = (outputData - min) / (max - min);

		rectUpdate(percent, outputData);
	}

	function rectUpdate(percent:Float, ?outputData)
	{
		moveDis._frame.frame.width = moveDis.width * percent;
		if (moveDis._frame.frame.width < 1)
			moveDis._frame.frame.width = 1;
		rod.x = follow.followX + follow.innerX + innerX + deleteButton.width * 1.2 + (moveBG.width - rod.width) * percent;

		if (outputData == null) return;
		follow.setValue(outputData);
		follow.change();
		follow.updateDisText();
	}
	
	private function createButton(size:Float, color:Int, symbol:String) {
		// 绘制按钮背景
		var button = new Shape();
		button.graphics.beginFill(color);
		button.graphics.drawRoundRect(0, 0, size, size, size / 4, size / 4);
		button.graphics.endFill();
		
		// 绘制符号
		button.graphics.lineStyle(3, 0xffffff); // 白色线条，3像素粗
		
		if (symbol == "+") {
			// 绘制加号：横线
			button.graphics.moveTo(size * 0.2, size * 0.5);
			button.graphics.lineTo(size * 0.8, size * 0.5);
			// 绘制加号：竖线
			button.graphics.moveTo(size * 0.5, size * 0.2);
			button.graphics.lineTo(size * 0.5, size * 0.8);
		} else if (symbol == "-") {
			// 绘制减号：横线
			button.graphics.moveTo(size * 0.2, size * 0.5);
			button.graphics.lineTo(size * 0.8, size * 0.5);
		}
		var bitmap:BitmapData = new BitmapData(Std.int(size), Std.int(size), true, 0);
		bitmap.draw(button);
		return bitmap;
	}
}

class StateButton extends FlxSpriteGroup{
	public var bg:Rect;
	public var stateName:FlxText;

	var follow:Option;

	public function new(width:Float, height:Float, follow:Option)
	{
		super(); //直接跟随option的x和y
		this.follow = follow;

		bg = new Rect(0, 0, width, height, width / 75, width / 75, EngineSet.mainColor, 0.5);
		add(bg);

		stateName = new FlxText(0, 0, 0, follow.description, Std.int(bg.width / 20));
		stateName.setFormat(Paths.font('montserrat.ttf'), Std.int(bg.width / 20), 0xffffff, CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		stateName.antialiasing = ClientPrefs.data.antialiasing;
		stateName.borderStyle = NONE;
		stateName.x += (bg.width - stateName.width) / 2;
		stateName.y += (bg.height - stateName.height) / 2;
		stateName.alpha = 0.8;
		add(stateName);
	}

	var colorChange:Bool = false;
	var timeCalc:Float;
	override function update(elapsed:Float) {
		super.update(elapsed);

		timeCalc += elapsed;
		
		if (!follow.allowUpdate) {
			timeCalc = 0;
			return;
		}

		if (timeCalc < 0.6) return;

		if (OptionsState.instance.mouseEvent.overlaps(OptionsState.instance.specBG) || OptionsState.instance.mouseEvent.overlaps(OptionsState.instance.downBG)) return;

		var mouse = OptionsState.instance.mouseEvent;

		if (mouse.overlaps(bg)) {
			if (!colorChange) {
				colorChange = true;
				bg.color = 0xffffff;
				bg.alpha = 1;
				stateName.color = EngineSet.mainColor;
				stateName.alpha = 0.8;
			}

			if (mouse.justReleased) {
				follow.change();
			}
		} else {
			if (colorChange) {
					colorChange = false;
					bg.color = EngineSet.mainColor;
					bg.alpha = 0.5;
					stateName.color = 0xFFFFFF;
					stateName.alpha = 0.8;
				}
		}
	}
}

class StringRect extends FlxSpriteGroup{
	public var bg:Rect;
	public var dis:FlxSprite;
	public var disText:FlxText;

	var follow:Option;

	var innerX:Float; //该摁键在option的x
	var innerY:Float; //该摁键在option的y

	public var isOpend:Bool = false;

	//not tested
	public function reload(X:Float, Y:Float, width:Float, height:Float, follow:Option)
	{
		//Remove These
		remove(bg);
		remove(disText);
		remove(dis);

		//Add them back
		addStringOption(X, Y, width, height, follow);
	}

	public function new(X:Float, Y:Float, width:Float, height:Float, follow:Option) {
		super(X, Y);

		addStringOption(X, Y, width, height, follow);
	}

	public function addStringOption(X:Float, Y:Float, width:Float, height:Float, follow:Option)
	{
		this.follow = follow;
		innerX = X;
		innerY = Y;

		bg = new Rect(0, 0, width, height, width / 20, width / 20, 0x000000, 0.3);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		disText = new FlxText(0, 0, 0, 'Tap to choose', Std.int(bg.width / 20 / 2));
		disText.setFormat(Paths.font('montserrat.ttf'), Std.int(bg.height / 2), 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		disText.antialiasing = ClientPrefs.data.antialiasing;
		disText.borderStyle = NONE;
		disText.x += bg.mainRound;
		disText.alpha = 0.3;
		disText.y += (bg.height - disText.height) / 2;
		add(disText);

		dis = new FlxSprite();
		dis.loadGraphic(createButton(height * 0.75, 0xffffff));
		dis.antialiasing = ClientPrefs.data.antialiasing;
		dis.x += bg.width - dis.width - (bg.height - dis.height) / 2; 
		dis.y += (bg.height - dis.height) / 2;
		dis.flipY = true;
		add(dis);
	}

	public var allowUpdate:Bool = true;
	var timeCalc:Float;
	override function update(elapsed:Float) {
		super.update(elapsed);

		timeCalc += elapsed;

		if (!follow.allowUpdate) {
			timeCalc = 0;
			return;
		}
		
		if (!allowUpdate) return;

		if (timeCalc < 0.6) return;

		if (OptionsState.instance.mouseEvent.overlaps(OptionsState.instance.specBG) || OptionsState.instance.mouseEvent.overlaps(OptionsState.instance.downBG)) return;
		
		var mouse = OptionsState.instance.mouseEvent;

		if (mouse.overlaps(bg)) {

			bg.color = 0xffffff;
			bg.alpha = 0.3;

			disText.color = EngineSet.mainColor;
			disText.alpha = 1;

			dis.color = EngineSet.mainColor;
			dis.alpha = 1;

			if (mouse.justReleased) {
				change();
			}
		} else {
			bg.color = 0x000000;
			bg.alpha = 0.3;

			disText.color = 0xffffff;
			disText.alpha = 0.3;

			dis.color = 0xffffff;
			dis.alpha = 0.3;
		}
	}

	var alphaTween:Array<FlxTween> = [];
	var changeTimer:Float = 0.45;
	public function change() {
		for (tween in alphaTween) {
			tween.cancel();
		}

		if (!follow.follow.peerCheck(follow)) return;

		if (isOpend) { //关闭
			disText.text = 'Tap to choose';
			dis.flipY = true;
			
			var tween = FlxTween.tween(follow.select.bg, {alpha: 0}, changeTimer, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween){follow.select.active = follow.select.visible = false; if (OptionsState.instance.stringCount.contains(follow.select)) OptionsState.instance.stringCount.remove(follow.select);} });
			alphaTween.push(tween);
			var tween = FlxTween.tween(follow.select.slider, {alpha: 0}, changeTimer, {ease: FlxEase.expoOut});
			alphaTween.push(tween);
			
			for (i in 0...follow.select.optionSprites.length) {
				follow.select.optionSprites[i].allowUpdate = false;
				var tween = FlxTween.tween(follow.select.optionSprites[i].textDis, {alpha: 0}, changeTimer, {ease: FlxEase.expoOut});
				alphaTween.push(tween);
			}

			follow.follow.optionAdjust(follow, -1 * (follow.select.bg.height + follow.inter));
			isOpend = !isOpend;
			follow.select.isOpend = isOpend;
		} else { //开启 
			if (!OptionsState.instance.stringCount.contains(follow.select)) OptionsState.instance.stringCount.push(follow.select);
			disText.text = 'Tap to close';
			dis.flipY = false;

			follow.select.active = follow.select.visible = true;
			var tween = FlxTween.tween(follow.select.bg, {alpha: 0.1}, changeTimer, {ease: FlxEase.expoIn});
			alphaTween.push(tween);
			var tween = FlxTween.tween(follow.select.slider, {alpha: 0.8}, changeTimer, {ease: FlxEase.expoIn});
			alphaTween.push(tween);
			for (i in 0...follow.select.optionSprites.length) {
				var tween = FlxTween.tween(follow.select.optionSprites[i].textDis, {alpha: 1}, changeTimer, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween){ follow.select.optionSprites[i].allowUpdate = true;} });
				alphaTween.push(tween);
			}

			follow.follow.optionAdjust(follow, follow.select.bg.height + follow.inter);
			isOpend = !isOpend;
			follow.select.isOpend = isOpend;
		}
	}

	private function createButton(size:Float, color:Int) {
		var button = new Shape();
		button.graphics.beginFill(color);
		
		// 2. 设置符号绘制样式
		button.graphics.lineStyle(3, 0xffffff); // 白色线条，3像素粗
		
		// 3. 计算符号位置（保留30%边距）
		var margin = size * 0.3;
		var centerX = size / 2;
		var symbolHeight = size * 0.4; // 符号高度占40%
		
		// 4. 绘制"^"符号
		button.graphics.moveTo(centerX, margin); // 起点：顶部中心
		button.graphics.lineTo(size * 0.22, margin + symbolHeight); // 向左下画线
		button.graphics.moveTo(centerX, margin); // 回到起点
		button.graphics.lineTo(size * 0.78, margin + symbolHeight); // 向右下画线
		
		// 5. 转换为BitmapData
		var bitmap = new BitmapData(Std.int(size), Std.int(size), true, 0);
		bitmap.draw(button);
		return bitmap;
	}
}

class StringSelect extends FlxSpriteGroup
{
	public var follow:Option;

	public var bg:Rect;
	public var slider:Rect;

	public var options:Array<String>;
	public var optionSprites:Array<ChooseRect>;

	var mainX:Float = 0;
	var mainY:Float = 0;

	public var specX:Float = 0;

	public var currentSelection:Int = 0;
	public var posiData:Float = 0;
	var optionMove:MouseMove;

	public var isOpend:Bool = false;

	//not tested
	public function reload(X:Float, Y:Float, width:Float, height:Float, follow:Option)
	{
		//Reset Everything
		remove(bg);
		optionSprites = [];
		remove(slider);
		OptionsState.instance.removeMove(optionMove);

		//Add them back
		addStringOption(X, Y, width, height, follow);
	}

	public function new(X:Float, Y:Float, width:Float, height:Float, follow:Option)
	{
		super(X, Y);

		addStringOption(X, Y, width, height, follow);
	}
	
	function addStringOption(X:Float, Y:Float, width:Float, height:Float, follow:Option)
	{
		mainX = X;
		mainY = Y;

		this.follow = follow;
		this.options = follow.strGroup;

		//这些alpha会在后面出现的时候设置（具体去看stringrect）

		var calcHeight:Float = height;
		if (follow.strGroup.length < 5) calcHeight = calcHeight * (follow.strGroup.length / 5);
		
		bg = new Rect(0, 0, width, calcHeight, width / 75, width / 75, 0xffffff, 0);
		add(bg);

		var init = 80;

		var calcWidth = width * (init - 2) / init;
		optionSprites = [];
		for (i in 0...options.length)
		{
			var option = new ChooseRect(width / 80, 0, calcWidth, height / 5, options[i], i, this);
			add(option);
			optionSprites.push(option);
			option.y = follow.followY + follow.innerY + mainY + i * height / 5; //初始化在state的y
		}
		
		// 创建滑块
		var calcWidth = width / init;
		var calcHeight = bg.height * 5 / options.length;
		if (calcHeight > bg.height) calcHeight = bg.height;
		slider = new Rect(width - calcWidth, 0, calcWidth, calcHeight, calcWidth, calcWidth, 0xffffff, 0);
		add(slider);

		var calc = -1 * (height / 5) * (options.length - 5);
		if (optionSprites.length < 5) calc = 0;

		optionMove = new MouseMove(this, 'posiData', 
								[calc , 0],
								[ 
									[follow.followX + follow.innerX + mainX - specX, follow.followX + follow.innerX + mainX - specX + bg.width], 
									[follow.y + mainY, follow.y + mainY + bg.height]
								]
								);
		OptionsState.instance.addMove(optionMove);
		optionMove.mouseWheelSensitivity = 10;
	}
	
	public var allowUpdate:Bool = true;
	override public function update(elapsed:Float):Void
	{
		optionMove.mouseLimit[0] = [follow.followX + follow.innerX + mainX - specX, follow.followX + follow.innerX + mainX - specX + bg.width];
		optionMove.mouseLimit[1] = [follow.y + mainY, follow.y + mainY + bg.height];
		super.update(elapsed);

		if (!allowUpdate) return;

		if (OptionsState.instance.mouseEvent.overlaps(OptionsState.instance.specBG) || OptionsState.instance.mouseEvent.overlaps(OptionsState.instance.downBG)) return;

		 for (i in 0...options.length)
		{
			var option = optionSprites[i];
			var calcHeight = bg.height / 5;
			if (options.length < 5) calcHeight = bg.height / options.length;
			option.y = follow.y + mainY + i * calcHeight + posiData; //初始化在state的y
		}
	
		var mouse = FlxG.mouse;
		
		var startY:Float = follow.y + mainY;
		var overY:Float  = follow.y + mainY + bg.height;
		
		for (str in optionSprites) {
			changeRect(str, startY, overY);
		}

		if (options.length > 5) { //对的其实我是真懒得兼容了
			var data = posiData;
			if (data > 0) data = 0;
			if (data < optionMove.moveLimit[0]) data = optionMove.moveLimit[0];
			data = Math.abs(data);
			slider.y = follow.y + mainY + (data / Math.abs(optionMove.moveLimit[0])) * (bg.height - slider.height);
		}
	}

	function changeRect(str:ChooseRect, startY:Float, overY:Float) { //ai真的太好用了喵 --狐月影
		// 获取选项矩形的顶部和底部坐标（相对于父容器）
		var optionTop = str.y;
		var optionBottom = str.y + str.height;
		
		// 计算实际可见区域
		var visibleTop = Math.max(optionTop, startY);	// 可见顶部取两者最大值
		var visibleBottom = Math.min(optionBottom, overY); // 可见底部取两者最小值
		
		// 完全不可见的情况（在背景上方或下方）
		if (visibleBottom <= startY || visibleTop >= overY) {
			str.visible = false;
			str.allowChoose = false;
			return;
		}
		
		// 设置可见性
		str.visible = true;
		str.allowChoose = true;

		// 计算裁剪参数（基于局部坐标系）
		var clipY = Math.max(0, startY - optionTop);  // 裁剪上边距
		var clipHeight = visibleBottom - visibleTop;  // 可见高度
		
		// 创建/更新裁剪矩形
		var swagRect = str.clipRect;
		if (swagRect == null) {
			swagRect = new FlxRect(0, clipY, str.width, clipHeight);
		} else {
			swagRect.set(0, clipY, str.width, clipHeight);
		}
		
		// 应用裁剪
		str.clipRect = swagRect;
	}
	
	public function updateSelection(index:Int):Void
	{
		for (i in 0...optionSprites.length) {
			if (i == index) optionSprites[i].setAlpha = 0.1;
			else optionSprites[i].setAlpha = 0;
		}
	}
}

class ChooseRect extends FlxSpriteGroup {
	public var bg:Rect;
	public var textDis:FlxText;

	public var optionSort:Int;

	var follow:StringSelect;

	var name:String;

	public var setAlpha:Float = 0;

	///////////////////////////////////////////////////////////////////////////////

	public function new(X:Float, Y:Float, width:Float, height:Float, name:String, sort:Int, follow:StringSelect) {
		super(X, Y);
		this.follow = follow;
		this.name = name;

		optionSort = sort;

		bg = new Rect(0, 0, width, height, height / 5, height / 5, EngineSet.mainColor, 0);
		add(bg);

		textDis = new FlxText(0, 0, 0, name, Std.int(height * 0.15));
		textDis.setFormat(Paths.font('montserrat.ttf'), Std.int(height * 0.45), 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		textDis.borderStyle = NONE;
		textDis.antialiasing = ClientPrefs.data.antialiasing;
		textDis.y += (height - textDis.height) * 0.5;
		add(textDis);
		textDis.alpha = 0;

		if (name == follow.follow.getValue()) setAlpha = 0.1; //标亮之前的设置
	}

	public var onFocus:Bool = false;
	public var onPress:Bool = false;
	public var onChoose:Bool = false;
	public var allowUpdate:Bool = false;
	public var allowChoose:Bool = false;
	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!follow.allowUpdate) {
			return;
		}

		var mouse = OptionsState.instance.mouseEvent;

		onFocus = mouse.overlaps(this);

		if (onFocus) {
			if (bg.alpha < 1) bg.alpha += EngineSet.FPSfix(0.09);

			if (mouse.justPressed) {
				
			}

			if (mouse.pressed) {
				onChoose = true;
			}

			if (mouse.justReleased && allowUpdate && allowChoose) {
				follow.follow.setValue(name);
				follow.follow.updateDisText();
				follow.follow.change();
				follow.updateSelection(optionSort);
				follow.follow.stringRect.change(); //关闭设置了喵
			}
		} else {
			if (bg.alpha > setAlpha) bg.alpha -= EngineSet.FPSfix(0.09);
			if (setAlpha > bg.alpha) bg.alpha = setAlpha;
		}

		bg.alpha = bg.alpha * textDis.alpha;

		if (!mouse.pressed)
		{
			
		}
	}
}