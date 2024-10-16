package shoebox.plugin.event 
{
	import flash.events.Event;
	import flash.filesystem.File;
	/**
	 * ...
	 * @author Hendrik
	 */
	public class PluginFileTransferEvent extends Event
	{
		public static var DATA_FILE_IN:String = "DATA_FILES_IN";
		
		public var files:Vector.<File>;
		public var nr:int;
		public function PluginFileTransferEvent(type:String, bucketNr:int, files:Vector.<File>) {
			this.files = files;
			this.nr = bucketNr;
			//trace("# PluginDataTransfer "+files.length+"x");
			super(type);
			
			
		}
		
	}

}