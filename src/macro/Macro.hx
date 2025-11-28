package macro;

import haxe.macro.Compiler;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Printer;
import haxe.macro.TypeTools;
import haxe.macro.TypedExprTools;

import tea.backend.SScriptVer;
import tea.backend.crypto.Base32;

#if sys
import sys.io.File;
#end

using StringTools;

class Macro
{
	public static var VERSION(default, null):SScriptVer = new SScriptVer(4, 1, 0);

	#if sys
	public static var isWindows(default, null):Bool =  ~/^win/i.match(Sys.systemName());
	public static var definePath(get, never):String;
	#end

	public static var macroClasses:Array<Class<Dynamic>> = [
		Compiler,
		Context,
		MacroStringTools,
		Printer,
		ComplexTypeTools,
		TypedExprTools,
		ExprTools,
		TypeTools,
	];

	macro
	public static function checkOpenFL() 
	{
		VERSION.checkVer();
		
		final defines = Context.getDefines();

		#if sys
		var pushedDefines:Array<String> = [];
		var string:String = "";
		for (i => k in defines)
		{
			if (!pushedDefines.contains(i))
			{
				string += '$i|$k';
				string += '\n';
				pushedDefines.push(i);
			}
		}
		var splitString:Array<String> = string.split('\n');
		if (splitString.length > 1 && string.endsWith('\n'))
		{
			splitString.pop();
			string = splitString.join('\n');
		}
		
		var path:String = definePath;
		File.saveContent(path, new Base32().encodeString(string));
		#end

		if (defines.exists('openflPos') && (
		#if openfl
		#if (openfl < "9.2.0")
		true
		#else
		false
		#end 
		#else
		true
		#end))
		#if (openfl < "9.2.0") throw 'Your openfl is outdated (${defines.get('openfl')}), please update openfl' #else throw 'You cannot use \'openflPos\' without targeting openfl' #end;
		return macro {}
	}

	#if sys
	static function get_definePath():String 
	{
		var env:String = if (isWindows) Sys.getEnv('USERPROFILE') else Sys.getEnv('HOME');
		if (isWindows && !env.endsWith('\\'))
			env += '\\';
		else if (!isWindows && !env.endsWith('/'))
			env += '/';

		return env + 'defines.thk';
	}
	#end
}
