package ;

typedef PlayerData = {
	x: Float,
	y: Float,
	id: String
}

class Player extends flixel.FlxSprite {
	public var data:PlayerData = null;
	public var needsUpdating = false;
	public var targetx:Float = 0;
	public var targety:Float = 0;
	var localPlayer = false;
	
	public function new (_data:PlayerData,isLocalPlayer = false){
		super(_data.x,_data.y);
		makeGraphic(60,60);

		localPlayer = isLocalPlayer;

		targetx = x;
		targety = y;

		data = _data;
	}
	override public function update (elapsed:Float){		

		if (!localPlayer){
			x = targetx;
			y = targety;
		}

		if (localPlayer)
		{
			data.x = x;
			data.y = y;		
			
			Sys.sleep(0.01);
		}

		 super.update(elapsed);
	}

}
