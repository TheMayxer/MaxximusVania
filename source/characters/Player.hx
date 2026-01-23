package characters;

import flixel.FlxG;
import flixel.math.FlxMath;

class Player extends Character
{
    final playerVelocity:Float = 390;

    public function new(x:Float, y:Float) {
        super(x,y,'andrezitos',100);
    }
    var iTime:Float = 0;
    override function update(elapsed:Float) {
        super.update(elapsed);
        iTime += elapsed;

		if(FlxG.keys.pressed.A||FlxG.keys.pressed.D)
		{
			velocity.x = FlxG.keys.pressed.A ? -playerVelocity : playerVelocity;
			flipX = FlxG.keys.pressed.A;

            angle = 0 + Math.sin(iTime*4)*10;
		} else {
			velocity.x  = 0;
            angle = FlxMath.lerp(angle, 0, elapsed*7);
		}
    }
}