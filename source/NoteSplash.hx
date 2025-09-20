package;

import shaders.RGBPalette;
import flixel.system.FlxAssets.FlxShader;

typedef NoteSplashConfig = {
	anim:String,
	minFps:Int,
	maxFps:Int,
	offsets:Array<Array<Float>>
}

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	public var rgbShader:PixelSplashShaderRef;
	private var idleAnim:String;
	private var _textureLoaded:String = null;

	private static var defaultNoteSplash:String = 'noteSplashes/noteSplashes';
	public static var configs:Map<String, NoteSplashConfig> = new Map<String, NoteSplashConfig>();

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);

		var skin:String = null;
		//if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		//else skin = getSplashSkin();

		if (ClientPrefs.data.useRGB) {
			skin = getSplashSkin();
		}
		else {
			skin = 'noteSplashes';
			if (PlayState.isPixelStage && ClientPrefs.data.splashSkin == ClientPrefs.defaultData.splashSkin) skin = 'pixelUI/noteSplashes';
			else if (ClientPrefs.data.splashSkin != ClientPrefs.defaultData.splashSkin) {
				var customSkin:String = 'noteSplashSkins/${skin}' + getNoteSkinPostfix(skin);
				var nonRGBCustomPixelNote:String = 'pixelUI/noteSplashSkins/${skin}' + getNoteSkinPostfix(skin);
				if(Paths.fileExists('images/' + nonRGBCustomPixelNote + '.png', IMAGE) && PlayState.isPixelStage) {
					customSkin = nonRGBCustomPixelNote;
				}
				if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;
			}
		}
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		if (ClientPrefs.data.useRGB) {
			rgbShader = new PixelSplashShaderRef();
			shader = rgbShader.shader;
			precacheConfig(skin);
		}
		else {
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;
		}
		cacheNoteSplashTexture(); //this thing needs to be cache the NoteSplash
		//setupNoteSplash(x, y, 0);
	}

	override function destroy()
	{
		configs.clear();
		super.destroy();
	}

	function cacheNoteSplashTexture(?note:Note = null) {
		var texture:String = null;

		if (ClientPrefs.data.useRGB) {
			texture = getSplashSkin();
		}
		else {
			texture = 'noteSplashes';
			if (PlayState.isPixelStage && ClientPrefs.data.splashSkin == ClientPrefs.defaultData.splashSkin) texture = 'pixelUI/noteSplashes';
			else if (ClientPrefs.data.splashSkin != ClientPrefs.defaultData.splashSkin) {
				var customSkin:String = 'noteSplashSkins/${texture}' + getNoteSkinPostfix(texture);
				var nonRGBCustomPixelNote:String = 'pixelUI/noteSplashSkins/${texture}' + getNoteSkinPostfix(texture);
				if(Paths.fileExists('images/' + nonRGBCustomPixelNote + '.png', IMAGE) && PlayState.isPixelStage) {
					customSkin = nonRGBCustomPixelNote;
				}
				if(Paths.fileExists('images/$customSkin.png', IMAGE)) texture = customSkin;
			}
		}
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		
		if (!ClientPrefs.data.useRGB) {
			if(note != null)
				if(Paths.fileExists('images/${note.noteSplashTexture}.png', IMAGE)) texture = note.noteSplashTexture;
		}

		if (ClientPrefs.data.useRGB) {
			var config:NoteSplashConfig = precacheConfig(texture);
			if(_textureLoaded != texture)
				config = loadAnims(texture, config);

			_textureLoaded = texture;
		}
		else {
			if(_textureLoaded != texture) {
				loadLegacyAnims(texture);
			}
		}
	}

	var maxAnims:Int = 2;
	public function setupNoteSplash(x:Float, y:Float, direction:Int = 0, ?note:Note = null) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;
		aliveTime = 0;

		var texture:String = null;
		//if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		//else texture = getSplashSkin();

		if (ClientPrefs.data.useRGB) {
			texture = getSplashSkin();
		}
		else {
			texture = 'noteSplashes';
			if (PlayState.isPixelStage && ClientPrefs.data.splashSkin == ClientPrefs.defaultData.splashSkin) texture = 'pixelUI/noteSplashes';
			else if (ClientPrefs.data.splashSkin != ClientPrefs.defaultData.splashSkin) {
				var customSkin:String = 'noteSplashSkins/${texture}' + getNoteSkinPostfix(texture);
				var nonRGBCustomPixelNote:String = 'pixelUI/noteSplashSkins/${texture}' + getNoteSkinPostfix(texture);
				if(Paths.fileExists('images/' + nonRGBCustomPixelNote + '.png', IMAGE) && PlayState.isPixelStage) {
					customSkin = nonRGBCustomPixelNote;
				}
				if(Paths.fileExists('images/$customSkin.png', IMAGE)) texture = customSkin;
			}
		}
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		
		if (!ClientPrefs.data.useRGB) {
			if(note != null)
				if(Paths.fileExists('images/${note.noteSplashTexture}.png', IMAGE)) texture = note.noteSplashTexture;
		}

		if (ClientPrefs.data.useRGB) {
			var config:NoteSplashConfig = precacheConfig(texture);
			if(_textureLoaded != texture)
				config = loadAnims(texture, config);

			var tempShader:RGBPalette = null;
			if(note != null && !note.noteSplashGlobalShader)
				tempShader = note.rgbShader.parent;
			else
				tempShader = Note.globalRgbShaders[direction];

			if(tempShader != null) rgbShader.copyValues(tempShader);

			_textureLoaded = texture;
			offset.set(10, 10);

			var animNum:Int = FlxG.random.int(1, maxAnims);
			animation.play('note' + direction + '-' + animNum, true);

			var minFps:Int = 22;
			var maxFps:Int = 26;
			if(config != null)
			{
				var animID:Int = direction + ((animNum - 1) * Note.colArray.length);
				//trace('anim: ${animation.curAnim.name}, $animID');
				var offs:Array<Float> = config.offsets[FlxMath.wrap(animID, 0, config.offsets.length-1)];
				offset.x += offs[0];
				offset.y += offs[1];
				minFps = config.minFps;
				maxFps = config.maxFps;
			}
			else
			{
				offset.x += -58;
				offset.y += -55;
			}

			if(animation.curAnim != null)
				animation.curAnim.frameRate = FlxG.random.int(minFps, maxFps);
		}
		else {
			if(_textureLoaded != texture) {
				loadLegacyAnims(texture);
			}

			//from PlayState (Handling on NoteSplash because I'm lazy to add this into editor)
			var hue:Float = 0;
			var sat:Float = 0;
			var brt:Float = 0;
			if (direction > -1 && direction < ClientPrefs.data.arrowHSV.length)
			{
				hue = ClientPrefs.data.arrowHSV[direction][0] / 360;
				sat = ClientPrefs.data.arrowHSV[direction][1] / 100;
				brt = ClientPrefs.data.arrowHSV[direction][2] / 100;
				if(note != null) {
					hue = note.noteSplashHue;
					sat = note.noteSplashSat;
					brt = note.noteSplashBrt;
				}
			}
			colorSwap.hue = hue;
			colorSwap.saturation = sat;
			colorSwap.brightness = brt;
			offset.set(10, 10);

			var animNum:Int = FlxG.random.int(1, 2);
			animation.play('note' + direction + '-' + animNum, true);
			if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		}
	}

	public static function getSplashSkin()
	{
		var skin:String = defaultNoteSplash;
		if(ClientPrefs.data.splashSkin != 'Psych')
			skin += '-' + ClientPrefs.data.splashSkin.trim().toLowerCase().replace(' ', '_');
		return skin;
	}

	public static function getNoteSkinPostfix(?ogSkin:String)
	{
		var skin:String = '';
		if(ClientPrefs.data.splashSkin != ClientPrefs.defaultData.splashSkin)
			skin = '-' + ClientPrefs.data.splashSkin.trim().toLowerCase().replace(' ', '_');
		return skin;
	}

	function loadLegacyAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
	}

	function loadAnims(skin:String, ?config:NoteSplashConfig = null, ?animName:String = null):NoteSplashConfig {
			maxAnims = 0;
			frames = Paths.getSparrowAtlas(skin);

			if(animName == null)
				animName = config != null ? config.anim : 'note splash';

			var config:NoteSplashConfig = precacheConfig(skin);
			while(true) {
				var animID:Int = maxAnims + 1;
				for (i in 0...Note.colArray.length) {
					if (!addAnimAndCheck('note$i-$animID', '$animName ${Note.colArray[i]} $animID', 24, false)) {
						//trace('maxAnims: $maxAnims');
						return config;
					}
				}
				maxAnims++;
				//trace('currently: $maxAnims');
			}
	}

	public static function precacheConfig(skin:String)
	{
		if(configs.exists(skin)) return configs.get(skin);

		var path:String = Paths.getPath('images/$skin.txt', TEXT);
		var configFile:Array<String> = CoolUtil.coolTextFile(path);
		if(configFile.length < 1) return null;
		
		var framerates:Array<String> = configFile[1].split(' ');
		var offs:Array<Array<Float>> = [];
		for (i in 2...configFile.length)
		{
			var animOffs:Array<String> = configFile[i].split(' ');
			offs.push([Std.parseFloat(animOffs[0]), Std.parseFloat(animOffs[1])]);
		}

		var config:NoteSplashConfig = {
			anim: configFile[0],
			minFps: Std.parseInt(framerates[0]),
			maxFps: Std.parseInt(framerates[1]),
			offsets: offs
		};
		//trace(config);
		configs.set(skin, config);
		return config;
	}

	function addAnimAndCheck(name:String, anim:String, ?framerate:Int = 24, ?loop:Bool = false)
	{
		animation.addByPrefix(name, anim, framerate, loop);
		return animation.getByName(name) != null;
	}

	static var aliveTime:Float = 0;
	static var buggedKillTime:Float = 0.5; //automatically kills note splashes if they break to prevent it from flooding your HUD
	override function update(elapsed:Float) {
		aliveTime += elapsed;
		if((animation.curAnim != null && animation.curAnim.finished) ||
			(animation.curAnim == null && aliveTime >= buggedKillTime)) kill();

		super.update(elapsed);
	}
}

