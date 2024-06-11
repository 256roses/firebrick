package firebrick;

import Raylib;

class Im {
        // style
        public static var fnt:Font;
        public static var fntSize = 24;
        public static var background =  Raylib.Color.create(15, 15, 15, 255);
        public static var foreground = Raylib.Colors.WHITE;
        public static var highlight = Raylib.Color.create(Std.int(255 * 0.26), Std.int(255 * 0.59), Std.int(255 * 0.98), Std.int(255 * 1));
        public static var border = Raylib.Color.create(Std.int(255 * 0.43), Std.int(255 * 0.43), Std.int(255 * 0.50), Std.int(255 * 0.50));
        public static var blue = Raylib.Color.create(40, 73, 122, 255);
    
        public static var padding:Int = 10;
        public static var headerPadding:Int = 5;
    
        // layouts
        public static var activeX:Int;
        public static var activeY:Int;
        public static var activeMode = 0;
        public static var incrementX:Int;
        public static var incrementY:Int;
    
        public static var previousX:Int = -1000;
        public static var previousY:Int = -1000;
    
        public static function startup(fontFile:String) {
            Im.fnt = Raylib.loadFont("content/fonts/editor_font.ttf");
            Raylib.setTextureFilter(Im.fnt.texture, TextureFilter.TRILINEAR);
        }
    
        public static function shutdown() {
            Raylib.unloadFont(fnt);
        }
    
        /**
            mode 0 - VERTICAL LAYOUT
            mode 1 - HORIZONTAL LAYOUT
        **/
        public static function begin(x:Int, y:Int, mode:Int) {
            activeX = x;
            activeY = y;
            activeMode = mode;
            incrementX = 0;
            incrementY = 0;
        }
    
        public static function end() {
            activeX = -1000;
            activeY = -1000;
            incrementX = 0;
            incrementY = 0;
        }
    
        public static function checkHover(x:Float, y:Float, w:Float, h:Float) {
            return Raylib.checkCollisionPointRec(Raylib.getMousePosition(), Raylib.Rectangle.create(Std.int(x), Std.int(y), Std.int(w), Std.int(h)));
        }
    
        public static function intBox(width:Int, name:String, defValue:Int):Int {
            var x = activeX + incrementX;
            var y = activeY + incrementY;
            var height = fntSize;
    
            var rect = Raylib.Rectangle.create(x, y, width, height);
            Raylib.drawRectangleRec(rect, Raylib.Color.create(40, 73, 122, 255));
            Raylib.drawRectangleLinesEx(rect, 1, border);
            text(x + width + 10, y, name, foreground);
    
            // display the number
            text(x + 10, y, '${defValue}', foreground);
            if(Raylib.checkCollisionPointRec(Raylib.getMousePosition(), rect)) {
                var t = String.fromCharCode(Raylib.getCharPressed());
                var r = '${defValue}';
                if(Raylib.isKeyPressed(Raylib.Keys.BACKSPACE) && r.length > 0) r = r.substring(0, r.length-1);
                var o = r;
                if(Std.parseInt(t) != null) o = r+t;
                defValue = Std.parseInt(o);
            }
    
            incrementNext(x, y, width, height);
            return defValue;
        }

        public static function floatBox(width:Int, name:String, defValue:Float):Float {
            var x = activeX + incrementX;
            var y = activeY + incrementY;
            var height = fntSize;
    
            var rect = Raylib.Rectangle.create(x, y, width, height);
            Raylib.drawRectangleRec(rect, Raylib.Color.create(40, 73, 122, 255));
            Raylib.drawRectangleLinesEx(rect, 1, border);
            text(x + width + 10, y, name, foreground);
    
            // display the number
            text(x + 10, y, '${defValue}', foreground);
            if(Raylib.checkCollisionPointRec(Raylib.getMousePosition(), rect)) {
                var t = String.fromCharCode(Raylib.getCharPressed());
                var r = '${defValue}';
                if(Raylib.isKeyPressed(Raylib.Keys.BACKSPACE) && r.length > 0) r = r.substring(0, r.length-1);
                var o = r;
                o = r+t;
                defValue = Std.parseFloat(o);
            }
    
            incrementNext(x, y, width, height);
            return defValue;
        }
    
