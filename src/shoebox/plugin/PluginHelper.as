package shoebox.plugin 
{
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	import com.adobe.serialization.json.JSON;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import shoebox.app.gui.UiMain;
	/**
	 * ...
	 * @author renderhjs
	 * PROVIDES SYSTEM FILE & CLIPBOARD TOOLS FOR STRING, BITMAP AND BINARY FILES
	 */
	public class PluginHelper{

		public function PluginHelper() {
			
		}
		
		
		public static function getFileBitmap(file:File,fnDone:Function=null,arg:*=null):void {
			if (file.exists) {//01 READ THE png, gif, jpg
				var stream:FileStream = new FileStream( );
				var bytes:ByteArray = new ByteArray();
				
				stream.open(file, FileMode.READ);
				stream.readBytes(bytes);stream.close( );
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fnComplete);
				loader.loadBytes(bytes);
				function fnComplete(e:Event):void {
					if (arg != null) {
						fnDone(e.target.content.bitmapData, arg);
					}else {
						fnDone(e.target.content.bitmapData);
					}
					
				}
			}
		}
		public static function getFileText(file:File):String {
			if (file.exists) {//01 READ xml, txt, asci based files
				
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				var str:String = stream.readUTFBytes(stream.bytesAvailable);
				stream.close();
				//str = str.replace(File.lineEnding, "\n");
				str = str.split(File.lineEnding).join("\n");
				
				
				return str;
			}
			return "";
		}
		
		public static function getSysJsonObj(s:String):Object {
			var obj:Object = null;
			try {//PREVENT CRASH ON FAULTY JSON OBJECTS
				obj = JSON.decode(s);
			}catch (e:Error) {
				obj = null;
			}
			return obj;
		}
		public static function getSysJsonString(o:Object):String {
			var s:String = "";//EMPTY STRING IF NULL OBJECT
			if (o != null) {
				s = JSON.encode(o);
			}
			return s;
		}

		public static function getSysPath(s:String):String {
			
			var os:String = Capabilities.os.substr(0, 3).toLowerCase();//win, mac
			
			if (s.indexOf("\\") != -1 && os == "mac") {//IS PC, convert to MAC
				if (s.indexOf("\\\\") != -1 && s.split("\\").length >= 3 && s.split(".").length >= 4) {//not matched in our databse, convert a IP network path to samba path
					s = s.slice(s.indexOf("\\\\") + 2, s.length);
					var a:Array = s.split(".");
					s = "smb://" + a[0] + "." + a[1] + "." + a[2] + "." + a[3];
				}
				s = s.split("\\").join("/");
			
			}else if (s.indexOf("/") != -1 && os == "win") {//is mac, convert to PC
				s = s.split("/").join("\\");
			}
			return s;
		}
		
		
		
		
		
		public static function setPopupMessage(txt:String):void {
			UiMain.instance.uiStatusPop.popup(txt);
		}
		
		public static function setClipBoardText(content:String):void {
			//trace("setClipBoardText");
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, content);
			UiMain.instance.uiStatusPop.popup("Copied Text to Clipboard");
		}
		public static function setClipBoardBitmap(bmpd:BitmapData):void {
			//trace("setClipBoardText");
			
			UiMain.instance.uiStatusPop.popup("Copied Bitmap to Clipboard");
		}
		public static function setFileBitmap(filename:String, bmpd:BitmapData,quality:Number=1):void {
			
			filename = getSysFileName(filename);
			
			var file:File = new File(filename);
			if (file.parent.exists) {
				//trace("saving BMP: " + filename);
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
		
		
		public static function setFileASCI(filename:String, string:String):void {
			filename = getSysFileName(filename);
			var file:File = new File(filename);
			if (file.parent.exists) {
				trace("save ASCI....");
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(string);
				stream.close();
			}
		}
		public static function setFileBinary(filename:String, data:ByteArray):void {
			filename = getSysFileName(filename);
			//to be fixed, not done yet
		}
		
		
		public static function getSysFileName(inp:String):String {
			
			var rChar:String = "_";
			
			//filter out illegal windows characters
			inp = inp.split("?").join(rChar);
			inp = inp.split("<").join(rChar);
			inp = inp.split("\"").join(rChar);
			inp = inp.split(">").join(rChar);
			//inp = inp.split("\"").join(rChar);
			inp = inp.split("|").join(rChar);
			inp = inp.split("*").join(rChar);
			inp = inp.split("^").join(rChar);
			inp = inp.split("=").join(rChar);
			inp = inp.split("+").join(rChar);
			inp = inp.split(";").join(rChar);
			
			//[",","<", ">", "^", "*", "=", "+", ";"];
			//SPECIAL CASE : under windows
			var a:Array = inp.split(":");
			var t:String = "";
			if (a.length > 1) {
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
		
		public static function parseTypedSpecialCharacters(inp:String):String {
			var repl:Array = [
				["\\t", "\t"],
				["\\n", "\n"],
				["\\\"", "\""],
				["\\r", "\r"]
			];
			
			var out:String = inp;
			for (var i:int = 0; i < repl.length; i++) {
				//trace("repl: " + repl[i][0] + " > ... , "+out.split(repl[i][0]).length+" x  "+out);
				out = out.split(repl[i][0]).join(repl[i][1]);
			}
			return out;
			//var out:String = inp.split(repl[0][0]).join(repl[0][1]);
			
		}

	}

}