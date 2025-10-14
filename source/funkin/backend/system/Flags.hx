package funkin.backend.system;

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
	
	// FunkinSprite Stuff
	public static var SOUND_EXT:String = #if web "mp3" #else "ogg" #end; // we also support wav
	public static var VIDEO_EXT:String = "mp4";
	public static var IMAGE_EXT:String = "png"; // we also support jpg

	// CNE Character Stuff
	@:also(funkin.game.Character_CNE.FALLBACK_CHARACTER)
	@:also(funkin.game.Character.FALLBACK_CHARACTER)
	public static var DEFAULT_CHARACTER:String = "bf";
	public static var DEFAULT_GIRLFRIEND:String = "gf";
	public static var DEFAULT_OPPONENT:String = "dad";
	public static var DEFAULT_HEALTH_ICON:String = "face";

	@:also(funkin.game.Character_CNE.FALLBACK_DEAD_CHARACTER)
	@:also(funkin.game.Character.FALLBACK_DEAD_CHARACTER)
	public static var DEFAULT_GAMEOVER_CHARACTER:String = "bf-dead";
	public static var STUNNED_TIME:Float = 5 / 60;

	/**
	 * Default background colors for songs or more without bg color
	 */
	public static var DEFAULT_COLOR:FlxColor = 0xFF9271FD;
	// -- End of Codename's Default Flags --
}