package options;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.animation.FlxAnimationController;
import flixel.math.FlxRect;

import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import openfl.system.System;
import openfl.geom.Rectangle;
import openfl.media.Sound;
import haxe.Json;

import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import flash.geom.Point;
import flash.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.display.Shape;
import flixel.util.FlxSpriteUtil;
import CheckboxThingie;

class Rect extends FlxSprite
{
	public var mainRound:Float;
	public function new(X:Float = 0, Y:Float = 0, width:Float = 0, height:Float = 0, roundWidth:Float = 0, roundHeight:Float = 0,
			Color:FlxColor = FlxColor.WHITE, ?Alpha:Float = 1, ?lineStyle:Int = 0, ?lineColor:FlxColor = FlxColor.WHITE)
	{
		super(X, Y);

		this.mainRound = roundWidth;

		loadGraphic(drawRect(width, height, roundWidth, roundHeight, lineStyle, lineColor));
		antialiasing = ClientPrefs.data.antialiasing;
		color = Color;
		alpha = Alpha;
	}

	function drawRect(width:Float, height:Float, roundWidth:Float, roundHeight:Float, lineStyle:Int, lineColor:FlxColor):BitmapData
	{
		var shape:Shape = new Shape();

		shape.graphics.beginFill(0xFFFFFF);
		shape.graphics.drawRoundRect(0, 0, Std.int(width), Std.int(height), roundWidth, roundHeight);
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0);
		bitmap.draw(shape);
		if (lineStyle > 0) drawLine(bitmap, lineStyle, roundWidth, roundHeight, lineColor);
		return bitmap;
	}

	static var lineShape:Shape = null;
	function drawLine(bitmap:BitmapData, lineStyle:Int, roundWidth:Float, roundHeight:Float, lineColor:FlxColor)
	{
		if (lineShape == null) {
			lineShape = new Shape();
			var lineSize:Int = lineStyle;
			lineShape.graphics.beginFill(lineColor);
			lineShape.graphics.lineStyle(1, lineColor, 1);
			lineShape.graphics.drawRoundRect(0, 0, bitmap.width, bitmap.height, roundWidth, roundHeight);
			lineShape.graphics.lineStyle(0, 0, 0);
			lineShape.graphics.drawRoundRect(lineSize, lineSize, bitmap.width - lineSize * 2, bitmap.height - lineSize * 2, roundWidth - lineSize * 2, roundHeight - lineSize * 2);
			lineShape.graphics.endFill();
		}

		bitmap.draw(lineShape);
	}
}

enum OriginType
{
	LEFT_UP;
	LEFT_CENTER;
	LEFT_DOWN;

	CENTER_UP;
	CENTER_CENTER;
	CENTER_DOWN;

	RIGHT_UP;
	RIGHT_CENTER;
	RIGHT_DOWN;
}

class RoundRect extends FlxSpriteGroup
{
	public var mainColor:FlxColor;
	public var mainWidth:Float; //获取的初始宽度，不可更改否则可能会有问题
	public var mainHeight:Float; //获取的初始高度，不可更改否则可能会有问题
	public var mainRound:Float; //获取的初始圆角，不可更改否则可能会有问题
	public var mainX:Float; //可更改，如果用于flxspritegroup需要重新输入
	public var mainY:Float; //可更改，如果用于flxspritegroup需要重新输入

	public var realWidth:Float; //建议从这里获取真实数据
	public var realHeight:Float; //建议从这里获取真实数据
	public var waitWidth:Float; //建议从这里获取即将到的数据
	public var waitHeight:Float; //建议从这里获取即将到的数据

	////////////////////////////////////////////////////////////////////////////////

	var widthEase:String;
	var heightEase:String;

	public var originType:OriginType;

	////////////////////////////////////////////////////////////////////////////////

	var leftUpRound:BaseSprite;
	var midUpRect:BaseSprite;
	var rightUpRound:BaseSprite;

	var midRect:BaseSprite;

	var leftDownRound:BaseSprite;
	var midDownRect:BaseSprite;
	var rightDownRound:BaseSprite;

