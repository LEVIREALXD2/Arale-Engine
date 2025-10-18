package backend.mouse;

import flixel.FlxBasic;

class MouseEvent extends FlxBasic
{
	public var justPressed:Bool = false;
	public var pressed:Bool = false;
	public var justReleased:Bool = false;

	public function new() {
		super();
	}

	var calcPos:Float = 0;
	var lastMouseY:Float = 0;
	var lastMouseX:Float = 0;
	override function update(elapsed:Float) {

		var mouse = FlxG.mouse;

		if (mouse.justPressed) { 
			justPressed = true; 
			lastMouseY = mouse.y;
			lastMouseX = mouse.x;
			calcPos = 0;
		}
		else justPressed = false;

		if (mouse.pressed) {
			pressed = true;
			calcPos += Math.abs(mouse.y - lastMouseY) + Math.abs(mouse.x - lastMouseX);
		}
		else pressed = false;

		if (mouse.justReleased && calcPos < 10) justReleased = true;
		else justReleased = false;
	
		super.update(elapsed);
	}

	public function overlaps(tar:FlxBasic):Bool {
		return FlxG.mouse.overlaps(tar);
	}
}