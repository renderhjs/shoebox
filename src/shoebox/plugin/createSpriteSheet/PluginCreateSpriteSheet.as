package shoebox.plugin.createSpriteSheet 
{
	import flash.display.Sprite;
	import flash.filesystem.File;
	import shoebox.app.gui.UiPluginWindow;
	import shoebox.plugin.cutSprites.RectPack;
	import shoebox.plugin.event.PluginFileTransferEvent;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.cutSprites.RectPack;
	import shoebox.plugin.PluginHelper;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	
	
	/**
	 * ...
	 * @author renderhjs
	 * PACKER BASED ON: http://www.natewm.com/media/software/experiments/python/rect_packing.py
	 */
	public class PluginCreateSpriteSheet extends PluginBase{
		[Embed(source="icon_48x48.png")]
		private var embd_bmp0:Class;
		private static var instance:PluginCreateSpriteSheet;
		
		public function PluginCreateSpriteSheet() {
			instance = this;
			this.label = "Pack Sprites";
			this.icon = new embd_bmp0().bitmapData;//tool icon
			//this.settings = {outerClosure:"var a:Array=[*];",elementClosure:"'*'",elementSplit:",",includeSubFolders:false };
			//this.settings = {padding:4,rotateClusters:false,cropAlpha:true,powerOfTwo:false};
			//this.settings = { padding:4, width:512, height:512, cropAlpha:true, txtFormat:"txtDtaScore.addAbs(\"@id\",@x,@y,@w,@h);\n", idFileNamesVar:"_@.png", fileName:"512_uiText.png" };
			this.settings = { 
				padding:0, 
				cropAlpha:true, 
				powerOfTwo:false, 
				txtFormatOuter:"<slices>\\n@loop</slices>", 
				txtFormatLoop:"\\t<img id=\"@id\" x=\"@x\" y=\"@y\" w=\"@w\" h=\"@h\"/>\\n", 
				txtFormatExtention:"xml", 
				idFileNamesVar:"_@.png", 
				fileName:"sheet.png",
				useCssOverHack:false
			};

			this.settingsTemplates.push(["AS3", { 
				padding:0, 
				cropAlpha:true, 
				powerOfTwo:false, 
				txtFormatOuter:"<slices>\\n@loop</slices>", 
				txtFormatLoop:"\\t<img id=\"@id\" x=\"@x\" y=\"@y\" w=\"@w\" h=\"@h\"/>\\n", 
				txtFormatExtention:"xml", 
				idFileNamesVar:"_@.png", 
				fileName:"sheet.png",
				useCssOverHack:false
			} ]);
			this.settingsTemplates.push(["CSS", { 
				padding:0, 
				cropAlpha:true, 
				powerOfTwo:false, 
				txtFormatOuter:"@loop", 
				txtFormatLoop:"@id{width:@w;height:@h;background: url(\"sprites.png\") no-repeat -@xpx -@ypx;}\\n", 
				txtFormatExtention:"css", 
				idFileNamesVar:"@.png", 
				fileName:"sprites.png",
				useCssOverHack:true
			} ]);
			this.settingsTemplates.push(["JSON", { 
				padding:4, 
				cropAlpha:true, 
				powerOfTwo:true, 
				txtFormatOuter:"{\"frames\": {\\n@loop\\n\\t\"meta\": {\"app\": \"ShoeBox\",\"size\": {\"w\":@w,\"h\":@h}}\\n}", 
				txtFormatLoop:"\\t\"@id\".png\":{\\n\\t\\t\"spriteSourceSize\": {\"x\":@x,\"y\":40,\"w\":@w,\"h\":@h},\\n\\t\\t\"sourceSize\": {\"w\":@w,\"h\":@h}\\n\\t},\\n", 
				txtFormatExtention:"json", 
				idFileNamesVar:"_@.png", 
				fileName:"sheet.png",
				useCssOverHack:false
			} ]);
			
			
			
			//txtDtaScore.addAbs("0",0,35,16,43);
			//this.settingsTemplates = [];
			this.settingsInfo = "Creates a sprite sheet. cropAlpha crops to alpha bounds.\n Output: txtFormatOuter defines the outer part of the ASCII output in which '@loop' embeds the txtFormatLoop part which specifies the ASCI ouput data where @id is the id, @x, @y, @w and @h represent the position and size. idFileNamesVar defines the variable for @id based on the file name, where '@' is the piece to search for and the rest defines the before and after pattern. txtFormatExtention defines the ASCI output file extention e.g css, xml, txt,.. leave it empty to not save any file";
			this.extentions = ["jpg", "gif", "png"];
			
			registerListenEventGetData(PluginFileTransferEvent.DATA_FILE_IN, fnListenData);
		}
		
		
		
		public static function pack(bmpd:Vector.<BitmapData>, ids:Vector.<String>,powerOf2:Boolean=false, doCrop:Boolean=true, padding:int=0):Vector.<RectPack> {
			//FUNCTION FOR OTHER TOOLS TO PACK STUFF
			
			//OTHERWISE ERROR?
			instance.settings.cropAlpha = doCrop;
			instance.settings.padding = padding;
			instance.settings.powerOfTwo = powerOf2;
			
			
			
			
			instance.m_numLoaded = int(bmpd.length);
			instance.m_bmpd = bmpd;
			instance.m_fileNames = ids;
			
			instance.fileReference = null;
			instance.m_localFolderUrl = "";
			
			instance.sortCompareSourceBitmaps();//SORT OUT DOUBLE SPRITES, BUILD TABLE TO KNOW WHICH ONE SHOULD BE REFERENCED x-times ON THE RECT ARRAY
			instance.startProcessing(powerOf2, doCrop, padding);//powerOfTwo, crop, padding
			//SORT RECT LIST
			
			//doubleBitmapOrder
			//packed_rect_list:Vector.<RectPack> = new Vector.<RectPack>();
			var recOut:Vector.<RectPack> = new Vector.<RectPack>();
			var i:int;
			var j:int;
			for (i = 0; i < instance.doubleBitmapOrder.length; i++) {//ORIGINAL INPUT LENGTH AND ORDER
				//recOut[i] = instance.packed_rect_list[0];//DEFAULT
				for (j = 0; j < instance.packed_rect_list.length; j++) {
					var r:RectPack = instance.packed_rect_list[j];
					if (r.sourceIdx == instance.doubleBitmapOrder[i]) {//YAP NEED THIS ONE
						recOut[i] = instance.packed_rect_list[j];
						break;
					}
				}
			}

			return recOut;
			//return instance.packed_rect_list;
		}
			
		public static function get bmpdSheet():BitmapData {
			return instance.bmpdFin;
		}
		
		
		
		
		
		
		
		
		private var m_localFolderUrl:String = "";
		private var m_numLoad:int = 0;
		private var m_numLoaded:int = 0;
		
		private var m_bmpd:Vector.<BitmapData> = new Vector.<BitmapData>();
		private var m_fileNames:Vector.<String> = new Vector.<String>();
		
		public var bmpdFin:BitmapData;
		private var fileReference:File = null;//reference to where this file is saved
		
		private var stage:Stage;
		private function fnListenData(e:PluginFileTransferEvent):void {
			m_numLoaded = 0;
			trace("recieved: " + e.files.length+" files");
			m_bmpd = new Vector.<BitmapData>();
			m_numLoad = e.files.length;
			if (e.files.length > 0) {
				fileReference = e.files[0];
				
				for (var i:int = 0; i < e.files.length; i++) {
					if (i == 0) {
						m_localFolderUrl = e.files[i].parent.nativePath;
					}
					m_bmpd[i] = null;
					m_fileNames[i] = e.files[i].name;
					PluginHelper.getFileBitmap(e.files[i], fnImageLoaded,i);
				}
			}
			
		}
		private function fnImageLoaded(b:BitmapData, nr:int):void {
			
			//crop the bitmap to its alpha bounds
			if (settings.cropAlpha) {
				
				var crop:Rectangle = b.getColorBoundsRect(0xFFFFFFFF, 0x000000, false);//alpha crop
				crop.width = Math.max(1, crop.width);
				crop.height = Math.max(1, crop.height);
				var bCrop:BitmapData = new BitmapData(crop.width, crop.height, true, 0x00000000);
				bCrop.copyPixels(b, crop, new Point());
				m_bmpd[nr] = bCrop;
			}else {
				m_bmpd[nr] = b;
			}
			//
			
			
			//m_bmpd.push(b);
			m_numLoaded++;
			
			if (m_numLoaded >= m_numLoad) {//all IMAGES ARE LOADED
				var i:int;
				var j:int;
				var r:RectPack;
				
				instance.sortCompareSourceBitmaps();//GET RID OF DOUBLE
				startProcessing(settings.powerOfTwo, settings.cropAlpha, settings.padding);
				
				//RE-ORDER ACCORDING TO ORIGINAL INPUT 
				var recOut:Vector.<RectPack> = new Vector.<RectPack>();
				for (i = 0; i < instance.doubleBitmapOrder.length; i++) {//ORIGINAL INPUT LENGTH AND ORDER
					for (j = 0; j < instance.packed_rect_list.length; j++) {
						r = instance.packed_rect_list[j];
						if (r.sourceIdx == instance.doubleBitmapOrder[i]) {//YAP NEED THIS ONE
							recOut[i] = instance.packed_rect_list[j];
							break;
						}
					}
				}
				packed_rect_list = recOut;
				trace("TEXTURE REF. ITEMS: " + recOut.length);
				
				

				//bmpdFin.copyPixels(bmpdTmp, bmpdTmp.rect, new Point());
				var width:int = bmpdFin.width;
				var height:int = bmpdFin.height;
				//var i:int;
				
				var shape:Shape = new Shape();
				var g:Graphics = shape.graphics;
				for (i = 0; i < packed_rect_list.length; i++) {
					r= packed_rect_list[i];
					g.lineStyle(0, 0xff7800, 0.3);
					g.drawRect(r.x, r.y, r.uvWidth, r.uvHeight);//not width as we need to substract the padding
					g.endFill();
				}
				//g.endFill();
				g.lineStyle(0, 0xff0000, 0.15);
				if (rect_list.length > 0) {
					g.beginFill(0xff0000, 0.5);
				}
				g.drawRect(0, 0, width, height);
				g.endFill();
				
				shape.x = shape.y = 8;

				var url:String = fnGetFileURL();
				var fName:String = url.slice(url.lastIndexOf("\\")+1,url.length);// settings.fileName;
				
				trace("> " + fName);
				
				
				//stage = UiPluginWindow.init(width+16,height+16,"Save "+width+"x"+height+" to "+fName+" ?",fnSaveFinalResult);
				stage = UiPluginWindow.init(Math.max(width+16,400),height+16,"Save "+width+"x"+height+" to "+fName+" ?",fnSaveFinalResult);
				UiPluginWindow.highlightMsg(fName);
				
				
				var bmpFin:Bitmap = new Bitmap(bmpdFin);
				bmpFin.x = bmpFin.y = 8;
				
				stage.addChild(bmpFin);
				stage.addChild(shape);
				
				
				//temptempSprite.scaleX  = temptempSprite.scaleY = 0.5;
				//temptempSprite.y  = height+16;
				//stage.addChild(temptempSprite);
			}
		}
		
		
		
		//private var temptempSprite:Sprite = new Sprite();
		private var doubleBitmapOrder:Vector.<int> = new Vector.<int>();//ORDER OF THE FINAL BMPD.<VEC> to the original BMPD.<VEC>
		
		private function sortCompareSourceBitmaps():void {
			doubleBitmapOrder = new Vector.<int>();//THE HOT DATA WE WANT + DELETE DOUBLE BMPD FROM THE INPUT VECTOR<BITMAPDATA>
			
			var i:int;
			var j:int;
			var k:int;
			var c:int = 0;
			
			
			
			var double:Vector.<Vector.<BitmapData>> = new Vector.<Vector.<BitmapData>>();//[0][Target,Source]
			//var delBmp:Vector.<BitmapData> = new Vector.<BitmapData>();
			
			var matchGroup:Vector.<Vector.<BitmapData>> = new Vector.<Vector.<BitmapData>>();
			
			for (i = 0; i < m_bmpd.length; i++) {
				doubleBitmapOrder.push(i);//each referencing to itself
				matchGroup[i] = new Vector.<BitmapData>();//PUSH ALL 
			}
			
			for (i = 0; i < m_bmpd.length; i++) {
				
				for (j = 0; j < m_bmpd.length; j++) {
					if (j > i) {
							
						var A:BitmapData = m_bmpd[i];//KEEP REFERENCE
						var B:BitmapData = m_bmpd[j];//DELETE

						if (A.width == B.width && A.height == B.height) {
							var eq:Number = compare2Bitmaps(A, B);
							
							if (eq >= 0.99) {//pretty much the same Bitmap, get rid of B

								var itm:Vector.<BitmapData> = new Vector.<BitmapData>();
								itm.push(B, A);//target, ref-source
								double.push(itm);
								
								//ADD UNIQUE MATCHING BITMAPS TO THIS GROUP
								if (matchGroup[i].indexOf(A) == -1) {
									matchGroup[i].push(A);
								}
								if (matchGroup[i].indexOf(B) == -1) {
									matchGroup[i].push(B);
								}
								if (matchGroup[j].indexOf(A) == -1) {
									matchGroup[j].push(A);
								}
								if (matchGroup[j].indexOf(B) == -1) {
									matchGroup[j].push(B);
								}
							}
						}
					}
				}
			}
			
			//connect connect matchGropus of other Groups, SO WE CAN MAP LATER ANY MATCHING INDEXOF(?)
			for (i = 0; i < matchGroup.length; i++) {
				for (j = 0; j < matchGroup.length; j++) {
					if (j != i) {
						var add:Boolean = false;
						for (k = 0; k < matchGroup[j].length; k++) {//CHECK IF ANY MATCHES
							if (matchGroup[i].indexOf( matchGroup[j][k]) != -1) {
								add = true;
								break;
							}
						}
						if (add) {//AT LEAST ONE MATCHES OF THE GROUPS, GET THEM OVER TO BOOTH
							for (k = 0; k < matchGroup[j].length; k++) {
								if (matchGroup[i].indexOf( matchGroup[j][k] ) == -1) {
									matchGroup[i].push(matchGroup[j][k]);
								}
								if (matchGroup[j].indexOf( matchGroup[j][k] ) == -1) {
									matchGroup[j].push(matchGroup[j][k]);
								}
							}
						}
					}
				}
				//trace("matchGroup["+i+"]: "+matchGroup[i].length);
			}
			
			
			
			
			var refBmpd:Vector.<BitmapData> = new Vector.<BitmapData>();
			for (i = 0; i < m_bmpd.length; i++) {
				refBmpd[i] = m_bmpd[i];
			}
			
			var idxDel:int;
			var idxSrc:int;
			var idxOrg:int;
			
			trace("double BMPD's " + double.length+" x");
			//DELETE DOUBLE BITMAPS
			for (i = 0; i < double.length; i++) {
				idxDel = m_bmpd.indexOf( double[i][0] );//INDEX OF TARGET
				idxSrc = m_bmpd.indexOf( double[i][1] );//INDEX OF SOURCE
				
				idxOrg = refBmpd.indexOf(double[i][0] );//INDEX OF TARGET
				if (idxDel != -1 && matchGroup[idxOrg].length > 0) {
					m_bmpd.splice(idxDel, 1);
					m_fileNames.splice(idxDel, 1);
				}
			}
			m_numLoaded = m_bmpd.length;
			
			for (i = 0; i < doubleBitmapOrder.length; i++) {
				var idx:int = m_bmpd.indexOf( refBmpd[i] );//where is it in the new bmpd vector??
				if (idx == -1) {//does not exist anymore, maybe some of the others in the matching group?
					for (j = 0; j < matchGroup[i].length; j++) {
						idx = m_bmpd.indexOf( matchGroup[i][j] );
						if (idx != -1) {
							break;
						}
					}
				}
				doubleBitmapOrder[i] = idx;
				//trace("ref: " + i + " = " + doubleBitmapOrder[i]+"\t\t (out of: "+matchGroup[i].length+")");
			}
		}
		private function compare2Bitmaps(A:BitmapData, B:BitmapData):Number {
			//returns p% of how equal they are
			
			var dO:Object = A.compare(B);
			if (dO === 0) {
				return 1;//EXACTLY MATCHING THROUGHOUT ALL 4 CHANNELS
			}else {
				
				var i:int;
				var j:int;
				var d:BitmapData = BitmapData(dO);
				var h:Vector.<Vector.<Number>> = d.histogram(d.rect);

				
				
				var v:int = 0;
				var t:int = d.width * d.height*4;
				
				
				
				for (i = 0; i < 4; i++) {//RGBA
					var z:Number = 0;
					for (j = 1; j < 256; j++) {//0-255
						v += h[i][j];
						z += h[3][j];
					}
				}
				
				return (1-v / t);//return p%
			}
			return 0;
		}
		
		private function fnSaveFinalResult():void {
			if (fileReference != null) {
				
				var url:String = fnGetFileURL();
				PluginHelper.setFileBitmap(url, bmpdFin);
				
				var out:String = fnGetStringOutput();
				PluginHelper.setClipBoardText(out);
				
				if (settings.txtFormatExtention != "") {
					var n:String = settings.fileName.slice(0, settings.fileName.lastIndexOf("."))+"."+settings.txtFormatExtention;
					var url2:String = fileReference.parent.nativePath + "\\" + n;
					
					PluginHelper.setFileASCI(url2, out);
				}
			}
		}
		
		private function fnGetFileURL():String {
			return fileReference.parent.nativePath+"\\"+settings.fileName;
		}
		
		private function fnGetStringOutput():String {
			
			var asci:String = "";
			
			if (settings.txtFormatOuter.indexOf("@loop") != -1){
				var i:int;
				var j:int;
				
				var idxOrg:int;
				var idxPck:int;
				
				//sort by filename... and output
				var sort:Array = [];
				for (i = 0; i < m_fileNames.length; i++) {
					sort.push(m_fileNames[i]);
				}
				sort.sort();
				
				
				
				//useCssOverHack
				if (settings.useCssOverHack) {
					//find double or matching filenames
					var s:String;
					var pattern:Array = ["_over","_o.","_rollover","_rollOver"];
					
					//1. GET PAIR KEYWORDS
					var keywords:Array = [];
					
					for (i = 0; i < sort.length; i++) {
						s = sort[i];
						for (j = 0; j < pattern.length; j++) {
							if (s.indexOf(pattern[j]) != -1) {
								
								keywords.push(	s.slice(0, s.lastIndexOf(pattern[j]))	);
								break;
							}
						}
					}
					
					//COLLECT PAIRS IN ARRAY
					trace("keywords: " + keywords);
					
					var pairs:Array = [];//2d array
					var single:Array = [];//1d array
					
					for (i = 0; i < keywords.length; i++) {
						pairs[i] = [];//2d array
					}
					
					for (i = 0; i < sort.length; i++) {
						s = sort[i];
						
						var isPaired:Boolean = false;
						for (j = 0; j < keywords.length; j++) {
							if (s.lastIndexOf(keywords[j]) == 0) {
								pairs[j].push( s );
								isPaired = true;
								break;
							}
						}
						if (!isPaired) {
							single.push(s);
						}
					}
					for (i = 0; i < pairs.length; i++) {
						trace(".. " + pairs[i]);
					}
					
					//LOOP FOR OUTPUT
					
					//SINGLES
					for (i = 0; i < single.length; i++) {
						idxOrg =  m_fileNames.indexOf( single[i] );
						idxPck = 0;
						for (j = 0; j < packed_rect_list.length; j++) {
							if (packed_rect_list[j].sourceIdx == idxOrg) {
								idxPck = j;
								break;
							}
						}
						asci += appendASCIOut(	packed_rect_list[idxPck]	, m_fileNames[idxOrg],false,false);
					}
					//PAIRS
					
					for (i = 0; i < pairs.length; i++) {
						if (pairs[i].length > 0){//A - without over
							idxOrg =  m_fileNames.indexOf( pairs[i][0] );
							idxPck = 0;
							for (j = 0; j < packed_rect_list.length; j++) {
								if (packed_rect_list[j].sourceIdx == idxOrg) {
									idxPck = j;
									break;
								}
							}
							asci += appendASCIOut(	packed_rect_list[idxPck]	, m_fileNames[idxOrg],true,false);
						}	
						if (pairs[i].length > 1){//B - with over
							idxOrg =  m_fileNames.indexOf( pairs[i][1] );
							idxPck = 0;
							for (j = 0; j < packed_rect_list.length; j++) {
								if (packed_rect_list[j].sourceIdx == idxOrg) {
									idxPck = j;
									break;
								}
							}
							idxOrg =  m_fileNames.indexOf( pairs[i][0] );//use the without over as id name
							asci += appendASCIOut(	packed_rect_list[idxPck]	, m_fileNames[idxOrg],true,true);
						}	
					}
					
					
				}else{
				
						
					for (i = 0; i < sort.length; i++) {
						idxOrg =  m_fileNames.indexOf( sort[i] );
						idxPck = 0;
						for (j = 0; j < packed_rect_list.length; j++) {
							if (packed_rect_list[j].sourceIdx == idxOrg) {
								idxPck = j;
								break;
							}
						}
						asci += appendASCIOut(	packed_rect_list[idxPck]	, m_fileNames[idxOrg],false,false);
					}
				}	
				
				
				
				
				
				
				
				
				
				
				asci = settings.txtFormatOuter.split("@loop").join(asci);
				asci = PluginHelper.parseTypedSpecialCharacters(asci);//fix Tab, new line and return characters
			}	
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			function appendASCIOut(r:RectPack,fName:String,cssOverHack:Boolean=false,cssIsOver:Boolean=false):String {

				//txtFormat:"txtDtaScore.addAbs(@id,@x,@y,@w,@h);\n" };
				
				
				
				
				var id:String = fName;
				var a:Array = settings.idFileNamesVar.split("@");
				if (a[0] == "") {
					a.splice(0, 1);
				}
				//trace("a: " + a);
				
				if (a.length == 2) {
					id = id.slice(0,  id.indexOf(a[1]));
					id = id.slice(id.lastIndexOf(a[0])+a[0].length, id.length);
				}else if (a.length == 1) {
					if (settings.idFileNamesVar.indexOf("@") == 0) {
						id = id.slice(0, id.indexOf(a[0]));
						trace("id: " + id);
					}
				}
				
				var s:String = settings.txtFormatLoop;
				if (cssOverHack && cssIsOver) {
					s = "@id{background-position: -@xpx -@ypx;width:@w;height:@h;}\\n\\n";//don't write other things again
				}
				s = s.split("@x").join( String(r.x) );
				s = s.split("@y").join( String(r.y) );
				s = s.split("@w").join( String(r.uvWidth) );
				s = s.split("@h").join( String(r.uvHeight) );
				
				
				if (!cssOverHack && !cssIsOver) {
					s = s.split("@id").join( id );
				}else if (cssOverHack && !cssIsOver) {
					//s = s.split(id).join( "a." + id);
					s = s.split("@id").join( "a." + id );
				}else if (cssOverHack && cssIsOver) {
					//s = s.split(id).join( "a."+id + ":hover, a." + id + ":focus, a." + id + ":active");
					s = s.split("@id").join( "a."+id + ":hover, a." + id + ":focus, a." + id + ":active");
				}
				
				return s;
			}
			
			
			
				
			
			return asci;
		}
		
		
		
		
		
		
		
		private function sortRects(A:RectPack, B:RectPack):Number{
			if (A.volSort < B.volSort){
				return 1;
			}else if (A.volSort > B.volSort){
				return -1;
			}else{
				return 0;
			}
		}
			
		private function build_tree(free_space:RectPack):void {

			if (free_space.width <= 0 || free_space.height <= 0) {
				return;//cancel
			}
			if (rect_list.length == 0){
				return;//cancel, list empty
			}

			var rect_index:int = 0;
			var done:Boolean = false;
			var step:int = Math.max(rect_index + rect_list.length / search_resolution, 1);//at least 1
			
			while (!done) {
				if (rect_list[rect_index].width <= free_space.width && rect_list[rect_index].height <= free_space.height) {
					done = true;
				}else {
					search_step++;
					rect_index += step;
					if (rect_index >= rect_list.length) {
						return;//cancel
					}
				}
			}
			
			var rect:RectPack = rect_list.splice(rect_index, 1)[0];
			//trace("..>");
			rect.x = free_space.x;
			rect.y = free_space.y;
			
			packed_rect_list.push(rect);
			
			area_covered += (rect.width * rect.height);
			if (free_space.width - rect.height > free_space.height - rect.width) {
				// cut into two nodes side-by-side
				// Shrink first node of spit nodes
				// call _build_tree for each new node
				build_tree( new RectPack(free_space.x, free_space.y + rect.height, rect.width, free_space.height - rect.height,0,-1));
				build_tree( new RectPack(free_space.x + rect.width, free_space.y, free_space.width - rect.width, free_space.height,0,-1));
			}else {
				// cut into two nodes one on top of the other
				// Shrink first node of spit nodes
				// call _build_tree for each new node
				build_tree( new RectPack(free_space.x + rect.width, free_space.y, free_space.width - rect.width, rect.height,0,-1));
				build_tree( new RectPack(free_space.x, free_space.y + rect.height, free_space.width, free_space.height - rect.height,0,-1));
			}
			
		}
		
		
		
		
		
		
		
		
		
		
		
		
		private function fnSortSearchReturnLength(width:int,height:int):int {
			var j:int;
			var sizeReturn:int = 1;//DEFAULT ABOVE 0 OTHERWISE IT WOULD BE A FIT
			
			//--------------------------
			rect_list = new Vector.<RectPack>();
			for (j = 0; j < m_bmpd.length; j++) {
				rect_list.push(new RectPack(0, 0, m_bmpd[j].width, m_bmpd[j].height,settings.padding,j));
				//rect_list.push(new RectPack(0, 0, m_bmpd[j].width, m_bmpd[j].height,settings.padding,0));
			}
			rect_list = rect_list.sort(sortRects);//SORT BY VOLUME
			//--------------------------
			
			if (Math.max(rect_list[0].width , rect_list[0].height) <= Math.max(width, height)) {//the single biggest texture fits, try fitting all in them now...
				//EMPTY VARIABLES BEFORE BUILDING A TREE MAP
				area_covered = 0;
				search_step = 0;
				packed_rect_list = new Vector.<RectPack>();
				build_tree( new RectPack(	0, 0, width, height, 0, -1));//STARTS THE PACKING
			}
			
			return rect_list.length;
		}
		
		
		
		private var sessionPowerOfTow:Boolean;
		private var sessionCropAlpha:Boolean;
		private var sessionPadding:int=0;
		
		private var search_resolution:int = 2000;//constant
		private var area_covered:int = 0;
		private var search_step:int = 0;
		private var rect_list:Vector.<RectPack> = new Vector.<RectPack>();
		private var packed_rect_list:Vector.<RectPack> = new Vector.<RectPack>();
		private function startProcessing(powerOfTwo:Boolean,cropAlpha:Boolean,padding:int ):void {
			
			
			
			
				
			
			
			
			
			
			
			
			sessionPowerOfTow 	= powerOfTwo;
			sessionCropAlpha	= cropAlpha;
			sessionPadding		= padding;
			

			var i:int; var j:int;
			var sizeFinal:int = 0;
			
			var width:int = 0;
			var height:int = 0;
			
			var maxSize:int;
			if ( sessionPowerOfTow ){//ONLY POWER OF 2 TEXTURES
			
				var sizes:Array = [32,64, 128, 256, 512, 1024,2048];//go through each of these sizes till there is a matching one
				sizeFinal = sizes[0];
				for (i = 0; i < sizes.length; i++) {
					if (fnSortSearchReturnLength(sizes[i], sizes[i]) <= 0){//there is a fit, exit loop
						sizeFinal = sizes[i];
						break;
					}
				}
				width = height = sizeFinal;
			}else{
			
				var length:int;
				
				
				
				//FIND THE SMALLEST SQUARE FIT
				var step:int =1024;//start with some value
				var stepIncr:int = step;
				
				var maxSteps:int = 32;
				
				var sizesFinal:int = 0;
				for (i = 0; i < maxSteps; i++) {
					length = fnSortSearchReturnLength(step, step);
					if (length > 0){//TO SMALL, GO BIGGER
						step += stepIncr;
					}else {//TO BIG PERHAPS, CHECK IF WE GO SMALLER IF IT WORKS BETTER?
						sizeFinal = step;
						step -= stepIncr;
					}
					stepIncr /= 2;//binary search, decrease range /2 each time so we refine more and more
				}
				
				//NOW TRY TO CHOP OFF SOME OF THE HEIGHT
				maxSteps = 16;
				stepIncr = sizeFinal*0.8;
				step = sizeFinal;
				
				width = sizeFinal;
				height = sizeFinal;
				
				//trace("A best size: " + width+" x "+height);
				
				for (i = 0; i < maxSteps; i++) {
					length = fnSortSearchReturnLength(width, step);
					if (length > 0){//TO SMALL, GO BIGGER
						step += stepIncr;
					}else {//TO BIG PERHAPS, CHECK IF WE GO SMALLER IF IT WORKS BETTER?
						height = step;
						step -= stepIncr;
					}
					stepIncr /= 2;//binary search, decrease range /2 each time so we refine more and more
					if (stepIncr == 0) {
						break;
					}
				}
				//trace("B best size: " + width+" x "+height);
				
				//NOW TRY TO CHOP OFF SOME OF THE WIDTH
				maxSteps = 16;
				stepIncr = sizeFinal*0.8;
				step = sizeFinal;

				for (i = 0; i < maxSteps; i++) {
					length = fnSortSearchReturnLength(step, height);
					if (length > 0){//TO SMALL, GO BIGGER
						step += stepIncr;
					}else {//TO BIG PERHAPS, CHECK IF WE GO SMALLER IF IT WORKS BETTER?
						width = step;
						step -= stepIncr;
					}
					stepIncr /= 2;//binary search, decrease range /2 each time so we refine more and more
					if (stepIncr == 0) {
						break;
					}
				}
				
				//trace("C best size: " + width+" x "+height);
				
				//BUILD FINAL ARRAYS TO OUTPUT AND RENDER
				rect_list = new Vector.<RectPack>();
				for (j = 0; j < m_bmpd.length; j++) {
					rect_list.push(new RectPack(0, 0, m_bmpd[j].width, m_bmpd[j].height,sessionPadding,j));
				}
				rect_list = rect_list.sort(sortRects);//SORT BY VOLUME
				//--------------------------
				//EMPTY VARIABLES BEFORE BUILDING A TREE MAP
				area_covered = 0;
				search_step = 0;
				packed_rect_list = new Vector.<RectPack>();
				build_tree( new RectPack(	0, 0, width, height, 0, -1));
				
			}
			//trace("best size: " + width+" x "+height);
			
			//TODO: ADD TIGHTEN RESULT BACK
			//tightenResult();
			
			var r:RectPack;
			var bmpdTmp:BitmapData = new BitmapData(width, height, true, 0x00000000);
			for (i = 0; i < packed_rect_list.length; i++) {
				r = packed_rect_list[i];
				r.width -= sessionPadding;
				r.height -= sessionPadding;
				bmpdTmp.copyPixels(m_bmpd[r.sourceIdx], m_bmpd[r.sourceIdx].rect, new Point(r.x, r.y));
			}
			if ( sessionPowerOfTow ){
				bmpdFin = bmpdTmp;
			}else {
				var crop:Rectangle = bmpdTmp.getColorBoundsRect(0xFFFFFFFF, 0x000000, false);//alpha crop
				bmpdFin = new BitmapData(crop.width+sessionPadding, crop.height+sessionPadding, true, 0x00000000);
				bmpdFin.copyPixels(bmpdTmp, bmpdTmp.rect, new Point());
				//width = bmpdFin.width;
				//height = bmpdFin.height;
			}
			
			
			
			
			
			
			
			
			
			
			
			
			/*
			var out:String = fnGetStringOutput();
			trace("OUT:\n" + out);
			setClipBoardText(out);
			*/
			
			
		}
		
		
		private function tightenResult():void {
			trace("tightenResult");
			
			
			var i:int;
			var j:int;
			var k:int;
			
			var r1:Rectangle;
			var r2:Rectangle;
			
			var maxSteps:int = 32;
			var stepIncr:int;
			var hit:Boolean;
			
			
			
			for (i = 0; i < packed_rect_list.length; i++) {
				//Y- axis
				r1 = packed_rect_list[i].rect;
				stepIncr = r1.height;
				for (j = 0; j < maxSteps; j++) {
					r1.y = Math.max(0, r1.y - stepIncr);
					hit = false;
					for (k = 0; k < packed_rect_list.length; k++) {
						if ( i != k) {//not same rect
							r2 = packed_rect_list[k].rect;
							if (r1.intersects(r2) || r1.containsRect(r2)) {
								hit = true;
								break;
							}
						}
					}
					if (!hit) {
						//trace(i+" / "+j+" ("+packed_rect_list.length+"). move.."+packed_rect_list[i].y,r1.y+" = "+(packed_rect_list[i].y-r1.y));
						packed_rect_list[i].y = r1.y;
					}else {
						r1.y = Math.max(0, r1.y + stepIncr);
					}
					stepIncr /= 2;//binary search, decrease range /2 each time so we refine more and more
					if (stepIncr <= 0 || r1.y == 0) {
						break;
					}
				}
				//X- axis
				r1 = packed_rect_list[i].rect;
				stepIncr = r1.width;
				for (j = 0; j < maxSteps; j++) {
					r1.x = Math.max(0, r1.x - stepIncr);
					hit = false;
					for (k = 0; k < packed_rect_list.length; k++) {
						if ( i != k) {//not same rect
							r2 = packed_rect_list[k].rect;
							if (r1.intersects(r2) || r1.containsRect(r2)) {
								hit = true;
								break;
							}
						}
					}
					if (!hit) {
						//trace(i+" / "+j+" ("+packed_rect_list.length+"). move.."+packed_rect_list[i].y,r1.y+" = "+(packed_rect_list[i].y-r1.y));
						packed_rect_list[i].x = r1.x;
					}else {
						r1.x = Math.max(0, r1.x + stepIncr);
					}
					stepIncr /= 2;//binary search, decrease range /2 each time so we refine more and more
					if (stepIncr <= 0 || r1.x == 0) {
						break;
					}
				}
			}
		}
		
		
	}

}