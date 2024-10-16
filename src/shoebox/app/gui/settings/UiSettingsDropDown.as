package shoebox.app.gui.settings 
{
	import shoebox.plugin.PluginBase;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.TextField;
	import tools.BmpSliceDraw;
	import tools.txtTools.TxtTools;
	import tools.WireButtons;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class UiSettingsDropDown extends Sprite{
		
		[Embed(source="../../../../../src/assets/slice_settingsDdnSingle_3x.png")]
		private var embd_bmp0:Class;
		
		[Embed(source="../../../../../src/assets/slice_settingsDdnTop_3x.png")]
		private var embd_bmp1:Class;
		[Embed(source="../../../../../src/assets/slice_settingsDdnMid_3x.png")]
		private var embd_bmp2:Class;
		[Embed(source="../../../../../src/assets/slice_settingsDdnBtm_3x.png")]
		private var embd_bmp3:Class;
		
		private var slice:BmpSliceDraw;// = new BmpSliceDraw((new embd_bmp0()).bitmapData);
		
		private var wb:WireButtons = new WireButtons();
		private var btnInit:SimpleButton;
		private var btnTop:SimpleButton;
		private var btnBtm:SimpleButton;
		private var btnSingle:SimpleButton;
		private var btnMid:Vector.<SimpleButton> = new Vector.<SimpleButton>();
		private var txtLbl:Vector.<TextField> = new Vector.<TextField>();
		
		private var isOpen:Boolean = false;
		
		private var txtInit:TextField = TxtTools.getTxt();
		
		private var plugin:PluginBase;
		
		
		public function UiSettingsDropDown(plugin:PluginBase, width:int) {
			this.plugin = plugin;
			//var height:int;
			slice = new BmpSliceDraw((new embd_bmp0()).bitmapData);
			//height = slice.slices[0].height;
			var i:int;
			
			
			btnInit = slice.getButtonStatesSlices(width);
			addChild(btnInit);
			
			
			TxtTools.formatBasic(txtInit, 11, 0x141414);
			txtInit.text = plugin.settingsTemplates.length+(plugin.settingsTemplates.length==1 ? " Template..." : " Templates...");
			addChild(txtInit);
			//txtLbl[i].y = btnInit.x;
			//txtLbl[i].x = 8;
			
			
			if ( plugin.settingsTemplates.length == 1) {
				slice = new BmpSliceDraw((new embd_bmp0()).bitmapData);
				btnSingle = slice.getButtonStatesSlices(width);
				addChild(btnSingle);
				
				wb.click(btnSingle, onClickItemNr,0);
				
			}else{
				
				slice = new BmpSliceDraw((new embd_bmp1()).bitmapData);
				btnTop = slice.getButtonStatesSlices(width);
				addChild(btnTop);
				///*
				slice = new BmpSliceDraw((new embd_bmp2()).bitmapData);
				var mC:int = plugin.settingsTemplates.length - 2;//middle COUNT
				mC = Math.max(0, mC);
				for (i = 0; i < mC; i++) {
					var h:int = 16;// slice.slices[0].height;
					btnMid[i] = slice.getButtonStatesSlices(width, h);
					btnMid[i].y = h + i * h;
					//btnMid[i].visible = false;
					
					wb.click(btnMid[i], onClickItemNr, i + 1);//1,2,..
					
					addChild(btnMid[i]);
				}
				
				slice = new BmpSliceDraw((new embd_bmp3()).bitmapData);
				btnBtm = slice.getButtonStatesSlices(width);
				btnBtm.y = 16 + mC * 16;
				addChild(btnBtm);
				
				wb.click(btnTop, onClickItemNr,0);
				wb.click(btnBtm, onClickItemNr, plugin.settingsTemplates.length - 1);	
			}	
			
			for (i = 0; i < plugin.settingsTemplates.length; i++) {
				txtLbl[i] = TxtTools.getTxt();
				TxtTools.formatBasic(txtLbl[i], 11, 0x141414);
				txtLbl[i].text = plugin.settingsTemplates[i][0];
				txtLbl[i].y = i *16;
				txtLbl[i].x = 8;
				addChild(txtLbl[i]);
			}
			

			wb.click(btnInit, onClickInit);
			
			close();
		}
		
		private function onClickInit():void {
			if (!isOpen) {
				 open();
			}
		}
		private function onClickItemNr(nr:int):void {
			trace("CLICK: " + nr);
			
			if (isOpen) {
				 close();
			}
			
			plugin.settings = plugin.settingsTemplates[nr][1];//2nd container is the settings object
			UiSettings.instance.close();
			UiSettings.instance.init(plugin);
			
			
		}
		
		
		public function open():void {
			setOpenCloseState(true);
		}
		public function close():void {
			setOpenCloseState(false);
		}
		
		private function setOpenCloseState(isOpen:Boolean):void {
			this.isOpen = isOpen;
			var i:int;
			for (i = 0; i < txtLbl.length; i++) {
				txtLbl[i].visible = isOpen;
			}
			if (txtLbl.length == 1) {//just 1 setting
				btnSingle.visible = isOpen;
			}else{
				for (i = 0; i < btnMid.length; i++) {
					btnMid[i].visible = isOpen;
				}
				
				btnTop.visible = isOpen;
				btnBtm.visible = isOpen;
			}
			
		}
		
	}

}