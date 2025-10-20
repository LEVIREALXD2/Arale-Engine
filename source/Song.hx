package;

import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import Note;
import Section.SwagSection;

#if sys
import sys.io.File;
import sys.FileSystem;
#end


typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var offset:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
	var format:String;

	@:optional var disableVSliceControls:Bool; //for mechanics

	@:optional var gameOverChar:String;
	@:optional var gameOverSound:String;
	@:optional var gameOverLoop:String;
	@:optional var gameOverEnd:String;

	@:optional var disableNoteRGB:Bool;

	@:optional var arrowSkin:String;
	@:optional var splashSkin:String;
	var validScore:Bool;
}

typedef ExtraChartOptionsMain =
{
	options:Array<ExtraChartOptions>
}

typedef ExtraChartOptions =
{
	forcedChart:String, // forced chart system, works like txt ones but this one in json instead of txt.
	forcedCamera:String //0.6 or 0.7x camera system (maybe CNE Camera can be added when Stage system full finished)
}

class Song
{
	public static var currentChartLoadSystem:String = null;
	public var song:String;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var arrowSkin:String;
	public var splashSkin:String;
	public var gameOverChar:String;
	public var gameOverSound:String;
	public var gameOverLoop:String;
	public var gameOverEnd:String;
	public var disableNoteRGB:Bool = false;
	public var speed:Float = 1;
	public var stage:String;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';
	public var format:String = 'psych_v1';

	private static function onLoadJson(songJson:Dynamic)
	{
		if(songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			songJson.player3 = null;
		}

		if(songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}
	}

	public function new(?song, ?notes, ?bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static var chartPath:String;
	public static var loadedSongName:String;
	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String, ?isEditor:Bool):SwagSong
	{
		currentChartLoadSystem = null;
		PlayState.cameraMode = null;

		getExtraChartOptions(folder);

		var cneChartExists:Bool = false;
		var convertedChart:String = null;

		/* Seperate songName & Difficulty */
		#if CNE_CHART_ALLOWED
		var lastDashIndex = jsonInput.lastIndexOf('-');
		var songName = jsonInput.substring(0, lastDashIndex);
		var diffString = jsonInput.substring(lastDashIndex + 1);

		// Lol (Little fix ig)
		if(Paths.formatToSongPath(diffString) == Paths.formatToSongPath(Difficulty.defaultDifficulty))
			diffString == Difficulty.defaultDifficulty;

		//check songs folder for cne charts
		var isCneExists:Bool = Paths.fileExists('songs/${songName}/charts/${diffString}.json', TEXT, false);

		if (isCneExists && songName != null && diffString != null) {
			trace('CNE Chart Exists, Chart Conversion is Starting!');
			cneChartExists = true;
			convertedChart = Converters.chart_CneToPsych(songName, diffString);
		}
		else trace('CNE Chart Not Exists, Using PsychEngine Chart Instead!');
		#end

		if (ClientPrefs.data.chartEditor == '1.0x' && isEditor) currentChartLoadSystem = 'psych_v1';
		else if (isEditor) currentChartLoadSystem = 'psych_legacy';
		else getChartVersion(jsonInput, folder, 'psych_legacy', cneChartExists, convertedChart);
		trace(currentChartLoadSystem);

		if (currentChartLoadSystem == 'psych_v1')
		{
			trace('Current Chart System: 1.0');
			if(folder == null) folder = jsonInput;
			PlayState.SONG = getChart(jsonInput, folder, cneChartExists, convertedChart);
			loadedSongName = folder;
			chartPath = _lastPath.replace('/', '\\');
			if(jsonInput != 'events') StageData.loadDirectory(PlayState.SONG);
			return PlayState.SONG;
		}
		else
		{
			trace('Current Chart System: 0.4-0.7x');
			var rawJson = null;

			var formattedFolder:String = Paths.formatToSongPath(folder);
			var formattedSong:String = Paths.formatToSongPath(jsonInput);

			#if MODS_ALLOWED
			var moddyFile:String = Paths.modsJson('$formattedFolder/$formattedSong');
			if (cneChartExists)
				rawJson = convertedChart.trim();
			else if(FileSystem.exists(moddyFile))
				rawJson = File.getContent(moddyFile).trim();
			#end

			if(rawJson == null) {
				var path:String = Paths.json('$formattedFolder/$formattedSong');
				#if sys
				if(FileSystem.exists(path))
					rawJson = File.getContent(path);
				else
				#end
					rawJson = Assets.getText(path);
			}
			
			while (!rawJson.endsWith("}"))
			{
				rawJson = rawJson.substr(0, rawJson.length - 1);
				// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
			}

			var songJson:Dynamic = parseJSONshit(rawJson);
			loadedSongName = folder;
			if(jsonInput != 'events') StageData.loadDirectory(songJson);
			onLoadJson(songJson);
			if (ClientPrefs.data.chartEditor == '1.0x' && isEditor)
				PlayState.SONG = songJson; //1.0 option fix
			return songJson;
		}
	}

