package characters;

import flixel.FlxG;

class Player extends Character
{
    public var temMachado:Bool = true;
    public var temEspada:Bool = true;
	public var podeTacaOMachado:Bool = true;
    public var podeLevarDano:Bool = true;
	public var podeAtacarComEspada:Bool = true;

    final playerVelocity:Float = 390;

    public function new(x:Float, y:Float) {
        super(x,y,'andrezitos',100);
    }
    override function update(elapsed:Float) {
        super.update(elapsed);

		if(FlxG.keys.pressed.LEFT||FlxG.keys.pressed.RIGHT)
		{
			velocity.x = FlxG.keys.pressed.LEFT ? -playerVelocity : playerVelocity;
			flipX = FlxG.keys.pressed.LEFT;
		} else {
			velocity.x  = 0;
		}
    }
}