	public function new(X:Float, Y:Float, width:Float = 0, height:Float = 0, round:Float, ease:OriginType = LEFT_UP, color:FlxColor = 0xffffff)
	{
		super(X, Y);
		this.mainColor = color;
		mainX = X;
		mainY = Y;
		originType = ease;

		leftUpRound = drawRoundRect(0, 0, round, round, round, 1);
		add(leftUpRound);
		midUpRect = drawRect(leftUpRound.width, 0, width - round * 2, round);
		add(midUpRect);
		rightUpRound = drawRoundRect(leftUpRound.width + midUpRect.width, 0, round, round, round, 2);
		add(rightUpRound);

		midRect = drawRect(0, leftUpRound.height, leftUpRound.width + midUpRect.width + rightUpRound.width, height - round * 2);
		add(midRect);

		leftDownRound = drawRoundRect(0, leftUpRound.height + midRect.height, round, round, round, 3);
		add(leftDownRound);
		midDownRect = drawRect(leftDownRound.width, leftUpRound.height + midRect.height, width - round * 2, round);
		add(midDownRect);
		rightDownRound = drawRoundRect(leftDownRound.width + midDownRect.width, leftUpRound.height + midRect.height, round, round, round, 4);
		add(rightDownRound);

		realWidth = mainWidth = midRect.width;
		realHeight = mainHeight = leftUpRound.height + midRect.height + leftDownRound.height;
		waitWidth = realWidth;
		waitHeight = realHeight;
		mainRound = Std.int(round);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		realWidth = midRect.width * midRect.scale.x;
		realHeight = leftUpRound.height * leftUpRound.scale.y + midRect.height * midRect.scale.y + leftDownRound.height * leftDownRound.scale.y;
	}

	//////////////////////////////////////////////////////

	public function changeWidth(data:Float, time:Float = 0.6, ease:String = 'backInOut')
	{
		waitWidth = data;
		if (time == 0) setChangeWidth(data);
		else tweenChangeWidth(data, time, ease);
	}

	function setChangeWidth(data:Float) {
		switch(originType)
		{
			case LEFT_UP, LEFT_CENTER, LEFT_DOWN:
				var output:Float = calcData(mainWidth, data, mainRound);
				midUpRect.scale.x = output;

				midUpRect.setX(mainX, - (mainWidth - data - mainRound * 2) / 2);
				rightUpRound.setX(mainX, data - mainRound);

				var output:Float = calcData(mainWidth, data, 0);
				midRect.scale.x = output;
				midRect.setX(mainX, - (mainWidth - data) / 2);

				var output:Float = calcData(mainWidth, data, mainRound);
				midDownRect.scale.x = output;
				midDownRect.setX(mainX, - (mainWidth - data - mainRound * 2) / 2);
				rightDownRound.setX(mainX, data - mainRound);


			case CENTER_UP, CENTER_CENTER, CENTER_DOWN:
				leftUpRound.setX(mainX, - (data - mainWidth) / 2);  
			   
				var output:Float = calcData(mainWidth, data, mainRound);
				midUpRect.scale.x = output;			 
				rightUpRound.setX(mainX, (mainWidth + data) / 2 - mainRound); 

				var output:Float = calcData(mainWidth, data, 0);
				midRect.scale.x = output;			  

				leftDownRound.setX(mainX, - (data - mainWidth) / 2); 
				var output:Float = calcData(mainWidth, data, mainRound);
				midDownRect.scale.x = output;
				rightDownRound.setX(mainX, (mainWidth + data) / 2 - mainRound);

			case RIGHT_UP, RIGHT_CENTER, RIGHT_DOWN:
				var output:Float = calcData(mainWidth, data, mainRound);
				midUpRect.scale.x = output;
				midUpRect.setX(mainX, (mainWidth - data) / 2 + mainRound);
				leftUpRound.setX(mainX, mainWidth - data); 

				var output:Float = calcData(mainWidth, data, 0);
				midRect.scale.x = output;
				midRect.setX(mainX, (mainWidth - data) / 2);

				var output:Float = calcData(mainWidth, data, mainRound);
				midDownRect.scale.x = output;
				midDownRect.setX(mainX, (mainWidth - data) / 2 + mainRound);
				leftDownRound.setX(mainX, mainWidth - data); 
		}
		realWidth = midRect.width * midRect.scale.x;
	}

