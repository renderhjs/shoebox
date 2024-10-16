package shoebox.app 
{
	import com.adobe.serialization.json.JSON;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.PluginHelper;
	import tools.Cookie;
	/**
	 * ...
	 * @author Hendrik
	 * READS AND SAVES SETTINGS FOR EACH PLUGIN, TAB ORDER AND DISTRUBUTION
	 */
	public class SettingsManager{
		/*
		[Embed(source="config.xml", mimeType="application/octet-stream")]
		private static var defaultXML:Class;
		*/
		private static var xml:XML;//THE XML WE WRITE AND READ INTO (RAM)
		
		
		public static var tabPlugins:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();//inidicates in what order in each tab plugins are distributed
		
		
		public function SettingsManager() {
			
		}
		
		
		
		public static function init():void {
			for (var i:int = 0; i < 2; i++) {
				tabPlugins[i] = new Vector.<int>();
			}
			
			
			
			pushPlugin(1, "PluginUiToolkit2xResizeJson");
			pushPlugin(1, "macPcPathConverter.PluginMacPcPathConverter");
			pushPlugin(1, "spriteHullPacking.PluginSpriteHullPacking");
			pushPlugin(1, "shareFolder.PluginShareFolder");
			pushPlugin(1, "extractTiles.PluginExtractTiles");
			
			pushPlugin(0, "createSpriteSheet.PluginCreateSpriteSheet");
			pushPlugin(0, "cutSprites.PluginCutSprites");
			pushPlugin(0, "aniToFrameSequence.PluginAniToFrameSequence");
			pushPlugin(0, "jpgaBitmap.PluginJpgaBitmap");
			pushPlugin(0, "listFiles.PluginListFiles");
			
			///*
			//pushPlugin(2, "spriteHullPacking.PluginSpriteHullPacking");
			
			//pushPlugin(2, "extractSwfAnimation.PluginExtractSwfAnimation");
			
			//*/
			
			loadPluginSettings();//try to load settings
			
		}
		private static function pushPlugin(tabNr:int, classId:String):void {
			PluginManager.addPluginClass(classId);//register this plugin and initialize it
			tabPlugins[tabNr].push(PluginManager.plugins.length-1);
		}
		
		
		private static var cookie:Cookie = new Cookie("ShoeBox");
		public static function loadPluginSettings():void {
			for (var i:int = 0; i < PluginManager.plugins.length; i++) {//go through all plugins and try to load former settings
				var pl:PluginBase = PluginManager.plugins[i];
				var dta:Object = cookie.get("setting." + pl.classId);
				if (dta != null) {
					//verify that all keyValues match up
					var keys:Array = [];
					var key:String;
					for (key in pl.settings) {
						keys.push(key);
					}
					
					//now read whats in the cookie
					var valid:Boolean = true;
					var count:int = 0;
					for (key in dta) {
						if (keys.indexOf(key) == -1) {
							valid = false;
							break;
						}else {
							count++;
						}
					}
					
					if (valid && count == keys.length) {//cookie is valid and can be loaded
						pl.settings = dta;
					}else {
						trace("Cookie changed for: " + pl.label+" canceled loading from cookie");
					}
				}
				//trace("dta: "+dta);
				
			}
		}
		public static function savePluginSettings(pl:PluginBase):void {
			trace("save plugin");
			
			cookie.set("setting." + pl.classId, pl.settings);
			cookie.save();
		}
		public static function saveTabPage(nr:int):void {
			trace("save tab: " + nr);
			cookie.set("tab.page", nr);
			cookie.save();
		}
		public static function loadTabPage():int {
			var nr:int = cookie.get("tab.page");
			trace("nr: " + nr, cookie.get("tab.page"));
			return nr;
		}
		
		
		/*
		public static function save():void {
			
		}
		*/
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		//private static ;
		//public static function load(fnDone:Function):void {
			//check if there is an existing XML to use, if not create one
			/*
			var xmlFile:File = File.applicationStorageDirectory.resolvePath("config.xml");
			xmlFile.parent.openWithDefaultApplication();
			
			trace("url:L " + xmlFile.nativePath);
			if (!xmlFile.exists) {//CREATE DEFAULT EMBEDDED XML file
				var xmlBytes:ByteArray = new defaultXML();
				xml = new XML( xmlBytes.readUTFBytes( xmlBytes.length ) );
				saveXmlToConfig(xml.toXMLString());//save XML to config folder
			}else {//XML EXISTS, READ IT
				//trace("XML exists...");
				var stream:FileStream = new FileStream();
				stream.open(xmlFile, FileMode.READ);
				var str:String = stream.readUTFBytes(stream.bytesAvailable);
				stream.close();
				str = str.split(File.lineEnding).join("\n");
				xml = new XML(str);
			}
			
			//var tabOrder:Array = [];
			//NOW WE HAVE THE xml OBJECT
			var tabs:XMLList = xml.tab;
			for (var i:int = 0; i < tabs.length(); i++) {
				
				//tabOrder[i] = [];
				tabPlugins[i] = new Vector.<int>();
				
				var plugins:XMLList = tabs[i].plugin;
				//trace("tab " + i+" . plugins: " + plugins.length());
				for (var j:int = 0; j < plugins.length(); j++) {
					var n:String = plugins[j].@name;
					var c:String = plugins[j].@["class"];
					var d:String = plugins[j].description.toString();
					var s:Object = PluginHelper.getSysJsonObj( plugins[j].settings.toString() );
					//var t:Object = PluginHelper.getSysJsonObj( plugins[j].templates.toString() );
					var stp:Array = [];
					stp.push(["default", s]);
					var setups:XMLList = plugins[j].setup;
					for (var k:int = 0; k < setups.length(); k++) {
						var n2:String = setups[k].@name;
						var s2:String = setups[k].toString();
						var o:Object = { };
						if (s2 != null) {
							o = PluginHelper.getSysJsonObj( s2 );
						}
						//trace("setup: " + n2, "'" + s2 + "'");
						stp.push([n2,o]);
					}
					
					
					PluginManager.addPluginClass(c,n,d,stp);//register this plugin and initialize it
					//tabOrder[i].push(PluginManager.plugins.length-1);
					
					tabPlugins[i].push(PluginManager.plugins.length-1);
					//trace("plugin: " + n+"\n\t"+c+"\n\t"+d+"\n\t"+s+"\n\t"+d);
				}
			}
			
			
			
			
			//var json:String = JSON.encode(targetPlugin.settings);
			
			//trace("app path ?\n\n"+xml.toXMLString())
					
			
			fnDone();
			*/
		//}
		/*
		public static function init():void {
			
		}
		
		
		private static function saveXmlToConfig(xmlString:String):void {
			PluginHelper.setFileASCI( File.applicationStorageDirectory.resolvePath("config.xml").nativePath, xmlString);
		}
		*/
		
		
	}
}