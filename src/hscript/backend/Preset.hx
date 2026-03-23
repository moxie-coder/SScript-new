package hscript.backend;

import haxe.ds.ArraySort;
import hscriptBase.Tools;

enum PresetMode
{
    NONE;
    MINI;
    REGULAR;
    #if !DISABLED_MACRO_SUPERLATIVE
    FULL;
    #end
}

@:access(hscript.backend.PresetClasses)
@:access(hscript.SScript)
class Preset
{
    public var presetMode:PresetMode;

    var script:SScript;
    var _destroyed:Bool = false;
    public function new(script:SScript)
    {
        if (script == null || script._destroyed)
            return;

        this.script = script;
        presetMode = SScript.defaultPreset;
    }

    function preset()
    {
        if (_destroyed || script == null || script._destroyed)
            return;

        var hArray = switch presetMode {
            case MINI: PresetClasses.miniHaxe;
            case REGULAR: PresetClasses.regularHaxe;
            #if !DISABLED_MACRO_SUPERLATIVE
            case FULL: PresetClasses.fullHaxe;
            #end
            case _: [];
        }

        for (i in hArray.copy()) {
            script.setClass(i);
        }
    }

    function destroy()
    {
        if (_destroyed)
            return;

        script = null;
        presetMode = null;

        _destroyed = true;
    }
}

class PresetClasses 
{
    static var miniHaxe:Array<Class<Dynamic>> = [
        Date, DateTools, EReg, Math, Reflect, Std, StringTools, Type,
        #if sys Sys, sys.io.File, sys.FileSystem #end
    ];

    static var regularHaxe:Array<Class<Dynamic>> = {
        var array = miniHaxe.copy();
        var array2:Array<Class<Dynamic>> = [
            EReg, List, StringBuf, Xml,
            haxe.Http, haxe.Json, haxe.Log, haxe.Serializer, haxe.Unserializer, haxe.Timer,
            #if sys haxe.SysTools, sys.io.Process, sys.io.FileInput, sys.io.FileOutput #end
        ];

        for (i in array2)
            array.push(i);

        array;
    }

    #if !DISABLED_MACRO_SUPERLATIVE
    static var fullHaxe:Array<Class<Dynamic>> = byMap();

    static function byMap():Array<Class<Dynamic>> {
        var classes:Array<Class<Dynamic>> = [];
        @:privateAccess for (i => k in Tools.allClassesAvailable) {
            classes.push(k);
        }

        ArraySort.sort(classes, function(a:Class<Dynamic>, b:Class<Dynamic>):Int {
            var a = Type.getClassName(a).toUpperCase();
            var b = Type.getClassName(b).toUpperCase();

            if (a < b)
                return -1;
            else if (a > b)
                return 1;
            else
                return 0;
        });
        return classes;
    }
    #end
}