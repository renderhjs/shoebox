package shoebox.plugin.cutSprites 
{
	import flash.geom.Matrix;
	import shoebox.app.gui.UiPluginWindow;
	import shoebox.plugin.event.PluginFileTransferEvent;
	import shoebox.plugin.PluginBase;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import shoebox.plugin.PluginHelper;
	import tools.color.HSL;
	import tools.txtTools.TxtTools;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class PluginCutSprites extends PluginBase{
		[Embed(source="icon_48x48.png")]
		private var embd_bmp0:Class;
		
		public function PluginCutSprites() {
			this.label = "Slice Sprites";
			this.icon = new embd_bmp0().bitmapData;//tool icon
			//this.settings = {minClusterSize:4,maxClusters:250,mergeSubClusters:true,fileName:"abc_###_@.png",baseLine:true,varNames:"ABCDEFGHIJKLMNOPQRSTUVWXYZ!?-012345678901234567890123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.!?-%$-:-,01234567890123456789:0123456789,",varNamesSplit:""};
			this.settings = {minClusterSize:4,maxClusters:250,mergeSubClusters:true,fileName:"slice##_@.png",baseLine:false,varNames:"01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24",varNamesSplit:","};
			//this.settingsInfo = "Cuts images into sprite blobs based on transparency bounds. MinClusterSize determines the minimal size of what a cluster can be in ^2. MaxClusters limits the maximum clusters that can be exported. For FileName use * for the name and # for the enumerator digits.";
			this.settingsInfo = "MinClusterSize determines the minimal size of a cluster ^2. For FileName use '*' for the name and '#' for the enumerator digits. '@' uses the varNames that are split with the varNamesSplit string (empty = per single character split).";
			this.settingsTemplates = [];
			this.extentions = ["jpg", "gif", "png"];
			
			this.settingsTemplates.push(["abcABC123.", {minClusterSize:4,maxClusters:200,mergeSubClusters:true,fileName:"font##_@.png",baseLine:false,varNames:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012345678.",varNamesSplit:""} ]);
			
			
			
			registerListenEventGetData(PluginFileTransferEvent.DATA_FILE_IN, fnListenData);
		}
		
		
		private var stage:Stage;
		private var space:int = 10;
		
		private var bmpdOrg:BitmapData;
		private var bmpdMsk:BitmapData;
		
		private var fileReference:File = null;//reference to where this file is saved
		private function fnListenData(e:PluginFileTransferEvent):void {
			fileReference = null;
			
			if (e.files.length > 0) {
				fileReference = e.files[0];
				loadImage(e.files[0],fnSubLoaded );
			}
			
			function fnSubLoaded(bmpd:BitmapData):void {
				
				
				
				findBlobs(bmpd);
				
			}
		}
		
		private function fnSaveFinalResult():void {
			if (fileReference != null) {
				for (var i:int = 0; i < bmpdFinals.length; i++) {
					var url:String = fnGetFileURL(i);
					PluginHelper.setFileBitmap(url, bmpdFinals[i]);
				}
			}
		}
		
		private function fnGetFileName(nr:int):String {
			var url:String = fnGetFileURL(nr);
			return url.slice(url.lastIndexOf("\\") + 1, url.length);
		}
		
		private function fnGetFileURL(nr:int):String {
			
			
			
			
			var variableNames:Array = settings.varNames.split(settings.varNamesSplit);//custom variables
			
			var f:String = fileReference.parent.nativePath;
			var n:String = fileReference.name.slice(0, fileReference.name.lastIndexOf("."));
			var ptrn:String = this.settings.fileName;
			var numDig:int = ptrn.length - ptrn.split("#").join("").length;
			ptrn = ptrn.split("#####").join("#");
			ptrn = ptrn.split("####").join("#");
			ptrn = ptrn.split("###").join("#");
			ptrn = ptrn.split("##").join("#");
			
			var nNew:String = ptrn.split("*").join(n);
			if (nr < variableNames.length){
				nNew = nNew.split("@").join(variableNames[nr]);
			}
			nNew = f + "\\" + nNew.split("#").join( formatInt(nr + 1, numDig));
	
			return nNew;
		}
		
		
		
		private function findBlobs(bmpd:BitmapData):void {
			//EXTEND CANVAS TO DETECT BLOBS AT EDGES
			bmpdOrg = bmpd.clone();
			bmpd = new BitmapData(bmpd.width + 4, bmpd.height + 4, true, 0x00000000);
			bmpd.draw(bmpdOrg, new Matrix(1, 0, 0, 1, 2, 2));
			bmpdOrg = bmpd.clone();
			
			
			
			
			//find blobs
			var bAlpha:BitmapData = fnGetMaskMatte(bmpd);
			bmpdMsk = bAlpha.clone();//the original Alpha BitmapData
			
			bAlpha = fnGetThresholdMask(bAlpha);

			
			

			var rects:Vector.<Rectangle> = new Vector.<Rectangle>();//blob rectangles
			var masks:Vector.<BitmapData> = new Vector.<BitmapData>();
			var FLOOD_FILL_COLOR:int = 0xffff0000;//RED
			var PROCESSED_COLOR:int = 0xff00ff00;//GREEN
			var i:int;
			
			var maxWidth:int = bAlpha.width;
			var maxHeight:int = bAlpha.height;
			var mainRect:Rectangle;
			while (i < settings.maxClusters) {
				
				mainRect = bAlpha.getColorBoundsRect(0xffffffff, 0xffffffff);
				if (mainRect.isEmpty()) break;
				
				var x:int = mainRect.x;
				for (var y:uint = mainRect.y; y < mainRect.y + mainRect.height; y++){  
					if (bAlpha.getPixel32(x, y) == 0xffffffff)  {  
						bAlpha.floodFill(x, y, FLOOD_FILL_COLOR);// fill it with some color  
						var blobRect:Rectangle = bAlpha.getColorBoundsRect(0xffffffff, FLOOD_FILL_COLOR); // get the bounds of the filled area - this is the blob
			  
						// check if it meets the min and max width and height  
						if (blobRect.width > settings.minClusterSize && blobRect.width < maxWidth && blobRect.height > settings.minClusterSize && blobRect.height < maxHeight)  {  
							
							if (rects.indexOf(blobRect) == -1){
							
								
								var msk:BitmapData = new BitmapData(blobRect.width, blobRect.height, false, 0xff000000);
								msk.copyPixels(bAlpha, blobRect, new Point());
								masks.push(msk);
								rects.push(blobRect);
							}
						}
						bAlpha.floodFill(x, y, PROCESSED_COLOR);  // mark blob as processed with some other color  
					}  
				}  
			  
				// increase number of detected blobs  
				i++; 
			}
			
			
			
			//REMOVE DOUBLE ENTRIES
			
			
			
			
			//MERGE SHAPES
			if (settings.mergeSubClusters) {
				var j:int;
				var rects2:Vector.<Rectangle> = new Vector.<Rectangle>();//blob rectangles
				var masks2:Vector.<BitmapData> = new Vector.<BitmapData>();
				var inside:Array = [];
				for (i = 0; i < rects.length; i++) {
					if (inside.indexOf(i) == -1) {
						
						var hasSub:Boolean = false;
						
						for (j = i+1; j < rects.length; j++) {
							if (i != j && inside.indexOf(j) == -1) {
								var recA:Rectangle = rects[i];
								var recB:Rectangle = rects[j];
								
								if (recA.containsRect(recB)) {
									trace("check merge: " + i, j);
									inside.push(j);
									hasSub = true;
									
									var bMask:BitmapData = new BitmapData(recA.width, recA.height, false, 0);
									bMask.copyChannel(bAlpha, recA, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.RED);//red means valid alpha
									rects2.push( recA );
									masks2.push( bMask);
									break;
								}
							}
						}
						if (!hasSub) {//DOESN'T have a sub element, so just copy regulary
							rects2.push( rects[i]);
							masks2.push( masks[i]);
						}
						
					}
				}
				rects = rects2;
				masks = masks2;
			}
			
			
			displayResults(rects, masks);
		}
		
		
		
		
		private function getBaseGridMatchIDs(rects:Vector.<Rectangle>, lines:Vector.<int>):Vector.<int> {
			
			var alignBottom:Boolean = true;
			var rad:int = 32;var d:int;
			var j:int; var i:int;
			
			var ret:Vector.<int> = new Vector.<int>();
			
			for (i = 0; i < rects.length; i++) {
				ret[i] = 0;
				for (j = 0; j < lines.length; j++) {
					d = Math.abs( lines[j] - getBaseGridComparePos(rects[i]) );
					if (d < rad) {
						ret[i] = j;
						break;
					}
				}
			}
			return ret;
		}
		private function getBaseGridComparePos(r:Rectangle,alignBottom:Boolean=true):Number {
			if (alignBottom) {
				return r.y + r.height;
			}else {
				return r.y;
			}
		}
		
		private function getBaseGridLines(rects:Vector.<Rectangle>):Vector.<int> {
			
			var alignBottom:Boolean = true;
			
			var rad:int = 32;var d:int;
			var yLines:Vector.<int> = new Vector.<int>();//y lines
			
			var j:int; var i:int;
			for (i = 0; i < rects.length; i++) {
				
				var found:Boolean = false;
				//CHECK FIRST IF IT MATCHES A EXISTING LINE
				for (j = 0; j < yLines.length; j++) {
					d = Math.abs( yLines[j] - getBaseGridComparePos(rects[i]) );
					if (d < rad) {
						if (alignBottom){
							yLines[j] = Math.max( yLines[j], getBaseGridComparePos(rects[i]));
						}else {
							yLines[j] = Math.min( yLines[j], getBaseGridComparePos(rects[i]));
						}
						found = true;
						break;
					}
				}
				//-------------------------------------------
				if (!found) {
					found = false;
					for (j = 0; j < rects.length; j++) {
						if (j != i) {
							d = Math.abs( getBaseGridComparePos(rects[i]) - getBaseGridComparePos(rects[j]) );
							if (d <= rad) {
								found = true;
								if (alignBottom){
									yLines.push( Math.max( getBaseGridComparePos(rects[j]), getBaseGridComparePos(rects[i]))	);
								}else {
									yLines.push( Math.min( getBaseGridComparePos(rects[j]), getBaseGridComparePos(rects[i]))	);
								}
								break;
							}
						}
					}
					if (!found) {
						yLines.push( getBaseGridComparePos(rects[i]));
					}
				}
			}
			
			trace("lines: " + yLines.length);
			return yLines;
		}
		
		
		private function displayResults(rects:Vector.<Rectangle>,masks:Vector.<BitmapData>):void {
		
			var i:int;
			
			var s:Number = 1.0;
			
			var sizes:Array = [];
			var sort:Array = [];
			//sort??
			
			var clusterSize:int = 32;
			
			
			/*
			var lineHeights:Vector.<Point> = new Vector.<Point>();
			var maxLines:int = 0;
			for (i = 0; i < rects.length; i++) {
				var ys:Number = Math.floor(rects[i].y / clusterSize);
				maxLines = Math.max(ys, maxLines);
			}
			trace("max lines: "+maxLines);
			*/
			
			var yLines:Vector.<int> = getBaseGridLines( rects );//Y positions
			
			//sort yLinesMatches
			sort = [];
			var refr:Array = [];
			for (i = 0; i < yLines.length; i++) {
				sort[i]  = refr[i] = yLines[i];
			}
			sort.sort(Array.NUMERIC);
			for (i = 0; i < yLines.length; i++) {
				yLines[i]  = sort[i];
			}
			trace("sort: " + yLines);
			
			var yLinesMatches:Vector.<int> = getBaseGridMatchIDs(rects, yLines);
			
			
			
			
			
			
			
			
			
			
			sort = [];
			
			
			for (i = 0; i < rects.length; i++) {
				//var snapY:Number = Math.floor(rects[i].y / clusterSize);
				var snapY:Number = yLinesMatches[i];
				var sz:Number = Math.floor(rects[i].y * bmpdOrg.width) + rects[i].x;//scanline position sorting
				sz = snapY * bmpdOrg.width + rects[i].x;
				sizes.push( sz);
				sort.push( sz);
			}
			sort.sort(Array.NUMERIC);
			
			
			
			
			var msg:String = "Save "+fnGetFileName(0)+" ... "+fnGetFileName(rects.length+1)+" ?";
			stage = UiPluginWindow.init((bmpdOrg.width) + 2 * space, (bmpdOrg.height) + 2 * space, msg,fnSaveFinalResult);
			
			
			
			var shape:Shape = new Shape();
			stage.addChild(shape);
			
			trace("SETTINGS B: >" + settings.varNamesSplit + "<");
			
			var variableNames:Array = settings.varNames.split(settings.varNamesSplit);//custom variables
			bmpdFinals = new Vector.<BitmapData>();
			var x:int = space;
			var y:int = bmpdOrg.height*0.5 + space * 2;
			var maxH:int = 0;
			
			for (i = 0; i < rects.length; i++) {
				//var bAlpha:BitmapData = fnGetFilteredChannelColor(masks[i].clone(), BitmapDataChannel.RED);
				
				var idx:int = i;
				idx = sizes.indexOf(sort[i]);

				
				var mask:BitmapData = fnGetFilteredChannelColor(masks[idx].clone(), BitmapDataChannel.RED);
				
				//MASK OUT with original alpha
				var bAlpha:BitmapData = mask.clone();
				bAlpha.copyPixels(bmpdMsk, rects[idx], new Point());
				bAlpha.draw(mask, null, null, BlendMode.MULTIPLY);
				
				//shift vertical values
				var sH:int = 0;
				var sY:int = 0;
				if (settings.baseLine) {
					sH += yLines[yLinesMatches[idx]] - (rects[idx].y +rects[idx].height);
				}
				
				var bFinal:BitmapData 
				if(mask.height+sH > 0){
					bFinal = new BitmapData(mask.width, mask.height + sH, true, 0x00000000);
				}else {
					bFinal = new BitmapData(1, 1, true, 0x00000000);
				}
				bFinal.copyPixels(bmpdOrg, rects[idx], new Point());
				bFinal.copyChannel(bAlpha, bAlpha.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
				
				bmpdFinals.push(bFinal);
				
				var b:Bitmap = new Bitmap(bFinal);
				b.smoothing = true;
				stage.addChild(b);
				b.x = rects[idx].x+space;
				b.y = rects[idx].y + space;
				
				if (settings.varNames != "") {
					
					if (i < variableNames.length){
						fnSetOutlineFx(b, i, rects.length, variableNames[i] );
					}else {
						fnSetOutlineFx(b, i, rects.length, formatInt(i + 1, 3) );
					}
				}else{
					fnSetOutlineFx(b, i, rects.length, formatInt(i + 1, 3) );
				}

				shape.graphics.lineStyle(0, 0xffffff,0.2);
				shape.graphics.drawRect(b.x, b.y, b.width, b.height);
			}
			
			shape.graphics.drawRect(space, space, bmpdOrg.width, bmpdOrg.height);
			
			shape.graphics.lineStyle(0, 0x2e90ff,0.3);
			for (i = 0; i < yLines.length; i++) {
				shape.graphics.moveTo(0+ space , yLines[i]+ space);
				shape.graphics.lineTo(bmpdOrg.width+ space , yLines[i]+ space);
			
			}
			
			
			
			
			
			
			
			
		}
		
		private var bmpdFinals:Vector.<BitmapData> = new Vector.<BitmapData>();
		
		
		private function formatInt(v:int, length:int = 3):String{
			var s:String = String(v);
			var org_le:int = s.length;
			for (var i:int = length-1; i >=org_le; i--) {
				s = "0" + s;
			}
			return s;
		}
		
		/*
		var outline:GlowFilter=new GlowFilter(0x000000,1.0,2.0,2.0,10);
outline.quality=BitmapFilterQuality.MEDIUM;
field1.filters=[outline];
		*/
		private function fnSetOutlineFx(d:DisplayObject,nr:int,max:int,label:String=""):void {
			var rd:Number = Math.random();
			var hsl:HSL = new HSL(nr/(max-1) *360.0, 1.0, 0.5);
			var c:int = hsl.toRGB().Hex;
			var r:Number = 1.1;
			d.filters = [new GlowFilter(c, 1, r , r, 20, BitmapFilterQuality.HIGH, false, true)];
			
			var txt:TextField = TxtTools.getTxt();
			TxtTools.formatBasic(txt, 12, c);
			stage.addChild(txt);
			txt.text = label;
			txt.x = d.x + d.width / 2 - txt.width / 2;
			txt.y = d.y + d.height / 2 - txt.height / 2;
			
			r = 1.5;
			txt.filters = [new GlowFilter(0x000000, 1, r , r, 20, BitmapFilterQuality.HIGH)];
			
		}
		
		private function fnGetMaskMatte(inp:BitmapData):BitmapData {
			var b:BitmapData = new BitmapData(inp.width, inp.height, false, 0x000000);
			b.copyChannel(inp, inp.rect, new Point(), 8, 1);//Copy Alpha to RED
			b.copyChannel(inp, inp.rect, new Point(), 8, 2);//Copy Alpha to GREEN
			b.copyChannel(inp, inp.rect, new Point(), 8, 4);//Copy Alpha to BLUE
			return b;
		}
		private function fnGetThresholdMask(inp:BitmapData):BitmapData {
			var b:BitmapData = new BitmapData(inp.width, inp.height, true, 0);
			b.threshold(inp,b.rect,new Point(),"<=", (0.99/100)*0xFFFFFF, 0x000000, 0xffffff,true);
			b.copyChannel(b, b.rect, new Point(), 8, 1);//Copy Alpha to RED
			b.copyChannel(b, b.rect, new Point(), 8, 2);//Copy Alpha to GREEN
			b.copyChannel(b, b.rect, new Point(), 8, 4);//Copy Alpha to BLUE
			
			var c:BitmapData = new BitmapData(inp.width, inp.height, false, 0);
			c.draw(b);
			b.dispose();
			return c;
		}
		private function fnGetFilteredChannelColor(inp:BitmapData,channelId:uint):BitmapData {
			var r:Rectangle = inp.rect;
			var pt:Point = new Point();
			var bWhite:BitmapData = new BitmapData(inp.width, inp.height, false, 0xffffffff);
			var bSub:BitmapData =  new BitmapData(inp.width, inp.height, false, 0);
			
			var b:BitmapData = inp.clone();//output bitmap
			var channels:Array = [BitmapDataChannel.RED,BitmapDataChannel.GREEN,BitmapDataChannel.BLUE];
			for (var i:int = 0; i < channels.length; i++){
				if (channels[i] != channelId) {
					
					bSub.copyChannel(inp, r, pt, channels[i], BitmapDataChannel.RED);
					bSub.copyChannel(inp, r, pt, channels[i], BitmapDataChannel.GREEN);
					bSub.copyChannel(inp, r, pt, channels[i], BitmapDataChannel.BLUE);
					bSub.draw(bWhite, null, null, BlendMode.INVERT);//invert mask
					b.draw(bSub, null, null, BlendMode.DARKEN);//darken out the spots we don't want
					b.copyChannel(b, r, pt, channelId, channels[i]);
				}
			}
			return b;
		}
		
		
		
		
		
		private function loadImage(file:File,fnDone:Function=null):void {
			
			//01 READ THE PNG
			
			var stream:FileStream = new FileStream( );
			var bytes:ByteArray = new ByteArray();
			
			stream.open(file, FileMode.READ);
			stream.readBytes(bytes);stream.close( );
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fnComplete);
			loader.loadBytes(bytes);
			function fnComplete(e:Event):void {
				fnDone(e.target.content.bitmapData);
			}
			
		}
		
	}

}