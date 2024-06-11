package firebrick.two;

import sys.io.File;
import haxe.Json;
import firebrick.two.RoomSerializables;
import sys.FileSystem;
import Raylib;

/** 
    A collection of rooms which can be arranged in a world. 
**/
class RoomCollection {
    public var file:String;

    public var gridsize:Int;
    public var defaultTileset:String;
    public var tilesetMap:Map<String, Map<Int, Rectangle>> = [];

    public var rooms:Array<Room> = [];

    public function new(file:String) {
        if(!FileSystem.exists(file)) { trace('Scene $file does not exist.'); return; }

        this.file = file;
        var data:RoomCollectionData = Json.parse(File.getContent(file));
        gridsize = data.gridsize;
        defaultTileset = data.defaultTileset;

        for(room in data.rooms) {
            rooms[room.id] = {
                x: room.x,
                y: room.y,
                width: room.width,
                height: room.height,
                solids: room.solids,
                parent: this,
                id: room.id,
                background: room.background,
                foreground: room.foreground,
                tileset: room.tileset,
                entities: room.entities
            }

            if(!tilesetMap.exists(room.tileset)) {
                var i = 1;
                var w = Std.int(Assets.images[room.tileset].width / gridsize);
                var h = Std.int(Assets.images[room.tileset].height / gridsize);
                var map:Map<Int, Rectangle> = [];
                for(c in 0...w) {
                    for(r in 0...h) {
                        var rec = Rectangle.create(r * gridsize, c * gridsize, gridsize, gridsize);
                        map.set(i, rec);
                        i++;
                    }
                }
                tilesetMap.set(room.tileset, map);
            }
        }
    }

    public function serialize() {
        var allRoomData:Array<RoomData> = [];
        for(room in rooms) {
            allRoomData[room.id] = {
                x: room.x,
                y: room.y,
                width: room.width,
                height: room.height,
                id: room.id,
                solids: room.solids,
                background: room.background,
                foreground: room.foreground,
                tileset: room.tileset,
                entities: room.entities
            }
        }

        var rcdata:RoomCollectionData = {
            rooms: allRoomData,
            defaultTileset: defaultTileset,
            gridsize: gridsize
        };

        File.saveContent(file, Json.stringify(rcdata, "  "));
    }

    /** Add a room **/
    public function add(room:Room) {
        rooms.push(room);

        if(!tilesetMap.exists(room.tileset)) {
            var i = 1;
            var w = Std.int(Assets.images[room.tileset].width / gridsize);
            var h = Std.int(Assets.images[room.tileset].height / gridsize);
            var map:Map<Int, Rectangle> = [];
            for(c in 0...w) {
                for(r in 0...h) {
                    var rec = Rectangle.create(r * gridsize, c * gridsize, gridsize, gridsize);
                    map.set(i, rec);
                    i++;
                }
            }
            tilesetMap.set(room.tileset, map);
        }
    }

    /** Remove a room **/
    public function remove(room:Room) {
        rooms.remove(room);
    }
}