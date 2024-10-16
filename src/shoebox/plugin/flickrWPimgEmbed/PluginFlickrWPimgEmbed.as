package shoebox.plugin.flickrWPimgEmbed 
{
	import shoebox.plugin.event.PluginClipBoardTransferEvent;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.PluginHelper;
	/**
	 * ...
	 * @author renderhjs
	 * Assumes that the image full res was uploaded at 800x600
	 */
	public class PluginFlickrWPimgEmbed extends PluginBase{
		[Embed(source="icon_48x48.png")]
		private var embd_bmp0:Class;
		
		public function PluginFlickrWPimgEmbed() {
			this.label = "FlickrWP img";
			this.icon = new embd_bmp0().bitmapData;//tool icon
			this.settingsInfo = "converts 1 flickr clipboard URL to WordPress html code";
			
			registerListenEventGetData(PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_TEXT, onClipBoardIn);
		}
		
		
		private var templ:String = "<a href=\"#URL\" target=\"_blank\"><img src=\"#IMG\" alt=\"\" /></a>";
		
		private function onClipBoardIn(e:PluginClipBoardTransferEvent):void {
			//if (e.dataType == PluginClipBoardTransferEvent.DATA_TYPE_TEXT) {
			if (e.type == PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_TEXT) {
				var u:String = e.string;
				trace("clipboard; " + u);
				
				if (u.indexOf(".flickr.com") != -1) {//its a flickr url
					var thb:String = "";
					var big:String = "";
					if (u.indexOf("_b.jpg") != -1) {
						thb = u.slice(0, u.indexOf("_b.jpg")) + ".jpg";
						big = u;
					}else {
						thb = u;
						big = u.slice(0, u.indexOf(".jpg")) + "_b.jpg";
					}
					
					
					trace("thb: " + thb);
					trace("big: " + big);
					
					var out:String = templ.split("#URL").join(big);
					out = out.split("#IMG").join(thb);
					
					PluginHelper.setClipBoardText(out);
					
				}
				
				
				
				
				
				
			}
		}
		
		
	}

}