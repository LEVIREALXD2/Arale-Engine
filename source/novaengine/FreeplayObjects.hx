package novaengine;

import options.ShapeEX;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.display.Shape;

import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Matrix;

import flixel.graphics.FlxGraphic;

import novaengine.FreeplayBackend;

class DataDis extends FlxSpriteGroup{
	var lineBG:Rect;
	public var lineDis:Rect;
	var text:FlxText;
	public var data:FlxText;

	public function new(x:Float, y:Float, width:Float, height:Float, dataName:String){
		super(x, y);

		lineBG = new Rect(0, 0, width, height, height, height, 0xffffff);
		lineBG.antialiasing = ClientPrefs.data.antialiasing;
		add(lineBG);

		lineDis = new Rect(0, 0, width, height, height, height, 0xffffff);
		lineDis.antialiasing = ClientPrefs.data.antialiasing;
		add(lineDis);

		text = new FlxText(0, 0, 0, dataName, 20);
		text.setFormat(Paths.font('montserrat.ttf'), 16, 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		text.borderStyle = NONE;
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.y += height * 1.5;
		add(text);

		data = new FlxText(0, 0, 0, dataName, 20);
		data.setFormat(Paths.font('montserrat.ttf'), 16, 0xffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		data.borderStyle = NONE;
		data.antialiasing = ClientPrefs.data.antialiasing;
		data.y += lineDis.height + text.height;
		add(data);
	}

	public function chanegData(data:Float) {

	}

}

class DetailRect extends FlxSpriteGroup{
	public var bg1:FlxSprite;
	public var bg2:FlxSprite;
	public var bg3:FlxSprite;

	public function new(x, y){
		super(x, y);
		bg1 = new FlxSprite(0).loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + 'detailsBG1'));
		bg1.alpha = 0.6;
		bg1.antialiasing = ClientPrefs.data.antialiasing;
		add(bg1);

		bg2 = new FlxSprite(0).loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + 'detailsBG2'));
		bg2.y += bg1.height - bg2.height;
		bg2.alpha = 0.4;
		bg2.antialiasing = ClientPrefs.data.antialiasing;
		add(bg2);

		bg3 = new FlxSprite(0).loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + 'detailsBG3'));
		bg3.y += bg1.height - bg3.height;
		bg3.alpha = 0.6;
		bg3.antialiasing = ClientPrefs.data.antialiasing;
		add(bg3);
	}
}

class StarRect extends FlxSpriteGroup{
	public var bg:Rect;
	public var text:FlxText;

	public function new(x:Float, y:Float, width:Float, height:Float){
		super(x, y);

		bg = new Rect(0, 0, width, height, height, height, 0xffffff);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		text = new FlxText(0, 0, 0, '0.99', Std.int(height * 0.25));
		text.setFormat(Paths.font('montserrat.ttf'), Std.int(height * 0.6), 0x242A2E, CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		text.borderStyle = NONE;
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.x = (bg.width - text.width) / 2;
		text.y = (bg.height - text.height) / 2;
		add(text);
	}
}

class BackButton extends FlxSpriteGroup {
	var pressRect:Rect;
	var disRect:Rect;

	var text:FlxText;

	var event:Dynamic -> Void = null;

	public function new(x:Float, y:Float, width:Float, height:Float, onClick:Dynamic -> Void = null) {
		super(x, y);

		pressRect = new Rect(0, 0, width, height, height / 4, height / 4);
		add(pressRect);
		pressRect.alpha = 0;

		disRect = new Rect(10, 0, width - 10, height - 10, height / 4, height / 4, EngineSet.mainColor);
		add(disRect);

		this.event = onClick;
	}
}

class FuncButton extends FlxSpriteGroup {

	static public var filePath:String = 'function/';

	var rect:FlxSprite;
	var light:FlxSprite;

	var text:FlxText;
	var icon:FlxSprite;

	var event:Dynamic -> Void = null;

	public function new(x:Float, y:Float, name:String, color:FlxColor = 0xffffff, onClick:Dynamic -> Void = null) {
		super(x, y);
		this.event = onClick;

		rect = new FlxSprite().loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + filePath + 'button'));
		rect.color = 0x24232C;
		rect.antialiasing = ClientPrefs.data.antialiasing;
		add(rect);

