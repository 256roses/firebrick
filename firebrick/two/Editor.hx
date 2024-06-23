package firebrick.two;

import haxe.DynamicAccess;
import firebrick.two.RoomSerializables;
import Raylib;

using StringTools;

enum PanelStates {
    Default;
    RoomCreation;
}

class Editor extends Module {
    public static var currentRoomCollection:RoomCollection;
    public static var currentRoomToPlay:Room;
    public static var setCurrentRoom = false;
    public static var active = false;

    var cam:Camera2D;
    var checkerboard:Texture;

    // ui locks
    var isBarActive = false;
    var isPanelActive = false;
    var isUiActive = false;
    var isUsingCamera = false;
    var isEntityPanelActive=false;

    var panelState:PanelStates = PanelStates.Default;
    var createRoomMode = false;
    var createEntityMode = false;

    // scene stuff
    var selectedRoom:Room = null;
    var selectedLayer:String = 'solids';
    var selectedTile:Int = 1; // default
    var canEdit = false;

    var entityList:Array<String> = [];
    var selectedEntity:EntityData = null;
    var entityToPlace:String = null;

    override function startup() {
        Im.startup('content/fonts/editor_font.ttf');

        var img = Raylib.genImageChecked(512, 512, 16, 16, Raylib.Colors.DARKGRAY, Raylib.Color.create(50, 50, 50, 255));
        checkerboard = Raylib.loadTextureFromImage(img);
        Raylib.unloadImage(img);

        cam = Camera2D.create(Vector2.zero(), Vector2.zero());
        cam.zoom = 2;

        for(k in Assets.entities.keys()) entityList.push(k);
    }

    override function shutdown() {
        Im.shutdown();
        Raylib.unloadTexture(checkerboard);
    }

    override function update() {
        if(isBarActive || isPanelActive || isEntityPanelActive) isUiActive = true;
        else isUiActive = false;

        if(!isUiActive) handleCamera();

        // change room details + display them
        if(selectedRoom == null) {
            if(currentRoomCollection.rooms == null || isUsingCamera || isUiActive) return;

            for(room in currentRoomCollection.rooms) {
                if(Raylib.checkCollisionPointRec(Raylib.getScreenToWorld2D(Raylib.getMousePosition(), cam), Raylib.Rectangle.create(room.x, room.y, room.width, room.height)) && Raylib.isMouseButtonPressed(Raylib.MouseButton.LEFT)) {
                    selectedRoom = room;
                }
            }

        } else {
            if(Raylib.isKeyPressed(Raylib.Keys.ESCAPE)) {
                if(selectedEntity!=null) {selectedEntity=null;isEntityPanelActive=false;return;}
                if(createEntityMode) {createEntityMode=false;return;}

                if(canEdit) {
                    canEdit = false;
                    panelState = Default;
                } else {
                    selectedRoom = null;
                }
            }
        }
        
        if(canEdit) panelState = RoomCreation;

        // CREATE NEW ROOM
        if(createRoomMode && !isUiActive && Raylib.isMouseButtonPressed(MouseButton.LEFT)) {
            if(Raylib.isKeyPressed(Raylib.Keys.ESCAPE)) {createRoomMode=false;return;}
            createNewRoom();
            createRoomMode = false;
        }

        // create new entity
        if(createEntityMode && !isUiActive && !isUsingCamera && Raylib.isMouseButtonPressed(MouseButton.LEFT)) {
            if(Raylib.isKeyPressed(Raylib.Keys.ESCAPE)) {createEntityMode=false;return;}
            createNewEntity();
            createEntityMode = false;
        }

        // placing tiles
        if(selectedRoom != null) {
            var mpos = Raylib.getScreenToWorld2D(Raylib.getMousePosition(), cam);
            if(Raylib.checkCollisionPointRec(mpos, Raylib.Rectangle.create(selectedRoom.x, selectedRoom.y, selectedRoom.width, selectedRoom.height)) && !isUsingCamera && !isUiActive && canEdit) {
                var mx = (mpos.x - selectedRoom.x);
                var my = (mpos.y - selectedRoom.y);
                var x = Std.int(mx / currentRoomCollection.gridsize);
                var y = Std.int(my / currentRoomCollection.gridsize);
                if(Raylib.isMouseButtonDown(Raylib.MouseButton.LEFT)) selectedRoom.set(x, y, selectedTile, selectedLayer);
                if(Raylib.isMouseButtonDown(Raylib.MouseButton.RIGHT)) selectedRoom.remove(x, y, selectedLayer);
            }
        }

        // selecting entity
        if(selectedRoom!=null && canEdit && selectedRoom.entities != null && selectedLayer == 'Entities') {
            for(entity in selectedRoom.entities) {
                if(Raylib.checkCollisionPointRec(Raylib.getScreenToWorld2D(Raylib.getMousePosition(), cam), Rectangle.create(entity.x, entity.y, currentRoomCollection.gridsize, currentRoomCollection.gridsize)) && !isUsingCamera &&!createEntityMode) {
                    if(Raylib.isMouseButtonPressed(Raylib.MouseButton.LEFT)) selectedEntity = entity;
                    else if(Raylib.isMouseButtonPressed(Raylib.MouseButton.RIGHT)) selectedRoom.entities.remove(entity);
                }
            }
        }

        if(createRoomMode || createEntityMode) Raylib.setMouseCursor(MouseCursor.POINTING_HAND);
        else Raylib.setMouseCursor(MouseCursor.DEFAULT);
    }

