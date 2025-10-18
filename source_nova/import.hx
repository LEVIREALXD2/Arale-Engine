#if !macro
import Paths;
import FunkinLua;

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import objects.state.general.*;
import backend.mouse.*;
import objects.screen.*;
import backend.data.*;
import backend.ui.*;
import shapeEx.*;

// FlxAnimate
#if flxanimate
import flxanimate.*;
//import flxanimate.PsychFlxAnimate as FlxAnimate;
#end

import options.base.*;
#if MODS_ALLOWED
import backend.Mods;
#end

#if DISCORD_ALLOWED
import Discord.DiscordClient;
#end

#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
import objects.AchievementPopup;
#end

//Flixel
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.sound.FlxSound;
import flixel.util.FlxDestroyUtil;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.effects.FlxSkewedSprite;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.util.FlxDestroyUtil;
import hxcodec.flixel.FlxVideo;
import psychlua.LuaUtils;
import haxe.ds.StringMap;
#end

using StringTools;