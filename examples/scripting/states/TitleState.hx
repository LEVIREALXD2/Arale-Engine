public static var introVideoFinished:Bool; //used static because static variables only can reset when game restart
public var introVideo:String = "intro"; //Intro Video

/* Disable/Enable Intro */
function onCutscenesIn(event) {
	if(FileSystem.exists(Paths.video(introVideo))) {
		if (introVideoFinished) event.cancelled = false;
		else event.cancelled = true;
	}
}

/* Make the intro video */
function postCreate() {
	if (FileSystem.exists(Paths.video(introVideo)) && !introVideoFinished) makeIntro(introVideo);
}

/* Video Functions */
var skipVideo:FlxText;
function makeIntro(videoPath:String)
{
	skipVideo = new FlxText(0, FlxG.height - 26, 0, "Press " + #if android "Back on your phone " #else "Enter " #end + "to skip", 18);
	skipVideo.setFormat(Assets.getFont("assets/fonts/montserrat.ttf").fontName, 18);
	skipVideo.alpha = 0;
	skipVideo.screenCenter(FlxAxes.X);
	skipVideo.scrollFactor.set();
	skipVideo.antialiasing = ClientPrefs.data.antialiasing;

	var video:MP4Sprite = new MP4Sprite();
	video.canvasWidth = 1280;
	video.canvasHeight = 720;

	video.finishCallback = function()
	{
		videoEnd();
		return;
	}

	video.playVideo(Paths.video(videoPath));
	add(video);
	showText();
}

function videoEnd()
{
	introVideoFinished = true;
	skipVideo.visible = false;
	startCutscenesOut();
}

function showText()
{
	add(skipVideo);
	skipVideo.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	FlxTween.tween(skipVideo, {alpha: 1}, 1, {ease: FlxEase.quadIn});
	FlxTween.tween(skipVideo, {alpha: 0}, 1, {ease: FlxEase.quadIn, startDelay: 4});
}