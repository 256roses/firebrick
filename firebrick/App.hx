package firebrick;

import firebrick.two.Editor;
import emscripten.Emscripten;
import Raylib;
import haxe.Log;
import cpp.Callable;

class App {
    public static var title:String;
    public static var windowWidth:Int;
    public static var windowHeight:Int;
    public static var fullscreen(get, null):Bool;

    public static var displayWidth:Int;
    public static var displayHeight:Int;
    public static var displayTarget:RenderTexture;
    public static var displayRatio:Float;
    static var srcRectangle:Rectangle;
    static var dstRectangle:Rectangle;

    public static var framerate:Int;
    public static var fixedUpdateRate:Int;
    static var timeCounter:Float;
    static var timeStep:Float;

    public static var editor:Editor;
    public static var logs:Array<String> = [];

    public static var bgColor:Color;

    public function new(cfg:{title:String, display:{w:Int, h:Int}, desktop:{w:Int, h:Int}, web:{w:Int, h:Int}}) {
        title = cfg.title;

        #if wasm
        windowWidth = cfg.web.w;
        windowHeight = cfg.web.h;
        #else
        windowWidth = cfg.desktop.w;
        windowHeight = cfg.desktop.h;
        #end

        displayWidth = cfg.display.w;
        displayHeight = cfg.display.h;

        framerate = 60;
        fixedUpdateRate = 60;

        timeStep = 1 / fixedUpdateRate;

        // setup logging
        Log.trace = function(v, ?infos) {
            var msg = '[${DateTools.format(Date.now(), "%H:%M:%S")} ${infos.fileName} ${infos.lineNumber}] $v';
            Sys.println(msg);
            logs.push(msg);
        }

        bgColor = Raylib.Colors.DARKGRAY;
    }

    public function run(m:Module) {
        Raylib.setTraceLogLevel(7);
        Raylib.setConfigFlags(ConfigFlags.VSYNC_HINT);
        Raylib.initWindow(windowWidth, windowHeight, title);

        displayRatio = windowWidth / displayWidth;

        Raylib.setTargetFPS(framerate);
        Raylib.setExitKey(Keys.NULL);

        Assets.load('content/library.json'); // hardcoded!!!

        #if firebrick_editor
        editor = new Editor();
        editor.startup();
        #end

        displayTarget = Raylib.loadRenderTexture(displayWidth, displayHeight);
        srcRectangle = Rectangle.create(0, 0, displayWidth, -displayHeight);
        dstRectangle = Rectangle.create(-displayRatio, -displayRatio, windowWidth + (displayRatio * 2), windowHeight + (displayRatio * 2));
    
        Module.currentModule = m;
        Module.currentModule.startup();

        #if wasm
        Emscripten.setMainLoop(Callable.fromStaticFunction(update), 60, 1);
        #else
        while(!Raylib.windowShouldClose()) {
            update();
        }
        #end

        Raylib.unloadRenderTexture(displayTarget);

        #if firebrick_editor
        if(Editor.active) editor.shutdown();
        #end

        // unload all assets
        Assets.unload();

        Module.currentModule.shutdown();
        Raylib.closeWindow();
    }

    public static function toggleFullscreen() {
        Raylib.toggleFullscreen();
    }

    static function update() {
        Module.currentModule.update();
        #if firebrick_editor
        if(Editor.active) {
            editor.update();
            if(Raylib.getScreenWidth() != 1600) {
                Raylib.setWindowSize(1600, 900);
                Raylib.showCursor();
                Raylib.enableCursor();
            }
        } else {
            if(Raylib.getScreenWidth() != windowWidth) Raylib.setWindowSize(windowWidth, windowHeight);
        }
        #end

        timeCounter += Raylib.getFrameTime();
        while(timeCounter > timeStep) {
            Module.currentModule.fixedUpdate();
            #if firebrick_editor
            if(Editor.active) editor.fixedUpdate();
            #end
            timeCounter -= timeStep;
        }

        Raylib.beginTextureMode(displayTarget);
        Raylib.clearBackground(bgColor);
        Module.currentModule.render();
        Raylib.endTextureMode();

        Raylib.beginDrawing();
        Raylib.clearBackground(Colors.RED);
        Raylib.drawTexturePro(displayTarget.texture, srcRectangle, dstRectangle, Vector2.zero(), 0, Colors.WHITE);
        #if firebrick_editor
        if(Editor.active) editor.render();
        else @:privateAccess editor.topBar();
        #end

        Module.currentModule.renderUI();
        Raylib.endDrawing();
    }

	static function get_fullscreen():Bool {
        return Raylib.isWindowFullscreen();
    }
}