package shoebox.app.gui 
{
	import shoebox.plugin.PluginBase;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import tools.BmpSliceDraw;
	import tools.txtTools.TxtTools;
	/**
	 * ...
	 * @author Hendrik
	 */
	public class UiDroplet extends Sprite{
		
		[Embed(source="../../../../src/assets/sprite_dropDashedBorder.png")]
		private var embd_bmp0:Class;
		[Embed(source="../../../../src/assets/sprite_dropFilled.png")]
		private var embd_bmp1:Class;
		[Embed(source="../../../../src/assets/sprite_dropOver.png")]
		private var embd_bmp2:Class;
		
		[Embed(source="../../../../src/assets/slice_bucketTxtBkg_3x.png")]
		private var embd_bmp3:Class;
		[Embed(source="../../../../src/assets/sprite_pasteOverArrow.png")]
		private var embd_bmp4:Class;
		
		
		
		private var sliceTxtBkg:BmpSliceDraw = new BmpSliceDraw((new embd_bmp3()).bitmapData);
		private var bmpOutline:Bitmap = new embd_bmp0();
		private var bmpFilled:Bitmap = new embd_bmp1();
		private var bmpIcon:Bitmap;
		
		private var txtName:TextField = TxtTools.getTxt();
		
		private var bmpPasteOver:Bitmap = new embd_bmp4() as Bitmap;
		private var sprPasteOver:Sprite = new Sprite();
		private var txtPasteOver:TextField = TxtTools.getTxt();
		
		private var bmpDropOver:Bitmap = new embd_bmp2();
		private var sprDropArea:Sprite = new Sprite();
		
		private var shpTxtBkg:Shape = new Shape();
		public function UiDroplet(plugin:PluginBase) {
			//addChild(bmpFilled);
			addChild(bmpOutline);
			addChild(bmpDropOver);
			if (plugin.icon != null){
				bmpIcon = new Bitmap(plugin.icon);
				addChild(bmpIcon);
				bmpIcon.x = bmpIcon.y = (76 - 48) / 2;
				bmpIcon.y -= 4;
				bmpIcon.alpha = 0.4;
			}
			
			addChild(shpTxtBkg);
			addChild(txtName);
			
			
			
			
			addChild(sprPasteOver);
			addChild(sprDropArea);
			sprDropArea.name = String(plugin.sysDropNr);
			bmpFilled.visible = false;
			
			//SETUP sprPasteOver
			sprPasteOver.addChild(bmpPasteOver);
			sprPasteOver.addChild(txtPasteOver);
			bmpPasteOver.y = 76-27;
			TxtTools.formatBasic(txtPasteOver, 12, 0x220b06);
			txtPasteOver.autoSize = TextFieldAutoSize.NONE;
			var f:TextFormat = txtPasteOver.getTextFormat();
			f.align = TextFormatAlign.CENTER;
			txtPasteOver.defaultTextFormat = f;
			txtPasteOver.width = 72;
			txtPasteOver.height = 12;
			txtPasteOver.text = "some label";
			txtPasteOver.y = 76 - 20+1;
			sprPasteOver.alpha = 0;//fade in later if needed
			
			//trace("bmp over: " + bmpPasteOver, bmpPasteOver.width);
			//
			
			
			//TEXTFIELD
			txtName.text = plugin.label;
			TxtTools.formatBasic(txtName, 8, 0x1c1c1c);
			if (txtName.width > 72) {
				txtName.autoSize = TextFieldAutoSize.NONE;
				txtName.width = 72;
			}
			txtName.x = (72 - txtName.width) / 2;
			txtName.y = 72 - txtName.height+2;
			var wT:int = Math.min(72, txtName.width + 8);//cap at 72
			shpTxtBkg.graphics.clear();
			sliceTxtBkg.draw(shpTxtBkg.graphics, (76-wT)/2, txtName.y+3, wT);
			
			//drop area for the files
			sprDropArea.graphics.beginFill(0x000000, 0.0);
			sprDropArea.graphics.drawRect(0,0,72,72);
			sprDropArea.graphics.endFill();
			
			
			plugin.sysDropArea = sprDropArea;
			plugin.sysDropUi = this;
			setDropOver(false);
		}
		
		public function setDropOver(state:Boolean):void {
			bmpDropOver.visible = state;
		}
		
		public function setPasteOver(state:Boolean,msg:String=""):void {
			TweenMax.to(sprPasteOver, 0.1, { alpha:(state ? 1:0) } );
			bmpDropOver.visible = state;
			if (state && msg != "") {
				txtPasteOver.text = msg;
			}
		}
	}

}