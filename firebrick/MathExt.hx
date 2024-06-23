package firebrick;

class MathExt {
    inline public static function lerp(from:Float, to:Float, t:Float) : Float {
		return from + (to - from) * t;
	}
}