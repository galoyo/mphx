package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import openfl.Lib;

import Player;


/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var clientSocket:mphx.client.Client;
	private var ownPlayer:FlxSprite;
	public var allPlayers:FlxGroup;
	private var _finalUpdate:Bool = false;
	private var player:Player;
	private var players = new Map<String,Player>();
	
	private var i:Int = 0;
	private var ii:Int = 0;
	
	override public function create():Void
	{
		super.create();

		trace("Start of playstate");

		FlxG.autoPause = false;

		allPlayers = new FlxGroup();
		add(allPlayers);
		
		var playerData:PlayerData = 
		{
			x: Math.floor(FlxG.width*Math.random()),
			y: Math.floor(FlxG.height*Math.random()),
			id: "player"+Math.random()*10000
		};

		player = new Player(playerData, true);
		player.visible = false;
			
		allPlayers.add(player);
		players.set(playerData.id, player);
			
		try{
			clientSocket = new mphx.client.Client(GameData.ip,GameData.port);

			clientSocket.onConnectionError = function (s)
			{
				FlxG.switchState(new MenuState());
				trace(s);
				return;
			}				
		
			clientSocket.connect();			
			clientSocket.send("Join", playerData);
			
		}	
		
		catch (e:Dynamic)
		{
			trace(e);			
		}		

		clientSocket.events.on("New Player", function (data) {

			if (players.exists(data.id)) 
			{
				player.visible = true;
				return;
			}

			var player = new Player(data);
			allPlayers.add(player);

			players.set(data.id, player);
			
			clientSocket.send("Update",player.data);

		});

		clientSocket.events.on("Player Move",function (data){
			if (data.id == player.data.id) return;

			if (players.exists(data.id) == false){
				var player = new Player(data);
				allPlayers.add(player);

				players.set(data.id,player);
			}

			var player = players.get(data.id);
			player.data = data;

			player.targetx = player.data.x;
			player.targety = player.data.y;
		});
		
			clientSocket.events.on("Update",function (data){
			if (data.id == player.data.id) return;

			if (players.exists(data.id) == false){
				var player = new Player(data);
				allPlayers.add(player);

				players.set(data.id,player);
			}

			var player = players.get(data.id);
			player.data = data;

			player.targetx = player.data.x;
			player.targety = player.data.y;
			
		});
		
		clientSocket.events.on("Disconnect",function (data){
			//if (data.id == player.data.id) return;

			var player = players.get(data.id);
			allPlayers.remove(player);

		});	
	}


	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.pressed.UP)
		{
			player.y -= 6; i = 0; 
			player.needsUpdating = true;
		}
		if (FlxG.keys.pressed.DOWN)
		{
			player.y += 6; i = 0; 
			player.needsUpdating = true;
		}
		if (FlxG.keys.pressed.LEFT)
		{
			player.x -= 6; i = 0; 
			player.needsUpdating = true;
		}
		if (FlxG.keys.pressed.RIGHT)
		{
			player.x += 6; i = 0; 
			player.needsUpdating = true;
		}

		if (player.needsUpdating){ //Once every second  frames
			
			clientSocket.send("Player Move",player.data);
			i = 0; 
			
			if (_finalUpdate == true) {ii = 10; _finalUpdate = false;}
			else _finalUpdate = true;
			
			player.needsUpdating = false;
		}
		
		
		if (i > 0 && ii == 10 && player.needsUpdating == false)
		{
			ii = 0;
			clientSocket.send("Player Move", player.data);
		}
		
		i++;
		
		clientSocket.onConnectionClose = function (error:mphx.utils.Error.ClientError)
		{
			clientSocket.close();
			FlxG.switchState(new MenuState());
		}
		
		setExitHandler(function() {
    clientSocket.send("Disconnect", player.data);
});
		
		clientSocket.update();
		super.update(elapsed);
	}
	
	
	

	public static function setExitHandler(func:Void->Void):Void {
		#if openfl_legacy
		openfl.Lib.current.stage.onQuit = function() {
			func();
			openfl.Lib.close();
		};
		#else
		openfl.Lib.current.stage.application.onExit.add(function(code) {
			func();
		});
		#end
	}
}
