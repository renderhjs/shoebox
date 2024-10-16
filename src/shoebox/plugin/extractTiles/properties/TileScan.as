package shoebox.plugin.extractTiles.properties 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Hendrik
	 */
	public class TileScan
	{
		
		public var sx:int = 0;
		public var sy:int = 0;
		
		public var tw:int;
		public var th:int;
		
		public var ix:int;
		public var iy:int;
		
		public var ids:Vector.<int> = new Vector.<int>();
		public var counts:Vector.<int> = new Vector.<int>();
		public var idsRect:Vector.<Rectangle> = new Vector.<Rectangle>();	
		public var tileId:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
		
		
		public function TileScan(b:BitmapData, tw:int,th:int, sx:int,sy:int) {
			this.sx = sx;
			this.sy = sy;
			this.tw = tw;
			this.th = th;
			
			ix = Math.floor((b.width-sx) / tw);//i-num x
			iy = Math.floor((b.height-sy) / th);
			
			var i:int; var j:int; var k:int;
			for (i = 0; i < iy; i++) {
				
				tileId[i] = new Vector.<int>();
				
				for (j = 0; j < ix; j++) {
					var x:int = j * tw + sx;
					var y:int = i * th + sy;
					
					if ( x+(tw-1) <= b.width && y+(th-1) <= b.width){
						
						
						var pix:Vector.<uint> = b.getVector(new Rectangle(x, y, tw, th));
						var uid:int = 0;
						for (k = 0; k < pix.length; k++) {
							uid += pix[k];
						}
						
						
						
						var idx:int = ids.indexOf(uid);
						if ( idx == -1) {
							//trace("pix: " + pix);
							ids.push(uid);
							counts.push(1);
							idsRect.push( new Rectangle(x, y, tw, th));
							idx = ids.length-1;
						}else {
							counts[idx] += 1;
						}
						
						tileId[i][j] = idx;
						
						
					}	
	
				}
			}
			
			
			
			
			
			
			/*
			var ix:int = Math.floor((b.width-sx) / tw);//i-num x
			var iy:int = Math.floor((b.height-sy) / th);
			
			//var arrayIds:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
			var arrayIds:Vector.<int> = new Vector.<int>();
			var arrayCnt:Vector.<int> = new Vector.<int>();
			
			var i:int; var j:int; var k:int;
			for (i = 0; i < iy; i++) {
				for (j = 0; j < ix; j++) {
					var x:int = j * tw + sx;
					var y:int = i * th + sy;
					
					if ( x+(tw-1) <= b.width && y+(th-1) <= b.width){
						
						
						var pix:Vector.<uint> = b.getVector(new Rectangle(x, y, tw, th));
						//var pix:Vector.<uint> = b.getVector(new Rectangle(x, y, 1, 1));
						var uid:int = 0;
						for (k = 0; k < pix.length; k++) {
							uid += pix[k];
						}
						
						
						
						var idx:int = arrayIds.indexOf(uid);
						if ( idx == -1) {
							//trace("pix: " + pix);
							arrayIds.push(uid);
							arrayCnt.push(1);
						}else {
							arrayCnt[idx] += 1;
						}
					}	
	
				}
			}
			
			*/
			
			
			
			
			
			
			
			
			
			
			
			
			
		}
		
		//public function sca
		
		
	}

}