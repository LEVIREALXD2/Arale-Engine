package options.packages;

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
				if (Font == null) Font =  Paths.font('montserrat.ttf');
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

		tapText = new FlxText(round, 0, 0, 'Tap To Search', Std.int(height / 2));
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