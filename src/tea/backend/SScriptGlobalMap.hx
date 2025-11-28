package tea.backend;

import haxe.ds.StringMap;
import tea.SScript;

/**
    A different kind of map that handles global scripts. 

    Underlying type is Dynamic.
**/
@:access(tea.SScript)
abstract SScriptGlobalMap(Dynamic) 
{    
    public var self(get, never):Dynamic;
    function get_self() return this;

    public function new() 
    {
        this = {};
    }

    @:arrayAccess
    public function set(key:String, obj:Dynamic):Void
    {
        Reflect.setField(this, key, obj);
        for (i in SScript.global)
        {
            if (!i._destroyed)
                i.set(key, obj);
        }
    }

    @:arrayAccess
    public function get(key:String):Dynamic 
        return Reflect.field(this, key);

    public function exists(key:String):Bool 
        return Reflect.hasField(this, key);

    public inline function clear():Void 
        this = {};

    public function remove(key:String):Void 
        Reflect.deleteField(this, key);
}