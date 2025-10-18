package novaengine;

import sys.thread.Thread;
import sys.thread.FixedThreadPool;
import sys.thread.Mutex;
import novaengine.thread.ThreadEvent;
import openfl.utils.Assets;

import Lambda;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;

import openfl.system.System;
import flixel.math.FlxMath;
import Song;
import haxe.ds.Map;
import Lambda; // 添加Lambda库支持
import options.ShapeEX;
import novaengine.FreeplayObjects;

import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Matrix;

import flixel.graphics.FlxGraphic;

import openfl.display.Shape;
import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;

class SmallNote // basically Note.hx but small as fuck
{
	public var strumTime:Float;
	public var noteData:Int;

	public function new(strum, data)
	{
		strumTime = strum;
		noteData = data;
	}
}

class DiffCalc
{
	public static var scale = 3 * 1.8;

	public static var lastDiffHandOne:Array<Float> = [];
	public static var lastDiffHandTwo:Array<Float> = [];

	public static function CalculateDiff(song:SwagSong, ?accuracy:Float = .93)
	{
		try
		{
			// cleaned notes
			var cleanedNotes:Array<SmallNote> = [];

			if (song == null)
				return 0.0;

			if (song.notes == null)
				return 0.0;

			if (song.notes.length == 0)
				return 0.0;

			// find all of the notes
			for (i in song.notes) // sections
			{
				for (ii in i.sectionNotes) // notes
				{
					var gottaHitNote:Bool = i.mustHitSection;

					if (ii[1] >= 3 && gottaHitNote)
						cleanedNotes.push(new SmallNote(ii[0] / song.speed, Math.floor(Math.abs(ii[1]))));
					if (ii[1] <= 4 && !gottaHitNote)
						cleanedNotes.push(new SmallNote(ii[0] / song.speed, Math.floor(Math.abs(ii[1]))));
				}
			}

			trace('calcuilafjwaf ' + cleanedNotes.length);

			var handOne:Array<SmallNote> = [];
			var handTwo:Array<SmallNote> = [];

			cleanedNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (cleanedNotes.length == 0)
				return 0;

			var firstNoteTime = cleanedNotes[0].strumTime;

			// normalize the notes

			for (i in cleanedNotes)
			{
				i.strumTime = (i.strumTime - firstNoteTime) * 2;
			}

			for (i in cleanedNotes)
			{
				switch (i.noteData)
				{
					case 0:
						handOne.push(i);
					case 1:
						handOne.push(i);
					case 2:
						handTwo.push(i);
					case 3:
						handTwo.push(i);
				}
			}

			// collect all of the notes in each col

			var leftHandCol:Array<Float> = []; // d 0
			var leftMHandCol:Array<Float> = []; // f 1
			var rightMHandCol:Array<Float> = []; // j 2
			var rightHandCol:Array<Float> = []; // k 3

			for (i in 0...handOne.length - 1)
			{
				if (handOne[i].noteData == 0)
					leftHandCol.push(handOne[i].strumTime);
				else
					leftMHandCol.push(handOne[i].strumTime);
			}
			for (i in 0...handTwo.length - 1)
			{
				if (handTwo[i].noteData == 3)
					rightHandCol.push(handTwo[i].strumTime);
				else
					rightMHandCol.push(handTwo[i].strumTime);
			}

			// length in segments of the song
			var length = ((cleanedNotes[cleanedNotes.length - 1].strumTime / 1000) / 0.5);

			// hackey way of creating a array with a length
			var segmentsOne = new haxe.ds.Vector(Math.floor(length));

			var segmentsTwo = new haxe.ds.Vector(Math.floor(length));

			// set em all to array's (so no null's)

			for (i in 0...segmentsOne.length)
				segmentsOne[i] = new Array<SmallNote>();
			for (i in 0...segmentsTwo.length)
				segmentsTwo[i] = new Array<SmallNote>();

			// algo loop
			for (i in handOne)
			{
				var index = Std.int((((i.strumTime * 2) / 1000)));
				if (index + 1 > length)
					continue;
				segmentsOne[index].push(i);
			}

			for (i in handTwo)
			{
				var index = Std.int((((i.strumTime * 2) / 1000)));
				if (index + 1 > length)
					continue;
				segmentsTwo[index].push(i);
			}

			// Remove 0 intervals
			/*for(i in 0...segmentsOne.length)
				{
					if (segmentsOne[i].length == 0)
						segmentsOne[i] = null;
				}

				for(i in 0...segmentsTwo.length)
				{
					if (segmentsTwo[i].length == 0)
						segmentsTwo[i] = null;
			}*/

			// get nps for both hands

			var hand_npsOne:Array<Float> = new Array<Float>();
			var hand_npsTwo:Array<Float> = new Array<Float>();

			for (i in segmentsOne)
			{
				if (i == null)
					continue;
				hand_npsOne.push(i.length * scale * 1.6);
			}
			for (i in segmentsTwo)
			{
				if (i == null)
					continue;
				hand_npsTwo.push(i.length * scale * 1.6);
			}

			// get the diff vector's for all of the hands

			var hand_diffOne:Array<Float> = new Array<Float>();
			var hand_diffTwo:Array<Float> = new Array<Float>();

			for (i in 0...segmentsOne.length)
			{
				var ve = segmentsOne[i];
				if (ve == null)
					continue;
				var fuckYouOne:Array<SmallNote> = [];
				var fuckYouTwo:Array<SmallNote> = [];
				for (note in ve)
				{
					switch (note.noteData)
					{
						case 0: // fingie 1
							fuckYouOne.push(note);
						case 1: // fingie 2
							fuckYouTwo.push(note);
					}
				}

				var one = fingieCalc(fuckYouOne, leftHandCol);
				var two = fingieCalc(fuckYouTwo, leftMHandCol);

				var bigFuck = ((((one > two ? one : two) * 8) + (hand_npsOne[i] / scale) * 5) / 13) * scale;

				// trace(bigFuck + " - hand one [" + i + "]");

				hand_diffOne.push(bigFuck);
			}

			for (i in 0...segmentsTwo.length)
			{
				var ve = segmentsTwo[i];
				if (ve == null)
					continue;
				var fuckYouOne:Array<SmallNote> = [];
				var fuckYouTwo:Array<SmallNote> = [];
				for (note in ve)
				{
					switch (note.noteData)
					{
						case 2: // fingie 1
							fuckYouOne.push(note);
						case 3: // fingie 2
							fuckYouTwo.push(note);
					}
				}

				var one = fingieCalc(fuckYouOne, rightMHandCol);
				var two = fingieCalc(fuckYouTwo, rightHandCol);

				var bigFuck = ((((one > two ? one : two) * 8) + (hand_npsTwo[i] / scale) * 5) / 13) * scale;

				hand_diffTwo.push(bigFuck);

				// trace(bigFuck + " - hand two [" + i + "]");
			}

			for (i in 0...4)
			{
				smoothBrain(hand_npsOne, 0);
				smoothBrain(hand_npsTwo, 0);

				smoothBrainTwo(hand_diffOne);
				smoothBrainTwo(hand_diffTwo);
			}

			// trace(hand_diffOne);
			// trace(hand_diffTwo);

			// trace(hand_npsOne);
			// trace(hand_npsTwo);

			var point_npsOne:Array<Float> = new Array<Float>();
			var point_npsTwo:Array<Float> = new Array<Float>();

			for (i in segmentsOne)
			{
				if (i == null)
					continue;
				point_npsOne.push(i.length);
			}
			for (i in segmentsTwo)
			{
				if (i == null)
					continue;
				point_npsTwo.push(i.length);
			}

			var maxPoints:Float = 0;

			for (i in point_npsOne)
				maxPoints += i;
			for (i in point_npsTwo)
				maxPoints += i;

			if (accuracy > .965)
				accuracy = .965;

			lastDiffHandOne = hand_diffOne;
			lastDiffHandTwo = hand_diffTwo;

			return truncateFloat(chisel(accuracy, hand_diffOne, hand_diffTwo, point_npsOne, point_npsTwo, maxPoints), 2);
		}
		catch (e:Dynamic)
		{
			return 0;
		}
	}

