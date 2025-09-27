package;

import flixel.util.FlxSave;
import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import flixel.animation.FlxAnimation;
import haxe.xml.Access;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

using StringTools;

#if cpp
@:cppFileCode('#include <thread>')
#end
class CoolUtil
{
	/*
	 * Returns `v` if not null
	 * @param v The value
	 * @return A bool value
	 */
	public static inline function isNotNull(v:Null<Dynamic>):Bool {
		return v != null && !isNaN(v);
	}

	/*
	 * Returns `v` if not null, `defaultValue` otherwise.
	 * @param v The value
	 * @param defaultValue The default value
	 * @return The return value
	 */
	public static inline function getDefault<T>(v:Null<T>, defaultValue:T):T {
		return (v == null || isNaN(v)) ? defaultValue : v;
	}

	/**
	 * For use when using Std.parseFloat, if not using that then use `getDefault`.
	 * @param v The value
	 * @param defaultValue The default value
	 * @return The return value
	 */
	public static inline function getDefaultFloat(v:Float, defaultValue:Float):Float {
		return (Math.isNaN(v)) ? defaultValue : v;
	}

	/**
	 * Gets an XML attribute from an `Access` abstract, without throwing an exception if invalid.
	 * Example: `xml.getAtt("test").getDefault("Hello, World!");`
	 * @param xml XML to get the attribute from
	 * @param name Name of the attribute
	 */
	public static inline function getAtt(xml:Access, name:String) {
		if (!xml.has.resolve(name)) return null;
		return xml.att.resolve(name);
	}

	static inline function isNull(a:Dynamic):Bool {
		return Type.enumEq(Type.typeof(a), TNull);
	}

	/**
	 * Converts a string of "1..3,5,7..9,8..5" into an array of numbers like [1,2,3,5,7,8,9,8,7,6,5]
	 * @param input String to parse
	 * @return Array of numbers
	 */
	public static function parseNumberRange(input:String):Array<Int> {
		var result:Array<Int> = [];
		var parts:Array<String> = input.split(",");

		for (part in parts) {
			part = part.trim();
			var idx = part.indexOf("..");
			if (idx != -1) {
				var start = Std.parseInt(part.substring(0, idx).trim());
				var end = Std.parseInt(part.substring(idx + 2).trim());

				if(start == null || end == null) {
					continue;
				}

				if (start < end) {
					for (j in start...end + 1) {
						result.push(j);
					}
				} else {
					for (j in end...start + 1) {
						result.push(start + end - j);
					}
				}
			} else {
				var num = Std.parseInt(part);
				if (num != null) {
					result.push(num);
				}
			}
		}
		return result;
	}

	/**
	 * Whenever a value is NaN or not.
	 * @param v Value
	 */
	public static inline function isNaN(v:Dynamic):Bool {
		return (v is Float) ? Math.isNaN(cast(v, Float)) : false;
	}

	/**
	 * Sets a field's default value, and returns it. In case it already exists, returns the existing one.
	 * @param v Dynamic to set the default value to
	 * @param name Name of the value
	 * @param defaultValue Default value
	 * @return T New/old value.
	 */
	public static function setFieldDefault<T>(v:Dynamic, name:String, defaultValue:T):T {
		if (Reflect.hasField(v, name)) {
			var f:Null<Dynamic> = Reflect.field(v, name);
			if (f != null)
				return cast f;
		}
		Reflect.setField(v, name, defaultValue);
		return defaultValue;
	}

	/**
	 * Tries to get a color from a `Dynamic` variable.
	 * @param c `Dynamic` color.
	 * @return The result color, or `null` if invalid.
	 */
	public static function getColorFromDynamic(c:Dynamic):Null<FlxColor> {
		// -1
		if (c is Int) return c;

		// -1.0
		if (c is Float) return Std.int(c);

		// "#FFFFFF"
		if (c is String) return FlxColor.fromString(c);

		// [255, 255, 255]
		if (c is Array) {
			var r:Int = 0;
			var g:Int = 0;
			var b:Int = 0;
			var a:Int = 255;
			var array:Array<Dynamic> = cast c;
			for(k=>e in array) {
				if (e is Int || e is Float) {
					switch(k) {
						case 0:	r = Std.int(e);
						case 1:	g = Std.int(e);
						case 2:	b = Std.int(e);
						case 3:	a = Std.int(e);
					}
				}
			}
			return FlxColor.fromRGB(r, g, b, a);
		}
		return null;
	}

