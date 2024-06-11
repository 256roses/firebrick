package firebrick.two;

import firebrick.two.RoomSerializables.EntityData;

@:structInit
class Room {
    // Position of the rooms in the room collection
    public var x:Int;
    public var y:Int;

    public var width:Int;
    public var height:Int;

    // Collidable tiles
    public var solids:Array<Int>;
    public var foreground:Array<Int>;
    public var background:Array<Int>;
    public var tileset:String;

    public var entities:Array<EntityData>;

    // Unique identifier for the room
    public var id:Int;
    public var parent:RoomCollection;

    public function renderBackground() {
        for(cx in 0...Std.int(width/parent.gridsize)) {
            for(cy in 0...Std.int(height/parent.gridsize)) {
                if(background[cx + width * cy] != 0) Raylib.drawTextureRec(Assets.images[tileset].spritesheet, parent.tilesetMap[tileset][background[cx + width * cy]], Raylib.Vector2.create(x + (cx * parent.gridsize), y + (cy * parent.gridsize)), Raylib.Colors.WHITE);
            }
        }
    }

    public function renderForeground() {
        for(cx in 0...Std.int(width/parent.gridsize)) {
            for(cy in 0...Std.int(height/parent.gridsize)) {
                if(foreground[cx + width * cy] != 0) Raylib.drawTextureRec(Assets.images[tileset].spritesheet, parent.tilesetMap[tileset][foreground[cx + width * cy]], Raylib.Vector2.create(x + (cx * parent.gridsize), y + (cy * parent.gridsize)), Raylib.Colors.WHITE);
            }
        }
    }

    public function renderSolids() {
        for(cx in 0...Std.int(width/parent.gridsize)) {
            for(cy in 0...Std.int(height/parent.gridsize)) {
                if(solids[cx + width * cy] != 0) Raylib.drawTextureRec(Assets.images[tileset].spritesheet, parent.tilesetMap[tileset][solids[cx + width * cy]], Raylib.Vector2.create(x + (cx * parent.gridsize), y + (cy * parent.gridsize)), Raylib.Colors.WHITE);
            }
        }
    }

    /** Set given `tile` at given `location` in `layer` (solids, foreground, background) **/
    public function set(cx:Int, cy:Int, tile:Int, layer:String) {
        if(layer == 'solids') solids[cy * width + cx] = tile;
        else if(layer == 'background') background[cy * width + cx] = tile;
        else if(layer == 'foreground') foreground[cy * width + cx] = tile;
    }

    /** Remove a tile at given `location` in `layer` (solids, foreground, background) **/
    public function remove(cx:Int, cy:Int, layer:String) {
        if(layer == 'solids') solids[cy * width + cx] = 0;
        else if(layer == 'background') background[cy * width + cx] = 0;
        else if(layer == 'foreground') foreground[cy * width + cx] = 0;
    }
}