	public static function chisel(scoreGoal:Float, diffOne:Array<Float>, diffTwo:Array<Float>, pointsOne:Array<Float>, pointsTwo:Array<Float>, maxPoints:Float)
	{
		var lowerBound:Float = 0;
		var upperBound:Float = 100;

		while (upperBound - lowerBound > 0.01)
		{
			var average:Float = (upperBound + lowerBound) / 2;
			var amtOfPoints:Float = calcuate(average, diffOne, pointsOne) + calcuate(average, diffTwo, pointsTwo);
			if (amtOfPoints / maxPoints < scoreGoal)
				lowerBound = average;
			else
				upperBound = average;
		}
		return upperBound;
	}

	public static function calcuate(midPoint:Float, diff:Array<Float>, points:Array<Float>)
	{
		var output:Float = 0;

		for (i in 0...diff.length)
		{
			var res = diff[i];
			if (midPoint > res)
				output += points[i];
			else
				output += points[i] * Math.pow(midPoint / res, 1.2);
		}
		return output;
	}

	public static function findStupid(strumTime:Float, array:Array<Float>)
	{
		for (i in 0...array.length)
			if (array[i] == strumTime)
				return i;
		return -1;
	}

	public static function fingieCalc(floats:Array<SmallNote>, columArray:Array<Float>):Float
	{
		var sum:Float = 0;
		if (floats.length == 0)
			return 0;
		var startIndex = findStupid(floats[0].strumTime, columArray);
		if (startIndex == -1)
			return 0;
		for (i in floats)
		{
			sum += columArray[startIndex + 1] - columArray[startIndex];
			startIndex++;
		}

		if (sum == 0)
			return 0;

		return (1375 * (floats.length)) / sum;
	}

