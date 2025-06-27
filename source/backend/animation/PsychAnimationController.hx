package backend.animation;

import flixel.animation.FlxAnimationController;

/**
 * Animation Controller for 0.6.x
 * @author KralOyuncu2010x (ArkoseLabs)
 */

class PsychAnimationController extends FlxAnimationController {
    public static var globalSpeed:Float = 1;
	public var followGlobalSpeed:Bool = true;

    public override function update(elapsed:Float):Void {
		if (_curAnim != null)
		{
			var e:Float = elapsed;
			if(followGlobalSpeed) e *= globalSpeed;

			_curAnim.update(e);
		}
		else if (_prerotated != null)
		{
			_prerotated.angle = _sprite.angle;
		}
	}
}