	var widthTweenArray:Array<FlxTween> = [];
	public function tweenChangeWidth(data:Float, time:Float = 0.6, ease:String = 'backInOut') {
		widthEase = ease;
		for (i in 0...widthTweenArray.length)
		{
			if (widthTweenArray[i] != null) widthTweenArray[i].cancel();
		}
		widthTweenArray = [];

		switch(originType)
		{
			case LEFT_UP, LEFT_CENTER, LEFT_DOWN:
				var output:Float = calcData(mainWidth, data, mainRound);
				widthScaleTween(midUpRect.scale, output, time, widthEase);
				widthBaseTween(midUpRect, mainX - (mainWidth - data - mainRound * 2) / 2, time, widthEase);
				widthBaseTween(rightUpRound, data - mainRound, time, widthEase);

				var output:Float = calcData(mainWidth, data, 0);
				widthScaleTween(midRect.scale, output, time, widthEase);
				widthBaseTween(midRect, mainX - (mainWidth - data) / 2, time, widthEase);

				var output:Float = calcData(mainWidth, data, mainRound);
				widthScaleTween(midDownRect.scale, output, time, widthEase);
				widthBaseTween(midDownRect, mainX - (mainWidth - data - mainRound * 2) / 2, time, widthEase);
				widthBaseTween(rightDownRound, data - mainRound, time, widthEase);


			case CENTER_UP, CENTER_CENTER, CENTER_DOWN:
				widthBaseTween(leftUpRound, mainX - (data - mainWidth) / 2, time, widthEase);  
				var output:Float = calcData(mainWidth, data, mainRound);
				widthScaleTween(midUpRect.scale, output, time, widthEase);			 
				widthBaseTween(rightUpRound, (mainWidth + data) / 2 - mainRound, time, widthEase);

				var output:Float = calcData(mainWidth, data, 0);
				widthScaleTween(midRect.scale, output, time, widthEase);			  

				widthBaseTween(leftDownRound, mainX - (data - mainWidth) / 2, time, widthEase);
				var output:Float = calcData(mainWidth, data, mainRound);
				widthScaleTween(midDownRect.scale, output, time, widthEase);
				widthBaseTween(rightDownRound, (mainWidth + data) / 2 - mainRound, time, widthEase);


			case RIGHT_UP, RIGHT_CENTER, RIGHT_DOWN:
				var output:Float = calcData(mainWidth, data, mainRound);
				widthScaleTween(midUpRect.scale, output, time, widthEase);
				widthBaseTween(midUpRect, (mainWidth - data) / 2 + mainRound, time, widthEase);
				widthBaseTween(leftUpRound, mainWidth - data, time, widthEase);

				var output:Float = calcData(mainWidth, data, 0);
				widthScaleTween(midRect.scale, output, time, widthEase);
				widthBaseTween(midRect, (mainWidth - data) / 2, time, widthEase);

				var output:Float = calcData(mainWidth, data, mainRound);
				widthScaleTween(midDownRect.scale, output, time, widthEase);
				widthBaseTween(midDownRect, (mainWidth - data) / 2 + mainRound, time, widthEase);
				widthBaseTween(leftDownRound, mainWidth - data, time, widthEase);
		}
	}

	function widthScaleTween(tag:Dynamic, duration:Float, time:Float, easeType:String)
	{
		var tween = FlxTween.tween(tag, {x: duration}, time, {ease: getTweenEaseByString(easeType)});
		widthTweenArray.push(tween);
	}

