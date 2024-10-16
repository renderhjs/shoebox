package shoebox.plugin.aniToFrameSequence 
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class Swf2Bitmaps{
		
		private var swfData:GetSwfData;
		private var numFrames:int = 0;
		private var bkgColor:int = 0xff0000;
		
		private var loader:Loader = new Loader();
		public var bmpds:Vector.<BitmapData> = new Vector.<BitmapData>();
		public var maxFrames:int = 60;
		
		private var swfWidth:int = 0;
		private var swfHeight:int = 0;
		private var swfFrame:int = 1;
		public function Swf2Bitmaps() {
			loader.contentLoaderInfo.addEventListener(Event.INIT, onSwfLoaded);
		}
		
		private var fnDoneCall:Function = null;
		
		public function load(f:File, fnDoneCall:Function):void {
			bmpds = new Vector.<BitmapData>();//empty array
			
			this.fnDoneCall = fnDoneCall;
			
			swfData = new GetSwfData(f.url);
			swfData.onData = function(data:Object):void{
				numFrames = data.frames;
				if (numFrames == 1) {
					numFrames = maxFrames;
				}
				bkgColor = data.backround;
				loader.load(new URLRequest(f.url));
			}
		}
		
		private function onSwfLoaded(e:Event):void {

			swfWidth 	= loader.contentLoaderInfo.width
			swfHeight 	= loader.contentLoaderInfo.height
			
			trace("SWF LOADED "+swfWidth,swfHeight);
			
			swfFrame = 1;
			loader.addEventListener(Event.EXIT_FRAME, fnDrawFrame);
			fnDrawFrame();//draw the first frame
			
		}

		private function fnDrawFrame(e:Event = null) : void {
			
			if (swfFrame <= Math.min(numFrames, maxFrames)){
			
				var b:BitmapData = new BitmapData(swfWidth, swfHeight,true,0x00000000);
				b.lock();
				b.draw(loader, null, null, null, null, true);
				b.unlock();
				
				bmpds[swfFrame-1] = b;
				
				
				swfFrame++;
			}else {
				loader.removeEventListener(Event.EXIT_FRAME, fnDrawFrame);
				trace("done rendering: " + swfFrame);
				if (fnDoneCall != null){
					fnDoneCall();
				}
			}
        }
		
		
	}

}