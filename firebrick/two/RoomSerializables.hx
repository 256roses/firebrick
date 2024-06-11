package firebrick.two;

typedef RoomCollectionData = {
    rooms:Array<RoomData>,
    defaultTileset:String,
    gridsize:Int,
}

typedef RoomData = {
    id:Int,
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    solids:Array<Int>,
    foreground:Array<Int>,
    background:Array<Int>,
    tileset:String,
    entities:Array<EntityData>
}

typedef EntityData = {
    id:String,
    x:Float,
    y:Float,
}