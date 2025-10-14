package novaengine;

import flixel.system.FlxAssets.FlxGraphicAsset;

class ChangeSprite extends FlxSpriteGroup //背景切换
{
	var bg1:MoveSprite;
	var bg2:MoveSprite;

	public function new(X:Float, Y:Float)
	{
		super(X, Y);

        bg1 = new MoveSprite(0, 0);
        bg1.antialiasing = ClientPrefs.data.antialiasing;
		add(bg1);

		bg2 = new MoveSprite(0, 0);
        bg2.antialiasing = ClientPrefs.data.antialiasing;
		add(bg2);
	}

    public function load(graphic:FlxGraphicAsset, scaleValue:Float = 1.1) {
        bg1.load(graphic, scaleValue);
        bg2.load(graphic, scaleValue);
        return this;
    }

	var mainTween:FlxTween;
    public function changeSprite(graphic:FlxGraphicAsset, time:Float = 0.6) {
        if (mainTween != null) { 
            mainTween.cancel();
        }

        bg2.loadGraphic(graphic, false, 0, 0, false, null);
        
        mainTween = FlxTween.tween(bg1, {alpha: 0}, time, {
            ease: FlxEase.expoIn,
            onComplete: function(twn:FlxTween)
            {
              bg1.loadGraphic(bg2.graphic);
              bg1.alpha = 1;
            }
		});
    }
}

class MoveSprite extends FlxSprite{
    public function new(X:Float = 0, Y:Float = 0) {
        super(X, Y);
    }

    public function load(graphic:FlxGraphicAsset, scaleValue:Float = 1.1) {
        this.loadGraphic(graphic, false, 0, 0, false);
        this.scrollFactor.set(0, 0);
        var scale = Math.max(FlxG.width * scaleValue / this.width, FlxG.height * scaleValue / this.height);
		this.scale.x = scale;
		this.scale.y = scale;
		this.updateHitbox();
    }

    public var bgFollowSmooth:Float = 0.2;

    public var allowMove:Bool = true;
    override function update(elapsed:Float)
	{
		super.update(elapsed);
        if (allowMove) {
			var mouseX = FlxG.mouse.getWorldPosition().x;
			var mouseY = FlxG.mouse.getWorldPosition().y;
			var centerX = FlxG.width / 2;
			var centerY = FlxG.height / 2;
			
			var targetOffsetX = (mouseX - centerX) * 0.01;
			var targetOffsetY = (mouseY - centerY) * 0.01;
			
			var currentOffsetX = this.x - (centerX - this.width / 2);
			var currentOffsetY = this.y - (centerY - this.height / 2);
			
			var smoothX = FlxMath.lerp(currentOffsetX, targetOffsetX, bgFollowSmooth);
			var smoothY = FlxMath.lerp(currentOffsetY, targetOffsetY, bgFollowSmooth);
			
			this.x = centerX - this.width / 2 + smoothX;
			this.y = centerY - this.height / 2 + smoothY;
		}
    }
}