package shoebox.plugin.aniToFrameSequence {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	public class GetSwfData extends Sprite{
		private var stream:URLStream;
		public var colorCode:int = 0;
		public var frames:Number = 0;
		public var onData:Function = function():void{}
		public function GetSwfData(path:String):void {
			stream = new URLStream();
			stream.load(new URLRequest(path));
			stream.addEventListener(Event.COMPLETE, onComplete);
		}
		private function onComplete(e:Event):void {
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			stream.readBytes(bytes, 0, 8);
			var sig:String = bytes.readUTFBytes(3);
			trace("SIG = " + sig);
			trace("ver = " + bytes.readByte());
			trace("size = " + bytes.readUnsignedInt());
			var compBytes:ByteArray = new ByteArray();
			compBytes.endian = Endian.LITTLE_ENDIAN;
			stream.readBytes(compBytes);
			if (sig == "CWS") {
				compBytes.uncompress();
			}
			var fbyte:* = compBytes.readUnsignedByte();
			var rect_bitlength:* = fbyte >> 3;
			var total_bits:* = rect_bitlength * 4;
			var next_bytes:* =  Math.ceil((total_bits - 3)/ 8);
			for(var i:int=0; i<next_bytes; i++) {
				compBytes.readUnsignedByte();
			}
			trace("frameRate = " + compBytes.readUnsignedShort());
			frames = compBytes.readUnsignedShort();


			while(true) {
				var tagcodelen:Number = compBytes.readUnsignedShort();
				var tagcode:Number = tagcodelen >> 6;
				var taglen:Number = tagcodelen & 0x3F;
				trace("tag code = " + tagcode + "\tlen = " + taglen);
				if (taglen >=63) {
					taglen = compBytes.readUnsignedInt();
				}
				if(tagcode == 9) {
					colorCode = RGB.decColor2hex(RGB.getHex(compBytes.readUnsignedByte(),compBytes.readUnsignedByte(),compBytes.readUnsignedByte()))
					break;
				}
				compBytes.readBytes(new ByteArray(), 0, taglen);
				//break;
			}
			onData({frames:frames,backround:colorCode})
		}
	}
}