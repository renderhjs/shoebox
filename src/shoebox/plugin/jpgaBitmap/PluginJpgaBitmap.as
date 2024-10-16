package shoebox.plugin.jpgaBitmap
{
	import shoebox.app.gui.UiPluginWindow;
	import shoebox.plugin.event.PluginFileTransferEvent;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.PluginHelper;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.filesystem.File;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Hendrik
	 */
	public class PluginJpgaBitmap extends PluginBase{
		[Embed(source="icon_48x48.png")]
		private var embd_bmp0:Class;
		
		public function PluginJpgaBitmap() {
			this.label = "JPGA Bitmap";
			this.icon = new embd_bmp0().bitmapData;//tool icon
			this.extentions = ["jpg", "jpeg", "png"];
			this.settings = { cropAlphaBounds:true, JpgCompression:90, fileNameEncoded:"*_jpga.jpg", fileNameDecoded:"*.png" };
			this.settingsInfo = "Encodes or Decodes a JPGA bitmap";

			this.settingsTemplates.push(["96% JPG Quality", { cropAlphaBounds:true, JpgCompression:96, fileNameEncoded:"*_jpga.jpg", fileNameDecoded:"*.png" } ]);
			this.settingsTemplates.push(["85% JPG Quality", { cropAlphaBounds:true, JpgCompression:85, fileNameEncoded:"*_jpga.jpg", fileNameDecoded:"*.png" } ]);
			this.settingsTemplates.push(["72% JPG Quality", { cropAlphaBounds:true, JpgCompression:72, fileNameEncoded:"*_jpga.jpg", fileNameDecoded:"*.png" } ]);
			
			registerListenEventGetData(PluginFileTransferEvent.DATA_FILE_IN, fnListenData);
		}
		
		private var filesDrag:Vector.<File> = new Vector.<File>();
		private var filesDragProcessCount:int = 0;
		private function fnListenData(e:PluginFileTransferEvent):void {
			
			filesDrag = e.files;
			filesDragProcessCount = 0;//reset
			if(filesDrag.length > 0){
				fnAskToSaveOk_0();
			}
			//fnProcessDroppedFile(0);
		}
		
		private function fnAskToSaveOk_0():void {
			
			
			//LOAD FIRST IMAGE
			
			PluginHelper.getFileBitmap(filesDrag[0], fnAskToSaveOk_1);
			
		}
		private function fnAskToSaveOk_1(bmp:BitmapData):void {
			
			var ext:String = filesDrag[0].extension.toLowerCase();
			
			
			
			
			
			var sample:BitmapData;
			if (ext == "jpg" || ext == "jpeg") {
				sample = fnDecode(bmp);
			}else if (ext == "png") {
				sample = fnEncode(bmp);
			}
			
			//GET LIST OF FILES TO SAVE, ONLY FILENAMES THOUGH
			var message:String;
			var new_names:Array = [];
			for (var i:int = 0; i < filesDrag.length; i++) {
				ext = filesDrag[i].extension.toLowerCase();
				var u:String = "";
				if (ext == "jpg" || ext == "jpeg") {
					u = fnGetSaveUrl(filesDrag[i],true);
				}else if (ext == "png") {
					u = fnGetSaveUrl(filesDrag[i],false);
				}
				var fName:String = u.slice(u.lastIndexOf("\\")+1,  u.lastIndexOf("."))+""+u.slice(u.lastIndexOf(".",u.length));
				new_names.push(fName);
			}
			if (new_names.length == 1) {
				message = "Save \"" + new_names[0] + "\" ?";
			}else {
				message = "Save [" + new_names[0] + " .. "+new_names[new_names.length-1]+"] ?";
			}
			
			
			
			
			var space:int = 8;
			stage = UiPluginWindow.init(Math.max(300,(sample.width) + 2 * space), Math.max(64,(sample.height) + 2 * space), message,fnAskToSaveOk_2);
			
			var b:Bitmap;
			b = new Bitmap(sample);
			b.x = b.y = space;
			stage.addChild(b);
		}
		private function fnAskToSaveOk_2():void {
			fnProcessDroppedFile(0);
		}
		
		
		
		
		
		private function fnProcessDroppedFile(nr:int):void {
			if (nr < filesDrag.length){
				filesDragProcessCount = nr;
				
				//01 LOAD SOURCE
				PluginHelper.getFileBitmap(filesDrag[nr], fnBmpLoaded,nr);
			}else {
				trace("Done :)");
			}
			//filesDragProcessCount++;
		}
		
		private var stage:Stage;
		
		private function fnBmpLoaded(bmp:BitmapData, nr:int):void {
			
			var ext:String = filesDrag[nr].extension.toLowerCase();
			
			var space:int = 8;
			var b:Bitmap;
			
			
			//var fName:String = filesDrag[nr].name.slice(0,  filesDrag[nr].name.lastIndexOf("."));
			//var fFolder:String = filesDrag[nr].parent.nativePath +"\\";
			//var url:String = filesDrag[nr].nativePath;
			var url:String;
			
			if (ext == "jpg" || ext == "jpeg") {//CONVERT TO PNG, DECODE
				var png:BitmapData = fnDecode(bmp);
				stage = UiPluginWindow.init((png.width) + 2 * space, (png.height) + 2 * space);
				
				
				b = new Bitmap(png);
				b.x = b.y = space;
				stage.addChild(b);
				
				//url = fFolder+""+settings.fileNameDecoded.split("*").join(fName);
				url = fnGetSaveUrl(filesDrag[nr],true);
				trace("save: " + url);
				
				PluginHelper.setFileBitmap(url, png);
				
			}else if (ext == "png") {//ENC
				var jpg:BitmapData = fnEncode(bmp);
				stage = UiPluginWindow.init((jpg.width) + 2 * space, (jpg.height) + 2 * space);
				
				b = new Bitmap(jpg);
				b.x = b.y = space;
				
				stage.addChild(b);
				
				//url = fFolder+""+settings.fileNameEncoded.split("*").join(fName);
				url = fnGetSaveUrl(filesDrag[nr],false);
				trace("save: " + url);
				
				PluginHelper.setFileBitmap(url, jpg, settings.JpgCompression / 100.0);
				
				
			}else {
				trace("file not supported: " + filesDrag[nr].name);
			}
			trace("bmpd loaded: " + nr+", "+ext);
			fnProcessDroppedFile(nr+1);
			
			
		}
		
		private function fnGetSaveUrl(f:File,doDecode:Boolean=true):String {
			var fName:String = f.name.slice(0,  f.name.lastIndexOf("."));
			var fFolder:String = f.parent.nativePath +"\\";
			var url:String = f.nativePath;
			
			if (doDecode){
				return fFolder + "" + settings.fileNameDecoded.split("*").join(fName);
			}else {
				return fFolder + "" + settings.fileNameEncoded.split("*").join(fName);
			}
			//
		}
		
		
		
		
		
		private function fnDecode(inp:BitmapData):BitmapData {
			var bOut:BitmapData = new BitmapData(Math.floor(inp.width/2), inp.height, true, 0x00000000);
			bOut.lock();
			
			bOut.draw(inp);
			var bAlpha:BitmapData = bOut.clone();
			var r:Rectangle = new Rectangle(bOut.width, 0, bOut.width, bOut.height);
			bAlpha.copyPixels(inp, r, new Point());
			bOut.copyChannel(bAlpha, bAlpha.rect, new Point(), 1, 8);//red to alpha
			bOut.unlock();
			return bOut;
		}
		
		private function fnEncode(inp:BitmapData):BitmapData {
			
			var bCrop:BitmapData;// = inp.clone();
			if (settings.cropAlphaBounds) {
				
				var crop:Rectangle = inp.getColorBoundsRect(0xFFFFFFFF, 0x000000, false);//alpha crop
				crop.width = Math.max(1, crop.width);
				crop.height = Math.max(1, crop.height);
				bCrop = new BitmapData(crop.width, crop.height, true, 0x00000000);
				bCrop.copyPixels(inp, crop, new Point());
				
				
			}else {
				bCrop = inp.clone();
			}
			
			//
			var bFin:BitmapData = new BitmapData((bCrop.width)*2,bCrop.height, false, 0);
			bFin.fillRect(new Rectangle(bCrop.width,0,bCrop.width,bCrop.height), 0xffff0000);
			bFin.draw(pixelPadding(bCrop));
			
			var bAlpha:BitmapData = new BitmapData(bCrop.width, bCrop.height, false, 0xff000000);
			bAlpha.copyChannel(bCrop, bCrop.rect, new Point(), 8, 1);//Copy Alpha to RED
			bAlpha.copyChannel(bCrop, bCrop.rect, new Point(), 8, 2);//Copy Alpha to GREEN
			bAlpha.copyChannel(bCrop, bCrop.rect, new Point(), 8, 4);//Copy Alpha to BLUE
			bFin.draw(bAlpha,new Matrix(1,0,0,1,bCrop.width,0));

			return bFin;
		}
		private function pixelPadding(bmpInp:BitmapData):BitmapData {
			var rB:BitmapData = bmpInp.clone();
			
			var blurStep:Number = 1.5;
			var i:int;
			var bFilter:BlurFilter = new BlurFilter(blurStep,blurStep,1);
			for (i = 0; i < 15; i++) { 
				rB.applyFilter(rB, rB.rect, new Point(), bFilter);
				rB.draw(rB );
			}	
			rB.draw(bmpInp);
			
			blurStep = 1.1;
			bFilter = new BlurFilter(blurStep,blurStep,1);
			for (i = 0; i < 15; i++) { 
				rB.applyFilter(rB, rB.rect, new Point(), bFilter);
				rB.draw(rB );
			}	
			rB.draw(bmpInp);//draw one original bmp on top
			
			return rB;
		}
		
		
		
		
		
		
	}

}