    function handleCamera() {
        // camera controls
        cam.zoom = cam.zoom + Raylib.getMouseWheelMove() * 0.1;
        if(cam.zoom < 0.125) cam.zoom = 0.125;

        if(Raylib.isKeyDown(Raylib.Keys.SPACE) && Raylib.isMouseButtonDown(Raylib.MouseButton.LEFT)) {
            var delta = vscale(Raylib.getMouseDelta(), -1.0 / cam.zoom);

            // set the camera target to follow the player
            cam.target = vadd(cam.target, delta);
        }

        if(Raylib.isKeyDown(Raylib.Keys.SPACE)) isUsingCamera = true;
        else isUsingCamera = false;
    }

    function vscale(v:Vector2, s:Float):Vector2 {
        return Vector2.create(v.x * s, v.y * s);
    }

    function vadd(v:Vector2, s:Vector2):Vector2 {
        return Vector2.create(v.x + s.x, v.y + s.y);
    }

    var mouseScaleReady= false;
    var mouseScaleMode = false;
    override function render() {
        // draw worldspace stuff here
        Raylib.beginMode2D(cam);

        var mpos = Raylib.getScreenToWorld2D(Raylib.getMousePosition(), cam);

        // checkerboard
        var rec = Raylib.Rectangle.create(cam.target.x, cam.target.y, Raylib.getScreenWidth() / cam.zoom, Raylib.getScreenHeight() / cam.zoom);
        Raylib.drawTexturePro(checkerboard, rec, rec, Vector2.zero(), 0, Raylib.Colors.WHITE);

        // drawing room tiles
        for(room in currentRoomCollection.rooms) {
            Raylib.drawRectangle(room.x, room.y, room.width, room.height, Raylib.Colors.BLACK);
            room.renderBackground();
            room.renderSolids();
            room.renderForeground();
            // drawing room entities
            for(entity in room.entities) {
                if(Assets.entities[entity.id]['sprite'] != null)
                    Raylib.drawTextureRec(Assets.images[Assets.entities[entity.id]['sprite']].spritesheet, Rectangle.create(0, 0, Assets.images[Assets.entities[entity.id]['sprite']].width, Assets.images[Assets.entities[entity.id]['sprite']].height), Raylib.Vector2.create(entity.x, entity.y), Colors.WHITE);
                else Raylib.drawRectangleLines(Std.int(entity.x), Std.int(entity.y), 32,  32, Raylib.Colors.RED);
            }
            Raylib.drawRectangleLinesEx(Raylib.Rectangle.create(room.x, room.y, room.width, room.height), 2, Im.foreground);
        }
        
        // drawing room border and grid
        if(selectedRoom != null) {
            Im.grid(selectedRoom.x, selectedRoom.y, selectedRoom.width, selectedRoom.height, currentRoomCollection.gridsize, Im.border);

            // changinrg room position
            if(Raylib.isKeyDown(Raylib.Keys.LEFT_CONTROL) && Raylib.isMouseButtonDown(Raylib.MouseButton.LEFT)) {
                var x = Std.int(mpos.x / currentRoomCollection.gridsize) * currentRoomCollection.gridsize;
                var y = Std.int(mpos.y / currentRoomCollection.gridsize) * currentRoomCollection.gridsize;
                selectedRoom.x = Std.int(x);
                selectedRoom.y = Std.int(y);
            }
        }

        // room size edit & room position change
        if(selectedRoom != null && !canEdit) {
            var rec = Rectangle.create(selectedRoom.x, selectedRoom.y, selectedRoom.width, selectedRoom.height);

            if (Raylib.checkCollisionPointRec(mpos, Raylib.Rectangle.create(rec.x + rec.width - 12, rec.y + rec.height - 12, 12, 12)))
            {
                mouseScaleReady = true;
                if (Raylib.isMouseButtonPressed(MouseButton.LEFT)) mouseScaleMode = true;
            }
            else mouseScaleReady = false;

            if (mouseScaleMode)
            {
                mouseScaleReady = true;
                var x = Std.int(mpos.x / currentRoomCollection.gridsize) * currentRoomCollection.gridsize;
                var y = Std.int(mpos.y / currentRoomCollection.gridsize) * currentRoomCollection.gridsize;
                rec.width = (x - rec.x);
                rec.height = (y - rec.y);
                if (Raylib.isMouseButtonReleased(MouseButton.LEFT)) mouseScaleMode = false;
            }

            selectedRoom.width = Std.int(rec.width);
            selectedRoom.height = Std.int(rec.height);

            Raylib.drawTriangle(Vector2.create(rec.x + rec.width - 12, rec.y + rec.height),
                    Vector2.create(rec.x + rec.width, rec.y + rec.height),
                    Vector2.create(rec.x + rec.width, rec.y + rec.height - 12), Raylib.Colors.WHITE);
        }

        // drawing current selected tile
        if(canEdit && selectedRoom != null && selectedLayer != 'Entities') {
            // draw mouse tile pick
            var tpx = Std.int(mpos.x / currentRoomCollection.gridsize);
            var tpy = Std.int(mpos.y / currentRoomCollection.gridsize);
            Raylib.drawTextureRec(Assets.images[selectedRoom.tileset].spritesheet, selectedRoom.parent.tilesetMap[selectedRoom.tileset][selectedTile], Raylib.Vector2.create(tpx * currentRoomCollection.gridsize, tpy * currentRoomCollection.gridsize), Colors.LIGHTGRAY);
        }

        // drawing entity to create
        if(createEntityMode) {
            var x = mpos.x;
            var y = mpos.y;
            if (Raylib.isKeyDown(Raylib.Keys.LEFT_SHIFT)) {
                if(Raylib.isKeyDown(Raylib.Keys.X)) x = Std.int( (Std.int(mpos.x / currentRoomCollection.gridsize) * currentRoomCollection.gridsize) );
                if(Raylib.isKeyDown(Raylib.Keys.Z)) y = Std.int( (Std.int(mpos.y / currentRoomCollection.gridsize) * currentRoomCollection.gridsize) );
            }

            if(Assets.entities[entityToPlace]['sprite'] != null)
                Raylib.drawTextureRec(Assets.images[Assets.entities[entityToPlace]['sprite']].spritesheet, Rectangle.create(0, 0, Assets.images[Assets.entities[entityToPlace]['sprite']].width, Assets.images[Assets.entities[entityToPlace]['sprite']].height), Raylib.Vector2.create(Std.int(x), Std.int(y)), Colors.WHITE);
            else Raylib.drawRectangleLines(Std.int(x), Std.int(y), 32,  32, Raylib.Colors.RED);
        }
        Raylib.endMode2D();

        // ---
        // UI
        // ---

        topBar();

        // panel ui lock
        if(Im.checkHover(0, Im.fntSize, Std.int(Raylib.getScreenWidth() * 0.3), Std.int(Raylib.getScreenHeight()))) isPanelActive = true;
        else isPanelActive = false;

        // panel
        var pw = Raylib.getScreenWidth() * 0.3;
        Im.rect(0, Im.fntSize, pw, Raylib.getScreenHeight());

        switch (panelState) {
            case RoomCreation:
                roomEditPanel();
            case Default:
                defaultPanel();
            default:
        }

        if(selectedEntity != null) {
            if(Raylib.checkCollisionPointRec(Raylib.getMousePosition(), Raylib.Rectangle.create(1600-350-20, 900-350-20, 350, 350)))  isEntityPanelActive = true;
            else isEntityPanelActive = false;

            Im.rect(1600-350-20, 900-350-20, 350, 350);
            Im.begin(1600-350-20+10,900-350-20,0);
            Im.label(selectedEntity.id);
            selectedEntity.x = Im.intBox(100, 'x', Std.int(selectedEntity.x));
            selectedEntity.y = Im.intBox(100, 'y', Std.int(selectedEntity.y));
            // !NOTE! Add support for custom values when necessary
            for(key => v in Assets.entities[selectedEntity.id]) {
                if(Std.isOfType(Assets.entities[selectedEntity.id][key], Int)) Assets.entities[selectedEntity.id][key] = Im.intBox(200, key, Assets.entities[selectedEntity.id][key]);
                else if(Std.isOfType(Assets.entities[selectedEntity.id][key], Float)) Assets.entities[selectedEntity.id][key] = Im.floatBox(200, key, Assets.entities[selectedEntity.id][key]);
            }
            Im.end();
            Im.rectBorder(1600-350-20, 900-350-20, 350, 350);
        }
    }

