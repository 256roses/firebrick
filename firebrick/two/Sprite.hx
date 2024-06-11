package firebrick.two;

class Sprite {
    public var x:Float;
    public var y:Float;

    public var currentFrame = 0;
    public var frameSpeed = 0;
    public var playingAnimation = false;
    var framesCounter = 0;

    public var width:Int;
    public var height:Int;
    var assetName:String;

    public var offsetX = 0;
    public var offsetY = 0;
    public var squashX:Float;
    public var squashY:Float;

    public var rotation = 0;
    public var direction = 1;

    public var tint = Raylib.Colors.WHITE;

    public function new(file:String, x:Float, y:Float) {
        this.x = x;
        this.y = y;

        assetName = file;
        width = Assets.images[file].width;
        height = Assets.images[file].height;

        assetName = file;
    }

    public function setSquashX(scale:Float) {
        squashY = 2 - scale;
        squashX = scale;
    }

    public function setSquashY(scale:Float) {
        squashX = 2 - scale;
        squashY = scale;
    }

    public function play(start:Int, end:Int, loop:Bool = true) {
        // if(!playingAnim) currentFrame = start;

        if(framesCounter >= (60/frameSpeed)) {
            framesCounter = 0;
            currentFrame++;
            if(loop)
                if(currentFrame > end) currentFrame = start;
        }
    }

    public function render() {
        framesCounter++;

        var widthVisual = width * squashX;
        var widthDif = width - widthVisual;
        var xOffset = x + (widthDif / 2);

        var heightVisual = height * squashY;
        var heightDif = height - heightVisual;
        var yOffset = y + (heightDif / 2);

        var animX = 0;
        var animY = 0;
        if(currentFrame > (Assets.images[assetName].spritesheet.width/width)) {
            animX = 0;
            animY += width;
        } else {
            animX = width * currentFrame;
        }

        Raylib.drawTexturePro(Assets.images[assetName].spritesheet, Raylib.Rectangle.create(animX, animY, width * direction, height), Raylib.Rectangle.create(xOffset, yOffset, width, height), Raylib.Vector2.create(offsetX, offsetY), rotation, tint);
        // Raylib.drawTexturePro(Assets.images[assetName].spritesheet, Raylib.Rectangle.create(animX, animY, width * direction, height), Raylib.Rectangle.create(xOffset, yOffset, width * squashX, height *  squashY), Raylib.Vector2.create(offsetX, offsetY), rotation, tint);

        squashX += (1 - squashX) * Math.min(1, 0.2 * 0.6);
        squashY += (1 - squashY) * Math.min(1, 0.2 * 0.6);
    }
}