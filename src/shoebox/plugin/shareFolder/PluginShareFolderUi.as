package shoebox.plugin.shareFolder 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.filesystem.File;
	import flash.text.TextField;
	import shoebox.app.gui.settings.UiSettingsButton;
	import shoebox.app.gui.UiPluginWindow;
	import tools.txtTools.TxtTools;
	/**
	 * ...
	 * @author Hendrik
	 */
	public class PluginShareFolderUi
	{
		private var stage:Stage;
		private var width:int = 256;
		private var headerHeight:int = 23;
		private var itemHeight:int = 18;
		private var maxItems:int = 8;
		
		private var txtTitle:TextField = TxtTools.getTxt();
		private var btnTitle:UiSettingsButton;
		private var listItms:Vector.<PluginShareFolderUiListItem> = new Vector.<PluginShareFolderUiListItem>();
		
		private var spr:Sprite = new Sprite();
		public function PluginShareFolderUi(psf:PluginShareFolder):void {
			var s:int = 8;
			var ih:int = 18;
			
			spr.mouseEnabled = false;
			spr.graphics.beginFill(0x1a1a1a);
			spr.graphics.drawRect(1, 1, width-2, headerHeight-1);
			
			for (var i:int = 0; i < maxItems; i++) {
				listItms[i] = new PluginShareFolderUiListItem(this);
				listItms[i].x = s;
				listItms[i].y = headerHeight+s + i * itemHeight;
				
				spr.addChild(listItms[i]);
			}
			TxtTools.formatBasic(txtTitle, 11, 0x6e6e6e);
			txtTitle.y = 3;
			txtTitle.x = 3;
			spr.addChild(txtTitle);
			
			btnTitle = new UiSettingsButton("Explore", 52,clickExplore);
			btnTitle.x = btnTitle.y = 3;
			spr.addChild(btnTitle);
			txtTitle.x = btnTitle.x + 52 + 2;
		}
		
		private function clickExplore():void {
			var dir:File = new File(folder);
			if (dir.exists) {
				if (dir.isDirectory){
					dir.openWithDefaultApplication();//will open this file
				}
				//dir.open
			}
		}
		
		public var folder:String = "";
		public function update(index:String, folder:String):void {
			this.folder = folder;
			
			if (!UiPluginWindow.isOpen) {
				stage = UiPluginWindow.init(width, maxItems * itemHeight+headerHeight+2*8);
				stage.addChild(spr);
			}
			
			txtTitle.text = folder;
			var a:Array = index.split("\n");
			if (a.length > 0){
				if (a[a.length - 1] == "") {
					a.pop();
				}
			}
			
			
			
			var count:int = Math.min(maxItems, a.length);
			for (var i:int = 0; i < maxItems; i++) {
				if (i < count){
					listItms[i].update(a[i]);
					listItms[i].visible = true;
				}else {
					listItms[i].visible = false;
				}
			}
		}
		
		
	}

}