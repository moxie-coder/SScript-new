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
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

using StringTools;

@:access(tools.ClassTools)
class Macro
{
	#if !macro
	public static final allClassesAvailable:Map<String, Class<Dynamic>> = tools.ClassTools.names.copy();
	#end

	public static var VERSION(default, null):SScriptVer = new SScriptVer(5, 1, 1);

	#if sys
	public static var isWindows(default, null):Bool =  ~/^win/i.match(Sys.systemName());
	public static var definePath(get, never):String;
	public static var settingsPath(get, never):String;
	#end

	static var credits:Array<String> = [
		"Special Thanks:",
		"- CrowPlexus\n",
	];

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
	public static function initiateMacro() 
	{
		final defines = Context.getDefines();

		var long:String = '-------------------------------------------------------------------';
		log('------------------------SScript ${VERSION} Macro------------------------');

		for (i in credits)
			log(i);

		log('Checking version...');
		
		#if (haxe >= "4.3.2")
		var v = VERSION.checkVer();

		if (v == null)
		{
			log('There was an error getting the latest version info, you may not have internet connection.');
			log('Continuing...');
		}
		else if (v)
			log('Done! You are using the latest SScript version!');
		else if (!v)
		{
			log('You\'re using an outdated version of SScript (${VERSION}). Please update it to ${SScriptVer.newerVer}.');
			#if sys 
			if (!FileSystem.exists(settingsPath))
			{
				log("Would you like to update SScript? This will abort the current compilation process.");
				Sys.print("(Y/N/D to never show this again): ");
				var r = Sys.stdin().readLine();
				if (["yes", "y"].contains(r.toLowerCase().trim()))
				{
					var p = new Process("haxelib remove SScript && haxelib install SScript");
					while (true) 
					{
						var o = p.stdout.readLine();
						if (o.trim() == "Done")
						{
							p.close();
							break;
						}
					}
					p = null;
					
					log("");
					log("Done.");
					log(long);
					Sys.exit(1);
				}
				else if (["no", "n"].contains(r.toLowerCase().trim()))
				{
					log("");
					log("Continuing...");
				}
				else if (r.toLowerCase().trim() == 'd')
				{
					log("");
					log("Updater will never be shown again. Continuing...");
					File.saveContent(settingsPath, "1");
				}
				else 
				{
					log("Invalid answer given, aborting.");
					log(long);
					Sys.exit(1);
				}
			}
			#end
		}
		#else
		log('You are using the ${defines.get("haxe")} version of Haxe, SScript works best with Haxe 4.3.2. Consider updating Haxe.');
		log('Continuing...');
		#end
		
		log(long);
		log("");

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
		#if (openfl < "9.2.0") Context.fatalError('Your openfl is outdated (${defines.get('openfl')}), please update openfl', (macro null).pos) #else Context.fatalError('You cannot use \'openflPos\' without targeting openfl', (macro null).pos) #end;

		if (defines.get("dce") != "std")
			Context.fatalError("SScript needs DCE to be std to work properly", (macro null).pos);

		Compiler.define('loop_unroll_max_cost', '25'); // Haxe will try to unroll big loops which may cause memory leaks, so max cost is downgraded to 25 from 250
		return macro {}
	}

	public static function log(log:String)
	{
		#if sys
		Sys.println(log);
		#else
		trace('\n' + log);
		#end
	}

	#if sys
	static function get_definePath():String 
	{
		var env:String = if (isWindows) Sys.getEnv('USERPROFILE') else Sys.getEnv('HOME');
		if (isWindows && !env.endsWith('\\'))
			env += '\\';
		else if (!isWindows && !env.endsWith('/'))
			env += '/';

		return env + 'defines.cocoa';
	}
	static function get_settingsPath():String 
	{
		var env:String = if (isWindows) Sys.getEnv('USERPROFILE') else Sys.getEnv('HOME');
		if (isWindows && !env.endsWith('\\'))
			env += '\\';
		else if (!isWindows && !env.endsWith('/'))
			env += '/';

		return env + 'settings.cocoa';
	}
	#end
}