package 
{
	import flash.events.ContextMenuEvent;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import shoebox.app.gui.settings.UiSettings;
	import shoebox.app.gui.UiDroplet;
	import shoebox.app.gui.UiMain;
	import shoebox.app.gui.UiPluginWindow;
	import shoebox.app.gui.UiWindowManager;
	import shoebox.app.PluginManager;
	import shoebox.app.SettingsManager;
	import shoebox.app.Version;
	import shoebox.plugin.event.PluginClipBoardTransferEvent;
	import shoebox.plugin.PluginBase;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeDragManager;
	import flash.display.BitmapData;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import mx.events.AIREvent;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.PluginHelper;
	import tools.KeyBind;
	import tools.WireButtons;
	
	/**
	 * ...
	 * @author renderhjs
	 */
	public class Main extends Sprite {
		
		private var pluginManager:PluginManager = new PluginManager();
		private var pluginWindow:UiPluginWindow;
		private var uiMain:UiMain;
		public var uiSettings:UiSettings;
		private var pluginTarget:PluginBase = null;
		private var wb:WireButtons = new WireButtons();
		public static var instance:Main;
		
		private var _contextMenu:ContextMenu;
		
		private var kb:KeyBind;
		
		public function Main():void {
			
			instance = this;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			//
			kb = new KeyBind(stage);
			SettingsManager.init();//load XML AND INITIALIZE PLUGINS THAT ARE NEEDED
			
			
			_contextMenu = new ContextMenu();
			_contextMenu.hideBuiltInItems();	
			var copyrightNotice:ContextMenuItem = new ContextMenuItem("renderhjs.net/shoebox");
			function openLink(e:ContextMenuEvent):void {
				navigateToURL(new URLRequest("http://renderhjs.net/shoebox/"), "_blank");
			}
			copyrightNotice.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, openLink);
			var version:ContextMenuItem = new ContextMenuItem("version "+Version.nr,true,false);
			_contextMenu.customItems.push(copyrightNotice);
			_contextMenu.customItems.push(version);
			//contextMenu = my_menu;
			
			kb.bindKey(49, onKeyNumericDown, 0);
			kb.bindKey(50, onKeyNumericDown, 1);
			kb.bindKey(51, onKeyNumericDown, 2);
			kb.bindKey(52, onKeyNumericDown, 3);
			kb.bindKey(53, onKeyNumericDown, 4);
			kb.bindKey(54, onKeyNumericDown, 5);
			kb.bindKey(55, onKeyNumericDown, 6);
			kb.bindKey(56, onKeyNumericDown, 7);
			kb.bindKey(57, onKeyNumericDown, 8);
			
			
			
			init();
		}
		
		
		
		
		
		
		public function init():void {
			
			//SettingsManager.init();
			//pluginManager.init();//init the plugins we need
			
			// UI STUFF
			pluginWindow = new UiPluginWindow(stage);
			uiMain = new UiMain(); addChild(uiMain);
			
			
			uiSettings = new UiSettings();
			assignPluginMouseEvents();
			
			trace("\n\nstart");
			
			uiMain.initTab(SettingsManager.loadTabPage());//show the first tab
			
			
			
			
			
			
			//uiMain.resize(stage.stageWidth, stage.stageHeight);
			
			stage.nativeWindow.x = (stage.fullScreenWidth - stage.stageWidth) / 2;
			stage.nativeWindow.y = (stage.fullScreenHeight - stage.stageHeight) / 2;
			
			NativeApplication.nativeApplication.autoExit = true;
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onApplicationActivate);
			
			
			
			
			//stage.addEventListener(AIREvent., onApplicationActivate);
			//addEventListener
			stage.addEventListener(Event.RESIZE, onStageResize);
			stage.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,onDragIn);
			stage.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDrop);
			stage.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, onDragExit);
			//
			
			//stage.nativeWindow.addEventListener(Event.ACTIVATE, onWindowActivate);
			uiMain.addEventListener(MouseEvent.RIGHT_CLICK, onMouseRightClickMain);
			
			
			UiWindowManager.sort();
			
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onApplicationExit);
			UiPluginWindow.window.addEventListener(Event.CLOSE, onApplicationExit);
			UiPluginWindow.window.addEventListener(Event.EXITING, onApplicationExit);
			UiPluginWindow.window.addEventListener(Event.CANCEL, onApplicationExit);
			
		}
		
		private function onMouseRightClickMain(e:MouseEvent):void {//OPEN SETTINGS
			var hit:Boolean = false;
			for (var i:int = 0; i < PluginManager.plugins.length; i++) {
				var sp:Sprite = PluginManager.plugins[i].sysDropArea;
				if (sp.visible) {
					var r:Rectangle = sp.getRect(sp);
					if (r.contains(sp.mouseX, sp.mouseY)) {
						hit = true;
						break;
					}
				}
			}
			if (!hit){
				_contextMenu.display(stage, stage.mouseX, stage.mouseY);
			}
		}
		
		private function assignPluginMouseEvents():void {
			for (var i:int = 0; i < PluginManager.plugins.length; i++) {
				var sp:Sprite = PluginManager.plugins[i].sysDropArea;
				//trace("RC: " + PluginManager.plugins[i].label);
				sp.addEventListener(MouseEvent.RIGHT_CLICK, onMouseRightClickDroplet);
				wb.click(sp, onMouseLeftClickDroplet, PluginManager.plugins[i]);
				wb.over(sp, onMouseRollOverDroplet, PluginManager.plugins[i]);
				wb.out(sp, PluginManager.plugins[i].sysDropUi.setPasteOver, false);
				
				sp.addEventListener(MouseEvent.MIDDLE_CLICK, onMouseMiddleClickDroplet);
				
				sp.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownDroplet);
				//sp.addEventListener(MouseEvent.MOUSE_UP, onMouseExitDroplet);
				sp.addEventListener(MouseEvent.MOUSE_OUT, onMouseExitDroplet);
			}
			
			
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		private function onApplicationExit(e:Event):void {
			trace("exit");
			e.preventDefault();
			setTimeout(NativeApplication.nativeApplication.exit, 100);
		}
		
		private function onApplicationActivate(e:*):void {
			trace("onApplicationActivate");
			
			//CHECK FOR IMPORT SCRIPT
			var valid:Boolean = false;
			
			var type:String = getClipBoardDataType();
			if (type == "text") {
				var s:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
				
				if (s.indexOf("::ShoeBox:") != -1) {
					
					var a:Array = s.split("::ShoeBox:");
					
					trace("setttings: " + a.length + "x");
					var i:int;
					var j:int;
					for (i = 0; i < a.length; i++) {
						if (a[i].indexOf(":") != -1 && a[i].indexOf("{") != -1 && a[i].indexOf("}") != -1){
							var pId:String = a[i].slice( 0, a[i].indexOf(":"));
							var dta:String = a[i].slice( a[i].indexOf(":") + 1, a[i].lastIndexOf("}")+1);

							if (dta.indexOf("{") == 0 && dta.lastIndexOf("}") == dta.length - 1) {
								var found:Boolean = false;
								var pl:PluginBase;
								for (j = 0; j < PluginManager.plugins.length; j++) {
									if (PluginManager.plugins[j].classId == pId) {
										found = true;
										pl = PluginManager.plugins[j];
										break;
									}
								}
								
								if (found) {
									
									
									//TODO THIS
									
									var obj:Object = PluginHelper.getSysJsonObj(dta);
									if (obj != null) {
										
										
										//verify that all keyValues match up
										var keys:Array = [];
										var key:String;
										for (key in pl.settings) {
											keys.push(key);
										}
										
										//now read whats in the cookie
										var same:Boolean = true;
										var count:int = 0;
										for (key in obj) {
											if (keys.indexOf(key) == -1) {
												same = false;
												break;
											}else {
												count++;
											}
										}
										if (same && count == keys.length) {//cookie is valid and can be loaded
											pl.settings = obj;
											
											valid = true;

											uiMain.uiStatusPop.popup("Settings \""+pl.label+"\" imported");
										}
									}
								}
							}
						}
					}
					
					if (!valid) {
						uiMain.uiStatusPop.popup("Error importing setting");
					}

					Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, "");//empty the clipboard
				}
			}
			/*
			if (!valid) {
				//TODO: SHOW MESSAGE THAT IT FAILED IMPORTING
				UiWindowManager.sort();
			}
			*/
			/*
			::ShoeBox:createSpriteSheet.PluginCreateSpriteSheet:{"powerOfTwo":false,"fileName":"sprites.png","padding":0,"idFileNamesVar":"@.png","txtFormatOuter":"@loop","cropAlpha":true,"txtFormatExtention":"css","useCssOverHack":true,"txtFormatLoop":"@id{width:@w;height:@h;background: url(\"sprites.png\") no-repeat -@xpx -@ypx;}\\n"}
			*/
			
			UiWindowManager.sort();
		}
		
		
		private function getClipBoardDataType():String {
			var clipTxt:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
			if (clipTxt != null) {
				return "text";
			}else {
				var clipBmp:BitmapData = Clipboard.generalClipboard.getData(ClipboardFormats.BITMAP_FORMAT) as BitmapData;
				if (clipBmp != null) {
					return "image";
				}
			}
			return "";
		}
		
		
		
		
		
		
		
		
		private var timeHoldDown:int = 300;//in ms
		
		private function onMouseDownDroplet(e:MouseEvent):void {//detect a hold down...
			var plugin:PluginBase =  PluginManager.plugins[int(Number(e.target.name))];
			plugin.holdStartTime = getTimer();
			plugin.holdDown = true;
			setTimeout(onMouseHoldDownDelay, timeHoldDown, plugin);
		}
		private function onMouseHoldDownDelay(plugin:PluginBase):void {
			if (plugin.holdStartTime > 0 && plugin.holdDown) {
				if (plugin.listenerFunctionEventClick != null) {
					plugin.listenerFunctionEventClick();
				}
			}
		}
		private function onMouseExitDroplet(e:MouseEvent):void {//detect a hold down...
			//trace("release...or out");
			var plugin:PluginBase =  PluginManager.plugins[int(Number(e.target.name))];
			plugin.holdDown = false;
		}
		
		private function onKeyNumericDown(nr:int):void {
			uiMain.initTab(nr);
		}
		
		
		
		
		
		
		
		
		
		private function onMouseMiddleClickDroplet(e:MouseEvent):void {//OPEN SETTINGS
			/*uiSettings.init(PluginManager.plugins[int(Number(e.target.name))]);
			uiMain.uiStatusPop.block(true);*/
			PluginManager.instance.dispatchRepeatAction(int(Number(e.target.name)));
		}
		
		private function onMouseRightClickDroplet(e:MouseEvent):void {//OPEN SETTINGS
			trace("name..."+e.target.name)
			uiSettings.init(PluginManager.plugins[int(Number(e.target.name))]);
			uiMain.uiStatusPop.block(true);
		}
		private function onMouseLeftClickDroplet(pl:PluginBase):void {//NORMAL CLICK, REPEAT ACTION FOR THIS DROPLET OR PASTE FROM CLIPBOARD
			
			var t:int = getTimer() - pl.holdStartTime;
			if (t >= timeHoldDown && pl.holdDown) {
				//trace("long click release, unused");
			}else{
				
				var type:String = getClipBoardDataType();
				if (type != "") {
					if (type == "image") {
						PluginManager.instance.dispatchClipboardInImage(pl.sysDropNr,  Clipboard.generalClipboard.getData(ClipboardFormats.BITMAP_FORMAT) as BitmapData);
					}else if (type == "text") {
						PluginManager.instance.dispatchClipboardInText(pl.sysDropNr,  String(Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT)));
					}
				}else {
					if (pl.listenerFunctionEventClick != null) {
						pl.listenerFunctionEventClick();
					}
				}
			}
		}
		private function onMouseRollOverDroplet(pl:PluginBase):void {
			
			var type:String = getClipBoardDataType();
			if (type != "") {
				if ((pl.sysSupportEventClipboardInText && type == "text") || (pl.sysSupportEventClipboardInImage && type == "image")) {
					pl.sysDropUi.setPasteOver(true,"paste "+type);
				}
			}
		}
		
		

		public function onMouseDragOverMove(pos:Point,e:NativeDragEvent):void {
			var i:int; var area:Sprite; var pl:PluginBase;
			for (i = 0; i < PluginManager.plugins.length; i++) {
				pl = PluginManager.plugins[i];
				area = pl.sysDropArea;
				if (area.hitTestPoint(uiMain.x + pos.x, uiMain.y + pos.y, false)) {
					if (pl.sysSupportEventFileIn) {
						var filesArray:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
						var numOk:int = 0;
						for each (var file:File in filesArray) {
							if (pl.extentions.indexOf( file.extension ) != -1) {
								numOk++;
								break;
							}
						}
						if (numOk > 0 || pl.extentions.length == 0){//plugin accepts at least 1 item of the to drop files
							pl.sysDropUi.setDropOver(true);
						}
						pluginTarget = pl;
						break;
					}
				}else {
					pl.sysDropUi.setDropOver(false);
				}
			}
		}
		public function onDragIn(e:NativeDragEvent):void {
			pluginTarget = null;
			NativeApplication.nativeApplication.activate();//ACTIVATE THIS APPLICATION
			NativeDragManager.acceptDragDrop(stage);
			onMouseDragOverMove(new Point(e.stageX,e.stageY),e);
		}

		public function onDrop(e:NativeDragEvent):void {
			if (pluginTarget != null){
				var filesArray:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				//var files:Vector.<File> = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Vector.<File>;
				//trace("# DROP."+filesArray);
				//trace("Plugin. "+pluginTarget.label);
				
				
				if (e.dropAction == "copy") {
					
				}else if (e.dropAction == "move") {
					
				}else if (e.dropAction == "link") {
					
				}
				
				
				
				var files:Vector.<File> = new Vector.<File>();
				for each (var file:File in filesArray) {
					if (pluginTarget.extentions.length == 0 || pluginTarget.extentions.indexOf( file.extension ) != -1) {
						files.push( file);	
					}
				}
				UiPluginWindow.close();//close if, former plugin window
				PluginManager.instance.dispatchFilesIn(pluginTarget.sysDropNr,files);
				
			}
			pluginTarget = null;
		}

		public function onDragExit(e:NativeDragEvent):void {
			onMouseDragOverMove( new Point(-1000, 0),e);
		}
		
		
		private function onStageResize(e:Event):void {
			uiMain.resize(stage.stageWidth, stage.stageHeight);
		}
		
	}
	
}