    var globalIncrement = 0;

    function topBar() {
        #if debug
        var x = 0;
        var y = 0;
        var w:Int = Raylib.getScreenWidth();
        var h:Int = Im.fntSize;

        // ui lock
        if(Im.checkHover(x, y, w, h)) isBarActive = true;
        else isBarActive = false;

        // draw the background rectangle of the topbar
        Im.rect(x, y, w, h);
        Im.rectBorder(x, y, w, h);

        Im.begin(0, 0, 0);
        {
            Im.label(currentRoomCollection.file);
        }
        Im.end();

        // play button :3
        Im.begin(Std.int(w/2 - (Raylib.measureText('Play', Im.fntSize))), 0, 1);
        {
            var text = 'Play';
            if(!active) {
                text = 'Stop';
            } else {
                text = 'Play';
            }

            if(Raylib.isKeyPressed(Raylib.Keys.F2)) active = !active;

            if(Im.textButton(text)) {
                active = !active;
                if(!active) {
                    setCurrentRoom = true;
                    if(selectedRoom != null) currentRoomToPlay = selectedRoom;
                }
            }
            if(Im.textButton('Re-load')) Assets.load('content/library.json');
        }
        Im.end();

        Im.begin(Raylib.getScreenWidth() - Raylib.measureText('save', Im.fntSize), 0, 1);
        if(Im.textButton('Save')) currentRoomCollection.serialize();
        Im.end();

        globalIncrement = Im.fntSize;
        #end
    }