        public static function inputBox(width:Int, name:String, defValue:String, col:Color = null):String {
            var x = activeX + incrementX;
            var y = activeY + incrementY;
            var height = fntSize;
    
            var rect = Raylib.Rectangle.create(x, y, width, height);
            Raylib.drawRectangleRec(rect, Raylib.Color.create(40, 73, 122, 255));
            Raylib.drawRectangleLinesEx(rect, 1, border);
            text(x + width + 10, y, name, foreground);
    
            // display the number
            if(col != null) text(x + 10, y, '${defValue}', col);
            else text(x + 10, y, defValue, col);
            if(Raylib.checkCollisionPointRec(Raylib.getMousePosition(), rect)) {
                var t  = null;
    
                var char = Raylib.getCharPressed();
                var str = String.fromCharCode(char);
    
                if(char > 0) t = str;
    
                var r = '${defValue}';
                if(Raylib.isKeyPressed(Raylib.Keys.BACKSPACE) && r.length > 0) r = r.substring(0, r.length-1);
                var o = r;
                if(t != null) o = r+t;
                defValue = o;
            }
    
            incrementNext(x, y, width, height);
            return defValue;
        }
    
        public static function button(width:Int, height:Int, name:String):Bool {
            var x = activeX + incrementX;
            var y = activeY + incrementY;
            var result = false;
    
            var w = width+Raylib.measureText(name, fntSize);
            var h = height+fntSize;
            var rec = Raylib.Rectangle.create(x, y, w, h);
    
            var tx = x + ((w - (Raylib.measureText(name, fntSize)))  / 2) + width;
            var ty = y + ((h -fntSize) /2);
    
            Raylib.drawRectangleRec(rec, blue);
            Raylib.drawRectangleLinesEx(rec, 1, border);
            if(Raylib.checkCollisionPointRec(Raylib.getMousePosition(), rec)) {
                text(tx, ty, name, highlight);
                if(Raylib.isMouseButtonPressed(Raylib.MouseButton.LEFT)) result = true;
            } else {
                text(tx, ty, name, foreground);
            }
    
            incrementNext(x, y, w, h);
            return result;
        }
    
        public static function textButton(name:String):Bool {
            var x = activeX + incrementX;
            var y = activeY + incrementY;
            var result = false;
    
            var rec = Raylib.Rectangle.create(x, y, Raylib.measureText(name, fntSize), fntSize);
            if(Raylib.checkCollisionPointRec(Raylib.getMousePosition(), rec)) {
                text(x, y, name, highlight);
                if(Raylib.isMouseButtonPressed(Raylib.MouseButton.LEFT)) result = true;
            } else {
                text(x, y, name, foreground);
            }
    
            incrementNext(x, y, rec.width, rec.height);
            return result;
        }
    
        public static function label(name:String) {
            var x = activeX + incrementX;
            var y = activeY + incrementY;
            text(x, y, name, foreground);
    
            incrementNext(x, y, Raylib.measureText(name, fntSize), fntSize);
        }
    
        public static function header(name:String, width:Int) {
            label(name);
            var x = activeX + incrementX;
            var y = activeY + incrementY;
    
            Raylib.drawLine(0, y, Std.int(width), y, border);
    
            incrementNext(x, y, width, headerPadding);
        }
    
        public static function text(x:Float, y:Float, text:String, c:Color) {
            Raylib.drawTextEx(fnt, text, Raylib.Vector2.create(x, y), fntSize, 0, c);
        }
    
        public static function rect(x:Float, y:Float, w:Float, h:Float) {
            Raylib.drawRectangle(Std.int(x), Std.int(y), Std.int(w), Std.int(h), background);
        }
    
        public static function rectBorder(x:Float, y:Float, w:Float, h:Float) {
            Raylib.drawRectangleLines(Std.int(x), Std.int(y), Std.int(w), Std.int(h), border);
        }
    
        public static function grid(x:Float, y:Float, w:Float, h:Float, size:Int, c:Color) {
                // x
                for(i in 0...Std.int(w / size)) {
                    var gx = Std.int(x + i * size);
                    Raylib.drawLine(gx, Std.int(y), gx, Std.int(y + h), c);
                }
    
                // y
                for(i in 0...Std.int(h / size)) {
                    var gy = Std.int(y + i * size);
                    Raylib.drawLine(Std.int(x), gy, Std.int(x + w), gy, c);
                }
        }
    
        static function incrementNext(x:Float, y:Float, w:Float, h:Float) {
            if(activeMode == 0) {
                incrementX = 0;
                incrementY = incrementY + Std.int(h + padding);
            } else {
                incrementX = incrementX + Std.int(w + padding);
                incrementY = 0;
            }
    
            previousX = Std.int(x);
            previousY = Std.int(y);
        }
}