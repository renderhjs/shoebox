package shoebox.plugin.macPcPathConverter 
{
	import shoebox.app.gui.UiPluginWindow;
	import shoebox.plugin.event.PluginClipBoardTransferEvent;
	import shoebox.plugin.event.PluginFileTransferEvent;
	import shoebox.plugin.PluginBase;
	import flash.display.Stage;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import shoebox.plugin.PluginHelper;
	import tools.txtTools.TxtTools;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class PluginMacPcPathConverter  extends PluginBase{
		[Embed(source="icon_48x48.png")]
		private var embd_bmp0:Class;
	
		private var illegalCharacters:Array = [",","<", ">", "^", "*", "=", "+", ";"];
		
		
		
		public function PluginMacPcPathConverter(){
			this.label = "Mac 2 PC url";
			this.icon = new embd_bmp0().bitmapData;//tool icon
			
			var paths:Array = [	"\\\\192.168.0.240\\xStaff\\=/Volumes/xStaff/",
								"B:\\=/Volumes/Work_10/", "A:\\=/Volumes/xAdmin/",
								"S:\\=/Volumes/xStuff/",
								"B:\\=afp://xserve._afpovertcp._tcp.local/Work_10/",
								"\\\\192.168.0.240\\Soap Software Library\\=/Volumes/Soap Software Library/"];
			
			
			this.settings = { driveMappings:paths,openOnlyFolder:true };
			this.settingsInfo = "Seperate mappings in driveMappings by ',' character. The = sign assigns a drive to a ip address.";

			registerListenEventGetData(PluginFileTransferEvent.DATA_FILE_IN, fnListenData);
			registerListenEventGetData(PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_TEXT, fnListenClipboard);
		}
		
		public function extConvertPath(inp:String):String {
			//CONVERT PATH TO THE SYSTEM PAHT
			var os:String = Capabilities.os.substr(0, 3).toLowerCase();
			var isMac:Boolean = false;
			//GET CLEAN BASE FORMA
			var s:String = fnRemoveIllegalChars(inp);
			s = s.split("\n").join("");
			s = s.split("\r").join("");
			s = s.split("\t").join("");
			
			if (s.indexOf("/") != -1 && os == "win") {//mac to PC
				//if the volume label is missing, default mac copy path
				if (s.indexOf("/Volumes/") == -1 && s.indexOf("afp://") == -1) {
					s = "/Volumes/" + s;
					s.split("//").join("/");
				}

				s = fnConvertPath(s, false);//convert to PC
			}else if (s.indexOf("\\") != -1 && os == "mac") {//PC TO MAC
				isMac = true;
				s = fnConvertPath(s, true);//convert to MAC
			}
			return s;
		}
		
		
		
		//private var stage:Stage;
		private function fnListenClipboard(e:PluginClipBoardTransferEvent):void {
			//recieve path from the clipboard, try to open the containing folder
			var os:String = Capabilities.os.substr(0, 3).toLowerCase();
			var isMac:Boolean = false;
			
			
			//GET CLEAN BASE FORMA
			var s:String = fnRemoveIllegalChars(e.string);
			s = s.split("\n").join("");
			s = s.split("\r").join("");
			s = s.split("\t").join("");
			
			trace("PATH A: " + s);
			
			
			if (s.indexOf("/") != -1 && os == "win") {//mac to PC
				//if the volume label is missing, default mac copy path
				if (s.indexOf("/Volumes/") == -1 && s.indexOf("afp://") == -1) {
					s = "/Volumes/" + s;
					s.split("//").join("/");
				}
				
				
				s = fnConvertPath(s, false);//convert to PC
			}else if (s.indexOf("\\") != -1 && os == "mac") {//PC TO MAC
				isMac = true;
				s = fnConvertPath(s, true);//convert to MAC
			}

			trace("PATH B: " + s);
			
			
			try{
				var file:File = new File(s);
				if (file.exists) {
					if (settings.openOnlyFolder == true){//ONLY OPEN FOLDERS, MORE SECURE
						if (file.isDirectory){
							file.openWithDefaultApplication();//will open this file
						}else {
							file.parent.openWithDefaultApplication();//
						}
					}else {
						file.openWithDefaultApplication();
					}
				}
			}catch (er:Error) {
				//txt.appendText("\nerror:\t" + er.message);
			}

			
			PluginHelper.setClipBoardText(s);
			
			//trace("conversion: " + s);
			//trace("conversion test to mac: " + fnConvertPath(e.string,true));
		}
		private function fnRemoveIllegalChars(inp:String):String {
			var s:String = inp;
			for (var i:int = 0; i < illegalCharacters.length; i++) {
				s = s.split(illegalCharacters[i]).join("_");
			}
			return s;
		}
		private function fnConvertPath(inp:String, toMac:Boolean=false):String {
			var i:int; var s:String;
			
			var a:Array = settings.driveMappings;// .split(",");
			var aPC:Array = [];//arrayPC indexies
			var aMAC:Array = [];
			
			for (i = 0; i < a.length; i++) {
				s = a[i];
				if (s.indexOf("=")!=-1){
					aPC[i] = s.split("=")[0];// s.slice(0, s.indexOf("="));
					aMAC[i] = s.split("=")[1];//s.slice(s.indexOf("=") + 1, s.length);
				}else {
					aPC[i] = "";
					aMAC[i] = "";
				}
			}
			
			
			s = inp;
			if (toMac) {//is PC, convert to mac
				for (i = 0; i < aPC.length; i++){
					s = s.split(aPC[i]).join(aMAC[i]);
				}
				
				trace(a.length+"x a[] = " + a.join(" | "));
				trace(aPC.length+"x aPC: " + aPC.join(" | "));
				trace(aMAC.length+"x aMAC: " + aMAC.join(" | "));
				
				trace("check find/ replace: " + s);
				if (s.indexOf("\\\\") != -1 && s.split("\\").length >= 3 && s.split(".").length >= 4) {//not matched in our databse, convert a IP network path to samba path
					s = s.slice(s.indexOf("\\\\") + 2, s.length);
					a = s.split(".");
					s = "smb://" + a[0] + "." + a[1] + "." + a[2] + "." + a[3];
					trace("is IP leftover...>"+s);
				}
				s = s.split("\\").join("/");
				//s = s.split(" ").join("\\ ");//MAC doesn't like a space, needs an escape character
				
			}else {//is mac, convert to PC
				for (i = 0; i < aMAC.length; i++){
					s = s.split(aMAC[i]).join(aPC[i]);
				}
				s = s.split("/ ").join(" ");//weird escape character space
				s = s.split("/").join("\\");
				//s = s.split("\\ ").join(" ");//mac doesn't like spaces, uses an escape character
			}
			
			return s;
		}
		
		
		
		
		
		private function fnListenData(e:PluginFileTransferEvent):void {
			var i:int;var j:int;
			var s:String = "";
			
			var out:String = "";
			for (i = 0; i < e.files.length; i++) {
				s = e.files[i].nativePath;
				
				s = fnRemoveIllegalChars(s);//remove illegal characters
				if (s.indexOf("/") != -1) {//its a mac path, convert to default PC format
					s = fnConvertPath(s, false);
				}
				out += s;
				if (i < (e.files.length - 1)) {
					out+="\n";
				}
			}
			if (e.files.length == 1) {
				s = e.files[0].nativePath;
				s = fnRemoveIllegalChars(s);//remove illegal characters
				trace("mac path: \"" + fnConvertPath(s, true)+"\"");
			}
			
			
			//mx.controls
			/*
			stage = UiPluginWindow.init(512, 128);
			var txt:TextField = TxtTools.getTxt();
			TxtTools.formatBasic(txt, 11, 0xffffff);
			txt.text = "";
			txt.appendText("org:\t\t" + e.files[0].nativePath);
			txt.appendText("\nfinal:\t\t" + s);
			
			txt.x = txt.y = 8;
			stage.addChild(txt);
			*/
			
			
			PluginHelper.setClipBoardText(out);
		}
		
	}

}