class PixelSplashShaderRef {
	public var shader:PixelSplashShader = new PixelSplashShader();

	public function copyValues(tempShader:RGBPalette)
	{
		for (i in 0...3)
		{
			shader.r.value[i] = tempShader.shader.r.value[i];
			shader.g.value[i] = tempShader.shader.g.value[i];
			shader.b.value[i] = tempShader.shader.b.value[i];
		}
		shader.mult.value[0] = tempShader.shader.mult.value[0];
		shader.enabled.value[0] = tempShader.shader.enabled.value[0];
	}

	public function new()
	{
		shader.r.value = [0, 0, 0];
		shader.g.value = [0, 0, 0];
		shader.b.value = [0, 0, 0];
		shader.mult.value = [1];
		shader.enabled.value = [true];

		var pixel:Float = 1;
		if(PlayState.isPixelStage) pixel = PlayState.daPixelZoom;
		shader.uBlocksize.value = [pixel, pixel];
		trace('Created shader ' + Conductor.songPosition);
	}
}

class PixelSplashShader extends FlxShader
{
	@:glFragmentHeader('
		#pragma header
		
		uniform vec3 r;
		uniform vec3 g;
		uniform vec3 b;
		uniform float mult;
		uniform bool enabled;
		uniform vec2 uBlocksize;

		vec4 flixel_texture2DCustom(sampler2D bitmap, vec2 coord) {
			vec2 blocks = openfl_TextureSize / uBlocksize;
			vec4 color = flixel_texture2D(bitmap, floor(coord * blocks) / blocks);
			if (!hasTransform) {
				return color;
			}

			if(!enabled || color.a == 0.0 || mult == 0.0) {
				return color * openfl_Alphav;
			}

			vec4 newColor = color;
			newColor.rgb = min(color.r * r + color.g * g + color.b * b, vec3(1.0));
			newColor.a = color.a;
			
			color = mix(color, newColor, mult);
			
			if(color.a > 0.0) {
				return vec4(color.rgb, color.a);
			}
			return vec4(0.0, 0.0, 0.0, 0.0);
		}')

	@:glFragmentSource('
		#pragma header

		void main() {
			gl_FragColor = flixel_texture2DCustom(bitmap, openfl_TextureCoordv);
		}')

	public function new()
	{
		super();
	}
}