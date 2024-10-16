package shoebox.app.gui 
{
	import shoebox.app.gui.settings.UiSettings;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import tools.BmpSliceDraw;
	import tools.txtTools.TxtTools;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class UiStatusPopUp extends Sprite{
		[Embed(source="../../../../src/assets/slice_statusMsgBkg_9x.png")]
		private var embd_bmp0:Class;
		[Embed(source="../../../../src/assets/slice_statusMsgFadeBkg_9x.png")]
		private var embd_bmp1:Class;
		
		private var sliceBkg:BmpSliceDraw = new BmpSliceDraw((new embd_bmp0()).bitmapData);
		private var sliceFadeBkg:BmpSliceDraw = new BmpSliceDraw((new embd_bmp1()).bitmapData);
		private var txtMessage:TextField = TxtTools.getTxt();
		
		
		public function UiStatusPopUp() {
			addChild(txtMessage);
			TxtTools.formatBasic(txtMessage, 20, 0xcbcbcb);
			this.mouseChildren = false;
			this.mouseEnabled = false;
			this.addEventListener(MouseEvent.CLICK, fnClick);
			this.addEventListener(MouseEvent.RIGHT_CLICK, fnClick);
			this.addEventListener(MouseEvent.MIDDLE_CLICK, fnClick);
		}
		private function fnClick(e:MouseEvent):void {
			if (this.mouseEnabled && this.visible && this.alpha == 1) {
				Main.instance.uiSettings.close();
			}
		}
		public function popup(msg:String, fnOnClick:Function = null):void {
			//var totWidth:int = UiMain.instance.width;
			var tW:int = stage.stageWidth;
			var tH:int = stage.stageHeight;
			
			txtMessage.text = msg;
			txtMessage.x = (tW - txtMessage.width) / 2;
			txtMessage.y = 34;

			graphics.clear();
			sliceFadeBkg.draw(graphics, 0, 0, tW, tH);//background fade
			
			
			var wT:int = Math.min(tW , txtMessage.width + 32);//cap at width
			sliceBkg.draw(graphics, (tW - wT) / 2, 26, wT, 45);
			
			this.alpha = 0;
			var t:Number = 0.3;
			var tStay:Number = 1.5;
			TweenMax.to(this, t, { autoAlpha:1 } );
			TweenMax.to(this, t, { autoAlpha:0,overwrite:false,delay:t+tStay } );
			
			//flash animation
			var num:int = 2;
			var tBlink:Number = 0.5;
			for (var i:int = 0; i < num; i++) {
				var d:Number = t+i * tBlink / num;
				TweenMax.fromTo(txtMessage, tBlink / num, { alpha:0.2,delay:d }, { alpha:1, overwrite:false,delay:d } );
			}
			
			
		}
		public function block(show:Boolean):void {
			var tW:int = stage.stageWidth;
			var tH:int = stage.stageHeight;
			graphics.clear();
			sliceFadeBkg.draw(graphics, 0, 0, tW, tH);//background fade
			
			trace("just block...");
			var t:Number = 0.3;
			txtMessage.alpha = 0;
			
			if (show) {
				TweenMax.to(this, t, { autoAlpha:1 } );
				this.mouseEnabled = true;
			}else {
				TweenMax.to(this, t, { autoAlpha:0 } );
				this.mouseEnabled = false;
			}
		}
		
		
	}

}