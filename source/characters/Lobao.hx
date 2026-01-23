package characters;

class Lobao extends Character
{
    public var lobaoFicaParado:Bool = false;
    public var lobaoPodeLevarDano:Bool = true;

    public function new(x:Float, y:Float) {
        super(x,y,'cachorrao',10);
    }

    public function cachorraoMoviments(e:Float, player:Player) {

		var cachorraoVelocity:Float = 0;
        if(!lobaoFicaParado)
        {
            if(x < player.x)
                cachorraoVelocity = 200;
		    else if (x > player.x)
                cachorraoVelocity = -200;
		    else 
                cachorraoVelocity = 0;
        }
		
        velocity.x = cachorraoVelocity;

		flipX = player.x > x;
	}
}