	public static function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	// based arrayer
	// basicily smmoth the shit
	public static function smoothBrain(npsVector:Array<Float>, weirdchamp:Float)
	{
		var floatOne = weirdchamp;
		var floatTwo = weirdchamp;

		for (i in 0...npsVector.length)
		{
			var result = npsVector[i];

			var chunker = floatOne;
			floatOne = floatTwo;
			floatTwo = result;

			npsVector[i] = (chunker + floatOne + floatTwo) / 3;
		}
	}

	// Smooth the shit but less
	public static function smoothBrainTwo(diffVector:Array<Float>)
	{
		var floatZero:Float = 0;

		for (i in 0...diffVector.length)
		{
			var result = diffVector[i];

			var fuck = floatZero;
			floatZero = result;
			diffVector[i] = (fuck + floatZero) / 2;
		}
	}
}

typedef RaSection =
{
	var mustHitSection:Bool;
	var sectionNotes:Array<Array<Float>>;
}

typedef RaNote =
{
	var time:Float;
	var lane:Int;
	var duration:Float;
	var isSlide:Bool;
}

class StarRating
{
	private var playerNotes:Array<RaNote> = [];
	private var songSpeed:Float = 1.0;

	// 优化后的权重分配
	private static final WEIGHTS:Map<String, Float> = [
		"density" => 0.35,
		"strain" => 0.35,
		"pattern" => 0.25,
		"sliderComplexity" => 0.12,
		"handBalance" => 0.03
	];

	public function new()
	{
	}

	public function calculateFullDifficulty(songData:SwagSong):{rating:String, stars:Float}
	{
		processNotes(songData.notes);
		if (playerNotes.length < 5)
			return {rating: "Easy", stars: 0.0};

		playerNotes.sort(sortNotes);
		this.songSpeed = songData.speed;

		var metrics = calculateAllMetrics();
		var rawDiff = combineMetrics(metrics);

		return getDifficultyRating(rawDiff);
	}

