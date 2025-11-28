package tools;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;
#end 

class EnumAbstractTools 
{
    /**
        Converts an enum abstract to StringMap of Dynamic.

        This should be only used for SScript's `setEnumAbstract` function.

        @param enumAbs The abstract itself.
    **/
    public static macro function enumAbstractToDynamic(enumAbs:Expr):Expr 
    {
        var type = Context.getType(enumAbs.toString());
        switch type.follow() 
        {
            case TAbstract(_.get() => ab, _) if (ab.meta.has(":enum")):
                var map:Array<Expr> = [];
                for (field in ab.impl.get().statics.get())
                {
                    if (field.meta.has(":enum") && field.meta.has(":impl"))
                    {
                        var fName = field.name;
                        var value = macro $enumAbs.$fName;
                        map.push(macro $v{fName} => $value);
                    }
                }

                return macro $a{map};
            default:
                throw new Error('${enumAbs.toString()} should be enum abstract', enumAbs.pos);
        }
    }    
}