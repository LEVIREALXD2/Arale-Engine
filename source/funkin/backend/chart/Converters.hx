/*
	PUT YOUR CONVERTER STUFFS HERE!!!
	PUT YOUR CONVERTER STUFFS HERE!!!
	PUT YOUR CONVERTER STUFFS HERE!!!
	PUT YOUR CONVERTER STUFFS HERE!!!
	PUT YOUR CONVERTER STUFFS HERE!!!
	PUT YOUR CONVERTER STUFFS HERE!!!
	PUT YOUR CONVERTER STUFFS HERE!!!
	PUT YOUR CONVERTER STUFFS HERE!!!
*/
package funkin.backend.chart;

import haxe.Json;

class Converters {
	#if CNE_CHART_ALLOWED
	/* very messy code but works
		most of the code tooked from https://github.com/SrtHero278/Stuffs
			I just love how the repo handles the camera movements
				I think we can directly read CNE Charts too but It would be useless
					because we don't have a editor for it */
	public static function chart_CneToPsych(song:String, diff:String):Dynamic {
		var json = Chart.parse(song, diff);
		if (json.stage == null || json.stage.trim() == "") json.stage = Flags.DEFAULT_STAGE;

		//psychJson fixes (HScript to Source Code Fixes)
		var babyBitch:Array<Dynamic> = []; //Kubz scouts

		//psychJson
		var psychJson = {
			song: json.meta.name,
			notes: [],
			events: babyBitch,
			bpm: json.meta.bpm,
			needsVoices: json.meta.needsVoices,
			speed: json.scrollSpeed,
			player1: "bf",
			player2: "pico",
			gfVersion: "gf",
			stage: json.stage //get the song stage
		};

		var curSpeed:Dynamic = json.scrollSpeed;
		var mustHit:Dynamic = false;
		var queueBPMChange:Dynamic = false;
		var curBPM:Dynamic = json.meta.bpm;
		var songTime:Dynamic = 0;
		var measureTimes:Array<Int> = [0];
		var altEvents:Dynamic = [for (i in 0...json.strumLines.length) [{time: 0, anim: false, idle: false}]];

		function addSections(tilTime:Dynamic, onPassedTime:Dynamic) {
			if (songTime >= tilTime) {
				onPassedTime();
				return;
			}

			var crochet:Dynamic = 60.0 / curBPM * 1000.0;
			var beats:Dynamic = (tilTime - measureTimes[measureTimes.length - 1]) / crochet;
			var snapMethod:Dynamic = Math.floor;
			beats = snapMethod(beats / (4 / 4)) * (4 / 4);

			for (i in 0...Math.ceil(beats / json.meta.beatsPerMeasure)) {
				psychJson.notes.push({
					sectionNotes: [],
					sectionBeats: (i == 0 && beats % json.meta.beatsPerMeasure > 0) ? beats % json.meta.beatsPerMeasure : json.meta.beatsPerMeasure,
					mustHitSection: mustHit,
					gfSection: false,
					bpm: curBPM,
					changeBPM: queueBPMChange,
					altAnim: false
				});
				queueBPMChange = false;
				songTime += psychJson.notes[psychJson.notes.length - 1].sectionBeats * crochet;
				measureTimes.push(songTime);
			}
			onPassedTime();
		}

		json.events.sort(function(ev1, ev2)
			return Math.floor(ev1.time - ev2.time)
		);

		for (event in json.events) {
			switch (event.name) {
				case "Camera Movement":
					addSections(event.time, function() {
						var charPosName = json.strumLines[event.params[0]].position ?? switch(json.strumLines[event.params[0]].type) {
							case 0: "dad";
							case 1: "boyfriend";
							case 2: "girlfriend";
						};
			
						mustHit = charPosName == "boyfriend";
					});
				case "BPM Change":
					addSections(event.time, function() {
						curBPM = event.params[0];
						queueBPMChange = true;
					});
				case "Add Camera Zoom":
					var isCamGame = (event.params[1] == "camGame") ? 1 : 0;
					var isCamHud = (event.params[1] == "camHUD") ? 1 : 0;
					var psychEvent:Dynamic = ["Add Camera Zoom", event.params[0] * isCamGame, event.params[0] * isCamHud];
					//trace('isCamGame is: ${isCamGame} and isCamHud is: ${isCamHud}');

					if (psychJson.events.length <= 0 || Math.round(psychJson.events[psychJson.events.length - 1][0]) != Math.round(event.time))
						psychJson.events.push([event.time, [psychEvent]]);
					else
						psychJson.events[psychJson.events.length - 1][1].push(psychEvent);
				case "Play Animation":
					var psychEvent:Dynamic = ["Play Animation", event.params[1], json.strumLines[event.params[0]].type];

					if (psychJson.events.length <= 0 || Math.round(psychJson.events[psychJson.events.length - 1][0]) != Math.round(event.time))
						psychJson.events.push([event.time, [psychEvent]]);
					else
						psychJson.events[psychJson.events.length - 1][1].push(psychEvent);
				case "Alt Animation Toggle":
					if (event.time == 0) {
						altEvents[event.params[2]][0].anim = event.params[0];
						altEvents[event.params[2]][1].idle = event.params[1];
						if (event.params[1]) {
							var psychEvent:Dynamic = ["Alt Idle Animation", Std.string(json.strumLines[event.params[0]].type), "-alt"];

							if (psychJson.events.length <= 0 || Math.round(psychJson.events[psychJson.events.length - 1][0]) != Math.round(event.time))
								psychJson.events.push([event.time, [psychEvent]]);
							else
								psychJson.events[psychJson.events.length - 1][1].push(psychEvent);
						}
						continue;
					}

					altEvents[event.params[2]].push({
						time: event.time,
						anim: event.params[0],
						idle: event.params[1]
					});

					trace('Gimme the actual value: ' + (altEvents[2].length - 1));
					if (altEvents[event.params[2]][Std.int(altEvents[2].length - 1)].idle != event.params[1]) {
						var psychEvent:Dynamic = ["Alt Idle Animation", Std.string(json.strumLines[event.params[0]].type), (event.params[1]) ? "-alt" : ""];

						if (psychJson.events.length <= 0 || Math.round(psychJson.events[psychJson.events.length - 1][0]) != Math.round(event.time))
							psychJson.events.push([event.time, [psychEvent]]);
						else
							psychJson.events[psychJson.events.length - 1][1].push(psychEvent);
					}
				default:
					var val1 = [for (i in 0...Math.ceil(event.params.length * 0.5))
						Std.string(event.params[i])
					].join(", ");
					
					var val2 = [for (i in Math.ceil(event.params.length * 0.5)...event.params.length)
						Std.string(event.params[i])
					].join(", ");
			
					if (psychJson.events.length <= 0 || Math.round(psychJson.events[psychJson.events.length - 1][0]) != Math.round(event.time))
						psychJson.events.push([event.time, [[event.name, val1, val2]]]);
					else
						psychJson.events[psychJson.events.length - 1][1].push([event.name, val1, val2]);
			}
		}
		psychJson.notes.push({
			sectionNotes: [],
			sectionBeats: json.meta.beatsPerMeasure,
			mustHitSection: mustHit,
			gfSection: false,
			bpm: curBPM,
			changeBPM: queueBPMChange,
			altAnim: false
		});

		var charDone = [false, false, false];
		for (s in 0...json.strumLines.length) {
			var strum = json.strumLines[s];
			if (charDone[strum.type]) return null;

			var altIndex:Int = 0;
			var measureIndex:Int = 0;
			curBPM = json.meta.bpm;
			charDone[strum.type] = true;

			strum.notes.sort(function(note1, note2)
				return Math.floor(note1.time - note2.time)
			);

			var numberThing:Int = 2;
			switch (strum.type) {
				case 0:
					psychJson.player2 = strum.characters[0];

					for (note in strum.notes) {
						while (songTime <= note.time) {
							songTime += 60.0 / curBPM * 1000.0 * json.meta.beatsPerMeasure;
							measureTimes.push(songTime);
							psychJson.notes.push({
								sectionNotes: [],
								sectionBeats: json.meta.beatsPerMeasure,
								mustHitSection: mustHit,
								gfSection: false,
								bpm: curBPM,
								changeBPM: false,
								altAnim: false
							});
						}
						while (measureTimes.length > measureIndex && measureTimes[measureIndex] <= note.time + 1)
							measureIndex++;
						while (altEvents[s].length > altIndex && altEvents[s][altIndex].time <= note.time + 1)
							altIndex++;

						var intFix = psychJson.notes[measureIndex - 1].mustHitSection ? 1 : 0;
						var psychNote:Dynamic = [note.time, note.id + 4 * intFix, note.sLen];
						if (note.type > 0)
							psychNote.push(json.noteTypes[note.type]);
						if (altEvents[s][altIndex - 1].anim)
							psychNote[3] = "Alt Animation";
						psychJson.notes[measureIndex - 1].sectionNotes.push(psychNote);
					}
				case 1:
					psychJson.player1 = strum.characters[0];

					for (note in strum.notes) {
						while (songTime <= note.time) {
							songTime += 60.0 / curBPM * 1000.0 * json.meta.beatsPerMeasure;
							measureTimes.push(songTime);
							psychJson.notes.push({
								sectionNotes: [],
								sectionBeats: json.meta.beatsPerMeasure,
								mustHitSection: mustHit,
								gfSection: false,
								bpm: curBPM,
								changeBPM: false,
								altAnim: false
							});
						}
						while (measureTimes.length > measureIndex && measureTimes[measureIndex] <= note.time)
							measureIndex++;
						while (altEvents[s].length > altIndex && altEvents[s][altIndex].time <= note.time)
							altIndex++;

						var intFix = !psychJson.notes[measureIndex - 1].mustHitSection ? 1 : 0;
						var psychNote:Dynamic = [note.time, note.id + 4 * intFix, note.sLen];
						if (note.type > 0)
							psychNote.push(json.noteTypes[note.type]);
						if (altEvents[s][altIndex - 1].anim)
							psychNote[3] = "Alt Animation";
						psychJson.notes[measureIndex - 1].sectionNotes.push(psychNote);
					}
				case 2:
					psychJson.gfVersion = strum.characters[0];

					for (note in strum.notes) {
						while (songTime <= note.time) {
							songTime += 60.0 / curBPM * 1000.0 * json.meta.beatsPerMeasure;
							measureTimes.push(songTime);
							psychJson.notes.push({
								sectionNotes: [],
								sectionBeats: json.meta.beatsPerMeasure,
								mustHitSection: mustHit,
								gfSection: false,
								bpm: curBPM,
								changeBPM: false,
								altAnim: false
							});
						}
						while (measureTimes.length > measureIndex && measureTimes[measureIndex] <= note.time)
							measureIndex++;
						while (altEvents[s].length > altIndex && altEvents[s][altIndex].time <= note.time)
							altIndex++;

						var intFix = psychJson.notes[measureIndex - 1].mustHitSection ? 1 : 0;
						var psychNote:Dynamic = [note.time, note.id + 4 * intFix, note.sLen];
						if (note.type == 0)
							psychNote.push("GF Sing");
						if (note.type > 0)
							psychNote.push("GF Sing: " + json.noteTypes[note.type]); //seperate gf and dad notes

						if (altEvents[s][altIndex - 1].anim)
							psychNote[3] = "Alt Animation";
						psychJson.notes[measureIndex - 1].sectionNotes.push(psychNote);
					}
				default: //for charts using more than 3 character
					numberThing++;

					for (note in strum.notes) {
						while (songTime <= note.time) {
							songTime += 60.0 / curBPM * 1000.0 * json.meta.beatsPerMeasure;
							measureTimes.push(songTime);
							psychJson.notes.push({
								sectionNotes: [],
								sectionBeats: json.meta.beatsPerMeasure,
								mustHitSection: mustHit,
								gfSection: false,
								bpm: curBPM,
								changeBPM: false,
								altAnim: false
							});
						}
						while (measureTimes.length > measureIndex && measureTimes[measureIndex] <= note.time)
							measureIndex++;
						while (altEvents[s].length > altIndex && altEvents[s][altIndex].time <= note.time)
							altIndex++;

						var psychNote:Dynamic = [note.time, note.id + 4 * psychJson.notes[measureIndex - 1].mustHitSection, note.sLen];
						if (note.type == 0)
							psychNote.push("Player ${numberThing} Sing");
						if (note.type > 0)
							psychNote.push("Player ${numberThing} Sing: " + json.noteTypes[note.type]); //seperate gf and dad notes

						if (altEvents[s][altIndex - 1].anim)
							psychNote[3] = "Player ${numberThing} Anim: " + "Alt Animation";
						psychJson.notes[measureIndex - 1].sectionNotes.push(psychNote);
					}
			}
		}
		var tracJson:String = Json.stringify({song: psychJson}, null, "\t");
		return tracJson;
	}
	#end
}