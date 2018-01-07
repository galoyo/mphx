package ;
import mphx.server.impl.Server;

typedef Player = {
	x: Int,
	y: Int,
	id: String
}

class Main{
	public var players:Map<mphx.connection.IConnection,Player>;
	private var ip:String;
	private var s:Server;
	
	public function new (){

		players = new Map();
		
		ip = "127.0.0.1";
		s = new mphx.server.impl.Server(ip, 8000);
		
		if (Sys.args()[0] != null) ip = Sys.args()[0];

		s.events.on("Join",function(data:Dynamic,sender:mphx.connection.IConnection){

			players.set(sender,data);
			trace("A new player has joined from client.");
			s.broadcast("New Player",data);
		});

		s.events.on("Player Move",function (data,sender){
			var player = players.get(sender);
			player.x = data.x;
			player.y = data.y;
			s.broadcast("Player Move",player);
		});

		s.events.on("Update",function (data,sender){
			var player = players.get(sender);
		
			s.broadcast("Player Move",player);
		});

		s.events.on("Disconnect",function (data,sender){
			var player = players.get(sender);

			s.broadcast("Disconnect",player);
		});

				
		s.start();
		
	}
	
	function makeID () {
		var id = "";
		var charactersToUse = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		for (i in 0...6)
		{
			id += charactersToUse.charAt(Math.floor(Math.random()*charactersToUse.length));
		}
		return id;
	}

	public static function main (){
		new Main();
	}
}