	function widthBaseTween(tag:Dynamic, duration:Float, time:Float, easeType:String)
	{
		var tween = FlxTween.num(tag.moveX, duration, time, {ease: getTweenEaseByString(easeType)}, function(v){tag.x = mainX + v; tag.moveX = v;});
		widthTweenArray.push(tween);
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////////////

	public function changeHeight(data:Float, time:Float = 0.6, ease:String = 'backInOut')
	{
		waitHeight = data;
		if (time == 0) setChangeHeight(data);
		else tweenChangeHeight(data, time, ease);
	}

	function setChangeHeight(data:Float) {
		switch(originType)
		{
			case LEFT_UP, CENTER_UP, RIGHT_UP :
				var output:Float = calcData(mainHeight, data, mainRound);
				midRect.scale.y = output;

				midRect.setY(mainY, - (mainHeight - data - mainRound * 2) / 2);

				leftDownRound.setY(mainY, data - mainRound);
				midDownRect.setY(mainY, data - mainRound);
				rightDownRound.setY(mainY, data - mainRound);

			case LEFT_CENTER, CENTER_CENTER, RIGHT_CENTER:
				var output:Float = calcData(mainHeight, data, mainRound);
				midRect.scale.y = output;

				leftUpRound.setY(mainY, (mainHeight - data) / 2);  
				midUpRect.setY(mainY, (mainHeight - data) / 2);
				rightUpRound.setY(mainY, (mainHeight - data) / 2); 

				leftDownRound.setY(mainY, (mainHeight + data) / 2 - mainRound);
				midDownRect.setY(mainY, (mainHeight + data) / 2 - mainRound);
				rightDownRound.setY(mainY, (mainHeight + data) / 2 - mainRound);

			case LEFT_DOWN, CENTER_DOWN, RIGHT_DOWN:
				var output:Float = calcData(mainHeight, data, mainRound);
				midRect.scale.y = output;
				midRect.setY(mainY, (mainHeight - data) / 2 + mainRound); 

				leftUpRound.setY(mainY, height - data); 
				midUpRect.setY(mainY, height - data);
				rightUpRound.setY(mainY, height - data); 
		}
		realHeight = leftUpRound.height * leftUpRound.scale.y + midRect.height * midRect.scale.y + leftDownRound.height * leftDownRound.scale.y;
	}

	var heightTweenArray:Array<FlxTween> = [];
	function tweenChangeHeight(data:Float, time:Float = 0.6, ease:String = 'backInOut')
	{
		heightEase = ease;
		for (i in 0...heightTweenArray.length)
		{
			if (heightTweenArray[i] != null)
				heightTweenArray[i].cancel();
		}
		heightTweenArray = [];
		switch(originType)
		{
			case LEFT_UP, CENTER_UP, RIGHT_UP :
				var output:Float = calcData(mainHeight, data, mainRound);
				heightScaleTween(midRect.scale, output, time, heightEase);
				heightBaseTween(midRect, - (mainHeight - data - mainRound * 2) / 2, time, heightEase);

				heightBaseTween(leftDownRound, data - mainRound, time, heightEase);
				heightBaseTween(midDownRect, data - mainRound, time, heightEase);  
				heightBaseTween(rightDownRound, data - mainRound, time, heightEase);


			case LEFT_CENTER, CENTER_CENTER, RIGHT_CENTER:
				var output:Float = calcData(mainHeight, data, mainRound);
				heightScaleTween(midRect.scale, output, time, heightEase);

				heightBaseTween(leftUpRound, (mainHeight - data) / 2, time, heightEase);
				heightBaseTween(midUpRect, (mainHeight - data) / 2, time, heightEase);  
				heightBaseTween(rightUpRound, (mainHeight - data) / 2, time, heightEase);

				heightBaseTween(leftDownRound, (mainHeight + data) / 2 - mainRound, time, heightEase);
				heightBaseTween(midDownRect, (mainHeight + data) / 2 - mainRound, time, heightEase);  
				heightBaseTween(rightDownRound, (mainHeight + data) / 2 - mainRound, time, heightEase);


			case LEFT_DOWN, CENTER_DOWN, RIGHT_DOWN:
				var output:Float = calcData(mainHeight, data, mainRound);
				heightScaleTween(midRect.scale, output, time, heightEase);
				heightBaseTween(midRect, (mainHeight - data) / 2 + mainRound, time, heightEase);

				heightBaseTween(leftUpRound, height - data, time, heightEase);
				heightBaseTween(midUpRect, height - data, time, heightEase);  
				heightBaseTween(rightUpRound, height - data, time, heightEase);
		}
	}

	function heightScaleTween(tag:Dynamic, duration:Float, time:Float, easeType:String)
	{
		var tween = FlxTween.tween(tag, {y: duration}, time, {ease: getTweenEaseByString(easeType)});
		heightTweenArray.push(tween);
	}

	function heightBaseTween(tag:Dynamic, duration:Float, time:Float, easeType:String)
	{
		var tween = FlxTween.num(tag.moveY, duration, time, {ease: getTweenEaseByString(easeType)}, function(v){tag.y = mainY + v; tag.moveY = v;});
		heightTweenArray.push(tween);
	}

	//////////////////////////////////////////////////////////

	function calcData(init:Float, target:Float, assist:Float):Float
	{
		return (target - assist * 2) / (init - assist * 2);
	}

	function drawRoundRect(x:Float, y:Float, width:Float = 0, height:Float = 0, round:Float = 0, type:Int):BaseSprite
	{
		var dataArray:Array<Float> = [0, 0, 0, 0];
		dataArray[type - 1] = round; // 选择哪个角，（左上，右上，左下，右下）

		var shape:Shape = new Shape();
		shape.graphics.beginFill(mainColor);
		shape.graphics.drawRoundRectComplex(0, 0, width, height, dataArray[0], dataArray[1], dataArray[2], dataArray[3]);
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0);
		bitmap.draw(shape);

		var sprite:BaseSprite = new BaseSprite(x, y);
		sprite.loadGraphic(bitmap);
		sprite.antialiasing = ClientPrefs.data.antialiasing;
		sprite.origin.set(0, 0);
		sprite.updateHitbox();
		return sprite;
	}