	// === 核心逻辑 ===
	private function processNotes(sections:Array<RaSection>)
	{
		playerNotes = [];
		for (section in sections)
		{
			var isPlayer = section.mustHitSection;
			for (noteData in section.sectionNotes)
			{
				var lane = convertLane(Std.int(noteData[1]), isPlayer);
				if (lane == -1)
					continue;

				playerNotes.push({
					time: noteData[0],
					lane: lane,
					duration: noteData[2],
					isSlide: noteData[2] > 0
				});
			}
		}
	}

	private inline function convertLane(original:Int, isPlayer:Bool):Int
	{
		return if (isPlayer)
		{
			(original >= 0 && original <= 3) ? original : -1;
		}
		else
		{
			(original >= 4 && original <= 7) ? (original - 4) : -1;
		}
	}

	// === 指标计算 ===
	private function calculateAllMetrics():Map<String, Float>
	{
		return [
			"density" => calculateDensity(),
			"strain" => calculateStrain(),
			"pattern" => calculatePatternComplexity(),
			"sliderComplexity" => calculateSliderComplexity(),
			"handBalance" => calculateHandBalance()
		];
	}

	private function calculateDensity():Float
	{
		if (playerNotes.length == 0)
			return 0.0;

		var totalTime = playerNotes[playerNotes.length - 1].time - playerNotes[0].time;
		var baseDensity = totalTime > 0 ? playerNotes.length / (totalTime / 1000) : 0.0;
		var maxComboBonus = calculateComboDensityBonus();
		var speedFactor = Math.pow(songSpeed, 2.5) + Math.log(songSpeed + 1);

		return normalizeValue(baseDensity * speedFactor * (1 + maxComboBonus), 10, 100);
	}

	private function calculateStrain():Float
	{
		var strainPeaks = [];
		var currentStrain = 0.0;
		var prevTime = -9999.0;
		var decayRate = 0.82;

		for (note in playerNotes)
		{
			var timeDiff = note.time - prevTime;
			var decay = Math.pow(decayRate, timeDiff / 200);
			currentStrain = currentStrain * decay + 1.0;
			strainPeaks.push(currentStrain);
			prevTime = note.time;
		}

		strainPeaks.sort(descendingSort);
		var threshold = calculatePeakThreshold(strainPeaks, 0.1);
		var topStrains = strainPeaks.filter(function(p) return p >= threshold);

		return normalizeValue(average(topStrains), 3.0, 35.0);
	}

	private function calculatePatternComplexity():Float
	{
		var patternMap = new Map<String, Int>();
		for (i in 1...playerNotes.length)
		{
			var delta = Math.abs(playerNotes[i].lane - playerNotes[i - 1].lane);
			var key = Std.string(delta);
			patternMap[key] = patternMap.exists(key) ? patternMap[key] + 1 : 1;
		}

		var entropy = 0.0;
		var total = playerNotes.length - 1;
		for (count in patternMap)
		{
			var p = count / total;
			entropy -= p * Math.log(p);
		}
		return normalizeValue(entropy, 0.8, 5.0);
	}

	private function calculateSliderComplexity():Float
	{
		var totalDuration = 0.0;
		var sliderCount = 0;
		for (note in playerNotes)
		{
			if (note.isSlide)
			{
				totalDuration += note.duration;
				sliderCount++;
			}
		}
		var complexity = sliderCount * Math.log(totalDuration / 500 + 1);
		return normalizeValue(complexity, 0, 180);
	}

	private function calculateHandBalance():Float
	{
		// 修复count方法问题
		var leftCount = Lambda.count(playerNotes, function(n) return n.lane < 2);
		var imbalance = Math.abs(leftCount - (playerNotes.length - leftCount)) / playerNotes.length;
		return 1 - normalizeValue(imbalance, 0, 0.4);
	}

