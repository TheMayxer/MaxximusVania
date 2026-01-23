package;

import flixel.FlxGame;
import mapas.Exterior;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, Exterior, 60, 60, true));
	}
}