	/**
	 * Switches frames from 2 FlxAnimations.
	 * @param anim1 First animation
	 * @param anim2 Second animation
	 */
	@:noUsing public static function switchAnimFrames(anim1:FlxAnimation, anim2:FlxAnimation) {
		if (anim1 == null || anim2 == null) return;
		var old = anim1.frames;
		anim1.frames = anim2.frames;
		anim2.frames = old;
	}

	/**
	 * Converts an array of numbers into a string of ranges.
	 * Example: [1,2,3,5,7,8,9,8,7,6,5] -> "1..3,5,7..9,8..5"
	 * @param numbers Array of numbers
	 * @param separator Separator between ranges
	 * @return String representing the ranges
	 */
	public static function formatNumberRange(numbers:Array<Int>, separator:String = ","):String {
		if (numbers.length == 0) return "";

		var result:Array<String> = [];
		var i = 0;

		while (i < numbers.length) {
			var start = numbers[i];
			var end = start;
			var direction = 0; // 0: no sequence, 1: increasing, -1: decreasing

			if (i + 1 < numbers.length) { // detect direction of sequence
				if (numbers[i + 1] == end + 1) {
					direction = 1;
				} else if (numbers[i + 1] == end - 1) {
					direction = -1;
				}
			}

			if(direction != 0) {
				while (i + 1 < numbers.length && (numbers[i + 1] == end + direction)) {
					end = numbers[i + 1];
					i++;
				}
			}

			if (start == end) { // no direction
				result.push('${start}');
			} else if (start + direction == end) { // 1 step increment
				result.push('${start},${end}');
			} else { // store as range
				result.push('${start}..${end}');
			}

			i++;
		}

		return result.join(separator);
	}

	/*
	 * Returns the filename of a path, without the extension.
	 * @param path Path to get the filename from
	 * @return Filename
	 */
	@:noUsing public static inline function getFilename(file:String) {
		var file = new haxe.io.Path(file);
		return file.file;
	}

	/**
	 * Equivalent of `Math.max`, except doesn't require a Int -> Float -> Int conversion.
	 * @param p1
	 * @param p2
	 * @return return p1 < p2 ? p2 : p1
	 */
	@:noUsing public static inline function maxInt(p1:Int, p2:Int)
		return p1 < p2 ? p2 : p1;

	/**
	 * Pushes an element to an array, but only if it doesn't already exist.
	 * @param array Array to push to
	 * @param element Element to push
	 */
	public static inline function pushOnce<T>(array:Array<T>, element:T) {
		#if (haxe >= "4.0.0")
		if (!array.contains(element))
			array.push(element);
		#else
		if (array.indexOf(element) == -1)
			array.push(element);
		#end
	}

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		var formatted:Array<String> = path.split(':'); //prevent "shared:", "preload:" and other library names on file path
		path = formatted[formatted.length-1];
		if(FileSystem.exists(path)) daList = File.getContent(path);
		#else
		if(Assets.exists(path)) daList = Assets.getText(path);
		#end

		return daList != null ? listFromString(daList) : [];
	}

	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	//uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void {
		Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void {
		Paths.music(sound, library);
	}

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
	public static function getSavePath(folder:String = 'ShadowMario'):String {
		@:privateAccess
		return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}
	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}
	
	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;

		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}
	
	public static function showPopUp(message:String, title:String):Void
	{
		/*#if android
		AndroidTools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		#else*/
		FlxG.stage.window.alert(message, title);
		//#end
	}

	@:noUsing public static inline function getMacroAbstractClass(className:String) {
		return Type.resolveClass('${className}_HSC');
	}

	#if cpp
	@:functionCode('
		return std::thread::hardware_concurrency();
	')
	#end
	public static function getCPUThreadsCount():Int
	{
		return 1;
	}
}
