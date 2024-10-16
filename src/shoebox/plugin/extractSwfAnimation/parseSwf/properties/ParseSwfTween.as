package shoebox.plugin.extractSwfAnimation.parseSwf.properties
{
	/**
	 * ...
	 * @author renderhjs
	 */
	public class ParseSwfTween{
		public var fA:int=-1;//frame A
		public var fB:int=-1;//frame B
		
		public var tpA:TransformProperty;
		public var tpB:TransformProperty;
		
		
		
		public function setA(frame:int, transProperty:TransformProperty):void {
			fA = frame;
			tpA = transProperty;
		}
		public function setB(frame:int, transProperty:TransformProperty):void {
			fB = frame;
			tpB = transProperty;
		}
		/*
		public function startTween():void {
			
		}
		public function endTween():void {
			
			
		}
		*/
		
		
		
		public function ParseSwfTween() {
			
		}
		
	}

}