#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download
cd ..
echo Makking the main haxelib and setuping folder in same time..
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib git linc_luajit https://github.com/PsychExtendedThings/linc_luajit --global
haxelib install tjson --global
haxelib git flixel https://github.com/PsychExtendedThings/flixel 5.6.1 --global
haxelib install flixel-addons 3.2.2 --global
haxelib install flixel-ui 2.4.0 --global
haxelib git SScript https://github.com/PsychExtendedThings/SScript --global
haxelib install hscript 2.4.0 --global
haxelib git hxCodec https://github.com/PsychExtendedThings/hxCodec-0.6.3 --global
haxelib git hxcpp https://github.com/PsychExtendedThings/hxcpp --global
haxelib git lime https://github.com/th2l-devs/lime --global
haxelib git openfl https://github.com/th2l-devs/openfl --global
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 42f1b5d193b4345ca7d6933380ab3105985b44a3 --global
echo Setting dependencies...
haxelib dev linc_luajit /root/haxelib/linc_luajit/git
haxelib dev tjson /root/haxelib/tjson/1,4,0
haxelib dev flixel /root/haxelib/flixel/git
haxelib dev flixel-addons /root/haxelib/flixel-addons/3,2,2
haxelib dev flixel-ui /root/haxelib/flixel-ui/2,4,0
haxelib dev SScript /root/haxelib/SScript/git
haxelib dev hscript /root/haxelib/hscript/2,4,0
haxelib dev hxCodec /root/haxelib/hxCodec/git
haxelib dev hxcpp /root/haxelib/hxcpp/git
haxelib dev lime /root/haxelib/lime/git
haxelib dev openfl /root/haxelib/openfl/git
echo Finished!