	// === 工具方法 ===
	private function normalizeValue(value:Float, min:Float, max:Float):Float
	{
		var clamped = (value - min) / (max - min);
		clamped = Math.max(0, Math.min(1, clamped));
		return clamped < 0.8 ? clamped * 0.8 : 0.8 + (clamped - 0.8) * 2.0;
	}

	private function calculateComboDensityBonus():Float
	{
		var maxBonus = 0.0;
		var currentCombo = 0;
		for (note in playerNotes)
		{
			currentCombo = note.isSlide ? 0 : currentCombo + 1;
			if (currentCombo > 20)
			{
				maxBonus = Math.max(maxBonus, (currentCombo - 20) * 0.03);
			}
		}
		return Math.min(maxBonus, 0.6);
	}

	private function calculatePeakThreshold(arr:Array<Float>, percentile:Float):Float
	{
		if (arr.length == 0)
			return 0.0;

		// 修复索引类型问题
		var index:Int = Std.int(Math.floor(arr.length * percentile));
		return arr[Std.int(Math.min(index, arr.length - 1))];
	}

	private function average(arr:Array<Float>):Float
	{
		return arr.length == 0 ? 0.0 : Lambda.fold(arr, function(a, b) return a + b, 0.0) / arr.length; // 使用Lambda.fold
	}

	private function sortNotes(a:RaNote, b:RaNote):Int
	{
		return a.time < b.time ? -1 : 1;
	}

	private static function descendingSort(a:Float, b:Float):Int
	{
		return a < b ? 1 : a > b ? -1 : 0;
	}

	private function combineMetrics(metrics:Map<String, Float>):Float
	{
		var total = 0.0;
		for (key in WEIGHTS.keys())
		{
			total += metrics.get(key) * WEIGHTS.get(key);
		}
		return total;
	}

	private function getDifficultyRating(raw:Float):{rating:String, stars:Float}
	{
		trace('raw: ' + raw);
		var stars = if (raw < 5.0)
		{
			Math.pow(raw, 1.2) * 2.5; // 现在逻辑有问题，raw无法突破1，但是意外的运行还不错，就暂时不改了 -狐月影留
		}
		else
		{
			2.5 * Math.pow(5.0, 1.2) + Math.pow(raw - 5.0, 1.6) * 1.8;
		};
		trace('stars: ' + stars);
		stars = stars * 4;
		// stars = Math.min(stars, 10.0);
		stars = Math.round(stars * 100) / 100;

		return if (stars < 2.0)
		{
			{rating: "Easy", stars: stars};
		}
		else if (stars < 4.0)
		{
			{rating: "Normal", stars: stars};
		}
		else if (stars < 6.0)
		{
			{rating: "Hard", stars: stars};
		}
		else if (stars < 8.0)
		{
			{rating: "Insane", stars: stars};
		}
		else if (stars < 9.5)
		{
			{rating: "Expert", stars: stars};
		}
		else
		{
			{rating: "God", stars: stars};
		}
	}

	// === 调试工具 ===
	public function debugMetrics(songData:SwagSong):Void
	{
		calculateFullDifficulty(songData);
		trace("=== Difficulty Metrics ===");
		trace('Density: ${calculateDensity()}');
		trace('Strain: ${calculateStrain()}');
		trace('Pattern: ${calculatePatternComplexity()}');
		trace('Sliders: ${calculateSliderComplexity()}');
		trace('Balance: ${calculateHandBalance()}');
		trace("==========================");
	}
}

class ScrollManager {

	var target:Array<SongRect>;
	public function new(tar:Array<SongRect>) { 
		this.target = tar;
	}

	var scrollFix:Int = 0;
	public function check(state:String) {
		scrollFix = Math.ceil(FreeplayStateNOVANew.instance.songPosiStart / SongRect.fixHeight) + 2;
		if (state == "up" || state == "down") {
			moveElementToPosition();
		}
	}