    function defaultPanel() {
        Im.begin(10, globalIncrement + 10, 0);
        if(selectedRoom != null) Im.label('Room: ' + selectedRoom.id);
        else Im.label('No room selected');
        Im.end();

        Im.begin(10, Im.previousY+32, 1);
        if(Im.button(10, 10, 'Create Room')) createRoomMode = true;
        if(Im.button(10, 10, 'Delete Room')) deleteSelectedRoom();
        if(Im.button(10, 10, 'Edit Room')) if(selectedRoom!=null) canEdit = true;
        Im.end();
    }

    function roomEditPanel() {
        // Layer select UI
        Im.begin(10, globalIncrement + 10, 1);
        if(Im.button(5, 5, 'Solids')) {
            selectedLayer = 'solids';
        } else if(Im.button(5, 5, 'BG')) {
            selectedLayer = 'background';
        } else if(Im.button(5, 5, 'FG')) {
            selectedLayer = 'foreground';
        } else if(Im.button(5, 5, 'Entities')) {
            selectedLayer = 'Entities';
        }

        globalIncrement = Im.previousY + Im.padding * 4 + Im.headerPadding;
        Im.end();

        // Selection UI
        Im.begin(10, globalIncrement, 0);
        if(selectedLayer != 'Entities' && selectedLayer != null) displayEditPanel();
        else if(selectedLayer == "Entities" && selectedLayer != null) displayEntityPanel();
        Im.end();
    }