	function drawRect(x:Float, y:Float, width:Float = 0, height:Float = 0):BaseSprite
	{
		var shape:Shape = new Shape();
		shape.graphics.beginFill(mainColor);
		shape.graphics.drawRect(0, 0, width, height);
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0);
		bitmap.draw(shape);

		var sprite:BaseSprite = new BaseSprite(x, y);
		sprite.loadGraphic(bitmap);
		return sprite;
	}

	public static function getTweenEaseByString(?ease:String = '')
	{
		switch (ease.toLowerCase().trim())
		{
			case 'backin':
				return FlxEase.backIn;
			case 'backinout':
				return FlxEase.backInOut;
			case 'backout':
				return FlxEase.backOut;
			case 'bouncein':
				return FlxEase.bounceIn;
			case 'bounceinout':
				return FlxEase.bounceInOut;
			case 'bounceout':
				return FlxEase.bounceOut;
			case 'circin':
				return FlxEase.circIn;
			case 'circinout':
				return FlxEase.circInOut;
			case 'circout':
				return FlxEase.circOut;
			case 'cubein':
				return FlxEase.cubeIn;
			case 'cubeinout':
				return FlxEase.cubeInOut;
			case 'cubeout':
				return FlxEase.cubeOut;
			case 'elasticin':
				return FlxEase.elasticIn;
			case 'elasticinout':
				return FlxEase.elasticInOut;
			case 'elasticout':
				return FlxEase.elasticOut;
			case 'expoin':
				return FlxEase.expoIn;
			case 'expoinout':
				return FlxEase.expoInOut;
			case 'expoout':
				return FlxEase.expoOut;
			case 'quadin':
				return FlxEase.quadIn;
			case 'quadinout':
				return FlxEase.quadInOut;
			case 'quadout':
				return FlxEase.quadOut;
			case 'quartin':
				return FlxEase.quartIn;
			case 'quartinout':
				return FlxEase.quartInOut;
			case 'quartout':
				return FlxEase.quartOut;
			case 'quintin':
				return FlxEase.quintIn;
			case 'quintinout':
				return FlxEase.quintInOut;
			case 'quintout':
				return FlxEase.quintOut;
			case 'sinein':
				return FlxEase.sineIn;
			case 'sineinout':
				return FlxEase.sineInOut;
			case 'sineout':
				return FlxEase.sineOut;
			case 'smoothstepin':
				return FlxEase.smoothStepIn;
			case 'smoothstepinout':
				return FlxEase.smoothStepInOut;
			case 'smoothstepout':
				return FlxEase.smoothStepInOut;
			case 'smootherstepin':
				return FlxEase.smootherStepIn;
			case 'smootherstepinout':
				return FlxEase.smootherStepInOut;
			case 'smootherstepout':
				return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}
}

