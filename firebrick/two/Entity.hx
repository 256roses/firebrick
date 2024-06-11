package firebrick.two;

import firebrick.two.RoomSerializables.EntityData;

class Entity {
    public var x:Float;
    public var y:Float;

    public function new(edata:EntityData) {
        this.x = edata.x;
        this.y = edata.y;
        startup();
    }

    public function startup() {}
    public function shutdown() {}
    public function update() {}
    public function fixedUpdate() {}
    public function render() {}
}