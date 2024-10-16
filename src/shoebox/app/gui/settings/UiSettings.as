package shoebox.app.gui.settings
{
	import shoebox.app.gui.UiMain;
	import shoebox.app.gui.UiWindowManager;
	import shoebox.app.SettingsManager;
	import shoebox.plugin.PluginBase;
	import com.greensock.loading.data.VideoLoaderVars;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.display.Graphics;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	import shoebox.plugin.PluginHelper;
	import tools.BmpSliceDraw;
	import tools.txtTools.TxtTools;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class UiSettings extends Sprite {
		[Embed(source="../../../../../src/assets/slice_settingsBkg_9x.png")]
		private var embd_bmp0:Class;
		public static var instance:UiSettings;
		private var sliceBkg:BmpSliceDraw = new BmpSliceDraw((new embd_bmp0()).bitmapData);
		
		
		private var sprUi:Sprite = new Sprite();
		private var layerBkg:Sprite = new Sprite();
		private var txtTitle:TextField = TxtTools.getTxt();
		private var txtInfo:TextField = TxtTools.getTxt();
		private var vecVariables:Vector.<UiSettingsVariableItem> = new Vector.<UiSettingsVariableItem>();
		private var g:Graphics;
		
		public var window:NativeWindow;
		private var btnOk:UiSettingsButton = new UiSettingsButton("Ok",45,onClickOk);
		//private var btnImport:UiSettingsButton = new UiSettingsButton("Import",64,onClickImport);
		private var btnExport:UiSettingsButton = new UiSettingsButton("Export",64,onClickExport);
		
		private var btnsTemplate:UiSettingsDropDown;
		
		private var targetPlugin:PluginBase = null;
		
		public function UiSettings() {
			UiSettings.instance = this;
			var options:NativeWindowInitOptions = new NativeWindowInitOptions();
			//options.type = NativeWindowType.NORMAL;
			options.type = NativeWindowType.UTILITY;
			options.resizable = false;
			options.maximizable = false;
			options.minimizable = false;
			options.transparent = true;
			options.systemChrome = "none";
			
			
			
			sprUi.addChild(layerBkg);
			sprUi.addChild(txtTitle);
			sprUi.addChild(txtInfo);
			sprUi.addChild(btnOk);
			//sprUi.addChild(btnImport);
			sprUi.addChild(btnExport);
			
			
			btnOk.visible = btnExport.visible = false;
			
			window = new NativeWindow(options);
			window.stage.scaleMode = StageScaleMode.NO_SCALE;
			window.stage.align = StageAlign.TOP_LEFT;
			window.stage.addChild(sprUi);
			window.visible = false;
			window.activate();
			
			
			
			TxtTools.formatBasic(txtTitle, 12, 0x7c7c7c);
			TxtTools.formatBasic(txtInfo, 10, 0x7c7c7c);
			
			layerBkg.addEventListener(MouseEvent.RIGHT_CLICK, close);
		}
		
		public function focus():void {
			
			window.orderToFront();
			UiWindowManager.sort();
		}
		
		private function storeSettings():void {
			if (targetPlugin != null) {
				
				trace("store:...");
				var i:int = 0;
				for (var key:String in targetPlugin.settings) {
					var raw:String = vecVariables[i].txtValue.text;
					var type:String = vecVariables[i].type;
					
					targetPlugin.settings[key] = vecVariables[i].parseDataFromTxtString();
					
					vecVariables[i].txtValue.text = String(targetPlugin.settings[key]);//take over the fixes
					vecVariables[i].reFormat();//reformat the color stuff
					
					trace("key: " + key + " = " + targetPlugin.settings[key]+", = "+raw);
					i++;
				}
				//save to cookie
				SettingsManager.savePluginSettings(targetPlugin);
				
			}
		}
		
		private function onClickOk():void {
			//save changes to Object
			storeSettings();
			setTimeout(close, 200);//set timeout on purpose, so the checked/ changed values are visible
		}
		/*
		private function onClickImport():void {
			var s:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
			if (s != null) {
				
				//TODO: VALIDATE
				if (s.indexOf("::ShoeBox:") != -1) {
					var valid:Boolean = false;
					var a:Array = s.split("::ShoeBox:");
					
					trace("setttings: " + a.length + "x");
					if (a.length == 1) {//only 1 setting
						
						
						
						
						
						
						
						var obj:Object = PluginHelper.getSysJsonObj(s);
						if (obj != null) {
							for (var key:String in obj) {
								if (targetPlugin.settings[key] != undefined) {
									targetPlugin.settings[key] = obj[key];
								}
							}
							close();
							init(targetPlugin);
						}
								
						
						
						
					}
					

				}
				
				
			}
			
		}*/
		private function onClickExport():void {
			storeSettings();//store current typed values
			var json:String = PluginHelper.getSysJsonString(targetPlugin.settings);
			PluginHelper.setClipBoardText("::ShoeBox:"+targetPlugin.classId+":"+json);
		}
		
		public function init(plugin:PluginBase):void {
			targetPlugin = plugin;
			var i:int = 0;
			var j:int = 0;
			var w:int = 256;
			
			
			
			
			
			g = layerBkg.graphics;
			g.clear();
			btnOk.visible = btnExport.visible = true;
			window.visible = true;
			
			
			
			for (i = 0; i < vecVariables.length; i++) {
				if (vecVariables[i] != null) {
					if (sprUi.contains( vecVariables[i] )) {
						sprUi.removeChild(vecVariables[i]);
					}
				}
			}
			vecVariables = new Vector.<UiSettingsVariableItem>();
			
			//TXT
			var sTxt:int = 8;
			txtTitle.text = "Settings " + plugin.label + "";
			TxtTools.formatKeywordsColor(txtTitle, [plugin.label], 0x111111);//make the tool name darker
			//txtTitle.text = "Settings";
			txtTitle.x = txtTitle.y = 6;
			
			
			
			
			//get alphabetical order
			var key:String;
			var order:Array = [];
			var sort:Array = [];
			for (key in plugin.settings) {
				order.push(key);
				sort.push(key);
				vecVariables.push(null);
			}
			sort.sort(Array.UNIQUESORT);
			trace("sort: " + sort);
			
			
			//FIND GROUPS
			var grps:Array = [];
			for (i = 0; i < sort.length; i++) {
				var id:String = "";
				for (j = 0; j < sort[i].length; j++) {
					var c:String = sort[i].charAt(j);
					if (j > 0 && c != c.toLowerCase()){
						id = sort[i].slice(0, j);
						break;
					}
				}
				if (id == "") {
					id = sort[i];
				}
				id = id.toLowerCase();
				if (grps.indexOf(id) == -1){
					grps.push(id);
				}
				
			}
			trace("> " + grps);
			
			var grpIdx:int = 0;
			var yBottom:int = 32+15;
			var aKeyWords:Array = [];//description keyword highlights
			for (i = 0; i < order.length; i++) {
				key = sort[i];
				
				if (i > 0 && key.indexOf(grps[grpIdx]) != 0) {
					grpIdx++;
				}
				
				var w2:int = w - sTxt * 2;
				//trace("SETTINGS C: >" + plugin.settings[key] + "< ("+key+")");
				var elm:UiSettingsVariableItem = new UiSettingsVariableItem(key,plugin.settings[key],typeof(plugin.settings[key]),w2*0.5,w2*0.5);
				elm.x = sTxt;
				elm.y = 32 + i * 15	+grpIdx * 2;
				yBottom = Math.max(yBottom, elm.y + 15);
				aKeyWords.push(key);
				
				sprUi.addChild(elm);
				//trace("SETTINGS D: >" + elm.txtValue.text + "< ("+key+")");
				
				elm.txtValue.addEventListener(Event.CHANGE, function(e:Event):void { 
					fnTextInput(e.target.parent);
				}); 
				elm.txtValue.addEventListener(FocusEvent.FOCUS_IN, function(e:Event):void { 
					var elmSub:UiSettingsVariableItem = e.target.parent as UiSettingsVariableItem;
					var txt:TextField = elmSub.txtValue;
					trace(",... ? "+elmSub.type,txt.text.length);
					if (elmSub.type != "boolean" && txt.text.length > 4 ) {
						trace(",... ? B");
						setTimeout(fnTextSelectText, 20, txt);//stupid bug doesn't let me set the focus right away at this very moment
					}
				}); 
				elm.txtValue.addEventListener(MouseEvent.CLICK, function(e:Event):void {
					var elmSub:UiSettingsVariableItem = e.target.parent as UiSettingsVariableItem;
					var txt:TextField = elmSub.txtValue;
					if (elmSub.type == "boolean") {
						fnInvertBoolean(elmSub);
						txt.setSelection(txt.text.length, txt.text.length);
					}
				});
				
				
				//vecVariables.push(elm);
				vecVariables[order.indexOf(key)] = elm;
				//i++;
			}
			
			/*
			
			var aKeyWords:Array = [];
			
			for (key in plugin.settings) {
				var w2:int = w - sTxt * 2;
				//trace("SETTINGS C: >" + plugin.settings[key] + "< ("+key+")");
				var elm:UiSettingsVariableItem = new UiSettingsVariableItem(key,plugin.settings[key],typeof(plugin.settings[key]),w2*0.5,w2*0.5);
				elm.x = sTxt;
				elm.y = 32+i*16;
				aKeyWords.push(key);
				
				sprUi.addChild(elm);
				//trace("SETTINGS D: >" + elm.txtValue.text + "< ("+key+")");
				
				elm.txtValue.addEventListener(Event.CHANGE, function(e:Event):void { 
					fnTextInput(e.target.parent);
				}); 
				elm.txtValue.addEventListener(FocusEvent.FOCUS_IN, function(e:Event):void { 
					var elmSub:UiSettingsVariableItem = e.target.parent as UiSettingsVariableItem;
					var txt:TextField = elmSub.txtValue;
					trace(",... ? "+elmSub.type,txt.text.length);
					if (elmSub.type != "boolean" && txt.text.length > 4 ) {
						trace(",... ? B");
						setTimeout(fnTextSelectText, 20, txt);//stupid bug doesn't let me set the focus right away at this very moment
					}
				}); 
				elm.txtValue.addEventListener(MouseEvent.CLICK, function(e:Event):void {
					var elmSub:UiSettingsVariableItem = e.target.parent as UiSettingsVariableItem;
					var txt:TextField = elmSub.txtValue;
					if (elmSub.type == "boolean") {
						fnInvertBoolean(elmSub);
						txt.setSelection(txt.text.length, txt.text.length);
					}
				});
				
				
				vecVariables.push(elm);
				i++;
			}
			*/
			
			txtInfo.text = plugin.settingsInfo;
			txtInfo.x = sTxt;
			txtInfo.y = yBottom + sTxt;// 32 + i * 16 + sTxt;
			txtInfo.wordWrap = true;
			txtInfo.autoSize = TextFieldAutoSize.LEFT;
			txtInfo.width = w - sTxt * 2;
			
			TxtTools.formatKeywordsColor(txtInfo, aKeyWords, 0xb6b6b6);
			
			
			
			var h:int = txtInfo.y + txtInfo.height + sTxt*2 + 17;//17 = button height for later
			
			btnExport.y = btnOk.y = txtInfo.y + txtInfo.height + sTxt;
			//btnImport.x = sTxt;
			btnExport.x = sTxt;
			btnOk.x = w - btnOk.width - sTxt;
			
			
			sliceBkg.draw(g, 0, 0, w, h);
			
			
			
			if (btnsTemplate != null){
				if (sprUi.contains(btnsTemplate)) {
					sprUi.removeChild(btnsTemplate);
				}
			}
			btnsTemplate = new UiSettingsDropDown(plugin, 128);
			btnsTemplate.x = w - 128 - 8;
			btnsTemplate.y = 8;
			sprUi.addChild(btnsTemplate);
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			window.width = w;
			window.height = h;

			window.x = Math.max(0,Main.instance.stage.nativeWindow.x + (Main.instance.stage.nativeWindow.width - w)/2);
			window.y = Math.max(0,Main.instance.stage.nativeWindow.y + (Main.instance.stage.nativeWindow.height - h)/2);
			window.orderToFront();
		}
		
		private function fnTextInput(elm:UiSettingsVariableItem):void {
			elm.reFormat();
		}
		
		private function fnTextSelectText(txt:TextField):void {
			window.stage.focus = txt;
			txt.setSelection(0, txt.text.length);
		}
		
		private function fnInvertBoolean(ui:UiSettingsVariableItem):void {
			ui.txtValue.text = String( !(ui.parseDataFromTxtString() as Boolean));
		}
		
		
		
		
		
		public function close(e:*=null):void {//remove what we created before
			window.orderToFront();
			window.visible = false;
			
			for (var i:int = 0; i < vecVariables.length; i++) {
				sprUi.removeChild(vecVariables[i]);
			}
			vecVariables = new Vector.<UiSettingsVariableItem>();
			UiMain.instance.uiStatusPop.block(false);
		}
		
		private function onMouseBkgDown(e:MouseEvent):void {
			window.stage.nativeWindow.startMove();
		}
	}
}