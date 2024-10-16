package shoebox.plugin.extractSwfAnimation.parseSwf
{
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.*;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * Loads both of AVM1 and AVM2 swf as AVM2.
	 */
	public class AVM2Loader extends Loader
	{
		private var _urlLoader:URLLoader;
		private var _context:LoaderContext;

		/**
		 * loads both of AVM1 and AVM2 movie as AVM2 movie.
		 */
		override public function load(request:URLRequest,context:LoaderContext=null):void
		{
			_context=context;

			_urlLoader=new URLLoader ;
			_urlLoader.dataFormat=URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener(Event.COMPLETE,_binaryLoaded,false,0,true);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR,_transferEvent,false,0,true);
			_urlLoader.addEventListener(ProgressEvent.PROGRESS,_transferEvent,false,0,true);
			_urlLoader.addEventListener(Event.OPEN,_transferEvent,false,0,true);
			_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS,_transferEvent,false,0,true);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,_transferEvent,false,0,true);
			_urlLoader.load(request);
		}

		private function _binaryLoaded(e:Event):void
		{
			loadBytes(ByteArray(_urlLoader.data),_context);
			_urlLoader=null;
		}

		private function _transferEvent(e:Event):void
		{
			dispatchEvent(e);
		}

		/**
		 * loads both of AVM1 and AVM2 movie as AVM2 movie.
		 */
		override public function loadBytes(bytes:ByteArray,context:LoaderContext=null):void
		{
			//uncompress if compressed
			bytes.endian=Endian.LITTLE_ENDIAN;
			trace("loadBytes" + bytes[0] );
			if (bytes[0] == 0x43) {
				//trace(" hackA");
				//many thanks for be-interactive.org
				var compressedBytes:ByteArray=new ByteArray() ;
				compressedBytes.writeBytes(bytes,8);
				compressedBytes.uncompress();

				bytes.length=8;
				bytes.position=8;
				bytes.writeBytes(compressedBytes);
				compressedBytes.length=0;

				//flag uncompressed
				bytes[0]=0x46;
			}
			hackBytes(bytes);
			/*if (context == null) {
				//context = new LoaderContext();
				context = new LoaderContext(false,null,null);
			}
			context.allowCodeImport = true;*/
			super.loadBytes(bytes,context);
		}

		/**
		 * if bytes are AVM1 movie, hack it!
		 */
		private function hackBytes(bytes:ByteArray):void
		{
			//trace(" hackB");
			if (bytes[4] < 0x09)
			{
				trace("hack 9");
				bytes[4]=0x09;
			}

			//trace(" hackC");
			//dirty dirty
			var imax:int=Math.min(bytes.length,100);
			for (var i:int=23; i < imax; i++)
			{
				if (bytes[i - 2] == 0x44 && bytes[i - 1] == 0x11)
				{
					bytes[i]=bytes[i] | 0x08;
					return;
				}
			}
		}
	}
}