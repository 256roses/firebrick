package firebrick;

import haxe.macro.Compiler;

class MacroExt {
    public static macro function setAssetPath(folder:String) {
        #if wasm
        Compiler.define('ASSET_PATH', '${sys.FileSystem.absolutePath(folder)}@$folder');
        #end
        return null;
    }

    public static macro function setOutput(folder:String) {
        #if wasm
        Compiler.setOutput(folder+'/wasm');
        #else
        Compiler.setOutput(folder+'/desktop');
        #end
        return null;
    }

    public static macro function setWebDefines() {
        #if wasm
        Compiler.define("emscripten");
        Compiler.define("HXCPP_LINK_EMSCRIPTEN_EXT", ".html");
        Compiler.define("disable-unicode-strings");
        #end
        return null;
    }
}