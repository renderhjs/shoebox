package shoebox.app 
{
	import flash.utils.ByteArray;
	import shoebox.app.gui.UiDroplet;
	import shoebox.plugin.aniToFrameSequence.PluginAniToFrameSequence;
	import shoebox.plugin.codeInspect.PluginCodeInspect;
	import shoebox.plugin.createSpriteSheet.PluginCreateSpriteSheet;
	import shoebox.plugin.cutSprites.PluginCutSprites;
	import shoebox.plugin.event.PluginClipBoardTransferEvent;
	import shoebox.plugin.event.PluginFileTransferEvent;
	import shoebox.plugin.extractSwfAnimation.PluginExtractSwfAnimation;
	import shoebox.plugin.extractTiles.PluginExtractTiles;
	import shoebox.plugin.flickrWPimgEmbed.PluginFlickrWPimgEmbed;
	import shoebox.plugin.jpgaBitmap.PluginJpgaBitmap;
	import shoebox.plugin.listFiles.PluginListFiles;
	import shoebox.plugin.macPcPathConverter.PluginMacPcPathConverter;
	import shoebox.plugin.aniToFrameSequence.PluginAniToFrameSequence;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.PluginUiToolkit2xResizeJson;
	import shoebox.plugin.shareFolder.PluginShareFolder;
	import shoebox.plugin.spriteHullPacking.PluginSpriteHullPacking;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Hendrik
	 */
	public class PluginManager extends EventDispatcher{
		//REFERENCE TO THE PLUGIN CLASSES
		private var p0:PluginListFiles;
		private var p1:PluginCutSprites;
		
		private var p3:PluginAniToFrameSequence;
		private var p4:PluginFlickrWPimgEmbed;
		private var p5:PluginMacPcPathConverter;
		private var p7:PluginJpgaBitmap;
		private var p8:PluginCodeInspect;
		private var p9:PluginShareFolder;
		private var p11:PluginExtractTiles;
		
		private var p2:PluginCreateSpriteSheet;
		private var p6:PluginUiToolkit2xResizeJson;
		private var p10:PluginExtractSwfAnimation;
		private var p12:PluginSpriteHullPacking;
		//PluginUiToolkit2xResizeJson
		
		
		
		
		public static var plugins:Vector.<PluginBase> = new Vector.<PluginBase>();
		public static var instance:PluginManager = null;
		
		
		public function PluginManager():void {
			if (PluginManager.instance == null){
				PluginManager.instance = this;
			}
		}
		
		//public static function addPluginClass(classId:String, name:String, description:String = "", templates:Array = null):void {
		public static function addPluginClass(classId:String):void {
			
			var cls:Class = getDefinitionByName("shoebox.plugin." + classId) as Class;
			//trace("cls "+cls);
			var plugin:PluginBase = new cls() as PluginBase;
				
			plugin.sysDropNr = plugins.length;
			plugin.classId = classId;
			//plugin.label = name;
			//plugin.label = plugin.label;
			//plugin.settingsInfo = description;
			plugins.push( plugin);
			
			plugin.ui = new UiDroplet(plugin);
			plugin.settingsTemplates.splice(0,0,["Default", clone(plugin.settings) ]);
			
			//this.settingsTemplates.push(["HTML", { outerClosure:"*", elementClosure:"*", elementSplit:"\\n" } ]);
			
		}
		
		private static function clone(source:Object):* {
			var copier:ByteArray = new ByteArray();
			copier.writeObject(source);
			copier.position = 0;
			return(copier.readObject());
		}	
			
			//instance.addClass(id);

		
		
		
		
		
		public function dispatchRepeatAction(bucketNr:int):void {
			//repeat last action
			trace("repeat last action");
		}
		
		public function dispatchFilesIn(bucketNr:int,files:Vector.<File>):void {
			dispatchEvent(new PluginFileTransferEvent(PluginFileTransferEvent.DATA_FILE_IN, bucketNr,files));
		}
		public function dispatchClipboardInText(bucketNr:int, data:String):void {
			dispatchEvent(new PluginClipBoardTransferEvent(PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_TEXT, bucketNr, data));
		}
		public function dispatchClipboardInImage(bucketNr:int, data:BitmapData):void {
			dispatchEvent(new PluginClipBoardTransferEvent(PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_IMAGE, bucketNr, data));
		}
		
	}

}