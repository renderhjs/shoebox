package shoebox.plugin.extractTiles 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import shoebox.app.gui.UiPluginWindow;
	import shoebox.plugin.event.PluginClipBoardTransferEvent;
	import shoebox.plugin.event.PluginFileTransferEvent;
	import shoebox.plugin.extractTiles.properties.TileScan;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.PluginHelper;
	import tools.color.HSL;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class PluginExtractTiles extends PluginBase{
		[Embed(source="icon_48x48.png")]
		private var embd_bmp0:Class;
		
		private var stage:Stage;
		private var g:Graphics;
		private var shp:Shape = new Shape();
		public function PluginExtractTiles() {
			
			this.label = "Extract Tiles";
			this.icon = new embd_bmp0().bitmapData;//tool icon
			//this.settings = {outerClosure:"var a:Array=[*];",elementClosure:"'*'",elementSplit:",",includeSubFolders:false };
			this.settings = {tileWidth:16,tileHeight:16};
			this.settingsTemplates = [];
			
			this.extentions = ["png","gif","jpg"];
			this.settingsInfo = "Extracts unique tiles of mockup artworks";
			
			registerListenEventGetData(PluginFileTransferEvent.DATA_FILE_IN, fnListenData);
			registerListenEventGetData(PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_IMAGE, onClipBoardIn);
			
			g = shp.graphics;
		}
		private function fnListenData(e:PluginFileTransferEvent):void {
			if (e.files.length == 1) {
				PluginHelper.getFileBitmap(e.files[0], recieveBmpd);
			}
		}
		private function onClipBoardIn(e:PluginClipBoardTransferEvent):void {
			recieveBmpd(e.bitmapData);
		}
		private function recieveBmpd(b:BitmapData):void {
			var space:int = 8;
			var w:int = b.width;
			var h:int = b.height;
			
			stage = UiPluginWindow.init(w*2 + 3 * space, h + 2 * space);
			
			var bmp:Bitmap = new Bitmap(b);
			bmp.x = bmp.y = space;
			stage.addChild(bmp);
			stage.addChild(shp);
			
			shp.x = shp.y = space;
			searchMain(b);
		}
		
		private function displayTileBank(b:BitmapData, ts:TileScan):void {
			var sx:int = 8 * 2 + b.width;
			var sy:int = 8;
			
			
			var tw:int = ts.tw + 0;
			var th:int = ts.th + 0;
			
			var numX:int = Math.floor(b.width / tw);
			
			
			
			var i:int;var j:int;var k:int;
			for (i = 0; i < ts.ids.length; i++) {
				
				var x:int = i % (numX);
				var y:int = Math.floor( i / numX);
				
				var b2:BitmapData = new BitmapData(ts.tw, ts.th, false, 0xff0000);
				b2.copyPixels(b, ts.idsRect[i], new Point(0, 0));
				var bmp:Bitmap = new Bitmap(b2);
				
				bmp.x = x * tw+sx;
				bmp.y = y * th+sy;
				
				stage.addChild(bmp);
				
				
			}
		}
		
		private function searchMain(b:BitmapData):void {
			var tw:int = settings.tileWidth;//FROM THE SETTINGS
			var th:int = settings.tileHeight;
			
			var i:int;var j:int;var k:int;
			var ts:TileScan;
			var results:Array = [];
			var maxTileGroups:int = Math.floor((b.width) / tw) * Math.floor((b.height) / th);
			//var minToBeat:int =  Math.floor((b.width) / tw) * Math.floor((b.height) / th);
			var minToBeat:int =  0;
			for (i = 0; i < th; i++) {
				for (j = 0; j < tw; j++) {
					//ts = searchTileGrid(b, tw, th, j, i);
					ts = new TileScan(b, tw, th, j, i);
					//var quality:int = res.length;
					var quality:int = 0;
					
					var tmpMax:int = 0;
					for (k = 0; k < ts.counts.length; k++) {
						//if (res[k] > 1) {
						quality += (ts.counts[k] * ts.counts[k]);//the more the better
						tmpMax = Math.max(ts.counts[k], tmpMax);
					}
					
					quality *= (maxTileGroups - ts.counts.length);
					//quality = (maxTileGroups - res.length);
					//quality = tmpMax;
					
					
					if (quality > minToBeat) {
						//trace("quality " +quality);
						minToBeat = quality;
						
					}
					//results.push( {z:quality,sx:j,sy:i,le:ts.counts.length,max:tmpMax } );
					results.push( {z:quality,ts:ts } );
				}
			}
			
			
			results.sortOn("z", Array.NUMERIC);
			results.reverse();
			
			
			for (i = 0; i < Math.min(results.length,4); i++) {
				trace("quality: " + results[i].z + ", res.length: " + results[i].le+", max: "+results[i].max);
			}
			
			//trace("best: " + results[0].z+" out of: "+results.length);
			
			
			//drag GRID
			//results.
			g.clear();
			g.lineStyle(0, 0xff0000, 1);
			g.drawRect(0, 0, b.width, b.height);
			g.lineStyle(0, 0, 1);
			ts = results[0].ts;
			var sx:int = ts.sx;
			var sy:int = ts.sy;
			var ix:int = ts.ix;
			var iy:int = ts.iy;
			
			for (i = 0; i < iy; i++) {
				g.moveTo(0, i*th+sy);
				g.lineTo(b.width, i*th+sy);
			}
			for (i = 0; i < ix; i++) {
				g.moveTo(i*tw+sx,0);
				g.lineTo(i*tw+sx,b.height);
			}
			
			
			
			g.lineStyle();
			//draw colors
			var s:int = 2;
			for (i = 0; i < iy; i++) {
				for (j = 0; j < ix; j++) {
					try{
						var id:int = ts.tileId[i][j];
					}catch(e:Error){}
					//var c:int = id / ts.ids.length * 0xffffff;
					var c:int = HslColor(id / (ts.ids.length - 1));
					//g.beginFill(c, 1);
					//g.lineStyle(1, c, 1);
					
					
					var x:int = sx + j * tw;
					var y:int = sy + i * th;
					g.beginFill(0);
					g.drawRect(x, y, s + 2, s + 2);
					g.beginFill(c);
					g.drawRect(x + 1, y + 1, s, s);
					
					
					
					
					//g.drawRect(x + tw / 2 - s / 2, y + th / 2 - s / 2, s, s);
					
					
				}
			}
			
			
			
			displayTileBank(b, ts);
			
		}
		
		
		private function HslColor(p:Number):int {
			var rd:Number = Math.random();
			var hsl:HSL = new HSL(p *360.0, 1.0, 0.5);
			return hsl.toRGB().Hex;
		}
		
		/*
		private function searchTileGrid(b:BitmapData,tw:int, th:int,sx:int,sy:int):TileScan {
			
			//var sx:int = 0;//shift x
			//var sy:int = 0;
			
			return ;
			
		}
		
		*/
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	}

}