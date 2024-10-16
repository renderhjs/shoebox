package shoebox.plugin.extractSwfAnimation.parseSwf.properties
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class TransformProperty{
		
		//most properties are from DisplayObject
		//	http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/DisplayObject.html
		public var id:int;
		public var target:DisplayObject;
		
		
		public var visible:int;
		public var x:Number;
		public var y:Number;
		
		public var bounds:Rectangle;
		
		//public var width:Number;
		//public var height:Number;
		
		public var scaleX:Number;
		public var scaleY:Number;
		
		public var alpha:Number;
		public var rotation:Number;
		
		
		public function TransformProperty(idx:int, d:DisplayObject) {
			id = idx;
			x = d.x;
			y = d.y;
			
			bounds = d.getBounds(d);
			visible = d.visible ? 1 : 0;
			scaleX = d.scaleX;
			scaleY = d.scaleY;
			alpha  = d.alpha;
			rotation  = d.rotation;
			target = d;
		}
		
	}

}