    var tileCam = Camera2D.create(Raylib.Vector2.zero(), Vector2.zero(), 0, 4);
    function displayEditPanel() {
        // header
        Im.header(selectedLayer, Std.int(Raylib.getScreenWidth() * 0.3));

        // draw rectangle to display the tileset
        var rec = Raylib.Rectangle.create(10, Im.activeY + Im.incrementY, Std.int(Raylib.getScreenWidth() * 0.3) - 20, Raylib.getScreenHeight() - globalIncrement - 60);
        Im.rectBorder(rec.x, rec.y, rec.width, rec.height);

        // camera controls
        if(Raylib.checkCollisionPointRec(Raylib.getMousePosition(), rec)) {
            tileCam.zoom = tileCam.zoom + Raylib.getMouseWheelMove() * 0.1;
            if(tileCam.zoom < 0.125) tileCam.zoom = 0.125;

            if(Raylib.isKeyDown(Raylib.Keys.SPACE) && Raylib.isMouseButtonDown(Raylib.MouseButton.LEFT)) {
                var delta = vscale(Raylib.getMouseDelta(), -1.0 / tileCam.zoom);

                // set the camera target to follow the player
                tileCam.target = vadd(tileCam.target, delta);
            }

            if(Raylib.isKeyDown(Raylib.Keys.SPACE)) isUsingCamera = true;
            else isUsingCamera = false;
        }

        var mpos = Raylib.getScreenToWorld2D(Raylib.getMousePosition(), tileCam);
        // draw mouse tile pick
        var tpx = Std.int(mpos.x / currentRoomCollection.gridsize);
        var tpy = Std.int(mpos.y / currentRoomCollection.gridsize);

        // SCISSOR BEGIN
        Raylib.beginScissorMode(Std.int(rec.x), Std.int(rec.y), Std.int(rec.width), Std.int(rec.height));

        Raylib.beginMode2D(tileCam);
        var images = Assets.images[selectedRoom.tileset];
        Raylib.drawTexture(Assets.images[selectedRoom.tileset].spritesheet, Std.int(0), Std.int(0), Raylib.Colors.WHITE);

        // draw grid
        Im.grid(0, 0, images.width, images.height, currentRoomCollection.gridsize, Im.border);
        Im.rectBorder(0, 0, images.width, images.height);

        Raylib.drawRectangleLines(tpx * currentRoomCollection.gridsize, tpy * currentRoomCollection.gridsize, currentRoomCollection.gridsize, currentRoomCollection.gridsize, Im.foreground);

        if(Raylib.checkCollisionPointRec(Raylib.getMousePosition(), rec)) {
            // SELECTING THE TILE
            if(tpx >= 0 && tpx <= images.width / currentRoomCollection.gridsize && tpy <= images.height / currentRoomCollection.gridsize && tpy >= 0 && Raylib.isMouseButtonPressed(Raylib.MouseButton.LEFT) && !Raylib.isKeyDown(SPACE)) {
                selectedTile = Std.int(tpy * (images.width/currentRoomCollection.gridsize) + (tpx)) + 1;
            }
        }

        // draw selected tile
        var sx = Std.int(Std.int((selectedTile-1) % Std.int(images.width/currentRoomCollection.gridsize)) * currentRoomCollection.gridsize);
        var sy = Std.int(Std.int((selectedTile-1) / Std.int(images.height/currentRoomCollection.gridsize)) * currentRoomCollection.gridsize);
        Raylib.drawRectangleLines(sx, sy, Std.int(currentRoomCollection.gridsize), Std.int(currentRoomCollection.gridsize), Im.blue);

        Raylib.endMode2D();

        Raylib.endScissorMode();
        // SCISSOR END
    }

