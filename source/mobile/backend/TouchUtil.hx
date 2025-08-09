package mobile.backend;

import flixel.FlxObject;
import flixel.input.touch.FlxTouch;

class TouchUtil
{
	public static var pressed(get, never):Bool;
	public static var justPressed(get, never):Bool;
	public static var justReleased(get, never):Bool;
	public static var released(get, never):Bool;
	public static var touch(get, never):FlxTouch;

	public static function overlaps(object:FlxObject, ?camera:FlxCamera):Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.overlaps(object, camera ?? object.camera))
				return true;

		return false;
	}

	public static function overlapsComplex(object:FlxObject, ?camera:FlxCamera):Bool
	{
		if (camera == null)
			for (camera in object.cameras)
				for (touch in FlxG.touches.list)
					@:privateAccess
					if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera))
						return true;
		else
			@:privateAccess
			if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera))
				return true;

		return false;
	}

	@:noCompletion
	private static function get_pressed():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.pressed)
				return true;

		return false;
	}

	@:noCompletion
	private static function get_justPressed():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.justPressed)
				return true;

		return false;
	}

	@:noCompletion
	private static function get_justReleased():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.justReleased)
				return true;

		return false;
	}

	@:noCompletion
	private static function get_released():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.released)
				return true;

		return false;
	}

	@:noCompletion
	private static function get_touch():FlxTouch
	{
		for (touch in FlxG.touches.list)
			if (touch != null)
				return touch;

		return FlxG.touches.getFirst();
	}
}

class Swipe
{
	/**
	 * Indicates if there is an up swipe gesture detected.
	 */
	public static var Up(get, never):Bool;

	/**
	 * Indicates if there is a down swipe gesture detected.
	 */
	public static var Down(get, never):Bool;

	/**
	 * Indicates if there is a left swipe gesture detected.
	 */
	public static var Left(get, never):Bool;

	/**
	 * Indicates if there is a right swipe gesture detected.
	 */
	public static var Right(get, never):Bool;

	/**
	 * Determines if there is an up swipe in the FlxG.swipes array.
	 *
	 * @return True if any swipe direction is up, false otherwise.
	 */
	@:noCompletion
	static function get_Up():Bool
	{
		#if FLX_POINTER_INPUT
		for (swipe in FlxG.swipes)
		{
			if (swipe.degrees > 45 && swipe.degrees < 135 && swipe.distance > 20) return true;
		}
		#end

		return false;
	}

	/**
	 * Determines if there is a down swipe in the FlxG.swipes array.
	 *
	 * @return True if any swipe direction is down, false otherwise.
	 */
	@:noCompletion
	static function get_Down():Bool
	{
		#if FLX_POINTER_INPUT
		for (swipe in FlxG.swipes)
		{
			if (swipe.degrees > -135 && swipe.degrees < -45 && swipe.distance > 20) return true;
		}
		#end

		return false;
	}

	/**
	 * Determines if there is a left swipe in the FlxG.swipes array.
	 *
	 * @return True if any swipe direction is left, false otherwise.
	 */
	@:noCompletion
	static function get_Left():Bool
	{
		#if FLX_POINTER_INPUT
		for (swipe in FlxG.swipes)
		{
			if (swipe.degrees > 45 && swipe.degrees < -45 && swipe.distance > 20) return true;
		}
		#end

		return false;
	}

	/**
	 * Determines if there is a right swipe in the FlxG.swipes array.
	 *
	 * @return True if any swipe direction is right, false otherwise.
	 */
	@:noCompletion
	static function get_Right():Bool
	{
		#if FLX_POINTER_INPUT
		for (swipe in FlxG.swipes)
		{
			if (swipe.degrees > -45 && swipe.degrees < 45 && swipe.distance > 20) return true;
		}
		#end

		return false;
	}
}