	var count:Int = 0;
	var _count:Int = -9999;
	public function moveElementToPosition() {
		if (FreeplayStateNOVANew.instance.songsMove.target > FreeplayStateNOVANew.instance.songPosiStart + SongRect.fixHeight * FreeplayStateNOVANew.instance.inter * target.length) {
			FreeplayStateNOVANew.songPosiData = FreeplayStateNOVANew.instance.songsMove.target = FreeplayStateNOVANew.instance.songsMove.target - SongRect.fixHeight * FreeplayStateNOVANew.instance.inter * target.length;   
				
			if (FreeplayStateNOVANew.instance.songsMove.lerpData > FreeplayStateNOVANew.instance.songPosiStart + SongRect.fixHeight * FreeplayStateNOVANew.instance.inter * target.length) {
				FreeplayStateNOVANew.instance.songsMove.lerpData -= SongRect.fixHeight * FreeplayStateNOVANew.instance.inter * target.length;			
			}	 
		}
		else if (FreeplayStateNOVANew.instance.songsMove.target < FreeplayStateNOVANew.instance.songPosiStart - SongRect.fixHeight * FreeplayStateNOVANew.instance.inter * target.length) {
			FreeplayStateNOVANew.songPosiData = FreeplayStateNOVANew.instance.songsMove.target = FreeplayStateNOVANew.instance.songsMove.target + SongRect.fixHeight * FreeplayStateNOVANew.instance.inter * target.length;
			
			if (FreeplayStateNOVANew.instance.songsMove.lerpData < FreeplayStateNOVANew.instance.songPosiStart - SongRect.fixHeight * FreeplayStateNOVANew.instance.inter * target.length) {
				FreeplayStateNOVANew.instance.songsMove.lerpData += SongRect.fixHeight * FreeplayStateNOVANew.instance.inter * target.length;
			}
		}			  

		count = FreeplayStateNOVANew.curSelected = Math.floor((FreeplayStateNOVANew.instance.songsMove.target - FreeplayStateNOVANew.instance.songPosiStart) / (SongRect.fixHeight * FreeplayStateNOVANew.instance.inter));

		if (count == _count) return;
		_count = count;

		var flipData:Int = target.length-1 - count - scrollFix;

		if (target.length < 0) return;

		for (i in 0...target.length) {
			if (i <= flipData) {
				target[i].currect = i;
			} else {
				target[i].currect = i - target.length;
			}
		}

		for (i in 0...target.length) {
			if (flipData < 0) {
				for (i in 0...Std.int(Math.abs(flipData))) {
					target[target.length-1 - i].currect = target[0].currect-1 - i;
				}
			}
			if (flipData - target.length-1 - scrollFix >= 0) {
				for (i in 0...Std.int(flipData - target.length-1 - scrollFix)) {
					target[i].currect = target[target.length-1].currect+1 + i;
				}
			}
		}
	}
}

typedef DataPrepare = {
	modPath:String,
	bgPath:String,
	iconPath:String,
	color:Array<Int>
}

class PreThreadLoad {
	public var loadFinish:Bool = false;

	public var maxCount:Int = 0;
	public var count:Int = 0;

	///////////////////////////////////////////////////////

	var loadRect:Array<DataPrepare> = [];
	var loadIcon:Array<String> = [];

	var rectPool:FixedThreadPool = null;
	var iconPool:FixedThreadPool = null;
	
	var threadCount = 0;
	var countMutex:Mutex;

	///////////////////////////////////////////////////////

	var devTrace:Bool = true; //开发测试用的

	public function new() {
		countMutex = new Mutex();
	}

	var rectPre:Map<String, DataPrepare> = [];
	var iconPre:Array<String> = [];
	public function start(data:Array<DataPrepare>) {
		ThreadEvent.create(function() {
			for (mem in data) {
				var rd:DataPrepare = mem;
				rd.bgPath = bgPathCheck(rd.modPath, 'data/${rd.bgPath}/bg');
				if (!rectPre.exists(rd.bgPath + ' ' + rd.color))
					rectPre.set(rd.bgPath + ' ' + rd.color, rd);

				var id:String = iconCheck(rd.modPath, mem.iconPath);
				if (!iconPre.contains(id))
					iconPre.push(id);
			}
			maxCount = Std.int(Lambda.count(rectPre) + iconPre.length);
			threadCount = CoolUtil.getCPUThreadsCount() - 1;
			if (devTrace) trace('load count: ' + maxCount);

			for (key => value in rectPre) {
				loadRect.push(value);
			}
			loadIcon = iconPre;
		}, load);
	}
	