    var c:Camera2D = Camera2D.create(Raylib.Vector2.zero(), Raylib.Vector2.zero());
    var e = '';
    function displayEntityPanel() {
        Im.header(selectedLayer, Std.int(Raylib.getScreenWidth() * 0.3));        
        if(entityList.contains(e)) e = Im.inputBox(Std.int(Raylib.getScreenWidth()*0.3)-20, '', e, Im.foreground);
        else e = Im.inputBox(Std.int(Raylib.getScreenWidth()*0.3)-20, '', e, Raylib.Colors.RED);

        var rec = Raylib.Rectangle.create(Im.activeX+Im.incrementX, Im.activeY + Im.incrementY, Raylib.getScreenWidth()*0.3-20, Raylib.getScreenHeight()-globalIncrement-60);

        Raylib.beginScissorMode(Std.int(rec.x), Std.int(rec.y), Std.int(rec.width), Std.int(rec.height));
        
        // cam.target = Raylib.Vector2.create(0, )
        if(Raylib.checkCollisionPointRec(Raylib.getMousePosition(), rec)) {
            c.target.y = c.target.y+(-Raylib.getMouseWheelMove() * 20); 
        }
        if(c.target.y < 0) c.target.y = 0;

        Raylib.beginMode2D(c);
        for(s in entityList) {
            if(s.contains(e)) {
                if(t(s)) {entityToPlace = s;createEntityMode=true;}
            }
        }
        Raylib.endMode2D();
        
        Raylib.endScissorMode();
    }

    function t(s:String) {
        var x = Im.activeX + Im.incrementX;
        var y = Im.activeY + Im.incrementY;
        var result = false;

        var rec = Raylib.Rectangle.create(x, y, Raylib.measureText(s, Im.fntSize), Im.fntSize);
        if(Raylib.checkCollisionPointRec(Raylib.getScreenToWorld2D(Raylib.getMousePosition(), c), rec)) {
            Im.text(x, y, s, Im.highlight);
            if(Raylib.isMouseButtonReleased(Raylib.MouseButton.LEFT)) result = true;
        } else {
            Im.text(x, y, s, Im.foreground);
        }

        @:privateAccess Im.incrementNext(x, y, rec.width, rec.height);
        return result;
    }


    function createNewRoom() {
        var mpos = Raylib.getScreenToWorld2D(Raylib.getMousePosition(), cam);

        var room:Room = {
            x: Std.int(mpos.x),
            y: Std.int(mpos.y),
            width: 256,
            height: 256,
            foreground: [],
            solids: [],
            background: [],
            entities: [],
            id: -1,
            tileset: currentRoomCollection.defaultTileset,
            parent: currentRoomCollection
        }

        room.id = currentRoomCollection.rooms.length;
        currentRoomCollection.add(room);
    }

    function deleteSelectedRoom() {
        if(selectedRoom!=null) currentRoomCollection.remove(selectedRoom);
        selectedRoom = null;
    }

    function createNewEntity() {
        var mpos = Raylib.getScreenToWorld2D(Raylib.getMousePosition(), cam);
        var x = mpos.x;
        var y = mpos.y;

        if (Raylib.isKeyDown(Raylib.Keys.LEFT_SHIFT)) {
            if(Raylib.isKeyDown(Raylib.Keys.X)) x = Std.int( (Std.int(mpos.x / currentRoomCollection.gridsize) * currentRoomCollection.gridsize) );
            if(Raylib.isKeyDown(Raylib.Keys.Z)) y = Std.int( (Std.int(mpos.y / currentRoomCollection.gridsize) * currentRoomCollection.gridsize) );
        }

        var entityData:EntityData = {
            x: Std.int(x),
            y: Std.int(y),
            id: entityToPlace,
        }

        selectedRoom.entities.push(entityData);
    }
}