		light = new FlxSprite().loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + filePath + 'light'));
		light.color = color;
		light.alpha = 0.8;
		light.antialiasing = ClientPrefs.data.antialiasing;
		add(light);

		icon = new FlxSprite().loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + filePath + name));
		icon.antialiasing = ClientPrefs.data.antialiasing;
		icon.color = color;
		icon.setGraphicSize(25);
		icon.updateHitbox();
		icon.x += rect.width / 2 - icon.width / 2;
		icon.y += rect.height / 4 - icon.height / 2 + 5;
		add(icon);

		text = new FlxText(0, 0, 0, name, Std.int(rect.height * 0.25));
		text.setFormat(Paths.font('montserrat.ttf'), Std.int(rect.height * 0.25), 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		text.borderStyle = NONE;
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.x = rect.width / 2 - text.width / 2;
		text.y = rect.height / 3 * 2 - text.height / 2 + 5;
		add(text);
	}
}

class PlayButton extends FlxSpriteGroup {
	var icon:FlxSprite;

	var event:Dynamic -> Void = null;

	public function new(x:Float, y:Float, onClick:Dynamic -> Void = null) {
		super(x, y);
		this.event = onClick;

		icon = new FlxSprite().loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + 'playButton'));
		icon.antialiasing = ClientPrefs.data.antialiasing;
		icon.setGraphicSize(250);
		icon.updateHitbox();
		add(icon);
	}
}

class HistoryRect extends FlxSpriteGroup {
	
}

class CollectionButton extends FlxSpriteGroup {
	static public var filePath:String = 'selectChange/';
	var bg:FlxSprite;
	var light:FlxSprite;
	
	public var onSelectChange:String->Void;

	public function new(x:Float, y:Float) {
		super(x, y);

		bg = new FlxSprite().loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + filePath + 'bg'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0x21272F;
		add(bg);
		
		light = new FlxSprite().loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + filePath + 'light'));
		light.antialiasing = ClientPrefs.data.antialiasing;
		light.color = 0x374248;
		add(light);
	}
}

class DiffSelect extends FlxSpriteGroup {

	static public var filePath:String = 'diff/';

	var bg:FlxSprite;
	var light:FlxSprite;
	
	public var onSelectChange:String->Void;

	public function new(x:Float, y:Float) {
		super(x, y);

		bg = new FlxSprite().loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + filePath + 'bg'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		
		light = new FlxSprite(75, 0).loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + filePath + 'light'));
		light.antialiasing = ClientPrefs.data.antialiasing;
		add(light);
	}
}

class SearchButton extends FlxSpriteGroup {
	var bg:FlxSprite;
	var search:PsychUIInputText;
	
	public var onSearchChange:String->Void;

	public function new(x:Float, y:Float) {
		super(x, y);

		bg = new FlxSprite().loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + 'searchButton'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		
		search = new PsychUIInputText(13, 8, Std.int(bg.width - 90), '', Std.int(bg.height / 2));
		search.bg.visible = false;
		search.behindText.alpha = 0;
		search.textObj.font = Paths.font('montserrat.ttf');
		search.textObj.antialiasing = ClientPrefs.data.antialiasing;
		search.textObj.color = FlxColor.WHITE;
		search.caret.color = 0x727E7E7E;
		add(search);
	}
}

class SortButton extends FlxSpriteGroup {
	static public var filePath:String = 'selectChange/';
	var bg:FlxSprite;
	var light:FlxSprite;
	
	public var onSelectChange:String->Void;

	public function new(x:Float, y:Float) {
		super(x, y);

		bg = new FlxSprite().loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + filePath + 'bg'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0x21272F;
		add(bg);
		
		light = new FlxSprite().loadGraphic(Paths.image(FreeplayStateNOVANew.filePath + filePath + 'light'));
		light.antialiasing = ClientPrefs.data.antialiasing;
		light.color = 0x374248;
		add(light);
	}
}

class DiffRect extends FlxSpriteGroup {
	public var light:Rect;
	private var bg:FlxSprite;
	private var diffName:FlxText;
	private var charter:FlxText;

	/////////////////////////////////////////////////////////////////////

	static public var fixHeight:Int = #if mobile 40 #else 30 #end;
	private var filePath:String = 'song/';

	public var id:Int = 0;
	public var currect:Int = 0;
	
	public var onSelectChange:String->Void;
	public function new(songNameSt:String, songChar:String, songMusican:String, songCharter:Array<String>, songColor:Array<Int>) {
		super(x, y);
	}
}

class SongRect extends FlxSpriteGroup {
	
	public var light:Rect;
	private var bg:FlxSprite;
	public var diffRectArray:Array<DiffRect> = [];
	private var icon:HealthIcon;
	private var songName:FlxText;
	private var musican:FlxText;

	/////////////////////////////////////////////////////////////////////

	static public var fixHeight:Int = #if mobile 80 #else 60 #end;

	public var id:Int = 0;
	public var currect:Int = 0;
	
