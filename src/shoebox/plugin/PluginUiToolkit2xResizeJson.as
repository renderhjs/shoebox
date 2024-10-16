package shoebox.plugin 
{
	import shoebox.plugin.event.PluginFileTransferEvent;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.FileReference;
	import shoebox.plugin.event.PluginFileTransferEvent;
	/**
	 * ...
	 * @author Hendrik
	 */
	public class PluginUiToolkit2xResizeJson extends PluginBase
	{
		
		public function PluginUiToolkit2xResizeJson() {
			this.label = "UiToolkit fix";
			
			this.settings = {  };
			this.settingsInfo = "Used for unity3D, reads a json TexturePacker config file and scales all x,y,w,h values down by 2. Used for 2x retina UiToolkit unity3d projects";

			registerListenEventGetData(PluginFileTransferEvent.DATA_FILE_IN, fnListenData);
		}
		
		private var fileBmp:File = null;
		private var fileJson:File = null;
		
		private function fnListenData(e:PluginFileTransferEvent):void {
			
			
			if (e.files.length == 2) {
				for (var i:int = 0; i < 2; i++) {
					if (e.files[i].extension == "png") {
						trace("scale image... ");
						fileBmp = e.files[i];
						PluginHelper.getFileBitmap(e.files[i], fnProcessPng);
						
					}else if (e.files[i].extension == "json") {
						trace("convert json... ");
						fileJson = e.files[i];
						//PluginHelper.getFileText(e.files[i], fnProcessJson);
						fnProcessJson( PluginHelper.getFileText(e.files[i]) );
					}
				}
			}
			/*
			if (e.files.length == 1){
				PluginHelper.loadText(e.files[0], fnTxtLoaded);
			}*/
		}
		
		
		
		
		
		
		
		
		
		private function fnProcessPng(b:BitmapData):void {
			
			trace("b: " + b.width, b.height);
			
			var w:int = Math.floor(b.width / 2);
			var h:int = Math.floor(b.height/ 2);
			var bNew:BitmapData = new BitmapData(w, h, true, 0x00000000);
			var m:Matrix = new Matrix();
			m.scale(0.5, 0.5);
			bNew.draw(b, m, null, null, null, true);
			/*
			//SHARPEN FILTER
			var matrix:Array = [ 0, -1, 0 , 
                                 -1, 5, -1 , 
                                 0, -1, 0]; 
			var convFilter:ConvolutionFilter = new ConvolutionFilter(3,3,null,1); 
			convFilter.matrix = matrix; 
			bNew.applyFilter(bNew, bNew.rect, new Point(), convFilter);
			*/
			
			
			
			
			
			var n:String = fileBmp.name;
			var fileMoveTo:File = new File(fileBmp.parent.nativePath+"\\"+n.slice(0,n.lastIndexOf("."))+"2x."+fileBmp.extension);
			var urlSource:String = fileBmp.nativePath;
			
			fileBmp.moveTo(fileMoveTo, true);
			
			trace("2x moved to: " + fileMoveTo.nativePath);
			trace("resized saved to: " + urlSource);
			
			
			PluginHelper.setFileBitmap(urlSource, bNew);
		}
		
		
		
		
		
		
		
		
		private function fnProcessJson(s:String):void {
			
			var r:String =  s;
			r = readVarAndScale("\"x\":",r, 0.5);
			r = readVarAndScale("\"y\":",r, 0.5);
			r = readVarAndScale("\"w\":",r, 0.5);
			r = readVarAndScale("\"h\":",r, 0.5);
			//trace(r);
			//setClipBoardText(r);
			var n:String = fileJson.name;
			var url2x:String = fileJson.parent.nativePath+"\\"+n.slice(0,n.lastIndexOf("."))+"2x.txt"
			
			
			var fileMoveTo:File = new File(fileJson.parent.nativePath+"\\"+n.slice(0,n.lastIndexOf("."))+".txt");
			fileJson.moveTo(fileMoveTo,true);
			
			PluginHelper.setFileASCI(fileMoveTo.nativePath, r);
			
			var file2x:File = new File(url2x);//2x file
			PluginHelper.setFileASCI(url2x, s);
			
			trace("final json file: " + fileJson.nativePath);
			
			
		}
		
		private function readVarAndScale(idKey:String, inp:String, scale:Number):String {
			
			var a:Array = [];
			a = inp.split(idKey);
			var r:String = a[0];
			for (var i:int = 1; i < a.length; i++) {
				var s:String = a[i];
				
				var n:String = "";
				if (s.indexOf("}") > -1 && s.indexOf("}") <= 5) {
					n = s.slice(0, s.indexOf("}"));
				}else if (s.indexOf(",") > -1 && s.indexOf(",") <= 5) {
					n = s.slice(0, s.indexOf(","));
				}
				
				var rest:String = s.slice(n.length, s.length);
				var float:Number = Math.floor(Number(n) * scale);
				trace("float: >" + float + "< | >"+n+"<");
				r += idKey+"" + String(float)+""+rest;
			}
			
			return r;
		}
		
	}

}