import options.NovaFlareOptionsObjects.OptionCata;
import options.NovaFlareOptionsObjects.NaviSprite;
import backend.data.UIScale;
import options.group.GraphicsGroup;
import options.group.UIGroup;
import options.group.SkinGroup;
import options.group.GameplayGroup;
import options.group.MobileGroup;

function onNaviCreate(event) {
	event.cancelled = true; //Disable Navi Creation because otherwise we got a error
	//Set your custom option (If you're a mod developer you can remove normal options)
	naviArray = [
		'Graphics',
		'Visual & UI',
		'Note Skins',
		'Gameplay',
		'Controls',
		'Free',
	];
	for (i in 0...naviArray.length) //Create Navi Manually because we disabled Auto Creation for fixing the error
	{
		var naviSprite = new NaviSprite(UIScale.adjust(FlxG.width * 0.005), UIScale.adjust(FlxG.height * 0.005) + i * UIScale.adjust(FlxG.height * 0.1), UIScale.adjust(FlxG.width * 0.19), UIScale.adjust(FlxG.height * 0.09), naviArray[i], i, false);
		naviSprite.antialiasing = ClientPrefs.data.antialiasing;
		add(naviSprite);
		naviSpriteGroup.push(naviSprite);

		addCustomCata(naviArray[i]); //we use different function because original one cannot be modified
	}
}

//Basically copy of original addCata() function
function addCustomCata(type) {
	var obj:OptionCata = null;

	var outputX:Float = naviBG.width + UIScale.adjust(FlxG.width * (0.8 / 40)); //已被初始化
	var outputWidth:Float = UIScale.adjust(FlxG.width * (0.8 - (0.8 / 40 * 2))); //已被初始化
	var outputY:Float = 100; //等待被初始化
	var outputHeight:Float = 200; //等待被初始化

	switch (type)
	{
		case 'Graphics':
			obj = new GraphicsGroup(outputX, outputY, outputWidth, outputHeight);
		case 'Visual & UI':
			obj = new UIGroup(outputX, outputY, outputWidth, outputHeight);
		case 'Note Skins':
			obj = new SkinGroup(outputX, outputY, outputWidth, outputHeight);
		case 'Gameplay':
			obj = new GameplayGroup(outputX, outputY, outputWidth, outputHeight);
		case 'Controls':
			obj = new MobileGroup(outputX, outputY, outputWidth, outputHeight);
		case 'Free':
			//we are using ModGroup for creation custom groups, `FreeGroup` means `scripting/options/FreeGroup.hx`
			//you can add multiple custom group with changing it
			obj = new ModGroup(outputX, outputY, outputWidth, outputHeight, 'FreeGroup');
		default:
			//nothing lol
	}
	cataGroup.push(obj);
	add(obj);
}

//Disable second Navi Creation
function CataCreation(event) {
	event.cancelled = true;
}