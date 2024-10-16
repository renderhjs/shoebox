package shoebox.plugin.extractSwfAnimation.parseSwf.properties
{
	/**
	 * ...
	 * @author Hendrik
	 */
	public class ParseSwfPropertyIds
	{
		static public var countVars:int = 5;//JUST X,Y for now
		
		static public var visible:int = 0;
		static public var x:int = 1;
		static public var y:int = 2;
		static public var rotation:int= 3;
		static public var alpha:int= 4;
		
		
		static private var strings:Array = ["visible","x", "y", "rotation", "alpha"];
		static public function string(id:int):String {
			return strings[id];
		}
		
		
		static public function getValue(id:int, tp:TransformProperty ):Number {
			//READ PROPERTY: x,y,rotation,alpha,...
			switch (id) {
				case visible:
					return tp.visible;
				case x:
					return tp.x;
				case y:
					return tp.y;
				case alpha:
					return tp.alpha;
				case rotation:
					return tp.rotation;
					break;
			}
			return 0;
		}
		
		
	}

}