package shoebox.app.gui 
{
	import com.greensock.plugins.StageQualityPlugin;
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.setTimeout;
	import mx.core.Window;
	import shoebox.app.gui.settings.UiSettingsButton;
	import tools.BmpSliceDraw;
	import tools.KeyBind;
	import tools.txtTools.TxtTools;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class UiPluginWindow{
		private static var g:Graphics;
		public static var window:NativeWindow;
		
		private static var	bkg:Sprite = new Sprite();
		private static var 	msg:TextField = TxtTools.getTxt();
		private static var 	btnOk:UiSettingsButton;
		private static var  fnBtnOk:Function;
		
		[Embed(source="../../../../src/assets/slice_settingsBkg_9x.png")]
		private static var embd_bmp0:Class;
		private static var sliceBkg:BmpSliceDraw = new BmpSliceDraw((new embd_bmp0()).bitmapData);
		
		
		private static var keyBind:KeyBind;
		
		public function UiPluginWindow(a_stage:Stage) {
			
			var options:NativeWindowInitOptions = new NativeWindowInitOptions();
			options.type = NativeWindowType.UTILITY;
			options.resizable = false;
			options.maximizable = false;
			options.minimizable = false;
			options.transparent = true;
			options.systemChrome = "none";
			
			window = new NativeWindow(options);
			window.stage.scaleMode = StageScaleMode.NO_SCALE;
			window.stage.align = StageAlign.TOP_LEFT;
			window.activate();
			window.visible = false;
			
			//UiPluginWindow.keyBind = new KeyBind(a_stage);//stage.nativeWindow.stage
			UiPluginWindow.keyBind = new KeyBind(window.stage);//stage.nativeWindow.stage
			
			
			
			bkg.addEventListener(MouseEvent.MOUSE_DOWN, onMouseBkgDown);
			bkg.addEventListener(MouseEvent.RIGHT_CLICK, fnCloseRightClick);
		}

		public function fnCloseRightClick(e:*=null):void {//remove what we created before
			close();
		}
		/*
		this.addEventListener(MouseEvent.CLICK, fnClick);
			this.addEventListener(MouseEvent.RIGHT_CLICK, fnClick);
			this.addEventListener(MouseEvent.MIDDLE_CLICK, fnClick);
		}*/
		private function onMouseBkgDown(e:MouseEvent):void {
			//if (this.mouseEnabled && this.visible && this.alpha == 1) {
				window.startMove();
			//}
		}
		
		
		
		private static var lastPosX:int = -1;
		private static var lastPosY:int = -1;
		
		public static function focus():void {
			window.orderToFront();
			UiWindowManager.sort();
		}
		
		public static function highlightMsg(key:String):void {
			TxtTools.formatKeywordsColor(msg, [key], 0xffa200);//highlight particular text part
			
		}
		
		public static function setMessage(message:String = ""):void {
			TxtTools.formatBasic(msg, 14, 0xededed);
			msg.text = message;
			msg.background = true;
			msg.backgroundColor = 0;
			//var tmpH:int = msg.height;
			//msg.autoSize = TextFieldAutoSize.NONE;
			//msg.width = width;
			//msg.height = tmpH;
			
			//height += msg.height;
			//msg.y = height - msg.height;
		}
		
		
		public static function init(width:int, height:int,message:String="",fnOkButton:Function=null):Stage {
			close();
			//var ext:int = 12;
			
			if (message != "" || fnOkButton != null) {
				TxtTools.formatBasic(msg, 14, 0xededed);
				msg.text = message;
				msg.background = true;
				msg.backgroundColor = 0;
				var tmpH:int = msg.height;
				msg.autoSize = TextFieldAutoSize.NONE;
				msg.width = width;
				msg.height = tmpH;
				
				height += msg.height;
				msg.y = height - msg.height;
			}
			
			window.visible = true;
			window.width = width;
			window.height = height;
			bkg.graphics.clear();
			sliceBkg.draw(bkg.graphics, 0, 0, width, height);
			
			
			//HACK: http://www.ngpixel.com/2009/07/06/adobe-air-bring-a-window-to-front-by-clicking-the-systemtrayicon/
			window.alwaysInFront = true;
			window.alwaysInFront = false;
			
			window.orderToFront();
			window.activate();
			//window.stage.focus = window.stage;
			//setTimeout(window.activate, 500);
			//window.restore();
			UiWindowManager.sort();
			
			//window.stage.
			
			
			if (lastPosX == -1){
				window.x = Main.instance.stage.nativeWindow.x;
				window.y = Main.instance.stage.nativeWindow.y + 108+8;
			}/*else {
				
				window.x = lastPosX;
				window.y = lastPosY;
			}*/
			lastPosX = window.x;
			lastPosY = window.y;
			
			
			
			window.stage.addChild(bkg);
			
			
			
			fnBtnOk = fnOkButton;
			if (message != "" || fnOkButton != null) {
				window.stage.addChild(msg);
				if (fnOkButton != null) {
					btnOk = new UiSettingsButton("Confirm", 64, onKeyExecute);//enter key
					btnOk.y = Math.ceil(height - msg.height / 2 - btnOk.height / 2);
					btnOk.x = width - btnOk.width - 8;
					window.stage.addChild(btnOk);
					
					keyBind.bindKey(13, onKeyExecute);
					
				}
			}
			
			
			return window.stage;
		}
		
		private static function onKeyExecute():void {//HIDE WINDOW AND SHOW POPUP CONFIRMATION MESSAGE
			fnBtnOk();
			close();
			UiMain.instance.uiStatusPop.popup(msg.text);
		}
		
		
		
		
		
		public static function get isOpen():Boolean {
			return window.visible;
		}
		public static function get hasFocus():Boolean {
			if (window.stage.mouseX >= 0 && window.stage.mouseX <= window.stage.stageWidth && window.stage.mouseY >= 0 && window.stage.mouseY <= window.stage.stageHeight) {
				return true;
			}
			return false;
		}
		
		
		
		
		public static function resize(width:int, height:int):void {
			window.width = width;
			window.height = height;
			bkg.graphics.clear();
			sliceBkg.draw(bkg.graphics, 0, 0, width, height);
		}
		
		public static function close():void {
			var num:int = window.stage.numChildren;
			for (var i:int = 0; i < num; i++) {
				window.stage.removeChildAt(0);
				/*var idx:int = Math.min(window.stage.numChildren-1, i);
				var c:DisplayObject = window.stage.getChildAt(idx);
				if (c != ..){
					window.stage.removeChild(c);
				}*/
			}
			bkg.graphics.clear();
			window.visible = false;
		}
		
		
		
		
		
		
	}

}