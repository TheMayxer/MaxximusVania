package characters;

class Lobao extends Character
{
    public var lobaoFicaParado:Bool = false;
    public var lobaoPodeLevarDano:Bool = true;

    public function new(x:Float, y:Float) {
        super(x,y,'cachorrao',10);
    }
}