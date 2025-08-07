#if !macro
import Paths;
import FunkinLua;

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

#if DISCORD_ALLOWED
import Discord.DiscordClient;
#end

//import them for now
import funkin.backend.scripting.*;
import funkin.backend.scripting.events.*;
import backend.mouse.*;
import backend.data.*;
import backend.ui.*;
import objects.screen.*;
import objects.state.general.*;
import shapeEx.*;
import codenamecrew.hscript.macros.*;
import funkin.backend.FunkinText;
import funkin.backend.FunkinSprite;
import funkin.backend.shaders.FunkinShader;
import funkin.backend.shaders.CustomShader;

//Returns hxCodec requests to hxvlc
//import vlc.MP4Handler;

import backend.BaseStage;
import Song.SwagSong;
import Section.SwagSection;
import tea.SScript;
import editors.StageEditorState;

// FlxAnimate
#if flxanimate
import flxanimate.*;
import flxanimate.PsychFlxAnimate as FlxAnimate;
#end

import options.base.*; //Import base ones instead of NovaFlare's
#if MODS_ALLOWED
import backend.Mods;
#end

#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
import objects.AchievementPopup;
#end

// Mobile Things
#if TOUCH_CONTROLS
import mobile.flixel.*;
import mobile.states.*;
import mobile.objects.*;
import mobile.options.*;
import mobile.backend.*;
import mobile.psychlua.*;
import mobile.substates.*;
import mobile.objects.Hitbox;
import mobile.objects.MobilePad;
import mobile.backend.MobileData;
#else
import mobile.backend.StorageUtil;
import mobile.backend.PsychJNI;
import mobile.options.*;
import mobile.backend.MobileScaleMode;
#end

// Android
#if android
import extension.androidtools.Tools as AndroidTools;
import extension.androidtools.Settings as AndroidSettings;
import extension.androidtools.widget.Toast as AndroidToast;
import extension.androidtools.content.Context as AndroidContext;
import extension.androidtools.Permissions as AndroidPermissions;
import extension.androidtools.os.Build.VERSION as AndroidVersion;
import extension.androidtools.os.Environment as AndroidEnvironment;
//import extension.androidtools.os.BatteryManager as AndroidBatteryManager;
import extension.androidtools.os.Build.VERSION_CODES as AndroidVersionCode;
#end

// Lua
#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
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
#if !NEW_PSYCH063
import flixel.system.FlxSound;
#else
import flixel.sound.FlxSound;
#end
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
//import hxcodec.flixel.FlxVideo;
import psychlua.LuaUtils;
import haxe.ds.StringMap;
#end

using StringTools;