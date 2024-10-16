package shoebox.plugin.shareFolder 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.text.TextField;
	import shoebox.app.gui.settings.UiSettingsButton;
	import shoebox.plugin.PluginHelper;
	import tools.BmpSliceDraw;
	import tools.txtTools.TxtTools;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class PluginShareFolderUiListItem extends Sprite {
		[Embed(source="icons_ui_type.png")]
		private var embd_bmp0:Class;
		
		private var uiParent:PluginShareFolderUi;
		
		private var txt:TextField = TxtTools.getTxt();
		private var btn:UiSettingsButton;
		private var slc:BmpSliceDraw;
		private var icons:Vector.<Bitmap> = new Vector.<Bitmap>();
		public function PluginShareFolderUiListItem(parent:PluginShareFolderUi):void {
			this.uiParent = parent;
			
			slc = new BmpSliceDraw((new embd_bmp0() as Bitmap).bitmapData );
			for (var i:int = 0; i < 3; i++) {
				icons[i] = new Bitmap(slc.slices[i]);
				icons[i].x = 7;
				icons[i].y = 1;
				addChild(icons[i]);
			}
			
			
			TxtTools.formatBasic(txt, 11, 0xc7c7c7);
			txt.selectable = false;
			txt.mouseEnabled = false;
			addChild(txt);
			txt.x = 82;
			
			
			btn = new UiSettingsButton("copy", 45,clickAction);
			btn.x = 30;
			addChild(btn);
			
			this.mouseEnabled = false;
			
			///*
			/*
			txt.text = a[i];
			txt.x = s;
			txt.y = sy+s + i * ih;*/
		}
		
		private var cmd:String = "";
		public function update(cmd:String):void {
			this.cmd = cmd;
			var a:Array = cmd.split(" ");
			var type:String = a[0];
			
			icons[0].visible = icons[1].visible = icons[2].visible = false;
			if (type == "bmp") {
				icons[1].visible = true;
				btn.label = "open";
			}else if (type == "txt") {
				icons[2].visible = true;
				btn.label = "copy";
			}else if (type == "file") {
				icons[0].visible = true;
				btn.label = "open";
			}
			
			a.shift();
			//txt.text = a.join(" ");
			txt.text = cmd.slice(cmd.indexOf(" ") + 1, cmd.lastIndexOf("_"));
		}
		
		
		private function clickAction():void {
			var a:Array = cmd.split(" ");
			var type:String = a[0];
			
			a.shift();
			var url:String = uiParent.folder + "\\"+a.join(" ");
			url = PluginHelper.getSysPath(url);//MAKE SURE MAC USERS ARE NOT LEFT ALONE, FIX PATH DEPENDING ON SYSTEM
			
			var file:File;
			file = new File(url);
			
			if (type == "bmp" || type == "file") {
				//open file with default OS app
				
				if (file.exists) {
					file.openWithDefaultApplication();//will open this file
				}
			}else if (type == "txt") {
				if (file.exists) {
					var txt:String = PluginHelper.getFileText(file);
					PluginHelper.setClipBoardText(txt);
				}
			}
			
			
		}
	}

}