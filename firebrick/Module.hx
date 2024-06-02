package firebrick;

class Module {
    public static var currentModule:Module;

    public function new() {}

    public function startup() {}
    public function shutdown() {}

    public function update() {}
    public function fixedUpdate() {}

    public function render() {}

    public static function changeModule(m:Module) {
        currentModule.shutdown();
        currentModule = null;
        currentModule = m;
        currentModule.startup();
    }
}