	public var onSelectChange:String->Void;
	public function new(songNameSt:String, songChar:String, songMusican:String, songCharter:Array<String>, songColor:Array<Int>) {
		super(x, y);

		light = new Rect(0, 0, 560, fixHeight, fixHeight / 2, fixHeight / 2, FlxColor.WHITE, 1, 1, EngineSet.mainColor);
		light.antialiasing = ClientPrefs.data.antialiasing;
		add(light);

		var path:String = PreThreadLoad.bgPathCheck(Mods.currentModDirectory, 'data/${songNameSt}/bg');

		var spr = new FlxSprite(0, 0).loadGraphic(Paths.image(path, null, false));

		var matrix:Matrix = new Matrix();
		var scale:Float = light.width / spr.width;
		if (light.height / spr.height > scale)
			scale = light.height / spr.height;
		matrix.scale(scale, scale);
		matrix.translate(-(spr.width * scale - light.width) / 2, -(spr.height * scale - light.height) / 2);

		var resizedBitmapData:BitmapData = new BitmapData(Std.int(light.width), Std.int(light.height), true, 0x00000000);
		resizedBitmapData.draw(spr.pixels, matrix);

		var colorTransform:ColorTransform = new ColorTransform();
		var color:FlxColor = FlxColor.fromRGB(songColor[0], songColor[1], songColor[2]);
		colorTransform.redMultiplier = color.redFloat;
		colorTransform.greenMultiplier = color.greenFloat;
		colorTransform.blueMultiplier = color.blueFloat;

		resizedBitmapData.colorTransform(new Rectangle(0, 0, resizedBitmapData.width, resizedBitmapData.height), colorTransform);

		resizedBitmapData.copyChannel(light.pixels, new Rectangle(0, 0, light.width, light.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);

		spr.loadGraphic(resizedBitmapData);

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image(path, null, false));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		icon = new HealthIcon(songChar, false);
		icon.setGraphicSize(Std.int(bg.height * 0.8));
		icon.x += bg.height / 2 - icon.height / 2;
		icon.y += bg.height / 2 - icon.height / 2;
		icon.updateHitbox();
		add(icon);

		songName = new FlxText(0, 0, 0, songNameSt, 20);
		songName.setFormat(Paths.font('montserrat.ttf'), Std.int(light.height * 0.3), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		songName.borderStyle = NONE;
		songName.antialiasing = ClientPrefs.data.antialiasing;
		songName.x += bg.height / 2 - icon.height / 2 + icon.width * 1.1;
		//songName.y = light.height * 0.05;
		add(songName);

		musican = new FlxText(0, 0, 0, songMusican, 20);
		musican.setFormat(Paths.font('montserrat.ttf'), Std.int(light.height * 0.2), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
		musican.borderStyle = NONE;
		musican.antialiasing = ClientPrefs.data.antialiasing;
		musican.x += bg.height / 2 - icon.height / 2 + icon.width * 1.1;
		musican.y += songName.textField.textHeight;
		add(musican);
	}

	static var lineShape:Shape = null;
	function drawLine(bitmap:BitmapData)
	{
		if (lineShape == null) {
			lineShape = new Shape();
			var lineSize:Int = 2;
			var round:Int = Std.int(bitmap.height / 2);
			lineShape.graphics.beginFill(EngineSet.mainColor);
			lineShape.graphics.lineStyle(1, EngineSet.mainColor, 1);
			lineShape.graphics.drawRoundRect(0, 0, bitmap.width, bitmap.height, round, round);
			lineShape.graphics.lineStyle(0, 0, 0);
			lineShape.graphics.drawRoundRect(lineSize, lineSize, bitmap.width - lineSize * 2, bitmap.height - lineSize * 2, round - lineSize * 2, round - lineSize * 2);
			lineShape.graphics.endFill();
		}

		bitmap.draw(lineShape);
	}

	public var onFocus(default, set):Bool = true;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		calcX();

		
	}

	private function set_onFocus(value:Bool):Bool
	{
		if (onFocus == value)
			return onFocus;
		onFocus = value;
		if (onFocus)
		{
			addDiffRect();
		} else {
			
		}
		return value;
	}

	public function addDiffRect() {
		
	}

	///////////////////////////////////////////////////////////////////////

	public var moveX:Float = 0;
	public var chooseX:Float = 0;
	public var diffX:Float = 0;
	public function calcX() {
		moveX = Math.pow(Math.abs(this.y + this.light.height / 2 - FlxG.height / 2) / (FlxG.height / 2) * 10, 1.9);
		this.x = FlxG.width - this.light.width + 70 + moveX + chooseX + diffX;
	}

	public var moveY:Float = 0;
	public var diffY:Float = 0;
}