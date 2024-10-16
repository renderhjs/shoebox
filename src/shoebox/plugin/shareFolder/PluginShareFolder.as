package shoebox.plugin.shareFolder 
{
	import com.adobe.air.filesystem.events.FileMonitorEvent;
	import com.adobe.air.filesystem.FileUtil;
	import flash.display.Stage;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import shoebox.app.gui.UiPluginWindow;
	import shoebox.app.PluginManager;
	import shoebox.plugin.event.PluginClipBoardTransferEvent;
	import shoebox.plugin.event.PluginFileTransferEvent;
	import shoebox.plugin.macPcPathConverter.PluginMacPcPathConverter;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.PluginHelper;
	import flash.filesystem.File;
	import shoebox.plugin.shareFolder.fileUtils.FileUtils;
	import tools.txtTools.TxtTools;
	/**
	 * ...
	 * @author Hendrik
	 */
	public class PluginShareFolder extends PluginBase{
		[Embed(source="icon_48x48.png")]
		private var embd_bmp0:Class;
		
		private var indexFileName:String = "index.txt";
		private var histroyLength:int = 4;
		private var fileUtils:FileUtils = new FileUtils();
		
		private var uiFolder:PluginShareFolderUi;
		
		private var timeQuickUpdate:int = 2500;
		
		
		public function PluginShareFolder(){
			this.label = "Share Folder";
			this.icon = new embd_bmp0().bitmapData;//tool icon
			this.settings = { shareId:"ch0", basePath:"\\\\192.168.0.240\\xStaff\\Hendrik" };
			this.settingsInfo = "Shares files in a folder on a specified folder 'shareId' within the basePath. Works also on network drives between Mac and PC for which the driveMappings map address from pc to mac and vise versa.";
			
			//this.settingsTemplates.push(["Hendrik", { shareId:"ch0", basePath:"\\\\192.168.0.240\\xStaff\\Hendrik" } ]);
			this.settingsTemplates.push(["Mark F.", { shareId:"shoeBoxShare", basePath:"\\192.168.0.240\xStaff\Mark F" } ]);
			this.settingsTemplates.push(["Patrick", { shareId:"shoeBoxShare", basePath:"\\192.168.0.240\xStaff\Pat" } ]);
			
			
			registerListenEventGetData(PluginFileTransferEvent.DATA_FILE_IN, fnListenData);
			registerListenEventGetData(PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_IMAGE, fnClipBoardBmp);
			registerListenEventGetData(PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_TEXT, fnClipBoardTxt);
			
			registerListenEventClick(fnClick);
			
			uiFolder = new PluginShareFolderUi(this);
			//registerListenEventGetData(
		}

		private function timerUpdate(skipAction:Boolean=false):void {
			if (UiPluginWindow.isOpen) {
				
				if (!skipAction){
					trace("...update..");
					var idx:String = readIndex();
					uiFolder.update(idx, getFolderUrl());//update UI
				}
				if (UiPluginWindow.hasFocus){
					setTimeout(timerUpdate,2500 );
				}else {
					setTimeout(timerUpdate,10000 );
				}
			}
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		private function fnClick():void {
			trace("CLICK SHARE SCRIPT");
			
			var dir:File = new File(getFolderUrl());
			if (dir.exists) {
				//checkDirectory();//MAKES SURE WE HAVE A FOLDER TO COPY INTO
				var index:String = readIndex();
				
				uiFolder.update(index, getFolderUrl());
				timerUpdate(true);
			}
		}
		
		private function fnClipBoardBmp(e:PluginClipBoardTransferEvent):void {
			trace("fnClipBoardBmp");
			if (e.type == PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_IMAGE) {
				var dir:File = new File(getFolderUrl());
				if (dir.parent.exists) {
					checkDirectory();//MAKES SURE WE HAVE A FOLDER TO COPY INTO
					var index:String = readIndex();
					var fName:String = "clipboard_bmp_"+generateSeed(8)+".png";
					PluginHelper.setFileBitmap(dir.nativePath + "\\" +fName , e.bitmapData);
					PluginHelper.setPopupMessage("Submited Bitmap");
					
					//write back to index so we know we changed something
					index = addItemToIndex(index, "bmp " + fName);
					var url:String = getFolderUrl() + "\\" + indexFileName;
					url = PluginHelper.getSysPath(url);//validate for mac users
					PluginHelper.setFileASCI(url, index);
					
					uiFolder.update(index, getFolderUrl());
					timerUpdate(true);
				}
			}
		}
		private function fnClipBoardTxt(e:PluginClipBoardTransferEvent):void {
			trace("fnClipBoardTxt");
			if (e.type == PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_TEXT) {
				var dir:File = new File(getFolderUrl());
				if (dir.parent.exists) {
					checkDirectory();//MAKES SURE WE HAVE A FOLDER TO COPY INTO
					var index:String = readIndex();
					//var fName:String = "clipboard_txt_" + generateSeed(8) + ".txt";
					
					var txt:String = e.string;
					txt = txt.split(File.lineEnding).join("\n");//get rid of odd double returns
					//txt = txt.split("\r\n").join("\n");//get rid of odd double returns
					//txt = txt.split("\n\r").join("\n");//get rid of odd double returns
					txt = txt.split("\r").join("\n");//get rid of odd double returns
					txt = txt.split("\n\n\n\n\n\n").join("\n");//get rid of odd double returns
					txt = txt.split("\n\n\n\n\n").join("\n");//get rid of odd double returns
					txt = txt.split("\n\n\n\n").join("\n");//get rid of odd double returns
					txt = txt.split("\n\n\n").join("\n");//get rid of odd double returns
					txt = txt.split("\n\n").join("\n");//get rid of odd double returns
					
					//trace("txt: " + txt.split("\n").length + " = \n" + txt);
					var fName:String = fnTextPreviewString(txt,28) +"_"+ generateSeed(8) + ".txt";
					
					
					PluginHelper.setFileASCI(dir.nativePath + "\\" +fName , txt);
					PluginHelper.setPopupMessage("Submited Text");
					
					//write back to index so we know we changed something
					index = addItemToIndex(index, "txt " + fName);
					var url:String = getFolderUrl() + "\\" + indexFileName;
					url = PluginHelper.getSysPath(url);//validate for mac users
					PluginHelper.setFileASCI(url, index);
					
					uiFolder.update(index, getFolderUrl());
					timerUpdate(true);
				}
			}
		}
		
		private function fnTextPreviewString(inp:String,l:int):String {
			inp = inp.split(" ").join("_");//split spaces
			inp = inp.split("\t").join("");//split tabs
			inp = inp.split("\\").join("");//split slash
			inp = inp.split("/").join("");//split slash
			//inp = inp.split("_").join("");//split _ so we can use it to filter out in the preview panel
			
			inp = PluginHelper.getSysFileName(inp);
			inp = inp.slice(0, Math.min(inp.length, l));
			
			return inp;
		}
		
		
		
		
		
		private function fnListenData(e:PluginFileTransferEvent):void {
			if (e.files.length > 0) {
				
				var dir:File = new File(getFolderUrl());
					
				
				if (dir.parent.exists) {
					checkDirectory();//MAKES SURE WE HAVE A FOLDER TO COPY INTO
					
					var index:String = readIndex();
					
					dir = new File( getFolderUrl() );
					var array:Array = [];
					var i:int;
					for (i = 0; i < e.files.length; i++) {
						array.push( e.files[i]);
					}
					
					//http://code.google.com/p/kurstcode/source/browse/trunk/libs/com/kurst/air/?r=2#air%2Ffile
					fileUtils.copyFileArrayToFolder(array, dir, true);
					
					for (i = 0; i < e.files.length; i++) {
						var fName:String = e.files[i].name;
						index = addItemToIndex(index, "file " + fName);
					}
					//write back to index so we know we changed something
					var url:String = getFolderUrl() + "\\" + indexFileName;
					url = PluginHelper.getSysPath(url);//validate for mac users
					PluginHelper.setFileASCI(url, index);
					
					PluginHelper.setPopupMessage(e.files.length + " files copied to share folder");
					uiFolder.update(index, getFolderUrl());
					timerUpdate(true);
					
				}else {
					PluginHelper.setPopupMessage("base path does not exist, check settings");
				}
			}
		}
		

		
		private function getFolderUrl():String {
			var url:String = settings.basePath;
			if ( settings.shareId != "") {
				url += "\\" + settings.shareId;
			}
			
			
			//search for share plugin...
			var found:Boolean = false;
			var pl:PluginBase;
			for (var i:int = 0; i <PluginManager.plugins.length ; i++) {
				pl = PluginManager.plugins[i];
				if (pl.classId == "macPcPathConverter.PluginMacPcPathConverter") {
					found = true;
					break;
				}
			}
			if (found) {//WE CAN TRANSLATE WITHIN THE USERS ENVIRONMENT
				var pc:PluginMacPcPathConverter = pl as PluginMacPcPathConverter;
				url = pc.extConvertPath(url);
			}

			url = PluginHelper.getSysPath(url);//MAKE SURE MAC USERS ARE NOT LEFT ALONE, FIX PATH DEPENDING ON SYSTEM
			
			return url;
		}
		
		private function checkDirectory():void {
			var idxDir:File = new File( getFolderUrl() );
			if (idxDir.parent.exists) {//base folder must exist
				if (!idxDir.exists && settings.shareId != ""){//CREATE A SUB FOLDER FOR THE CHANNEL
					idxDir.createDirectory();
				}
			}
		}
		
		
		private function readIndex():String {
			//reads the folder index
			
			var url:String = getFolderUrl() + "\\" + indexFileName;
			url = PluginHelper.getSysPath(url);//validate for mac users
			
			var idxFile:File = new File(url);
			if (!idxFile.exists) {//doesn't exist, create one
				PluginHelper.setFileASCI(url, "");//create empty text file
				return "";
			}else {
				return PluginHelper.getFileText( idxFile);
			}
			
			return "";
		}
		
		private function addItemToIndex(idx:String,cmdLine:String):String {
			var s:String = idx;
			var a:Array = idx.split("\n");
			a.unshift(cmdLine);
			if (a.length > 0){
				if (a[a.length - 1] == "") {
					a.pop();
				}
			}
			s = a.join("\n");
			return s;
		}
		
		private function generateSeed(length:int):String{
			var a:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
			//var a:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
			var alphabet:Array = a.split("");
			var randomLetter:String = "";
			for (var i:Number = 0; i < length; i++){
				randomLetter += alphabet[Math.floor(Math.random() * alphabet.length)];
			}
			return randomLetter;
		}
		
		
	}

}