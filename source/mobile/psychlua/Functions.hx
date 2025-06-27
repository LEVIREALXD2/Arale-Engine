package mobile.psychlua;

import lime.ui.Haptic;
import flixel.util.FlxSave;
import mobile.backend.TouchFunctions;
import mobile.objects.MobileControls.ControlsGroup;
import mobile.objects.MobileControls.Config;
import FunkinLua.CustomSubstate;
#if android
import android.widget.Toast as AndroidToast;
#end

class MobileFunctions
{
	static var config:Config = new Config('saved-controls');

	public static function implement(funk:FunkinLua)
	{
		#if LUA_ALLOWED
		var lua:State = funk.lua;

		#if TOUCH_CONTROLS
		//Use them for 8k charts or something
		Lua_helper.add_callback(lua, 'HitboxPressed', function(button:String):Bool
		{
			return PlayState.checkHBoxPress(button, 'pressed');
		});

		Lua_helper.add_callback(lua, 'HitboxJustPressed', function(button:String):Bool
		{
			return PlayState.checkHBoxPress(button, 'justPressed');
		});

		Lua_helper.add_callback(lua, 'HitboxReleased', function(button:String):Bool
		{
			return PlayState.checkHBoxPress(button, 'released');
		});

		Lua_helper.add_callback(lua, 'HitboxJustReleased', function(button:String):Bool
		{
			return PlayState.checkHBoxPress(button, 'justReleased');
		});
		#end

		#if LUAMPAD_ALLOWED
		//OMG
		Lua_helper.add_callback(lua, 'mobilePadPressed', function(buttonPostfix:String):Bool
		{
			return PlayState.checkMPadPress(buttonPostfix, 'pressed');
		});

		Lua_helper.add_callback(lua, 'mobilePadJustPressed', function(buttonPostfix:String):Bool
		{
			return PlayState.checkMPadPress(buttonPostfix, 'justPressed');
		});

		Lua_helper.add_callback(lua, 'mobilePadReleased', function(buttonPostfix:String):Bool
		{
			return PlayState.checkMPadPress(buttonPostfix, 'released');
		});

		Lua_helper.add_callback(lua, 'mobilePadJustReleased', function(buttonPostfix:String):Bool
		{
			return PlayState.checkMPadPress(buttonPostfix, 'justReleased');
		});

		Lua_helper.add_callback(lua, 'addMobilePad', function(DPad:String, Action:String, ?addToCustomSubstate:Bool = false, ?posAtCustomSubstate:Int = -1):Void
		{
			PlayState.instance.makeLuaMobilePad(DPad, Action);
			if (addToCustomSubstate)
			{
				if (PlayState.instance.luaMobilePad != null || !PlayState.instance.members.contains(PlayState.instance.luaMobilePad))
					CustomSubstate.insertLuaMpad(posAtCustomSubstate);
			}
			else
				PlayState.instance.addLuaMobilePad();
		});

		Lua_helper.add_callback(lua, 'addMobilePadCamera', function():Void
		{
			PlayState.instance.addLuaMobilePadCamera();
		});

		Lua_helper.add_callback(lua, 'removeMobilePad', function():Void
		{
			PlayState.instance.removeLuaMobilePad();
		});
		#end

		#if TOUCH_CONTROLS
		Lua_helper.add_callback(lua, "MobileC", function(enabled:Bool = false):Void
		{
			MusicBeatState.mobilec.visible = enabled;
		});

		Lua_helper.add_callback(lua, "switchMobileControls", function(?cValue:Int):Void
		{
			PlayState.instance.reloadControls(cValue);
		});

		Lua_helper.add_callback(lua, 'getCurMobilecMode', function():String
		{
			var curMode:String = '${MobileControls.mode}';
			return curMode;
		});

		//better support
		Lua_helper.add_callback(lua, "changeMobileControls", function(?cValue:Int, ?mode:String, ?action:String):Void
		{
			if (mode == null) mode = "NONE";
			if (action == null) action = "NONE";
			PlayState.instance.reloadControls(cValue, mode, action);
		});

		Lua_helper.add_callback(lua, "setMobileControlsPosition", function(?x:Float, ?y:Float):Void
		{
			if (MusicBeatState.mobilec != null) {
				if (x != null) MusicBeatState.mobilec.x = x;
				if (y != null) MusicBeatState.mobilec.y = y;
			}
		});

		Lua_helper.add_callback(lua, "reloadMobileControls", function():Void
		{
			PlayState.instance.reloadControls();
		});

		Lua_helper.add_callback(lua, "addMobileControls", function(?cValue:Int, ?mode:String, ?action:String):Void
		{
			PlayState.instance.addControls(cValue, mode, action);
		});

		Lua_helper.add_callback(lua, "removeMobileControls", function():Void
		{
			PlayState.instance.removeControls();
		});
		#end

		#if mobile
		Lua_helper.add_callback(lua, "vibrate", function(duration:Null<Int>, ?period:Null<Int>)
		{
			if (period == null)
				period = 0;
			if (duration == null)
				return FunkinLua.luaTrace('vibrate: No duration specified.');
			return Haptic.vibrate(period, duration);
		});

		Lua_helper.add_callback(lua, "touchJustPressed", TouchFunctions.touchJustPressed);
		Lua_helper.add_callback(lua, "touchPressed", TouchFunctions.touchPressed);
		Lua_helper.add_callback(lua, "touchJustReleased", TouchFunctions.touchJustReleased);
		Lua_helper.add_callback(lua, "touchPressedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchPressedObject: $object does not exist.');
				return false;
			}
			return TouchFunctions.touchOverlapObject(obj) && TouchFunctions.touchPressed;
		});

		Lua_helper.add_callback(lua, "touchJustPressedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchJustPressedObject: $object does not exist.');
				return false;
			}
			return TouchFunctions.touchOverlapObject(obj) && TouchFunctions.touchJustPressed;
		});

		Lua_helper.add_callback(lua, "touchJustReleasedObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchJustPressedObject: $object does not exist.');
				return false;
			}
			return TouchFunctions.touchOverlapObject(obj) && TouchFunctions.touchJustReleased;
		});

		Lua_helper.add_callback(lua, "touchOverlapsObject", function(object:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchOverlapsObject: $object does not exist.');
				return false;
			}
			return TouchFunctions.touchOverlapObject(obj);
		});
		#end

		#end
	}
}

