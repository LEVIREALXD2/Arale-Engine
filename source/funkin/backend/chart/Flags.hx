package funkin.backend.chart;

import flixel.util.FlxColor;
import lime.app.Application;
import lime.utils.AssetLibrary as LimeAssetLibrary;
import lime.utils.AssetType;

/**
 * A class that reads the `flags.ini` file, allowing to read settable Flags (customs too).
 */
class Flags {
	// -- Codename Flags --
	// Converter Stuff
	public static var DEFAULT_DIFFICULTY:String = "normal";
	public static var DEFAULT_STAGE:String = "stage";

	// Internal stuff
	public static var DEFAULT_BPM:Float = 100.0;
	public static var DEFAULT_BEATS_PER_MEASURE:Int = 4;
	public static var DEFAULT_STEPS_PER_BEAT:Int = 4;
	public static var DEFAULT_LOOP_TIME:Float = 0.0;

	/**
	 * Default background colors for songs or more without bg color
	 */
	public static var DEFAULT_COLOR:FlxColor = 0xFF9271FD;
	// -- End of Codename's Default Flags --
}