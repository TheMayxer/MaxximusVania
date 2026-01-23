package mapas;

import flixel.math.FlxPoint;
import flixel.util.FlxCollision;

class Sala extends MapaMainState
{
    public function new() {
        super(
            Exterior.new, null,
            [2600, 800],
            'sala',
            ['janelas_fodas','doors','paredes_chao'],
            ['janelas-tiles','door','paredes_chao'],
            2,
            new FlxPoint(400,200),
            1
        );
    }

    override function create() {
        super.create();
    }
}