	public static function getExtraChartOptions(folder:String) {
		var loadedSongFolder = 'data/' + Paths.formatToSongPath(folder) + '/extraOptions.json';
		var extraChartOptions:ExtraChartOptionsMain;

		if (Paths.fileExists(loadedSongFolder, TEXT, false)) {
			var customChartOption = Paths.getPath(loadedSongFolder, TEXT, true);
			extraChartOptions = cast Json.parse(File.getContent(customChartOption));

			for (option in extraChartOptions.options) {
				if (option.forcedCamera != null) PlayState.cameraMode = option.forcedCamera;
			}
		}
	}

	// PsychEngine 1.0
	public static function convert(songJson:Dynamic) // Convert old charts to psych_v1 format
	{
		if(songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			if(Reflect.hasField(songJson, 'player3'))
				Reflect.deleteField(songJson, 'player3');
		}

		if(songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}

		var sectionsData:Array<SwagSection> = songJson.notes;
		if(sectionsData == null) return;
		for (section in sectionsData)
		{
			var beats:Null<Float> = cast section.sectionBeats;
			if (beats == null || Math.isNaN(beats))
			{
				section.sectionBeats = 4;
				if(Reflect.hasField(section, 'lengthInSteps')) Reflect.deleteField(section, 'lengthInSteps');
			}
			for (note in section.sectionNotes)
			{
				var gottaHitNote:Bool = (note[1] < 4) ? section.mustHitSection : !section.mustHitSection;
				note[1] = (note[1] % 4) + (gottaHitNote ? 0 : 4);
				if(note[3] != null && !Std.isOfType(note[3], String))
					note[3] = Note.defaultNoteTypes[note[3]]; //compatibility with Week 7 and 0.1-0.3 psych charts
			}
		}
	}

	static var _lastPath:String;
	public static function getChart(jsonInput:String, ?folder:String, ?cneExists:Bool, ?convertedChart:String):SwagSong
	{
		var rawData:String = loadJson(jsonInput, folder, cneExists, convertedChart);
		return rawData != null ? parseJSON(rawData, jsonInput) : null;
	}

	public static function getChartVersion(jsonInput:String, ?folder:String, ?convertTo:String = 'psych_v1', ?cneExists:Bool, ?convertedChart:String):Void
	{
		var rawData:String = loadJson(jsonInput, folder, cneExists, convertedChart);

		var songJson:SwagSong = cast Json.parse(rawData);
		if (songJson.song != null && convertTo == 'psych_legacy')
		{
			var subSong:SwagSong = Reflect.field(songJson, 'song');
			if (songJson.format.startsWith('psych_v1') || subSong.format.startsWith('psych_v1'))
				currentChartLoadSystem = 'psych_v1';
			else
			{
				currentChartLoadSystem = 'psych_legacy';
				songJson.validScore = true;
			}
		}
	}
	
	public static function loadJson(jsonInput:String, ?folder:String, ?cneExists:Bool, ?convertedChart:String)
	{
		if(folder == null) folder = jsonInput;
		var rawData:String = null;

		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);

		#if MODS_ALLOWED
		_lastPath = Paths.modsJson('$formattedFolder/$formattedSong');
		if (cneExists)
			rawData = convertedChart;
		else if(FileSystem.exists(_lastPath))
			rawData = File.getContent(_lastPath);
		#end

		//Base Songs
		if(rawData == null)
		{
			_lastPath = Paths.json('$formattedFolder/$formattedSong');
			#if sys
			if(FileSystem.exists(_lastPath))
				rawData = File.getContent(_lastPath);
			else
			#end
				rawData = Assets.getText(_lastPath);
		}
		return rawData;
	}

	public static function parseJSON(rawData:String, ?nameForError:String = null, ?convertTo:String = 'psych_v1'):SwagSong
	{
		var songJson:SwagSong = cast Json.parse(rawData);

		if(Reflect.hasField(songJson, 'song'))
		{
			var subSong:SwagSong = Reflect.field(songJson, 'song');
			if(subSong != null && Type.typeof(subSong) == TObject)
				songJson = subSong;
		}
		if(convertTo != null && convertTo.length > 0)
		{
			var fmt:String = songJson.format;
			if(fmt == null) fmt = songJson.format = 'unknown';
			switch(convertTo)
			{
				case 'psych_v1':
					if(!fmt.startsWith('psych_v1')) //Convert to Psych 1.0 format
					{
						trace('converting chart $nameForError with format $fmt to psych_v1 format...');
						songJson.format = 'psych_v1_convert';
						convert(songJson);
					}
			}
		}
		return songJson;
	}
}

/**
 * TO DO: V-Slice Chart Data here.
 */