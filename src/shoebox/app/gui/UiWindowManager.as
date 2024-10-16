package shoebox.app.gui 
{
	import shoebox.app.gui.settings.UiSettings;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class UiWindowManager
	{
		
		public function UiWindowManager() 
		{
			
		}
		public static function sort():void {
			//trace("sort..");
			
			UiMain.instance.stage.nativeWindow.orderToFront();
			if (UiPluginWindow.window.visible){
				UiPluginWindow.window.orderToFront();
			}
			if (UiSettings.instance.window){
				UiSettings.instance.window.orderToFront();
			}
			
		}
		
	}

}