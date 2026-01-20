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

class MapaMainState extends FlxState
{
    public var mapLoader:FlxOgmo3Loader;
    public var objectsMapGroup:FlxTypedGroup<FlxTilemap>;
    public var armasGroup:FlxTypedGroup<ArmaLetal>;
    public var espada:ArmaLetal;

    public var mapName:String = '';
    public var mapLayers:Array<String> = [];
    public var mapImages:Array<String> = [];
    public var playerPositions:FlxPoint = new FlxPoint(0,0);
    public var objectToCollide:Int = 0;

    public var player:Player;

    public function new(mapName:String, mapLayers:Array<String>, mapImages:Array<String>, objectToCollide:Int, playerPositions:FlxPoint) {
        super(); //nomes auto explicativos
        this.mapName = mapName;
        this.mapLayers = mapLayers;
        this.mapImages = mapImages; 
        this.objectToCollide = objectToCollide;
        this.playerPositions = playerPositions;
    }

    override function create() {
        super.create();

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

        FlxG.collide(player, objectsMapGroup.members[objectToCollide]);
        player.scale.set(FlxMath.lerp(player.scale.x, 1, elapsed*7),FlxMath.lerp(player.scale.y, 1, elapsed*7));
            
        if(player.isTouching(DOWN) && FlxG.keys.justPressed.SPACE||FlxG.keys.justPressed.W)
			player.velocity.y = -400;

        tacarMachado();
        abaterComEspada();

    }

    public function tacarMachado() {
        if(!player.temMachado) return;

		if(player.podeTacaOMachado && FlxG.keys.justPressed.E)
		{
			var machado = new ArmaLetal('machado',4);
			machado.setPosition(player.x + player.width/2 - machado.width/2, player.y);
			machado.velocity.set(player.flipX ? -180 : 180,-900);
			machado.acceleration.y = 1600;
			machado.angularAcceleration = FlxG.random.float(-250,250);
			machado.ID = 99;
			armasGroup.add(machado);

			player.podeTacaOMachado = false;
			new FlxTimer().start(1,(_)->player.podeTacaOMachado = true);
		}
	}

    public function abaterComEspada()
	{
        if(!player.temEspada) return;

        espada.setPosition((player.flipX ? player.x-60 : player.x+60), player.y+player.height/2 - espada.height/2);
		espada.flipX = player.flipX;

		if(FlxG.mouse.justPressed && player.podeAtacarComEspada)
		{
			player.podeAtacarComEspada = false;
			espada.visible = true;
			espada.animation.play('attack');
			new FlxTimer().start(0.5,(_)->player.podeAtacarComEspada = true);
		}
	}

    public function healthDamageText(object:FlxObject, amount:Int) {
        var text = new FlxText(object.x,object.y,0,Std.string(amount),40);
        text.color = FlxColor.RED;
        text.setPosition(object.x + object.width/2 - text.width/2, object.y);
        FlxTween.tween(text,{y:text.y - 60}, 2, {onComplete:(_)->text.destroy()});
        insert(members.indexOf(object),text);
    }
}