	static var bitmapMutex:Mutex = new Mutex();
	static public function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true, ?threadLoad:Bool = false)
	{
		if (bitmap == null)
		{
			#if MODS_ALLOWED
			if (FileSystem.exists(file))
				bitmap = BitmapData.fromFile(file);
			else
			#end
			{
				if (Assets.exists(file, IMAGE))
					bitmap = Assets.getBitmapData(file);
			}

			if (bitmap == null)
				return null;
		}

		var thread:Bool = false;
		if (threadLoad != null) thread = threadLoad;

		if (thread) bitmapMutex.acquire();
		if (thread) bitmapMutex.release();

		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
		if (thread) bitmapMutex.acquire();
		if (thread) bitmapMutex.release();
		
		return newGraphic;
	}
	
	static public function modCachePath(modPath:String, key:String)
	{
		if (modPath != '') modPath = modPath + '/';
		var fileToCheck:String = Paths.mods(modPath + key);
		if (FileSystem.exists(fileToCheck))
			return fileToCheck;

		for (mod in Mods.getGlobalMods())
		{
			var fileToCheck:String = Paths.mods(mod + '/' + key);
			if (FileSystem.exists(fileToCheck))
				return fileToCheck;
		}

		return #if mobile Sys.getCwd() + #end 'assets/shared/' + key;
	}

	static public function bgPathCheck(mod:String, path:String):String {
		if (!FileSystem.exists(modCachePath(mod, path + '.png')))
			path = 'images/menuDesat.png';
		return modCachePath(mod, path);
	}

	static public function iconCheck(mod:String, path:String):String {
		var name:String = 'images/icons/' + path;
		if (!FileSystem.exists(modCachePath(mod, name + '.png')))
			name = 'images/icons/icon-' + path;
		if (!FileSystem.exists(modCachePath(mod, name + '.png')))
			name = 'images/icons/icon-face';
		return modCachePath(mod, name + '.png');
	}

	function load() {
		Sys.sleep(0.005); //先释放下线程

		lineShape = null;
		var light = new Rect(0, 0, 560, SongRect.fixHeight, SongRect.fixHeight / 2, SongRect.fixHeight / 2, FlxColor.WHITE, 1, 1, EngineSet.mainColor);
		drawLine(light.pixels); //lineShape此时赋予数据

		var rectThread:Int = Math.ceil(threadCount * 0.75);
		var iconThread:Int = Std.int(Math.max(1, threadCount - rectThread));
		if (devTrace) trace('thread count: ' + threadCount + ' rect: ' + rectThread + ' icon: ' + iconThread);

		rectPool = new FixedThreadPool(rectThread);
		iconPool = new FixedThreadPool(iconThread);

		for (i in 0...loadRect.length) {
			var memData:DataPrepare = loadRect[i];
			rectPool.run(() -> {
				var file:String = memData.bgPath;
				try
				{	
					var newGraphic:FlxGraphic = null;
					var bitmap:BitmapData = null;
					
					if (FileSystem.exists(file)) {
						bitmap = BitmapData.fromFile(file);
					} else {
						trace('RECT: no such image ${file} exists');
						return;
					}

					if (bitmap != null) {
						newGraphic = cacheBitmap(file, bitmap, false, true);
					} else {
						trace('RECT: oh no the bitmap is null NOOOO ${file}');		
					}
																 
					if (newGraphic == null) {
	
						trace('RECT: load ' + file + ' fail');
						return;
					}
					
					var matrix:Matrix = new Matrix();
					var scale:Float = light.width / newGraphic.width;
					if (light.height / newGraphic.height > scale)
						scale = light.height / newGraphic.height;
					matrix.scale(scale, scale);
					matrix.translate(-(newGraphic.width * scale - light.width) / 2, -(newGraphic.height * scale - light.height) / 2);
					
					var resizedBitmapData:BitmapData = new BitmapData(Std.int(light.width), Std.int(light.height), true, 0x00000000);
					resizedBitmapData.draw(newGraphic.bitmap, matrix);
					
					if (file.indexOf('menuDesat') != -1)
					{
						var colorTransform:ColorTransform = new ColorTransform();
						var color:FlxColor = FlxColor.fromRGB(memData.color[0], memData.color[1], memData.color[2]);
						colorTransform.redMultiplier = color.redFloat;
						colorTransform.greenMultiplier = color.greenFloat;
						colorTransform.blueMultiplier = color.blueFloat;
						
						resizedBitmapData.colorTransform(new Rectangle(0, 0, resizedBitmapData.width, resizedBitmapData.height), colorTransform);
					}
					
					drawLine(resizedBitmapData);
					
					resizedBitmapData.copyChannel(light.pixels, new Rectangle(0, 0, light.width, light.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
	
					newGraphic = FlxGraphic.fromBitmapData(resizedBitmapData);
					
					countMutex.acquire();
						count++;
						if (count >= maxCount) {
							loadFinish = true;
							rectPool.shutdown();
							rectPool = null;
							iconPool.shutdown();
							iconPool = null;
						}
						
					countMutex.release();
					if (devTrace) trace('RECT: load ' + file + ' color r:' + memData.color[0] + ' g:' + memData.color[1] + ' b:' + memData.color[2] + ' finish');
				}
				catch (e:Dynamic)
				{
					Sys.sleep(0.001);
					trace('RECT: ERROR! fail on preloading image ' + file);
				}
			});
		}

		for (i in 0...loadIcon.length) {
			iconPool.run(() -> {
				var file:String = loadIcon[i];
				try
				{
					var newGraphic:FlxGraphic = null;
					var bitmap:BitmapData = null;
					
					if (FileSystem.exists(file)) {
						bitmap = BitmapData.fromFile(file);
					} else {
						trace('ICON: no such image ${file} exists');
						return;
					}

					if (bitmap != null) {
						newGraphic = cacheBitmap(file, bitmap, false, true);
					} else {
						trace('oh no the bitmap is null NOOOO ${file}');
					}

					if (newGraphic == null) {

						trace('ICON: load ' + file + ' fail');
						return;
					}
					
					countMutex.acquire();
						count++;
						
						if (count >= maxCount) {
							loadFinish = true;
							rectPool.shutdown();
							rectPool = null;
							iconPool.shutdown();
							iconPool = null;
						}
						
					countMutex.release();
					if (devTrace) trace('ICON: load ' + file + ' finish');
				}
				catch (e:Dynamic)
				{
					Sys.sleep(0.001);
					trace('ICON: ERROR! fail on preloading image ' + file);
				}
			});
		}
	}

	static var lineShape:Shape = null;
	function drawLine(bitmap:BitmapData)
	{
		if (lineShape == null) {
			lineShape = new Shape();
			var lineSize:Int = 2;
			var round:Int = Std.int(bitmap.height / 2);
			lineShape.graphics.beginFill(EngineSet.mainColor);
			lineShape.graphics.lineStyle(1, EngineSet.mainColor, 1);
			lineShape.graphics.drawRoundRect(0, 0, bitmap.width, bitmap.height, round, round);
			lineShape.graphics.lineStyle(0, 0, 0);
			lineShape.graphics.drawRoundRect(lineSize, lineSize, bitmap.width - lineSize * 2, bitmap.height - lineSize * 2, round - lineSize * 2, round - lineSize * 2);
			lineShape.graphics.endFill();
		}

		bitmap.draw(lineShape);
	}
}