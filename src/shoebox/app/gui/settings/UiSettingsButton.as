package shoebox.app.gui.settings 
{
	import com.greensock.TweenMax;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.TextField;
	import shoebox.app.gui.UiMain;
	import tools.BmpSliceDraw;
	import tools.txtTools.TxtTools;
	import tools.WireButtons;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class UiSettingsButton extends Sprite{
		[Embed(source="../../../../../src/assets/sliceMulti_settingsButtons_3x.png")]
		private var embd_bmp0:Class;
		private var sliceStates:BmpSliceDraw = new BmpSliceDraw((new embd_bmp0()).bitmapData);
		private var sliceUp:BmpSliceDraw = new BmpSliceDraw( sliceStates.slices[0] );
		private var sliceOv:BmpSliceDraw = new BmpSliceDraw( sliceStates.slices[1] );
		//private var sliceDn:BmpSliceDraw = new BmpSliceDraw( sliceStates.slices[2] );

		
		private var wb:WireButtons = new WireButtons();
		
		//var btn:SimpleButton
		private var shpUp:Shape = new Shape();
		private var shpOv:Shape = new Shape();
		//private var shpDn:Shape = new Shape();
		private var sprBtn:Sprite = new Sprite();
		
		private var txt:TextField = TxtTools.getTxt();

		public function UiSettingsButton(label:String = "", w:int=64,fnClick:Function=null) {
			
			
			sliceUp.draw(shpUp.graphics, 0, 0, w);
			sliceOv.draw(shpOv.graphics, 0, 0, w);
			//sliceDn.draw(shpDn.graphics, 0, 0, w);
			
			sprBtn.graphics.beginFill(0xff0000);
			sprBtn.graphics.drawRect(0, 0, w, shpUp.height);
			
			
			
			shpUp.alpha = 1;
			shpOv.alpha = 0;
			
			wb.click(sprBtn, fnClick);
			wb.over(sprBtn, onOver);
			wb.out(sprBtn, onOut);

			TxtTools.formatBasic(txt, 12, 0x1f1f1f,"font1");
			txt.text = label;
			txt.y = -1;
			txt.x = (w - txt.width) / 2;
			txt.mouseEnabled = false;
			
			addChild(sprBtn);
			addChild(shpUp);
			addChild(shpOv);
			addChild(txt);
			/*
			if (keyboardCode != -1) {
				//assigned keyboard key
				fnCall = fnClick;
				UiMain.keyBind.bindKey(keyboardCode, onKeyExecute);
			}*/
		}
		public function set label(v:String):void {
			txt.text = v;
		}
		
		
		private function onOver():void {
			var t:Number = 0.2;
			TweenMax.to(shpOv, t, { alpha:1 } );
		}
		private function onOut():void {
			var t:Number = 0.2;
			TweenMax.to(shpOv, t, { alpha:0 } );
		}
		
		
		
		
		
	}

}