#if android
class AndroidFunctions
{
	public static function implement(funk:FunkinLua)
	{
		#if LUA_ALLOWED
		var lua:State = funk.lua;

		Lua_helper.add_callback(lua, "isDolbyAtmos", AndroidTools.isDolbyAtmos());
		Lua_helper.add_callback(lua, "isAndroidTV", AndroidTools.isAndroidTV());
		Lua_helper.add_callback(lua, "isTablet", AndroidTools.isTablet());
		Lua_helper.add_callback(lua, "isChromebook", AndroidTools.isChromebook());
		Lua_helper.add_callback(lua, "isDeXMode", AndroidTools.isDeXMode());
		Lua_helper.add_callback(lua, "backJustPressed", FlxG.android.justPressed.BACK);
		Lua_helper.add_callback(lua, "backPressed", FlxG.android.pressed.BACK);
		Lua_helper.add_callback(lua, "backJustReleased", FlxG.android.justReleased.BACK);
		Lua_helper.add_callback(lua, "menuJustPressed", FlxG.android.justPressed.MENU);
		Lua_helper.add_callback(lua, "menuPressed", FlxG.android.pressed.MENU);
		Lua_helper.add_callback(lua, "menuJustReleased", FlxG.android.justReleased.MENU);
		Lua_helper.add_callback(lua, "getCurrentOrientation", () -> PsychJNI.getCurrentOrientationAsString());
		Lua_helper.add_callback(lua, "setOrientation", function(hint:Null<String>):Void
		{
			switch (hint.toLowerCase())
			{
				case 'portrait':
					hint = 'Portrait';
				case 'portraitupsidedown' | 'upsidedownportrait' | 'upsidedown':
					hint = 'PortraitUpsideDown';
				case 'landscapeleft' | 'leftlandscape':
					hint = 'LandscapeLeft';
				case 'landscaperight' | 'rightlandscape' | 'landscape':
					hint = 'LandscapeRight';
				default:
					hint = null;
			}
			if (hint == null)
				return FunkinLua.luaTrace('setOrientation: No orientation specified.');
			PsychJNI.setOrientation(FlxG.stage.stageWidth, FlxG.stage.stageHeight, false, hint);
		});
		Lua_helper.add_callback(lua, "minimizeWindow", () -> AndroidTools.minimizeWindow());
		Lua_helper.add_callback(lua, "showToast", function(text:String, duration:Null<Int>, ?xOffset:Null<Int>, ?yOffset:Null<Int>)
		{
			if (text == null)
				return FunkinLua.luaTrace('showToast: No text specified.');
			else if (duration == null)
				return FunkinLua.luaTrace('showToast: No duration specified.');

			if (xOffset == null)
				xOffset = 0;
			if (yOffset == null)
				yOffset = 0;

			AndroidToast.makeText(text, duration, -1, xOffset, yOffset);
		});
		Lua_helper.add_callback(lua, "isScreenKeyboardShown", () -> PsychJNI.isScreenKeyboardShown());

		Lua_helper.add_callback(lua, "clipboardHasText", () -> PsychJNI.clipboardHasText());
		Lua_helper.add_callback(lua, "clipboardGetText", () -> PsychJNI.clipboardGetText());
		Lua_helper.add_callback(lua, "clipboardSetText", function(text:Null<String>):Void
		{
			if (text != null) return FunkinLua.luaTrace('clipboardSetText: No text specified.');
			PsychJNI.clipboardSetText(text);
		});

		Lua_helper.add_callback(lua, "manualBackButton", () -> PsychJNI.manualBackButton());

		Lua_helper.add_callback(lua, "setActivityTitle", function(text:Null<String>):Void
		{
			if (text != null) return FunkinLua.luaTrace('setActivityTitle: No text specified.');
			PsychJNI.setActivityTitle(text);
		});
		#end
	}
}
#end