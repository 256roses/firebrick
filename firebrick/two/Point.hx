package firebrick.two;

class Point {
    public var x:Float;
    public var y:Float;

    public var xInt(get, set):Int;
    public var yInt(get, set):Int;

    public function new(x:Float, y:Float) {
        this.x = x;
        this.y = y;
    }

    public function set(x:Float, y:Float) {
        this.x = x;
        this.y = y;
    }

    function set_xInt(value:Int):Int {
        x = value;
        return value;
    }

    function get_xInt():Int {
        return Std.int(x);
    }

    function set_yInt(value:Int):Int {
        y = value;
        return value;
    }

    function get_yInt():Int {
        return Std.int(y);
    }

    public function toString():String {
        return 'x: $x y: $y';
    }
}