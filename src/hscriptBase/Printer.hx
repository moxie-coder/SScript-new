/*
 * Copyright (C)2008-2017 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
package hscriptBase;
import hscriptBase.Expr;

@:access(hscriptBase.Tools)
@:access(hscriptBase.TeaClass)
@:access(hscriptBase.TeaEAbstract)
@:keep
class Printer {
	public static function errorToString( e : Expr.Error ) {
		var message = switch( e.e ) {
			case ENullObjectReference: "Null Object Reference";
			case EInvalidChar(c): "Invalid character: '"+(StringTools.isEof(c) ? "EOF" : String.fromCharCode(c))+"' ("+c+")";
			case EUnexpected(s): "Unexpected " + s;
			case EUnterminatedString: "Unterminated string";
			case EUnterminatedComment: "Unterminated comment";
			case EInvalidPreprocessor(str): "Invalid preprocessor (" + str + ")";
			case ETypeNotFound(s): "Type not found : " + s;
			case EUnknownVariable(v): "Unknown variable: "+v;
			case EInvalidIterator(v): "Invalid iterator: "+v;
			case EInvalidOp(op): "Invalid operator: "+op;
			case EInvalidAccess(f): "Invalid access to field " + f;
			case EInvalidAssign: "Invalid assign";
			case ECustom(msg): msg;
			case EInvalidFinal(v): "This expression cannot be accessed for writing";
		};
		var str = e.origin + ":" + e.line + ": " + message;
		return str;
	}
}
