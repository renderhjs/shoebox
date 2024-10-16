package shoebox.plugin.codeInspect 
{
	import shoebox.app.gui.UiPluginWindow;
	import shoebox.plugin.event.PluginFileTransferEvent;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.PluginHelper;
	import flash.display.Stage;
	import flash.text.TextField;
	import tools.txtTools.TxtTools;
	/**
	 * ...
	 * @author Hendrik
	 */
	public class PluginCodeInspect extends PluginBase{
		//[Embed(source="icon_48x48.png")]
		//private var embd_bmp0:Class;
		
		public function PluginCodeInspect() {
			this.label = "Code Inspect";
			//this.icon = new embd_bmp0().bitmapData;//tool icon
			this.extentions = ["txt", "as", "cs"];
			this.settings = {  };
			this.settingsInfo = "";

			registerListenEventGetData(PluginFileTransferEvent.DATA_FILE_IN, fnListenData);
		}

		private function fnListenData(e:PluginFileTransferEvent):void {
			if (e.files.length == 1) {
				
				//PluginHelper.getFileText(e.files[0],fnLoaded);
				fnLoaded( PluginHelper.getFileText(e.files[0]));
			}
		}
		
		
		
		
		
		private var txt:TextField;
		private var stage:Stage;
		private function fnLoaded(s:String):void {
			//s = s.split("\t").join("");
			//s = s.split("\n\t").join("\t");
			
			s = fnCleanCode(s);
			//s = s.replace("\n\n\n\n\n", "\n");
			//s = s.replace("\n\n\n\n", "\n");
			//s = s.replace("\n\n\n", "\n");
			
			
			/*s =
			s = s.replace("\r\n", "\n");
			s = s.replace("\r", "\n");
			s = s.replace("\n\n\n", "\n");
			s = s.replace("\n\n", "\n");
			*/
			
			var w:int = 600;
			var h:int = 800;
			stage = UiPluginWindow.init(w, h);
			txt = TxtTools.getTxt();
			TxtTools.formatBasic(txt, 10, 0x525252);
			txt.width = w;
			txt.height = h;
			
			
			stage.addChild(txt);
			txt.text = s;
			readVars(s);

		}
		
		private function fnCleanCode(s:String):String {
			var i:int;
			for (i = 0; i < 20; i++) {
				s = s.split("\n\n").join("\n");
			}
			
			s = s.split("\n{").join("{");
			
			
			var c1:RegExp = new RegExp("//.*","g");//single comment
			var c2:RegExp = /\/\*[\s\S]*?\*\//gm;//multi line comment
			var i1:RegExp = new RegExp("import .*","g");//import
			var i2:RegExp = /trace\(.*/g;//trace lines be gone
			//;new RegExp("trace(.*", "g");//trace
			s = s.replace(c1, "");
			s = s.replace(c2, "");
			s = s.replace(i1, "");
			s = s.replace(i2, "");
			
			
			for (i = 0; i < 20; i++) {
				s = s.split("\n\n").join("\n");
				s = s.split("\t\n").join("\n");
			}
			
			//loosen vars in brackets and alike
			s = s.split("(").join("( ");
			s = s.split(")").join(" )");
			s = s.split("[").join("[ ");
			s = s.split("]").join(" ]");
			s = s.split("+").join(" + ");
			s = s.split("-").join(" - ");
			s = s.split("*").join(" * ");
			s = s.split(",").join(" , ");
			s = s.split(">").join(" > ");
			s = s.split("<").join(" < ");
			s = s.split("/").join(" / ");
			s = s.split("=").join(" = ");
			s = s.split("  ").join(" ");
			
			
			
			return s;
		}
		
		private function readVars(s:String):void {
			
			//var c1:RegExp=/\*.*?\*/;
			
			//var Comment = 
			/*var v1:RegExp = new RegExp("\b(var|private|public)\b","g");//
			s = s.replace(v1, "@");*/
			//var regExp:RegExp=/[(|)|M|%]/g;

			var i:int;
			
			s = s.split("\t").join("");
			var lns:Array = s.split("\n");
			for (i = 0; i < lns.length; i++) {
				var wrds:Array = lns[i].split(" ");
				if (wrds.indexOf("var") >= 0) {
					var vName:String = "var "+wrds[ wrds.indexOf("var") + 1];
					vName = vName.slice(0, vName.indexOf(":"));
					//s = s.split(lns[i]).join("> "+vName);
					//txt.text = s;
					TxtTools.formatKeywordsColor(txt,[vName],0x4f981e);
				}
				
				if (wrds.indexOf("function") >= 0 && wrds.indexOf("var") == -1) {
					
					var fName:String = "function "+wrds[ wrds.indexOf("function") + 1];
					fName = fName.slice(0, fName.indexOf("("));
					//s = s.split(lns[i]).join("> "+vName);
					//txt.text = s;
					TxtTools.formatKeywordsColor(txt,[fName],0x0fade8);
					//TxtTools.formatKeywordsColor(txt,[lns[i]],0x0fade8);
				}
				
				if (wrds.indexOf("class") >= 0 ) {
					
					//var fName:String = "function "+wrds[ wrds.indexOf("function") + 1];
					//fName = fName.slice(0, fName.indexOf("("));
					//s = s.split(lns[i]).join("> "+vName);
					//txt.text = s;
					//TxtTools.formatKeywordsColor(txt,[fName],0x0fade8);
					TxtTools.formatKeywordsColor(txt,[lns[i]],0xb45ef1);
				}
			}
			
			
			
			
			
			
			
			
			//take out functions
			
			
			
			
		}
		
		
		
		
		
	}
}