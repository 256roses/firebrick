package firebrick.two;

class Body {
    public var x:Float;
    public var y:Float;
    /** Grid X coordinate **/
    public var cx:Int = 0;
    /** Grid Y coordinate **/
    public var cy:Int = 0;
    /** X position within grid (0-1) **/
    public var rx:Float = 0;
    /** Y position within grid (0-1) **/
    public var ry:Float = 0;

    public var velocityX:Float = 0;
    public var velocityY:Float = 0;
    public var accelerationX:Float = 0;
    public var accelerationY:Float = 0;
    public var maximumSpeed:Float = 1;
    public var friction:Float = 0.98;
    public var airResistance:Float = 0.98;
    public var gravity:Float = 0.98;

    public var passThrough:Bool = false;
    public var collisionData:CollisionData;
    public var radius:Int;
    public var repelForce:Int;
    public var isColliding:Bool       = false;
    public var isCollidingTop:Bool    = false;
    public var isCollidingBottom:Bool = false;
    public var isCollidingLeft:Bool   = false;
    public var isCollidingRight:Bool  = false;

    public var offsetX:Int = 0;
    public var offsetY:Int = 0;

    public static var ALL_BODIES:Array<Body> = [];

    public function new(x:Float, y:Float, collisionData:CollisionData) {
        this.collisionData = collisionData;
        setPosition(x, y);
        ALL_BODIES.push(this);
    }

    public function fixedUpdate() {
        handleMovement();
        handleActorCollision();
    }

    public function handleMovement() {
        if(!isCollidingBottom) velocityY += gravity;

        velocityX += accelerationX;
        velocityY += accelerationY;

        if(velocityX > maximumSpeed) velocityX = maximumSpeed;
        if(velocityX < -maximumSpeed) velocityX = -maximumSpeed;
        
        rx += velocityX;
        velocityX *= friction;

        if(collisionData.exists(cx + 1, cy) && rx >= 0) {
            rx = 0;
            velocityX = 0;
            isColliding = true;
            isCollidingRight = true;
        } else  {
            isColliding = false;
            isCollidingRight = false;
        }

        if(collisionData.exists(cx - 1, cy) && rx <= 0) {
            rx = 0;
            velocityX = 0;
            isColliding = true;
            isCollidingLeft = true;
        } else {
            isColliding = false;
            isCollidingLeft = false;
        }

        while(rx > 1) {
            rx = 0;
            cx++;
        }

        while(rx < 0) {
            rx = 1;
            cx--;
        }

        ry += velocityY;
        velocityY *= airResistance;

        if(collisionData.exists(cx, cy - 1) && ry <= 0) {
            ry = 0;
            velocityY = 0;
            isColliding = true;
            isCollidingTop = true;
        } else {
            isColliding = false;
            isCollidingTop = false;
        }

        if(collisionData.exists(cx, cy + 1) && ry >= 0) {
            ry = 0;
            velocityY = 0;
            isColliding = true;
            isCollidingBottom = true;
        } else {
            isColliding = false;
            isCollidingBottom = false;
        }

        while(ry > 1) {
            ry = 0;
            cy++;
        }
        while(ry < 0) {
            ry = 1;
            cy--;
        }

        x = (cx + rx) * collisionData.gridSize;
        y = (cy + ry) * collisionData.gridSize;
    }

    public function handleActorCollision() {
        for(actor in ALL_BODIES) {
            if(actor != this && Math.abs(cx - actor.cx) <= 2 && Math.abs(cy - actor.cy) <= 2) {
                var distance = (actor.x - x) * (actor.x - x) + (actor.y - y) * (actor.y - y);
                if(distance <= radius + actor.radius) {
                    var angle = Math.atan2(actor.y - y, actor.x - x);
                    var repelPower = (radius + actor.radius - distance) / (radius  + actor.radius);
                    velocityX -= Math.cos(angle) * repelPower * repelForce;
                    velocityY -= Math.sin(angle) * repelPower * repelForce;
                    actor.velocityX += Math.cos(angle) * repelPower * repelForce;
                    actor.velocityY += Math.sin(angle) * repelPower * repelForce;
                }
            }
        }
    }

    public inline function overlapsActor(e:Body):Bool {
        var maxDist = radius + e.radius;
        var distSqr = (e.x - x) * (e.x - x) + (e.y - y) * (e.y - y);
        return distSqr <= maxDist * maxDist;
    }

    public function setPosition(x:Float, y:Float) {
        this.x = x;
        this.y = y;
        cx = Std.int(this.x / collisionData.gridSize);
        cy = Std.int(this.y / collisionData.gridSize);
        rx = (this.x - cx * collisionData.gridSize) / collisionData.gridSize;
        ry = (this.y - cy * collisionData.gridSize) / collisionData.gridSize;
    }
}