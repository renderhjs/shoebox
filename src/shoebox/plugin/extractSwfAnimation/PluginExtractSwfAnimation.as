package shoebox.plugin.extractSwfAnimation 
{
	import flash.display.AVM1Movie;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MorphShape;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import shoebox.app.gui.UiPluginWindow;
	import shoebox.plugin.createSpriteSheet.PluginCreateSpriteSheet;
	import shoebox.plugin.cutSprites.RectPack;
	import shoebox.plugin.event.PluginFileTransferEvent;
	import shoebox.plugin.extractSwfAnimation.parseSwf.AVM2Loader;
	import shoebox.plugin.extractSwfAnimation.parseSwf.ParseSwfFrames;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.PluginHelper;
	import tools.BmpSliceDraw;
	import tools.txtTools.TxtTools;
	import tweenTex.TweenTexAnimation;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class PluginExtractSwfAnimation extends PluginBase{
		
		[Embed(source="icon_48x48.png")]
		private var embd_bmp0:Class;
		
		public function PluginExtractSwfAnimation() {
			this.label = "Extract SWF";
			this.icon = new embd_bmp0().bitmapData;//tool icon
			this.settings = { 
				frames:8,
				powerOfTwo:true,
				texMargin:2
			};

			this.settingsTemplates = [];
			this.settingsInfo = "";
			this.extentions = ["swf"];
			
			registerListenEventGetData(PluginFileTransferEvent.DATA_FILE_IN, fnListenData);
			
			
			
			
			loader.contentLoaderInfo.addEventListener(Event.INIT, fnSWFLoaded);
		}
		
		
		
		private var urlRequest:URLRequest;
		private var loader:Loader = new Loader();
		private var loaderAVM1:AVM2Loader = new AVM2Loader();
		private var swf:DisplayObject;
		private var stage:Stage;
		
		private var fileSource:File;
		private function fnListenData(e:PluginFileTransferEvent):void {
			if (e.files.length == 1) {//JUST ONE FILE ALLOWED
				fileSource = e.files[0];
				urlRequest = new URLRequest(e.files[0].nativePath);
				loader.load(urlRequest);
			}
		}
		
		private var parse:ParseSwfFrames;
		private var export:ParseSwfExportXML = new ParseSwfExportXML();
		
		private var texture:BitmapData = null;//THE FINAL SPRITESHEET
		private var textureIds:Vector.<int> = new Vector.<int>();
		private var textureRects:Vector.<RectPack> = new Vector.<RectPack>();
		
		private function fnSWFLoaded(e:Event):void {
			
			
			
		
			
			
			stage = UiPluginWindow.init(1300, 800, "Parsing swf...",saveData);
			//UiPluginWindow.highlightMsg(finFileName.slice(0, finFileName.lastIndexOf(".")));
				
			
			var info:LoaderInfo = e.target as LoaderInfo;

			if (info.content is AVM1Movie) {
				var avm1:AVM1Movie = AVM1Movie(info.content);
				
				var loaderContext:LoaderContext = new LoaderContext();
				loaderContext.allowLoadBytesCodeExecution = true;
				
				trace("ITS A AVM1 MOVIE");
				loaderAVM1 = new AVM2Loader();
				loaderAVM1.contentLoaderInfo.addEventListener(Event.INIT, fnSWFLoadedAVM1);
				loaderAVM1.load(urlRequest,loaderContext);
				
			}else {//AS3 regular movie
				swf = loader.content;//the root
				swf.visible = false;
				//loader.visible = false;
			
				stage.addChild(swf);//IF ITS AS3 SWF ALL FINE
				swf.x = swf.y = 8;
				parse = new ParseSwfFrames(swf,settings.frames,fnDoneParsing);
			}
			
		}
		
		private function fnSWFLoadedAVM1(e:Event):void {
			loaderAVM1.content.removeEventListener(Event.COMPLETE, fnSWFLoadedAVM1);
			trace("fnSWFLoadedAVM1 ...");
			swf = loaderAVM1;//the root
			swf.visible = false;
			//loader.visible = false;
		
			stage.addChild(swf);//IF ITS AS3 SWF ALL FINE
			//swf.x = swf.y = 8;
			parse = new ParseSwfFrames(swf,settings.frames,fnDoneParsing);
			
		}
		
		
		
		
		
		
		
		
		
		
		private function saveData():void {
			
			var baseDir:String = fileSource.parent.nativePath;
			var baseName:String = fileSource.name;
			if (baseName.indexOf(".") != -1) {
				baseName = baseName.split(".")[0];
			}
			
			//JUST QUICK OVERWRITE
			//settings.powerOfTwo = false;
			//settings.texMargin = 16;
			
			fnGetSpriteSheet();//creates the texture bitmapData and textureIds array
			
			
			var rec:String = export.exportTextureData(textureRects);
			var ani:String = export.exportAnimation(parse, textureIds,rectBounds);
			
			
			
			//INSTANT PREVIEW STUFF
			var space:int = 40;
			var tta:TweenTexAnimation = new TweenTexAnimation(rec, ani, texture);
			tta.x = space;
			tta.y = space;
			stage.addChild(tta);
			
			if (tta.width < 400) {
				tta.scaleX = tta.scaleY = 2.0;
			}
			
			var tex2:BitmapData = texture.clone();
			tex2.fillRect(tex2.rect, 0xffc9bb97);
			tex2.draw(texture);
			//tex2.draw(texture,null,null,);
			var b:Bitmap = new Bitmap(tex2);
			var maxW:int = 400
			if (b.width > maxW) {
				b.width = maxW;
				b.scaleY = b.scaleX;
			}
			b.x = 400 * 2;
			stage.addChild(b);
			trace("--------------------------------------");
			//trace("ANI: "+ani)
			
			//SAVE STUFF
			
			//PluginHelper.setFileBitmap(baseDir+"\\"+baseName+".png",texture);
			/*
			PluginHelper.setFileASCI(baseDir + "\\" + baseName + "_tex.xml", rec);
			PluginHelper.setFileASCI(baseDir + "\\" + baseName + "_ani.xml", ani);
			*/
			
			//trace("save to: " + baseDir);
			//trace("name base: " + baseName);
			
			
		}
		private function saveDataUnity():void {
			var baseDir:String = fileSource.parent.nativePath;
			var baseName:String = fileSource.name;
			if (baseName.indexOf(".") != -1) {
				baseName = baseName.split(".")[0];
			}
			var className:String = baseName + "_TexTween";
			//baseDir.
			
			fnGetSpriteSheet();//creates the texture bitmapData and textureIds array
			var rec:String = export.exportTextureData(textureRects);
			var ani:String = export.exportAnimation(parse, textureIds,rectBounds);
			
			//UNITY SAVE
			trace("\n\n");
			//trace(ani);
			trace("\n----------UNITY SAVE-----------\n\n");
			var unity:ParseSwfExportUnity3d = new ParseSwfExportUnity3d();
			var out:String = unity.exportUnityCode(className, ani, rec, texture);//create UNITY CODE
			
			PluginHelper.setClipBoardText(ani);
			
			
			PluginHelper.setFileBitmap(baseDir+"\\"+baseName+".png",texture);
			PluginHelper.setFileASCI(baseDir+"\\"+className+".cs",out);
			
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		private var rectBounds:Vector.<Rectangle> = new Vector.<Rectangle>();
		
		private function fnGetSpriteSheet():void {
			
			texture = null;//THE FINAL SPRITESHEET
			textureIds = new Vector.<int>();
			rectBounds = new Vector.<Rectangle>();//RECTNANGLE BOUNDS
			
			var i:int;var j:int;
			
			//var bmpdObjIds:Vector.<int> = new Vector.<int>();
			
			var bmpd:Vector.<BitmapData> = new Vector.<BitmapData>();
			var ids:Vector.<String> = new Vector.<String>();
			for (i = 0; i < parse.objects.length; i++) {
				var d:DisplayObject = parse.objects[i];
				rectBounds[i] = d.getBounds(d);
				//trace("rect: " + rects[i]);
				//bmpdObjIds[i] = -1;
				textureIds[i] = -1;
				if (!(d is DisplayObjectContainer)) {
					
					var bnd:Rectangle = d.getBounds(d);
					
					
					if (bnd.width > 0 && bnd.height > 0) {
						//trace("TEXTURE: " + d.name,bnd);
					
						var b:BitmapData = new BitmapData(Math.ceil(bnd.width), Math.ceil(bnd.height), true, 0x00000000);
						b.draw(d, new Matrix(1, 0, 0, 1, -bnd.x, -bnd.y));
						bmpd.push(b);
						ids.push("tex" + (i).toString());
						textureIds[i] = bmpd.length - 1;
					}
				}
			}

			//textureRects = PluginCreateSpriteSheet.pack(bmpd, ids,settings.powerOfTwo, true, settings.texMargin);
			textureRects = PluginCreateSpriteSheet.pack(bmpd, ids,settings.powerOfTwo, true, Number(settings.texMargin));


			var bmpdDbg:Shape = new Shape();
			bmpdDbg.graphics.lineStyle(0, 0xe29447);
			var bmpdSheet:Bitmap = new Bitmap(PluginCreateSpriteSheet.bmpdSheet,"auto",true);
			for (i = 0; i < textureRects.length; i++) {
				bmpdDbg.graphics.drawRect(textureRects[i].x, textureRects[i].y, textureRects[i].width-1, textureRects[i].height-1);
			}
			bmpdDbg.graphics.lineStyle(0, 0xb83b14);
			bmpdDbg.graphics.drawRect(0, 0, PluginCreateSpriteSheet.bmpdSheet.width-1, PluginCreateSpriteSheet.bmpdSheet.height-1);
			
			
			texture = PluginCreateSpriteSheet.bmpdSheet;
			
			//texture.draw(bmpdDbg);
			
		}
		
		private function fnDoneParsing():void {
			trace("DONE RENDERING "+parse.frames.length+" x FRAMES");
			//UiPluginWindow.
			
			UiPluginWindow.setMessage("Save Texture, Texture-xml and Animation XML?");
			
			saveData();//TEMP
			//saveDataUnity();//
			
			
			
			
			
			
			
			
			var i:int; var j:int;
			
			var width:int = 400;
			var height:int = 800;
			
			var spr:Sprite = new Sprite();
			spr.y = 240;
			stage.addChild(spr);
			
			var iw:int = 80;
			var ih:int = 10;
			var count:int = 0;
			
			var timeLineObj:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			
			spr.graphics.lineStyle(0, 0x0d0d0d,0.3);
			/*
			for (i = 0; i < parse.objects.length; i++) {
				
				
				//if (!(parse.objects[i] is DisplayObjectContainer)){
					
					timeLineObj.push( parse.objects[i] );
					
					var txt:TextField = TxtTools.getTxt();
					TxtTools.formatBasic(txt, 10, 0xe4ff93);
					
					txt.text = parse.objects[i].name+" "+fnGetObjType( parse.objects[i]);
					
					
					
					txt.autoSize = TextFieldAutoSize.NONE;
					//txt.background = true;
					//txt.backgroundColor = 0x0d0d0d;
					txt.height = ih-1;
					//txt.width = iw-1;
					txt.y = count * ih-3;
					spr.addChild(txt);
					
					
					spr.graphics.moveTo(0, count * ih);
					spr.graphics.lineTo(width, count * ih);
					spr.graphics.moveTo(0, (count+1) * ih);
					spr.graphics.lineTo(width, (count + 1) * ih);
					
					if (!(parse.objects[i] is DisplayObjectContainer)) {
						var _d:DisplayObject = parse.objects[i];
						var _bnd:Rectangle = _d.getBounds(_d);
						if(_bnd.width > 0 && _bnd.height > 0){
							var _b:BitmapData = new BitmapData(ih, ih, false, 0x121212);
							var _m:Matrix = new Matrix(1, 0, 0, 1, -_bnd.x, -_bnd.y);
							_m.scale( ih/ _bnd.width  , ih /_bnd.width  );
							_m.ty += 3;
							_b.draw(_d, _m);
							var bm:Bitmap = new Bitmap(_b);
							spr.addChild(bm);
							bm.y = count * ih;
						}
						
					}
					
					
					count++;
				//}
			}
			
			
			
			var fw:int = (width - iw) / parse.frames.length;
			for (i = 0; i < parse.frames.length; i++) {
				var x:int = iw +  i * fw;
				//spr.graphics.beginFill(0xb6b6b6);
				spr.graphics.moveTo(x, 0);
				spr.graphics.lineTo(x, parse.objects.length * ih);
			}
			
			//render the tweens...
			for (i = 0; i < parse.tweens.length; i++) {
				//var x:int = iw +  i * fw;
				var y:int = i * ih + ih/2;
				//spr.graphics.beginFill(0xb6b6b6);
				for (j = 0; j < parse.tweens[i].length; j++) {
					var A:int = parse.tweens[i][j].fA * fw + iw; 
					var B:int = parse.tweens[i][j].fB * fw + iw; 
					
					var r:Number = ih/2-2;
					spr.graphics.lineStyle(2, 0x0090ff);
					spr.graphics.moveTo( A + fw / 2, y);
					spr.graphics.lineTo( B + fw / 2, y);
					spr.graphics.beginFill(0xdaefff);
					spr.graphics.drawCircle(A + fw / 2, y, r);
					spr.graphics.drawCircle(B + fw / 2, y, r);
					spr.graphics.endFill();
				}
			}
			*/
			
			//

			
			var bmpdSheet:Bitmap = new Bitmap(texture);
			var tw:Number = 400;
			if (bmpdSheet.width > tw){
				bmpdSheet.width = tw;
				bmpdSheet.scaleY = bmpdSheet.scaleX;
			}
			//spr.addChild(bmpdSheet);
			bmpdSheet.x = width+8;
			bmpdSheet.y = -240+8;
			
			
			
			
			
			
			/*
			var tw:int = 0;
			count = 0;
			for (i = 0; i < parse.objects.length; i++) {
				var d:DisplayObject = parse.objects[i];
				if (!(d is DisplayObjectContainer)) {
					
					var bnd:Rectangle = d.getBounds(d);
					var b:BitmapData = new BitmapData(bnd.width, bnd.height, false, 0xffe2cf77);
					b.draw(d, new Matrix(1, 0, 0, 1, -bnd.x, -bnd.y));
					var bmp:Bitmap = new Bitmap(b);
					//bmpd.push( bmp );
					
					spr.addChild(bmp);
					
					bmp.x = 160+tw;
					bmp.y = -130+20;
					tw += (bmp.width+1);
					count++;
					
				}
				
			
			}
			*/
			
			
			
			
			
			
			
			
			
			
			/*
			//draw frame dots
			var fw:int = (width - iw) / parse.frames.length;
			for (i = 0; i < parse.frames.length; i++) {
				
				
				
				
				var x:int = iw +  i * fw;
				
				for (var j:int = 0; j < parse.frames[i].length; j++){//EVERY OBJECT WE CATCHED
					
					var yIn:int = timeLineObj.indexOf( parse.frames[i][j].target );
				
				
				
					//var y:int = parse.frames[i][j].id * ih;
					var y:int = yIn * ih;
					
					
					
					spr.graphics.beginFill(0xb6b6b6);
					spr.graphics.drawRect(x+2, y+2, fw-4, ih-4);
					
				}
			}
			*/
			
		}
		
		private function fnGetObjType(d:DisplayObject):String {
			
			if (d is StaticText) {
				return "txt";
			}else if (d is Bitmap) {
				return "bmp";
			}else if (d is Shape) {
				return "shp";
			}else if (d is MorphShape) {
				return "mSh";
			}else if (d is DisplayObjectContainer) {
				return "mcl";
			}
			return "??";
		}
		
		
		
		/*
		private function fnScanDisplayObj(d:DisplayObject):void {
			var n:String = d.name;
			var o:Object = d as Object;
			
			var bnds:Rectangle = d.getBounds(d);
			
			var mc:MovieClip = o as MovieClip;
			
			trace("_____________");
			trace("1. name: " + n);
			trace("2. bnds: " + bnds.x,bnds.y,bnds.width,bnds.height);
			trace("3. cont: " + (o is DisplayObjectContainer));
			
			var i:int;
			var j:int;
			
			if (mc != null) {
				trace("4. frms: " + mc.totalFrames);
				mc.gotoAndStop(1);
				for (i = 0; i < mc.totalFrames; i++) {
					fnSubCheckFrame();
					mc.gotoAndStop(i+1);
				}
			}else {
				trace("4. no MC");
				fnSubCheckFrame();
			}
			
			
			
			
				
			function fnSubCheckFrame():void{	
				if (o is DisplayObjectContainer) {
					var c:DisplayObjectContainer = o as DisplayObjectContainer;
					trace("5. chil: " + c.numChildren);
				
					for (j = 0; j < c.numChildren; j++) {
						fnScanDisplayObj( c.getChildAt(j) );
					}
				}
			}	
			
			
			
			
		}
		
		*/
		
		
		
		
	}

}