package characters;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

class Character extends FlxSprite
{
    public var health:Int;
    public var image:String;
    public var accelerationY:Float;
    public var shakeTween:FlxTween;
    public var colorTween:FlxTween;

    public function new(x:Float,y:Float, image:String, health:Int,  ?accelerationY:Float = 1500) {
        super(x,y);

        this.image = image;
        this.accelerationY = accelerationY;
        this.health = health;
        loadGraphic(Paths.image('characters/$image'));
        acceleration.y = accelerationY;
        shakeTween = FlxTween.shake(this, 0.01, 0.5, XY);
        colorTween = FlxTween.color(this, 0.7, FlxColor.RED, FlxColor.WHITE);
    }



    override function update(elapsed:Float) {
        super.update(elapsed);
        scale.set(FlxMath.lerp(scale.x, 1, elapsed*7),FlxMath.lerp(scale.y, 1, elapsed*7));
    }
}