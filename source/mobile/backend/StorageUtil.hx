package mobile.backend;

import lime.system.System as LimeSystem;
import haxe.io.Path;
import haxe.Exception;
#if android
import android.Tools;
import android.callback.CallBack;
#end

/**
 * A storage class for mobile.
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class StorageUtil
{
	#if sys
	// root directory, used for handling the saved storage type and path
	public static final rootDir:String = LimeSystem.applicationStorageDirectory;

	public static function getStorageDirectory():String
		return #if android haxe.io.Path.addTrailingSlash(AndroidContext.getExternalFilesDir()) #elseif ios lime.system.System.documentsDirectory #else Sys.getCwd() #end;

	public static function getCustomStorageDirectories(?getPaths:Bool, ?doNotSeperate:Bool):Array<String>
	{
		var packageName:String = 'com.kraloyuncu.psychextendedrebase';
		#if termux packageName += 'debug'; #end

		var curTextFile:String = '/storage/emulated/0/Android/data/${packageName}/files/assets/mobile/storageModes.txt';
		var ArrayReturn:Array<String> = [];
		for (mode in CoolUtil.coolTextFile(curTextFile))
		{
			//trace('Mode: $mode');
			if(mode.trim().length < 1) continue;

			//turning the readle to original one (also, much easier to rewrite the code) -KralOyuncu2010x
			if (mode.contains('Name: ')) mode = mode.replace('Name: ', '');
			if (mode.contains(' Folder: ')) mode = mode.replace(' Folder: ', '|');
			//trace(mode);

			var dat = mode.split("|");
			if (doNotSeperate)
				ArrayReturn.push(mode); //get both as array
			else if (getPaths)
				ArrayReturn.push(dat[1]); //get paths as array
			else
				ArrayReturn.push(dat[0]); //get storage name as array
		}
		return ArrayReturn;
	}

	#if android
	// always force path due to haxe
	public static function getExternalStorageDirectory():String
	{
		var daPath:String = '';
		#if android
		if (!FileSystem.exists(rootDir + 'storagetype.txt'))
			File.saveContent(rootDir + 'storagetype.txt', ClientPrefs.data.storageType);

		var curStorageType:String = File.getContent(rootDir + 'storagetype.txt');

		/* More Txt Friendly Code (I can add custom paths later) */
		switch(curStorageType) {
			case 'EXTERNAL':
				daPath = '/storage/emulated/0/.PsychEngine';
			case 'EXTERNAL_EX':
				daPath = '/storage/emulated/0/.Psych Extended';
			case 'EXTERNAL_OBB':
				#if termux daPath = '/storage/emulated/0/Android/obb/com.kraloyuncu.psychextendedrebasedebug';
				#else daPath = '/storage/emulated/0/Android/obb/com.kraloyuncu.psychextendedrebase'; #end
			case 'EXTERNAL_MEDIA':
				daPath = '/storage/emulated/0/Android/media/' + lime.app.Application.current.meta.get('packageName');
			case 'EXTERNAL_DATA': //do not use `default:` for that, otherwise game tries to get data instead of selected option
				#if termux daPath = '/storage/emulated/0/Android/data/com.kraloyuncu.psychextendedrebasedebug/files';
				#else daPath = '/storage/emulated/0/Android/data/com.kraloyuncu.psychextendedrebase/files'; #end
		}

		for (line in getCustomStorageDirectories(false, true))
		{
			if (line.startsWith(curStorageType) && (line != '' || line != null)) {
				//trace('our line: ${line}');
				var dat = line.split("|");
				//trace('our dat: ${dat}');
				daPath = dat[1];
				//trace('our daPath: ${daPath}');
				//continue;
			}
		}

		/*
		for (mode in getCustomStorageDirectories(false)) {
			if (curStorageType == mode) {
				for (path in getCustomStorageDirectories(true)) {
					var textFile:Array<String> = getCustomStorageDirectories(false, true);
					if (curStorageType == mode) {
						daPath = path;
						continue;
					}
				}
				continue;
			}
		}
		*/

		daPath = Path.addTrailingSlash(daPath);
		#elseif ios
		return LimeSystem.documentsDirectory;
		#else
		return Sys.getCwd();
		#end

		return daPath;
	}

	public static function requestPermissions():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO', 'READ_MEDIA_VISUAL_USER_SELECTED']);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');

		if ((AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU
			&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES'))
			|| (AndroidVersion.SDK_INT < AndroidVersionCode.TIRAMISU
				&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')))
			CoolUtil.showPopUp('If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress OK to see what happens', 'Notice!');

		try
		{
			if (!FileSystem.exists(StorageUtil.getStorageDirectory()))
				FileSystem.createDirectory(StorageUtil.getStorageDirectory());
		}
		catch (e:Dynamic)
		{
			CoolUtil.showPopUp('Please create directory to\n${StorageUtil.getStorageDirectory()}\nPress OK to close the game', "Error!");
			lime.system.System.exit(1);
		}

		try
		{
			if (!FileSystem.exists(StorageUtil.getExternalStorageDirectory() + 'mods'))
				FileSystem.createDirectory(StorageUtil.getExternalStorageDirectory() + 'mods');
			if (!FileSystem.exists(StorageUtil.getExternalStorageDirectory() + 'modpack'))
				FileSystem.createDirectory(StorageUtil.getExternalStorageDirectory() + 'modpack');
		}
		catch (e:Dynamic)
		{
			CoolUtil.showPopUp('Please create directory to\n${StorageUtil.getExternalStorageDirectory()}\nPress OK to close the game', "Error!");
			lime.system.System.exit(1);
		}
	}


	public static function createDirectories(directory:String):Void
	{
		try
		{
			if (FileSystem.exists(directory) && FileSystem.isDirectory(directory))
				return;
		}
		catch (e:haxe.Exception)
		{
			trace('Something went wrong while looking at directory. (${e.message})');
		}

		var total:String = '';
		if (directory.substr(0, 1) == '/')
			total = '/';

		var parts:Array<String> = directory.split('/');
		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part != '')
			{
				if (total != '' && total != '/')
					total += '/';

				total += part;

				try
				{
					if (!FileSystem.exists(total))
						FileSystem.createDirectory(total);
				}
				catch (e:Exception)
					trace('Error while creating directory. (${e.message}');
			}
		}
	}

	public static function checkExternalPaths(?splitStorage = false):Array<String>
	{
		var process = new Process('grep -o "/storage/....-...." /proc/mounts | paste -sd \',\'');
		var paths:String = process.stdout.readAll().toString();
		if (splitStorage)
			paths = paths.replace('/storage/', '');
		return paths.split(',');
	}

	public static function getExternalDirectory(externalDir:String):String
	{
		var daPath:String = '';
		for (path in checkExternalPaths())
			if (path.contains(externalDir))
				daPath = path;

		daPath = haxe.io.Path.addTrailingSlash(daPath.endsWith("\n") ? daPath.substr(0, daPath.length - 1) : daPath);
		return daPath;
	}
	#end

	public static function saveContent(fileName:String, fileData:String, ?alert:Bool = true):Void
	{
		final folder:String = #if android StorageUtil.getExternalStorageDirectory() + #else Sys.getCwd() + #end 'saves/';
		try
		{
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);

			File.saveContent('$folder/$fileName', fileData);
			if (alert)
				CoolUtil.showPopUp('${fileName} has been saved.', "Success!");
		}
		catch (e:Dynamic)
			if (alert)
				CoolUtil.showPopUp('${fileName} couldn\'t be saved.\n${e.message}', "Error!");
			else
				trace('$fileName couldn\'t be saved. (${e.message})');
	}
	#end
}