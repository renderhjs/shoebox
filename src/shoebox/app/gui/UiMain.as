package  shoebox.app.gui
{
	import shoebox.app.gui.tabs.UiTab;
	import shoebox.app.gui.tabs.UiTabs;
	import shoebox.app.PluginManager;
	import com.greensock.plugins.StageQualityPlugin;
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import shoebox.app.gui.tabs.UiTabs;
	import shoebox.app.PluginManager;
	import shoebox.app.SettingsManager;
	import tools.BmpSliceDraw;
	import tools.KeyBind;
	import tools.WireButtons;
	/**
	 * ...
	 * @author Hendrik
	 */
	public class UiMain extends Sprite{
		public static var instance:UiMain;
		
		[Embed(source="../../../../src/assets/slice_mainBkg_9x.png")]
		private var embd_bmp0:Class;
		[Embed(source="../../../../src/assets/slice_bottomTab_3x.png")]
		private var embd_bmp1:Class;
		[Embed(source="../../../../src/assets/sprite_dragSides.png")]
		private var embd_bmp2:Class;
		[Embed(source="../../../../src/assets/sprites_btnClose_3x.png")]
		private var embd_bmp3:Class;
		
		
		
		
		
		public var uiStatusPop:UiStatusPopUp = new UiStatusPopUp();
		
		private var wb:WireButtons;
		private var g:Graphics;
		private var sliceMainBkg:BmpSliceDraw = new BmpSliceDraw((new embd_bmp0()).bitmapData);
		private var sliceBottomBkg:BmpSliceDraw = new BmpSliceDraw((new embd_bmp1()).bitmapData);
		private var sliceSideGrab:BmpSliceDraw = new BmpSliceDraw((new embd_bmp2()).bitmapData);
		private var sliceCloseBtn:BmpSliceDraw = new BmpSliceDraw((new embd_bmp3()).bitmapData);
		
		private var btnClose:SimpleButton = new SimpleButton();
		
		private var layerBackground:Sprite = new Sprite();
		//private var arrayDroplets:Vector.<UiDroplet> = new Vector.<UiDroplet>();
		
		public var uiTabs:UiTabs = new UiTabs();
		
		public function UiMain() {
			instance = this;
			
			wb		= new WireButtons();
			
			//keyBind
			
			addChild(layerBackground);
			
			btnClose.upState = sliceCloseBtn.getShapeSingle(0);
			btnClose.overState = sliceCloseBtn.getShapeSingle(1);
			btnClose.downState = sliceCloseBtn.getShapeSingle(2);
			
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.beginFill(0xff0000);
			g.drawRect(0, 0, 17, 17);
			btnClose.hitTestState = s;
			wb.click(btnClose, fnCloseApp);
			
			addChild(btnClose);
			
			//
			var i:int;
			for (i = 0; i < PluginManager.plugins.length; i++){
				var d:UiDroplet = PluginManager.plugins[i].ui;
				//d.name = i.toString();
				addChild(d);
				d.x = 12 + i * (72 + 10);
				d.y = 10;
			}
			addChild(uiTabs);
			addChild(uiStatusPop);
			
			
			uiTabs.y = 93;
			
			layerBackground.addEventListener(MouseEvent.MOUSE_DOWN, onMouseBkgDown);
			
		}
		
		
		public function initTab(nr:int):void {
			trace("INIT TAB: " + nr);
			uiTabs.setTab(nr);
		}
		
		
		
		public function resize(w:int, h:int):void {//RESIZE THE MAIN UI WINDOW
			
			g = layerBackground.graphics;
			g.clear();
			
			sliceBottomBkg.draw(g, 0, h - sliceBottomBkg.height, w, h - sliceBottomBkg.height);
			sliceMainBkg.draw(g, 0, 0, w, h - 17);//draw Body
			
			//
			sliceSideGrab.draw(g, 2, 22);
			sliceSideGrab.draw(g, w - 2 - sliceSideGrab.width, 22);
			
			btnClose.x = w - 17;
			btnClose.y = h - 17;
			
			uiTabs.resize(w);
		}
		
		
		
		
		private function onMouseBkgDown(e:MouseEvent):void {
			UiWindowManager.sort();//sort things again
			stage.nativeWindow.startMove();
		}
		
		private function fnCloseApp():void {
			NativeApplication.nativeApplication.exit();
		}
		
	}

}