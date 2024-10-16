package shoebox.plugin.listFiles 
{
	import shoebox.app.PluginManager;
	import shoebox.plugin.event.PluginFileTransferEvent;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.PluginHelper;
	/**
	 * ...
	 * @author Hendrik
	 */
	public class PluginListFiles extends PluginBase{
		[Embed(source="icon_48x48.png")]
		private var embd_bmp0:Class;
		
		
		public function PluginListFiles() {//INITIALIZE
			this.label = "List Files";
			this.icon = new embd_bmp0().bitmapData;//tool icon
			//this.settings = {outerClosure:"var a:Array=[*];",elementClosure:"'*'",elementSplit:",",includeSubFolders:false };
			this.settings = {outerClosure:"var a:Array = [*];",elementClosure:"\"*\"",elementSplit:", " };
			this.settingsTemplates = [];
			this.settingsTemplates.push(["AS3 Array", { outerClosure:"var a:Array = [*];", elementClosure:"\"*\"", elementSplit:", " } ]);
			this.settingsTemplates.push(["Plain", { outerClosure:"*", elementClosure:"*", elementSplit:"\\n" } ]);
			
			//this.extentions = ["txt", "as3", "css"];
			this.settingsInfo = "Lists selected files and folders to the clipboard. Use the * character in outerClosure and elementClosure as a placefolder for the filename.";
			
			registerListenEventGetData(PluginFileTransferEvent.DATA_FILE_IN, fnListenData);
		}
		
		private function fnListenData(e:PluginFileTransferEvent):void {
			trace("LISTEN..." + e.files.length, sysDropNr,"ext: ",extentions.length,extentions);
			var i:int;
			
			var out:String = "";
			
			var outerClosure:String = settings.outerClosure;
			var elementClosure:String = settings.elementClosure;
			var elementSplit:String = settings.elementSplit;
			
			var rpl:Array = [["\\n", "\n"], ["\\r", "\r"], ["\\t", "\t"]];
			for (i = 0; i < rpl.length ; i++) {
				outerClosure = outerClosure.split(rpl[i][0]).join(rpl[i][1]);
				elementClosure = elementClosure.split(rpl[i][0]).join(rpl[i][1]);
				elementSplit = elementSplit.split(rpl[i][0]).join(rpl[i][1]);
			}
			
			
			
			
			if (outerClosure.split("*").length>=2 != -1 && elementClosure.split("*").length>=2) {
				
				out = outerClosure.split("*")[0];
				
				for (i= 0; i < e.files.length; i++) {
					out += elementClosure.split("*")[0] + "" + e.files[i].name + "" + elementClosure.split("*")[1];
					if (i < e.files.length-1) {
						out += elementSplit;
					}
				}
				
				out +=outerClosure.split("*")[1];
			}
			
			PluginHelper.setClipBoardText(out);
			
		}
		
		
	}

}