class BaseSprite extends FlxSprite {
	public var moveX:Float = 0;
	public var moveY:Float = 0;

	public function new(x:Float, y:Float) {
		super(x, y);
		moveX = x;
		moveY = y;
	}

	public function setX(main:Float, off:Float):Void {
		this.x = main + off;
		moveX = off;
	}

	public function setY(main:Float, off:Float):Void {
		this.y = main + off;
		moveY = off;
	}
}

class Triangle extends FlxSprite
{
	public function new(X:Float, Y:Float, Size:Float, Inner:Float)
	{
		super(X, Y);

		loadGraphic(drawHollowTriangle(Size, Inner));
		antialiasing = ClientPrefs.data.antialiasing;
	}

	function drawHollowTriangle(sideLength:Float, innerSide:Float):BitmapData
	{
		var shape:Shape = new Shape();

		// 图像的宽度和高度，确保三角形在图像中居中
		var imageSize:Float = sideLength * Math.sqrt(3); // 等边三角形的高为边长的sqrt(3)/2，乘以2得到图像大小
		// 图像中心点
		var centerX:Float = imageSize / 2;
		var centerY:Float = imageSize / 2 + 5; // +5 是修复bug

		// 计算等边三角形的三个顶点位置，确保中心位于图像中心
		var angleStep:Float = Math.PI * 2 / 3; // 顶点之间的角度差为120度，即2π/3
		var p1:Point = new Point(centerX + sideLength * Math.cos(0), centerY + sideLength * Math.sin(0));
		var p2:Point = new Point(centerX + sideLength * Math.cos(angleStep), centerY + sideLength * Math.sin(angleStep));
		var p3:Point = new Point(centerX + sideLength * Math.cos(angleStep * 2), centerY + sideLength * Math.sin(angleStep * 2));

		// 绘制外部三角形
		shape.graphics.beginFill(0xFFFFFF);
		shape.graphics.lineStyle(3, 0xFFFFFF, 1);
		shape.graphics.moveTo(p1.x, p1.y);
		shape.graphics.lineTo(p2.x, p2.y);
		shape.graphics.lineTo(p3.x, p3.y);
		shape.graphics.lineTo(p1.x, p1.y);
		shape.graphics.endFill();

		// 绘制内部三角形
		var innerSideLength:Float = sideLength * (1 - innerSide);
		var innerP1:Point = new Point(centerX + innerSideLength * Math.cos(0), centerY + innerSideLength * Math.sin(0));
		var innerP2:Point = new Point(centerX + innerSideLength * Math.cos(angleStep), centerY + innerSideLength * Math.sin(angleStep));
		var innerP3:Point = new Point(centerX + innerSideLength * Math.cos(angleStep * 2), centerY + innerSideLength * Math.sin(angleStep * 2));

		shape.graphics.beginFill(0x00); // 设置填充颜色为透明
		shape.graphics.moveTo(innerP1.x, innerP1.y);
		shape.graphics.lineTo(innerP2.x, innerP2.y);
		shape.graphics.lineTo(innerP3.x, innerP3.y);
		shape.graphics.lineTo(innerP1.x, innerP1.y);
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(Std.int(imageSize * 1.2), Std.int(imageSize * 1.2), true, 0);
		bitmap.draw(shape);
		return bitmap;
	}
}