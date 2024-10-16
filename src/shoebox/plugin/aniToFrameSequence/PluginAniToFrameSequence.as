package shoebox.plugin.aniToFrameSequence 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import org.bytearray.gif.events.GIFPlayerEvent;
	import org.bytearray.gif.frames.GIFFrame;
	import org.bytearray.gif.player.GIFPlayer;
	import shoebox.app.gui.UiPluginWindow;
	import shoebox.plugin.event.PluginFileTransferEvent;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.PluginHelper;
	import tools.NumberFormat;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class PluginAniToFrameSequence extends PluginBase{
		[Embed(source="icon_48x48.png")]
		private var embd_bmp0:Class;
		
		private var bmpdOutput:BitmapData;
		private var orgFileName:String;
		private var orgFileDir:File;
		private var finFileName:String;
		
		public function PluginAniToFrameSequence() {
			this.label = "Ani 2 Sheet";
			this.icon = new embd_bmp0().bitmapData;//tool icon
			//this.settings = {outerClosure:"var a:Array=[*];",elementClosure:"'*'",elementSplit:",",includeSubFolders:false };
			this.settings = {maxFrames:60,cropGroupAlpha:true,singleRow:false,margin:0,saveSequence:true};
			this.settingsTemplates = [];
			this.settingsInfo = "Converts animated GIF or SWF to animation spritesheet.\ncropGroupAlpha crops all frames as a group to its closest alpha bounds. margin defines additional space between the frames.";
			this.extentions = ["swf", "gif"];
			registerListenEventGetData(PluginFileTransferEvent.DATA_FILE_IN, fnListenData);
		}
		
		private function fnListenData(e:PluginFileTransferEvent):void {
			
			
			if (e.files.length == 1) {
				if (e.files[0].exists){
					var ext:String = e.files[0].extension.toLowerCase();
					
					orgFileName = e.files[0].name.slice(0, e.files[0].name.lastIndexOf("."));;
					orgFileDir = e.files[0].parent;//THE DIRECTORY
					
					
					trace("ext:\t" + ext+"\nFileName:\t"+orgFileName);
					
					//1 ANIMATED GIF
					if (ext == "gif") {
						parseGIF(e.files[0]);
						
					//2 ANIMATED SWF
					}else if (ext == "swf") {
						parseSWF(e.files[0]);
					
					//3 SPRITESHEET PNG?
					}else if (ext == "png") {
						//
					}
				}
			}
			
			
			
			
			
			
			
			
			//2 detect image sequence
			
			//3 load mov, avi h264 based data
			//http://flashthusiast.com/2008/03/02/loading-and-displaying-video-in-actionscript-30-no-more-video-objects/
		}
		
		
		private function ProcessSpriteSheet(frames:Vector.<BitmapData>):void {
			if (frames.length > 0) {
				if (settings.cropGroupAlpha){//CROP FRAMES?
					cropFrames(frames);
				}
				//
				
				var s:int = settings.margin;//SPACING
				var iw:int = frames[0].width;//INSTANCE WIDTH
				var ih:int = frames[0].height;
				var size:Point = fnSheetGetBestCanvasSize(frames.length, iw, ih);//COLUMNS AND ROW SIZE
				bmpdOutput = new BitmapData(size.x*(iw+s),size.y*(ih+s), true, 0x00000000);
				
				var shp:Shape = new Shape();//DEBUG SHAPE SHOWING CROP AREAS
				var g:Graphics = shp.graphics;
				
				for (var i:int = 0; i < frames.length; i++) {
					var x:int = (i % size.x) * (iw + s);
					var y:int = Math.floor(i / size.x ) * (ih + s);
					bmpdOutput.copyPixels( frames[i], frames[i].rect, new Point(x, y));
					
					
					//RENDER DEBUG INFO
					g.lineStyle(0, 0x8aff00,0.3);
					var crop:Rectangle = frames[i].getColorBoundsRect(0xFFFFFFFF, 0x000000, false);//alpha crop
					g.drawRect(x + crop.x, y + crop.y, crop.width, crop.height);
					
					if (settings.margin > 0) {
						g.lineStyle(0, 0x3b79cd,0.2);
						g.drawRect(x, y, iw, ih);
					}
					g.lineStyle(0, 0x191919);//DARK GREY
					g.drawRect(x, y, iw+s, ih+s);
				}
				
				finFileName = fnGetFileName(frames.length, size.x, size.y, iw, ih);
				
				var stage:Stage = UiPluginWindow.init(bmpdOutput.width, bmpdOutput.height, "save \"" + finFileName + "\" ?", fnSaveOkButton);
				UiPluginWindow.highlightMsg(finFileName.slice(0, finFileName.lastIndexOf(".")));
				
				var b:Bitmap = new Bitmap(bmpdOutput);
				stage.addChild(b);
				stage.addChild(shp);
			}
		}
		
		private var finSeqSaveNum:int = 0;
		private var finSeqSaveFrames:Vector.<BitmapData>;
		private function ProcessImageSequence(frames:Vector.<BitmapData>):void {
			//saveSequence
			if (frames.length > 0) {
				if (settings.cropGroupAlpha){//CROP FRAMES?
					cropFrames(frames);
				}
				var s:int = 8;
				var w:int = frames[0].width;
				var h:int = frames[0].height;
				
				w = Math.max(640, w);
				
				//
				
				finSeqSaveFrames = frames;
				
				var A:String = fnGetFileNameSequence(0);
				var B:String = fnGetFileNameSequence(frames.length - 1);
				
				//A = A.slice(A.lastIndexOf("//
				
				
				var stage:Stage = UiPluginWindow.init(w + 2 * s, h + 2 * s, "save \"" + A + " ... " + B + "\" ?", fnSaveOkSquenceButton);
				UiPluginWindow.highlightMsg(A.slice(0, A.lastIndexOf(".")));
				UiPluginWindow.highlightMsg(B.slice(0, B.lastIndexOf(".")));
				var b:Bitmap = new Bitmap(frames[0]);
				stage.addChild(b);
				b.x = b.y = s;
				//UiPluginWindow.highlightMsg(finFileName.slice(0, finFileName.lastIndexOf(".")));
				
			}
		}
		private function fnSaveOkSquenceButton():void {
			finSeqSaveNum = 0;//reset
			fnSaveSequence(0);//start with first
		}
		private function fnSaveSequence(nr:int):void {
			if (nr < finSeqSaveFrames.length) {
				var url:String = orgFileDir.resolvePath(	fnGetFileNameSequence(nr)	).nativePath;
				PluginHelper.setFileBitmap(url, finSeqSaveFrames[nr]);
				
				fnSaveSequence(nr + 1);
			}else {
				trace("DONE");
				finSeqSaveFrames = new Vector.<BitmapData>();//empty array
			}
		}
		
		
		
		
		
		
		
		
		
		
		
		
		private function fnSaveOkButton():void {
			
			
			//var url:String = PluginHelper.getSysFileName( orgFileDir.nativePath + "\\" + finFileName);
			var url:String = orgFileDir.resolvePath(finFileName).nativePath;
			
			trace("SAVE..\n"+url);
			
			PluginHelper.setFileBitmap(url, bmpdOutput);
			
			
			/*
			finFileName
			orgFileName = e.files[0].name.slice(0, e.files[0].name.lastIndexOf("."));;
			orgFileDir = e.files[0].parent;//THE DIRECTORY
			*/
		}
		
		private function fnGetFileName(num:int, cols:int, rows:int, iw:int, ih:int):String {
			//var st:String = PluginHelper.getSysFileName( orgFileName);//validate
			var st:String = PluginHelper.getSysFileName( orgFileName);//validate
			st += "_"+num+"_"+iw+"x"+ih;
			st+=".png"
			return st;
		}
		private function fnGetFileNameSequence(nr:int):String {
			//var st:String = PluginHelper.getSysFileName( orgFileName);//validate
			var st:String = PluginHelper.getSysFileName( orgFileName);//validate
			st += "_"+NumberFormat.formatInteger(nr,4);
			st+=".png"
			return st;
		}
		
		
		private function fnSheetGetBestCanvasSize(num:int, iw:int, ih:int):Point {
			if (settings.singleRow){
				return new Point(num,1);
			}else {
				var ratio:Number = ih / iw ;//w =1.0, h = ...
				var sort:Array = [];
				
				for (var i:int = num; i > 0; i--) {
					
					var cols:int = i;
					var rows:int = Math.ceil( num / i);
					
					var w:int = cols * iw;
					var h:int = rows * ih;
					var vol:Number = w * h;
					var lft:Number = vol - (num * (iw * ih));
					
					var sortR:Number = lft + Math.abs(cols-rows) * (iw * ih)/2; //the lower the difference the better
					sort.push( { s:sortR, cols:cols, rows:rows } );
				}
				sort.sortOn("s", Array.NUMERIC);
				var col:int = sort[0].cols;
				var row:int = sort[0].rows;
				
				if ((row * ih) > (col * iw)) {
					return new Point(row,col);
				}else{
					return new Point(col, row);
				}
			}
		}
		
		
		
		
		private function cropFrames(bmpds:Vector.<BitmapData>):void {
			var xA:Number;//DISTANCE UPPER LEFT CORNER
			var xB:Number;
			var yA:Number;//DISTANCE LOWER RIGHT CORNER
			var yB:Number;

			var i:int;
			for (i = 0; i < bmpds.length; i++) {
				var crop:Rectangle = bmpds[i].getColorBoundsRect(0xFFFFFFFF, 0x000000, false);//alpha crop
				if (i == 0) {
					xA = crop.x;
					yA = crop.y;
					xB = bmpds[i].width - crop.width - xA;
					yB = bmpds[i].height - crop.height - yA;
				}else {
					xA = Math.min(crop.x , xA);
					yA = Math.min(crop.y , yA);
					xB = Math.min( bmpds[i].width - crop.width - crop.x , xB);
					yB = Math.min( bmpds[i].height - crop.height - crop.y , yB);
				}
			}
			//FINAL CROP
			var fCrop:Rectangle = new Rectangle(xA, yA, bmpds[0].width - xB-xA, bmpds[0].height - yB-yA);
			for (i = 0; i < bmpds.length; i++) {
				var b:BitmapData = bmpds[i];
				var c:BitmapData = new BitmapData(fCrop.width, fCrop.height, true, 0xffff0000);
				c.copyPixels(b, fCrop, new Point());
				bmpds[i] = c;
				b.dispose();
			}
		}
		
		
		
		
		private function parseGIF(f:File):void {
			var myGIFPlayer:GIFPlayer = new GIFPlayer();
			
			var stream:FileStream = new FileStream( );
			var bytes:ByteArray = new ByteArray();
			
			stream.open(f, FileMode.READ);
			stream.readBytes(bytes);
			stream.close( );
			
			myGIFPlayer.addEventListener ( GIFPlayerEvent.COMPLETE, onComplete );
			myGIFPlayer.loadBytes(bytes);
			
			function onComplete(e:GIFPlayerEvent):void {
				trace("frames: "+myGIFPlayer.totalFrames);
				var bmps:Vector.<BitmapData> = new Vector.<BitmapData>();
				var i:int;
				for (i = 0; i < myGIFPlayer.frames.length; i++) {
					bmps[i] = myGIFPlayer.frames[i].bitmapData;
				}
				if (settings.saveSequence){
					ProcessImageSequence(bmps);
				}else {
					ProcessSpriteSheet(bmps);
				}
			}
		}
		
		private function parseSWF(f:File):void {
			trace("load SWF:");
			var swfBmp:Swf2Bitmaps = new Swf2Bitmaps();
			swfBmp.maxFrames = settings.maxFrames;
			swfBmp.load(f,doneLoading);
			function doneLoading():void {
				
				if (settings.saveSequence){
					ProcessImageSequence(swfBmp.bmpds);
				}else {
					ProcessSpriteSheet(swfBmp.bmpds);
				}
				
			}
		}
	}

}