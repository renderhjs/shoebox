package shoebox.plugin.event 
{
	import flash.display.BitmapData;
	import flash.events.Event;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class PluginClipBoardTransferEvent extends Event{
		
		public static var DATA_CLIPBOARD_IN_IMAGE:String = "DATA_CLIPBOARD_IN_IMAGE";
		public static var DATA_CLIPBOARD_IN_TEXT:String = "DATA_CLIPBOARD_IN_TEXT";
		
		//public static var DATA_TYPE_TEXT:String = "text";
		//public static var DATA_TYPE_IMAGE:String = "image";
		
		public var bitmapData:BitmapData = null;
		public var string:String = null;
		public var nr:int;
		
		public function PluginClipBoardTransferEvent(type:String, bucketNr:int, data:Object) {
			if (type == PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_IMAGE) {
				this.bitmapData = data as BitmapData;
			}else if (type == PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_TEXT) {
				this.string = String(data);
			}
			
			this.nr = bucketNr;
			super(type);
		}
		
	}

}