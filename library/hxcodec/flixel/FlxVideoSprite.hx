package hxcodec.flixel;

#if flixel
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import hxcodec.flixel.FlxVideo;

/**
 * This class allows you to play videos using sprites (FlxSprite).
 */
class FlxVideoSprite extends FlxSprite
{
	public var bitmap:FlxVideo;
	public var canvasWidth:Null<Int>;
	public var canvasHeight:Null<Int>;
	public var fillScreen:Bool = false;

	public var openingCallback:Void->Void = null;
	public var finishCallback:Void->Void = null;

	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);

		makeGraphic(1, 1, FlxColor.TRANSPARENT);

		bitmap = new FlxVideo();
		bitmap.canUseAutoResize = false;
		bitmap.alpha = 0;
		bitmap.openingCallback = function()
		{
			if (openingCallback != null)
				openingCallback();
		}
		bitmap.finishCallback = function()
		{
			oneTime = false;
			if (finishCallback != null)
				finishCallback();

			kill();
		}
	}

	private var oneTime:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (bitmap.isPlaying && bitmap.isDisplaying && bitmap.bitmapData != null && !oneTime)
		{
			var graphic:FlxGraphic = FlxG.bitmap.add(bitmap.bitmapData, false, '');
			if (graphic.imageFrame.frame == null)
			{
				trace('the frame of the image is null?');
				return;
			}

			loadGraphic(graphic);
			if (canvasWidth != null && canvasHeight != null)
			{
				setGraphicSize(canvasWidth, canvasHeight);
				updateHitbox();

				var size:Float = (fillScreen ? Math.max : Math.min)(scale.x, scale.y);
				scale.set(size, size); // lol
			}
			oneTime = true;
		}
	}

	public function pause() {
		bitmap.pause();
	}

	public function resume() {
		bitmap.resume();
	}

	public var usedLoadFunction:Bool = false;
	public function load(Path:String, Loop:Bool = false, PauseMusic:Bool = false):Void
	{
		bitmap.play(Path, Loop, PauseMusic);
		bitmap.pause();
	}

	public function play():Void
		resume();

	/**
	 * Native video support for Flixel & OpenFL
	 * @param Path Example: `your/video/here.mp4`
	 * @param Loop Loop the video.
	 * @param PauseMusic Pause music until the video ends.
	 */
	public function playVideo(Path:String, Loop:Bool = false, PauseMusic:Bool = false):Void
		bitmap.play(Path, Loop, PauseMusic);
}
#end