package shoebox.plugin.cutSprites 
{
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class RectPack{
		public var width:int;
		public var height:int;
		public var x:int;
		public var y:int;
		public var sourceIdx:int = 0;
		public var volSort:Number = 0;
		
		public var uvWidth:int;
		public var uvHeight:int;
		
		public function RectPack(x:int, y:int, width:int, height:int,padding:int, sourceIdx:int) {
			this.width = width+padding;
			this.height = height+padding;
			this.x = x;
			this.y = y;
			this.sourceIdx = sourceIdx;
			
			this.uvWidth = width;
			this.uvHeight = height;
			
			volSort = width + height;//sort based on this
		}
		public function get rect():Rectangle {
			return new Rectangle(x, y, width, height);
		}
		
		
	}

}