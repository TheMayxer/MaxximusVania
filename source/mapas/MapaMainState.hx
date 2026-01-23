package mapas;

import characters.*;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.NextState;

class MapaMainState extends FlxState
{
    public var mapLoader:FlxOgmo3Loader;
    public var objectsMapGroup:FlxTypedGroup<FlxTilemap>;
    public var armasGroup:FlxTypedGroup<ArmaLetal>;
    public var espada:ArmaLetal;
    public var camFollow:FlxObject;

    ////////////////////////////////////////////////////
    ////////coisas relacionadas ao state-principal//////////
    ///////////////////////////////////////////////////

    public var mapName:String = '';
    public var mapLayers:Array<String> = [];
    public var mapImages:Array<String> = [];
    public var playerPositions:FlxPoint = new FlxPoint(0,0);
    public var mapSize:Array<Float> = [0,0];
    public var prevState:NextState;
    public var nextState:NextState;
    public var objectToCollide:Int = 0;
    public var mapID:Int = 0;

    public var player:Player;

    public function new(prevState:NextState, nextState:NextState, mapSize:Array<Float>, mapName:String, mapLayers:Array<String>, mapImages:Array<String>, objectToCollide:Int, playerPositions:FlxPoint, mapID:Int) {
        super(); //nomes auto explicativos
        this.prevState = prevState;
        this.nextState = nextState;
        this.mapSize = mapSize;
        this.mapName = mapName;
        this.mapLayers = mapLayers;
        this.mapImages = mapImages; 
        this.objectToCollide = objectToCollide;
        this.playerPositions = playerPositions;
        this.mapID = mapID;
    }

    override function create() {
        super.create();

        FlxG.worldBounds.set(0,0,mapSize[0],mapSize[1]);

        mapLoader = new FlxOgmo3Loader(Paths.ogmo('data/mapas/$mapName/$mapName'),Paths.json('data/mapas/$mapName/$mapName'));

        objectsMapGroup = new FlxTypedGroup<FlxTilemap>();
        add(objectsMapGroup);

        if(mapLayers.length > 0 && mapImages.length > 0)
        {
            for(i in 0...mapLayers.length)
            {
                var object = mapLoader.loadTilemap(Paths.image('mapas/$mapName/${mapImages[i]}'),mapLayers[i]);
                objectsMapGroup.add(object);
            }
        }

        objectsMapGroup.members[objectToCollide].immovable = true;

        player = new Player(playerPositions.x,playerPositions.y);
        add(player);

        camFollow = new FlxObject(player.x,player.y,1,1);
        add(camFollow);

        FlxG.camera.follow(camFollow, NO_DEAD_ZONE, 0.06);
        FlxG.camera.setScrollBoundsRect(0,0,mapSize[0],mapSize[1]);

        armasGroup = new FlxTypedGroup<ArmaLetal>();
        add(armasGroup);

        espada = new ArmaLetal('espada',2);
        espada.visible = false;
        espada.animation.onFinish.add(function(animName:String) {
			espada.visible = false;
			espada.deuDano = false;
			espada.updateHitbox();
		});
        armasGroup.add(espada);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(nextState!=null && FlxG.keys.justPressed.K)
            FlxG.switchState(nextState);

        if(prevState!=null && FlxG.keys.justPressed.J)
            FlxG.switchState(nextState);

        FlxG.collide(player, objectsMapGroup.members[objectToCollide]);
        camFollow.setPosition(player.x + 50,player.y);
            
        if(player.isTouching(DOWN) && (FlxG.keys.justPressed.SPACE||FlxG.keys.justPressed.W))
			player.velocity.y = -700;

        tacarMachado();
        abaterComEspada();
        tacarFaquinha();

    }

    public function tacarMachado() {
		if(PlayerVars.temMachado && FlxG.keys.justPressed.E)
		{
			var machado = new ArmaLetal('machado',4);
			machado.setPosition(player.x + player.width/2 - machado.width/2, player.y);
			machado.velocity.set(player.flipX ? -180 : 180,-900);
			machado.acceleration.y = 1600;
			machado.angularVelocity = player.flipX ? -900: 900;
			machado.ID = 99;
			armasGroup.add(machado);

			PlayerVars.podeTacaOMachado = false;
			new FlxTimer().start(1,(_)->PlayerVars.podeTacaOMachado = true);
		}
	}

    public function tacarFaquinha()
    {
        if(PlayerVars.podeTacaFaquinha && FlxG.mouse.justPressedRight)
        {
            var faquinha = new ArmaLetal('faquinha',2);
            faquinha.setPosition(player.x + player.width/2 - faquinha.width/2, player.y + player.height/2 - faquinha.height/2);
            faquinha.velocity.x = (player.flipX ? - 1100 : 1100);
            faquinha.flipX = player.flipX;
            armasGroup.add(faquinha);

            PlayerVars.podeTacaFaquinha = false;
            new FlxTimer().start(0.5, (_)->PlayerVars.podeTacaFaquinha = true);
        }
    }

    public function abaterComEspada()
	{
        if(!PlayerVars.temEspada) return;

        espada.setPosition((player.flipX ? player.x-60 : player.x+60), player.y+player.height/2 - espada.height/2);
		espada.flipX = player.flipX;

		if(FlxG.mouse.justPressed && PlayerVars.podeAtacarComEspada)
		{
			PlayerVars.podeAtacarComEspada = false;
			espada.visible = true;
			espada.animation.play('attack');
			new FlxTimer().start(0.5,(_)->PlayerVars.podeAtacarComEspada = true);
		}
	}

    public function healthDamage(object:Character, amount:Int) {
        if(object.colorTween.active)
            object.colorTween.cancel();
        if(object.shakeTween.active)
            object.shakeTween.cancel();

        object.colorTween.start();
        object.shakeTween.start();

        object.scale.set(FlxG.random.float(0.8,1.2),FlxG.random.float(0.8,1.2));

        object.health -= amount;
        var text = new FlxText(object.x,object.y,0,Std.string(amount),40);
        text.color = FlxColor.RED;
        text.setPosition(object.x + object.width/2 - text.width/2, object.y);
        FlxTween.tween(text,{y:text.y - 60}, 2, {onComplete:(_)->text.destroy()});
        insert(members.indexOf(object),text);
    }

    public function cachorroDanoStuff(arma:ArmaLetal, lobao:Lobao) {

        if(arma.name == 'faquinha')
            arma.destroy();

        healthDamage(lobao, arma.dano);
		lobao.health -= arma.dano;
		lobao.lobaoPodeLevarDano = false;
		arma.deuDano = lobao.lobaoFicaParado= true;

		lobao.scale.set(FlxG.random.float(0.8,1.2),FlxG.random.float(0.8,1.2));
		FlxTween.cancelTweensOf(lobao);
		FlxTween.color(lobao,0.7, FlxColor.RED, FlxColor.WHITE);
		new FlxTimer().start(0.5,(_)->lobao.lobaoFicaParado = false);
		new FlxTimer().start(1,(_)->lobao.lobaoPodeLevarDano = true);
	}

    public function cachorraoMoviments(e:Float, lobao:Lobao) {

		var cachorraoVelocity:Float = 0;
        if(!lobao.lobaoFicaParado)
        {
            if(lobao.x < player.x)
                cachorraoVelocity = 200;
		    else if (lobao.x > player.x)
                cachorraoVelocity = -200;
		    else 
                cachorraoVelocity = 0;
        }
		
        lobao.velocity.x = cachorraoVelocity;

		lobao.flipX = player.x > lobao.x;
	}
}