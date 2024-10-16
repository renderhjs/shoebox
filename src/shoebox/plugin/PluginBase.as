package shoebox.plugin 
{
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import shoebox.app.gui.UiDroplet;
	import shoebox.app.gui.UiMain;
	import shoebox.app.PluginManager;
	import shoebox.plugin.event.PluginClipBoardTransferEvent;
	import shoebox.plugin.event.PluginFileTransferEvent;
	/**
	 * ...
	 * @author renderhjs
	 * Base plugin functions to extend any custom plugin with
	 */
	public class PluginBase extends EventDispatcher{
		
		public var label:String = "myScript";
		public var classId:String = "";
		public var icon:BitmapData = null;
		public var settings:Object = { };
		public var settingsTemplates:Array = [];
		public var settingsInfo:String = "";
		public var extentions:Array = [];
		
		public var holdStartTime:int = 0;//used for detecting hold down guesstures
		public var holdDown:Boolean = false;//used for detecting hold down guesstures
		
		public var sysDropArea:Sprite = null;
		public var sysDropUi:UiDroplet = null;
		public var sysDropNr:int = 0;
		public var sysSupportEventFileIn:Boolean = false;
		public var sysSupportEventClipboardInText:Boolean = false;
		public var sysSupportEventClipboardInImage:Boolean = false;
		public var ui:UiDroplet;
		
		
		
		private var listenerFunctionEventFileData:Function = null;
		private var listenerFunctionEventClipboardText:Function = null;
		private var listenerFunctionEventClipboardImage:Function = null;
		public var 	listenerFunctionEventClick:Function = null;
		public function registerListenEventGetData(type:String, functionListener:Function):void {
			if (type == PluginFileTransferEvent.DATA_FILE_IN) {
				listenerFunctionEventFileData = functionListener;
				sysSupportEventFileIn = true;
				PluginManager.instance.addEventListener(type, recieveListenEventGetFiles);
			}else if (type == PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_TEXT) {
				listenerFunctionEventClipboardText = functionListener;
				sysSupportEventClipboardInText = true;
				PluginManager.instance.addEventListener(type, recieveListenEventGetClipBoardData);
			}else if (type == PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_IMAGE) {
				listenerFunctionEventClipboardImage = functionListener;
				sysSupportEventClipboardInImage = true;
				PluginManager.instance.addEventListener(type, recieveListenEventGetClipBoardData);
			}
		}
		
		public function registerListenEventClick(functionListener:Function):void {
			listenerFunctionEventClick = functionListener;
		}
		
		/*
		private var listenerFunctionGetFiles:Function = null;
		public function registerListenEventGetData(type:String, functionListener:Function):void {
			listenerFunctionGetFiles = functionListener;
			PluginManager.instance.addEventListener(type, recieveListenEventGetFiles);
		}
		
		private var listenerFunctionGetClipBoard:Function = null;
		public function registerListenEventGetData(type:String, functionListener:Function):void {
			listenerFunctionGetFiles = functionListener;
			PluginManager.instance.addEventListener(type, recieveListenEventGetFiles);
		}
		*/
		
		
		private function recieveListenEventGetFiles(e:PluginFileTransferEvent):void {
			if (sysDropNr == e.nr) {
				listenerFunctionEventFileData(e);
			}
		}
		private function recieveListenEventGetClipBoardData(e:PluginClipBoardTransferEvent):void {
			if (sysDropNr == e.nr) {
				if (e.string != null){
					listenerFunctionEventClipboardText(e);
				}else {
					listenerFunctionEventClipboardImage(e);
				}
			}
		}
		
		//-------------------------------------------------
		/*
		public function setClipBoardText(content:String):void {
			
		}
		public function setClipBoardBitmap(bmpd:BitmapData):void {
			
		}
		public function setFileBitmap(filename:String, bmpd:BitmapData,quality:Number=1):void {
			
		}
		
		
		public function setFileASCI(filename:String, string:String):void {
			PluginHelper.setFileASCI(filename, string);
		}
		public function setFileBinary(filename:String, data:ByteArray):void {
			
		}
		
		
		private function validateFileName(inp:String):String {
			
		}
		*/
		
		
		
		
		
		
		
		
		
		
		
		
		/*
		public function setClipBoardText(content:String):void {
			trace("setClipBoardText");
			
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, content);
			UiMain.instance.uiStatusPop.popup("Copied Text to Clipboard");
		}
		public function setClipBoardBitmap(bmpd:BitmapData):void {
			trace("setClipBoardText");
			
			UiMain.instance.uiStatusPop.popup("Copied Bitmap to Clipboard");
		}
		public function setFileBitmap(filename:String, bmpd:BitmapData,quality:Number=1):void {
			
			filename = validateFileName(filename);
			
			var file:File = new File(filename);
			if (file.parent.exists) {
				trace("saving BMP: " + filename);
				var ext:String = file.extension.toLowerCase();
				
				var stream:FileStream = new FileStream();
				if(ext == "png"){
					stream.open(file, FileMode.WRITE);
					stream.writeBytes(PNGEncoder.encode(bmpd),0);//write the file
					stream.close();//close writing operation
				}else if (ext == "jpg" || ext == "jpeg") {
					stream.open(file, FileMode.WRITE);
					var jEnc:JPGEncoder = new JPGEncoder(Math.round(quality * 100));
					stream.writeBytes(jEnc.encode(bmpd),0);//write the file
					stream.close();//close writing operation
				}
			}
		}
		
		
		public function setFileASCI(filename:String, string:String):void {
			
			filename = validateFileName(filename);
			
			var file:File = new File(filename);
			if (file.parent.exists) {
				trace("can be saved: " + filename);
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(string);
				stream.close();
			}
		}
		public function setFileBinary(filename:String, data:ByteArray):void {
			filename = validateFileName(filename);
		}
		
		
		private function validateFileName(inp:String):String {
			
			var rChar:String = "_";
			
			//filter out illegal windows characters
			inp = inp.split("?").join(rChar);
			inp = inp.split("<").join(rChar);
			inp = inp.split("\"").join(rChar);
			inp = inp.split(">").join(rChar);
			inp = inp.split("\"").join(rChar);
			inp = inp.split("|").join(rChar);
			inp = inp.split("*").join(rChar);
			
			//SPECIAL CASE : under windows
			var a:Array = inp.split(":");
			var t:String = "";
			if (a.length > 0) {
				if (a[0].length == 1) {//only valid on windows after the first volume character
					t += a[0] + ":";
				}
				a.splice(0, 1);
				for (var i:int = 0; i < a.length; i++) {//check for remaining characters in the path
					t += a[i];
					if (i < a.length-1) t += rChar;
				}
				inp = t;
			}
			
			var os:String = Capabilities.os.substr(0, 3).toLowerCase();
			if (os == "win") {//mac to PC
				inp = inp.split("//").join("\\");//forward mac to PC backwards
			}else if (os == "mac") {
				inp = inp.split("\\").join("//");//backward PC slash to forward mac
				inp = inp.split(":").join(rChar);
			}
			
			return inp;
		}
		*/
	}

}