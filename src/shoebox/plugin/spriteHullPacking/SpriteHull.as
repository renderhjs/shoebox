package shoebox.plugin.spriteHullPacking 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.sakri.flash.bitmap.MarchingSquares;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class SpriteHull
	{
		
		public var pts:Vector.<Point>;
		public var distance:Number = 0;
		
		public var angDiff:Vector.<Number>;
		public var rect:Rectangle;
		private var angDiffMax:Number = 0;//The maximum angle inwards or outwards
		
		public function SpriteHull(b:BitmapData) {
			var ext:BitmapData = new BitmapData(b.width + 2, b.height + 2, true, 0x00000000);
			ext.draw(b, new Matrix(1, 0, 0, 1, 1, 1));
			b = ext;
			
			rect = new Rectangle(0, 0, b.width, b.height);
			
			
			pts = MarchingSquares.getBlobOutlinePointsClockwise(b);
			
			//REDUCE OR SAMPLE POINTS
			distance = 0;
			
			var i:uint;
			var pts_smth:Vector.<Point> = new Vector.<Point>();
			var decimal:int = 2;
			for (i = 0; i < pts.length; i++) {
				if (i % decimal == 0) {
					pts_smth.push(pts[i]);
					
					//DISTANCE
					if (pts_smth.length > 1) {
						var d:Number = pts_smth[pts_smth.length - 1].subtract(pts_smth[pts_smth.length - 1 - 1]).length;
					
						distance += d;
						
						if (d < decimal*0.5) {
							pts_smth.splice(pts_smth.length - 1, 1)
							distance -= d;
						}
						
					}
					
				}
			}
			pts = pts_smth;
		}
		
		
		public function calcAngles():void {
			//FIND DIFFERENCE ANGLES
			var i:uint;
			
			var angMin:Number;
			var angMax:Number;
			angDiff = new Vector.<Number>();
			
			
			var ang_d:Number
			
			for (i = 0; i < pts.length; i++) {
				var ang_a:Number=0;//angle a = forward
				var ang_b:Number=0;//angle b = one back
				
			
				if (i == 0) {
					ang_a = fnGetAngle(pts[i], pts[i + 1]);
					ang_b = fnGetAngle(pts[pts.length-1], pts[i]);
				}else if (i == pts.length - 1) {
					ang_a = fnGetAngle(pts[i], pts[0]);
					ang_b = fnGetAngle(pts[i - 1], pts[i]);
				}else {
					ang_a = fnGetAngle(pts[i], pts[i + 1]);
					ang_b = fnGetAngle(pts[i - 1], pts[i]);
				}
				
				ang_d = Math.atan2( Math.sin(ang_a - ang_b), Math.cos(ang_a - ang_b));//difference angle
				
				
				if (i == 0) {
					angMax = angMin = ang_d;
				}else {
					angMin = Math.min(angMin, ang_d);
					angMax = Math.max(angMax, ang_d);
				}
				
				angDiff[i] = ang_d;
			}
			angDiffMax = Math.max( Math.abs(angMax), Math.abs(angMin));
		}
		public function limitByAngle(a:Number):void {
			//merge low thresholds, aka no differences
			
			a*= Math.PI / 180;//convert to radians
			
			var i:uint;
			var pts_reduce:Vector.<Point> = new Vector.<Point>();
			
			//var le:int = pts.length;
			
			for (i = 0; i < pts.length; i++) {
				if ( Math.abs(angDiff[i])  > a) {
					pts_reduce.push( pts[i]);
				}
			}

			pts = pts_reduce;
		}
		
		public function limitBySnap(rad:Number):void {
			var i:uint;
			var j:uint;
			
			//var snapped:Array = [];
			//var fin:Vector.<Point> = new Vector.<Point>();
			for (i = 0; i < pts.length; i++) {
				
				var dx:Number = 0;
				var dy:Number = 0;
				var snap:Array = [];
				for (j = 0; j < pts.length; j++) {
					var d:Number = pts[i].subtract(pts[j]).length;
					if (d <= rad) {
						snap.push(j);
						//snapped.push(j);
						dx += pts[j].x;
						dy += pts[j].y;
					}
				}
				//
				for (j = 0; j < snap.length; j++) {
					pts[snap[j]].x = dx / snap.length;
					pts[snap[j]].y = dy / snap.length;
				}
			}
			//keep only unique points in order
			var fin:Vector.<Point> = new Vector.<Point>();
			for (i = 0; i < pts.length; i++) {
				var found:Boolean = false;
				
				for (j = 0; j < fin.length; j++) {
					var B:Point = fin[j];
					if (B.x == pts[i].x && B.y == pts[i].y) {
						found = true;
						break;
					}
				}
				if (!found) {
					fin.push(pts[i]);
				}
			}
			pts = fin;
		}
		
		private function fnGetAngle(A:Point, B:Point):Number {
			var dx:Number = B.x - A.x;
			var dy:Number = B.y - A.y;
			return Math.atan2( dy, dx);
			//Math.atan2( dy,dx)*180/Math.PI; 
		}
		
		
		
		
	}

}