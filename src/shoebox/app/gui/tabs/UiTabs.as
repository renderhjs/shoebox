package shoebox.app.gui.tabs 
{
	import air.net.ServiceMonitor;
	import flash.display.Sprite;
	import shoebox.app.PluginManager;
	import shoebox.app.SettingsManager;
	import shoebox.plugin.PluginBase;
	import tools.WireButtons;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class UiTabs extends Sprite {
		
		//private
		private var tabs:Vector.<UiTab> = new Vector.<UiTab>();
		//public var plugins:Vector.<Vector.<PluginBase>> = new Vector.<Vector.<PluginBase>>();//inidicates in what order in each tab plugins are distributed
		private var wb:WireButtons = new WireButtons();
		public function UiTabs() {
			var lbls:Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];
			for (var i:int = 0; i < SettingsManager.tabPlugins.length; i++) {
				var t:UiTab = new UiTab(lbls[i]);
				tabs.push( t );
				addChild(t);
				
				wb.click( t , setTab, i);
			}
			//tabs[0].over = true;
			//setTab(0);
		}
		
		
		public function setTab(nr:int):void {
			nr = Math.min(nr, tabs.length - 1);
			var i:int;
			for (i = 0; i < tabs.length; i++) {
				tabs[i].over = (i == nr);
			}
			
			//SettingsManager.tabPlugins.../
			trace("SET TAB");
			
			var c:int = 0;
			for (i = 0; i < PluginManager.plugins.length; i++) {
				var pl:PluginBase = PluginManager.plugins[i];
				if (SettingsManager.tabPlugins[nr].indexOf( PluginManager.plugins[i].sysDropNr ) != -1) {
					pl.ui.visible = true;
					
					pl.ui.x = 12 + c * (72 + 10);
					pl.ui.y = 10;
					
					c++;
				}else {
					pl.ui.visible = false;
					pl.ui.x = 5000;
				}
			}
			SettingsManager.saveTabPage(nr);
		}
		
		
		public function resize(width:int):void {
			width -= 17+8;
			var sp:int = 4;
			var iw:int = Math.floor(width / tabs.length);
			for (var i:int = 0; i < tabs.length; i++) {
				tabs[i].resize(iw-2*sp);
				tabs[i].x = i * iw+sp;
			}
		}
		
	}

}