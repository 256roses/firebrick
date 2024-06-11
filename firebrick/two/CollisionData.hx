package firebrick.two;

class CollisionData {
    public var x:Int;
    public var y:Int;
    public var width:Int;
    public var height:Int;
    public var data:Array<Int> = [];
    public var gridSize:Int = 32; // default
    
    public function new(x:Int, y:Int, w:Int, h:Int, d:Array<Int>, gridSize:Int = 32) {
        this.x = x;
        this.y = y;
        width = w;
        height = h;
        data = d;
        this.gridSize = gridSize;
    }

    public function exists(cx:Int, cy:Int):Bool {
        var ox = cx - Std.int(x/gridSize);
        var oy = cy - Std.int(y/gridSize);

        return data[index(ox, oy)] > 0;
    }

    public inline function index(column, row):Int{
        return width * row + column;
    }

    public inline function column(index:Int):Int
    {
        return Std.int(index % width);
    }

    public inline function row(index:Int):Int
    {
        return Std.int(index / height);
    }
}