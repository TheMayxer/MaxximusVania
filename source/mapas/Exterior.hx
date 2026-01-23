package mapas;

import characters.Lobao;
import characters.Player;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class Exterior extends MapaMainState
{
    //var enemyHealth:Int = 10;
    var lobao:Lobao;
    var machado:ArmaLetal;
    static var lobaoJaMorreu:Bool = false;

    public function new() {
        super(
            null, Sala.new,
            [1300,800],
            'exterior',
            ['fundo','castelo','arvores-bemproxima','door', 'layer-paredes'],
            ['arvores-fundo','castelo-fundo','arvore-muitoproxima','door', 'parede_chao'],
            4,
            new FlxPoint(100,400),
            0
        );
    }

    override function create() {

        FlxG.camera.bgColor = FlxColor.fromInt(0xFF1A1224);
        var nuvens = new FlxBackdrop(Paths.image('mapas/exterior/nuvem'),X,1.5);
        nuvens.velocity.x = -100;
        add(nuvens);
        
        super.create();

        if(!PlayerVars.temMachado)
        {
            machado = new ArmaLetal('machado',4);
            machado.setPosition(player.x + player.width + 30, 400);
            machado.acceleration.y = 1500;
            add(machado);
        }

        if(!lobaoJaMorreu)
        {
            lobao = new Lobao(0,0);
		    lobao.setPosition(FlxG.width - lobao.width * 2, FlxG.height*0.2);
		    add(lobao);
        }
        
    }

    override function update(elapsed:Float) {
        super.update(elapsed);


        if(!PlayerVars.temMachado)
        {
            FlxG.collide(machado, objectsMapGroup.members[objectToCollide]);

            if(player.overlaps(machado))
            {
                machado.destroy();
                PlayerVars.temMachado = true;
            }
        }
        
        if(lobao.alive && !lobaoJaMorreu)
        {
            FlxG.collide(lobao,objectsMapGroup.members[objectToCollide]);
            cachorraoMoviments(elapsed,lobao);
            FlxG.overlap(player,lobao,function(player:Player, lobao:Lobao) {
			    if (PlayerVars.podeLevarDano)
			    { 
                    healthDamage(player, 10);
				    PlayerVars.podeLevarDano = false;
				    new FlxTimer().start(1,(_)->PlayerVars.podeLevarDano = true);
			    }
		    });
        }

        if(!lobaoJaMorreu && lobao.health <= 0 && lobao.alive)
        {
            lobaoJaMorreu = true;
            lobao.kill();
        }
            
        for(arma in armasGroup.members)
		{
			if(!lobaoJaMorreu && arma.overlaps(lobao) && lobao.alive)
			{
                if(!arma.deuDano)
                {
                    if(arma.name!= 'espada')
                        cachorroDanoStuff(arma,lobao);
                    else if(arma.visible)
                        cachorroDanoStuff(arma,lobao);
                }
			}
		}   
    }
}