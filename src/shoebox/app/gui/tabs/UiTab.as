package shoebox.app.gui.tabs 
{
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import tools.BmpSliceDraw;
	import tools.txtTools.TxtTools;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class UiTab extends Sprite{
		[Embed(source="../../../../../src/assets/slice_tabActive_3x.png")]
		private var embd_bmp0:Class;
		[Embed(source="../../../../../src/assets/slice_tabOther_3x.png")]
		private var embd_bmp1:Class;
		[Embed(source="../../../../../src/assets/sprite_tabActiveCircleBkg.png")]
		private var embd_bmp2:Class;
		
		private var sliceTab0:BmpSliceDraw = new BmpSliceDraw((new embd_bmp0()).bitmapData);
		private var sliceTab1:BmpSliceDraw = new BmpSliceDraw((new embd_bmp1()).bitmapData);
		//private var sliceCircle:BmpSliceDraw = new BmpSliceDraw((new embd_bmp2()).bitmapData);
		
		private var shpTab0:Shape = new Shape();
		private var shpTab1:Shape = new Shape();
		private var bmpCircle:Bitmap;
		
		private var txtActive:TextField = TxtTools.getTxt();
		private var txtPassive:TextField = TxtTools.getTxt();
		
		public function UiTab(nr:int) {
			
			addChild(shpTab0);
			addChild(shpTab1);
			
			bmpCircle = new embd_bmp2();
			addChild(bmpCircle);
			
			TxtTools.formatBasic(txtActive, 12, 0x202020,"font1");
			txtActive.text = String(nr);
			
			
			TxtTools.formatBasic(txtPassive, 10, 0x434343,"font0");
			txtPassive.text = String(nr);
			
			addChild(txtActive);
			addChild(txtPassive);
			
			
			over = false;
			resize(64);
		}
		
		public function resize(width:int):void {
			//var g:Graphics = graphics;
			shpTab0.graphics.clear();
			shpTab1.graphics.clear();
			sliceTab0.draw(shpTab0.graphics, 0, 0, width, sliceTab0.height);
			sliceTab1.draw(shpTab1.graphics, 0, 0, width, sliceTab1.height);
			
			bmpCircle.x = int((width - bmpCircle.width)/2);
			bmpCircle.y = -3;
			
			txtActive.x = int((width - txtActive.width)/2);
			txtActive.y = bmpCircle.y - 1;
			
			txtPassive.x = int((width - txtPassive.width)/2);
			txtPassive.y = -1;
			
			
		}
		public function set over(val:Boolean):void {
			shpTab0.visible = val;
			shpTab1.visible = !val;
			bmpCircle.visible = val;
			txtActive.visible = val;
			
			txtPassive.visible = !val;
		}
	}

}