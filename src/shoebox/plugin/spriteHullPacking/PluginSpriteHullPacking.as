package shoebox.plugin.spriteHullPacking 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import net.sakri.flash.bitmap.BitmapDataUtil;
	import net.sakri.flash.bitmap.BitmapShapeExtractor;
	import net.sakri.flash.bitmap.ExtractedShapeCollection;
	import net.sakri.flash.bitmap.MarchingSquares;
	import net.sakri.flash.vector.ShapeOptimizer;
	import net.sakri.flash.vector.VectorShape;
	import shoebox.app.gui.UiPluginWindow;
	import shoebox.plugin.event.PluginFileTransferEvent;
	import shoebox.plugin.PluginBase;
	import shoebox.plugin.PluginHelper;
	import tools.Color;
	/**
	 * ...
	 * @author Hendrik
	 */
	public class PluginSpriteHullPacking extends PluginBase{
		[Embed(source="icon_48x48.png")]
		private var embd_bmp0:Class;

		public function PluginSpriteHullPacking(){
			this.label = "Spr. Hull Packing";
			this.icon = new embd_bmp0().bitmapData;//tool icon
			this.settings = {};
			this.settingsInfo = "Packs hulls of sprites into a texture sheet";
			this.extentions = ["jpg", "jpeg", "png","gif"];
			
			
			registerListenEventGetData(PluginFileTransferEvent.DATA_FILE_IN, fnListenData);
			//registerListenEventGetData(PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_IMAGE, fnClipBoardBmp);
			//registerListenEventGetData(PluginClipBoardTransferEvent.DATA_CLIPBOARD_IN_TEXT, fnClipBoardTxt);
			
			//registerListenEventClick(fnClick);
			
			//uiFolder = new PluginShareFolderUi(this);
			//registerListenEventGetData(
		}
		
		private var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>();
		
		private var filesDrag:Vector.<File> = new Vector.<File>();
		private function fnListenData(e:PluginFileTransferEvent):void {
			filesDrag = e.files;
			fnProcessDroppedFile(0);
		}
		private function fnProcessDroppedFile(nr:int):void {
			if (nr < filesDrag.length){//01 LOAD SOURCE
				PluginHelper.getFileBitmap(filesDrag[nr], fnPushBitmap, nr);
			}else {
				trace("Done :)");
				fnInit();
			}
		}
		private function fnPushBitmap(b:BitmapData, nr:int):void {
			bitmaps[nr] = b;
			fnProcessDroppedFile(nr + 1);
		}
		
		//-----------------------------------------------------------------------------------------
		
		
		
		
		
		
		private var stage:Stage;
		private function fnInit():void {
			
			var sW:int = 700;
			var sH:int = 500;
			
			stage = UiPluginWindow.init(sW, sH);
			
			
			var s:int = 4;
			
			var mtxW:int = 133+s;
			var mtxH:int = 100+s;
			for (var i:int = 0; i < bitmaps.length; i++) {
				fnProcessBmp(bitmaps[i],i%Math.floor(sW/mtxW)*mtxW+s, Math.floor(i / (Math.floor(sW/mtxW)))*mtxH+s );
			}
			
			
			
			
		}
		
		
		
		private function fnProcessBmp(b:BitmapData,xOff:int=0,yOff:int=0):void {
			var i:uint;
			//var b:BitmapData = bitmaps[nr];
			var a:Number = 15;
			var px:int = 8;
			
			a = 8;
			px = 5;
			
			
			
			var sh:SpriteHull = new SpriteHull(b);
			sh.calcAngles();
			sh.limitByAngle(a/2);
			
			sh.limitBySnap(px);
			
			
			for (i = 0; i < 3; i++) {
				sh.calcAngles();
				sh.limitByAngle(a);
			
			}
			
			
			
			sh.calcAngles();
			/*
			sh.calcAngles();
			sh.limitByAngle(3);
			*/
			
			//
			
			
			/*
			sh.calcAngles();
			sh.limitByAngle(8);
			sh.calcAngles();
			sh.limitByAngle(8);
			*/
			/*
			var ext:BitmapData = new BitmapData(b.width + 2, b.height + 2, true, 0x00000000);
			ext.draw(b, new Matrix(1, 0, 0, 1, 1, 1));
			b = ext;
			
			var pts:Vector.<Point> = MarchingSquares.getBlobOutlinePointsClockwise(b);
				
			trace("pts: " + pts.length);
			
			
			//REDUCE OR SAMPLE POINTS
			var dis:Number = 0;
			
			var pts_smth:Vector.<Point> = new Vector.<Point>();
			var decimal:int = 2;
			for (i = 0; i < pts.length; i++) {
				if (i % decimal == 0) {
					pts_smth.push(pts[i]);
					
					//DISTANCE
					if (pts_smth.length > 1) {
						var d:Number = pts_smth[pts_smth.length - 1].subtract(pts_smth[pts_smth.length - 1 - 1]).length;
					
						dis += d;
						
						if (d < decimal*0.5) {
							pts_smth.splice(pts_smth.length - 1, 1)
							dis -= d;
						}
						
					}
					
				}
			}
			pts = pts_smth;
			
			
			//FIND DIFFERENCE ANGLES
			var ang_a:Number=0;//angle a = forward
			var ang_b:Number=0;//angle b = one back
				
				
			var angMin:Number;
			var angMax:Number;
			var angDiff:Vector.<Number> = new Vector.<Number>();
			var angDiffMax:Number;
			
			var ang_d:Number
			
			for (i = 0; i < pts.length; i++) {
				
				if (i == 0) {
					ang_a = fnGetAngle(pts[i], pts[i + 1]);
					ang_b = fnGetAngle(pts[pts.length-1], pts[i]);
				}else if (i == pts.length - 1) {
					ang_a = fnGetAngle(pts[i], pts[0]);
					ang_b = fnGetAngle(pts[i - 1], pts[i]);
				}else {
					ang_a = fnGetAngle(pts[i], pts[i + 1]);
					ang_b = fnGetAngle(pts[i - 1], pts[i]);
				}
				
				ang_d = Math.atan2( Math.sin(ang_a - ang_b), Math.cos(ang_a - ang_b));//difference angle
				
				
				if (i == 0) {
					angMax = angMin = ang_d;
				}else {
					angMin = Math.min(angMin, ang_d);
					angMax = Math.max(angMax, ang_d);
				}
				
				angDiff[i] = ang_d;
			}
			angDiffMax = Math.max( Math.abs(angMax), Math.abs(angMin));
			
			
			//merge low thresholds, aka no differences
			
			var pts_reduce:Vector.<Point> = new Vector.<Point>();
			var ang_reduce:Vector.<Number> = new Vector.<Number>();
			for (i = 0; i < pts.length; i++) {
				if ((angDiff[i])*180/Math.PI  >= 5) {
					pts_reduce.push( pts[i]);
					ang_reduce.push( angDiff[i]);
				}
			}
			pts = pts_reduce;
			angDiff = ang_reduce;
			
			
			for (i = 0; i < pts.length; i++) {
				
				if (i == 0) {
					ang_a = fnGetAngle(pts[i], pts[i + 1]);
					ang_b = fnGetAngle(pts[pts.length-1], pts[i]);
				}else if (i == pts.length - 1) {
					ang_a = fnGetAngle(pts[i], pts[0]);
					ang_b = fnGetAngle(pts[i - 1], pts[i]);
				}else {
					ang_a = fnGetAngle(pts[i], pts[i + 1]);
					ang_b = fnGetAngle(pts[i - 1], pts[i]);
				}
				
				ang_d = Math.atan2( Math.sin(ang_a - ang_b), Math.cos(ang_a - ang_b));//difference angle
				
				
				if (i == 0) {
					angMax = angMin = ang_d;
				}else {
					angMin = Math.min(angMin, ang_d);
					angMax = Math.max(angMax, ang_d);
				}
				
				angDiff[i] = ang_d;
			}
			
			pts_reduce = new Vector.<Point>();
			ang_reduce = new Vector.<Number>();
			for (i = 0; i < pts.length; i++) {
				if ((angDiff[i])*180/Math.PI  >= 3) {
					pts_reduce.push( pts[i]);
					ang_reduce.push( angDiff[i]);
				}
			}
			pts = pts_reduce;
			angDiff = ang_reduce;
			
			for (i = 0; i < pts.length; i++) {
				
				if (i == 0) {
					ang_a = fnGetAngle(pts[i], pts[i + 1]);
					ang_b = fnGetAngle(pts[pts.length-1], pts[i]);
				}else if (i == pts.length - 1) {
					ang_a = fnGetAngle(pts[i], pts[0]);
					ang_b = fnGetAngle(pts[i - 1], pts[i]);
				}else {
					ang_a = fnGetAngle(pts[i], pts[i + 1]);
					ang_b = fnGetAngle(pts[i - 1], pts[i]);
				}
				
				ang_d = Math.atan2( Math.sin(ang_a - ang_b), Math.cos(ang_a - ang_b));//difference angle
				
				
				if (i == 0) {
					angMax = angMin = ang_d;
				}else {
					angMin = Math.min(angMin, ang_d);
					angMax = Math.max(angMax, ang_d);
				}
				
				angDiff[i] = ang_d;
			}
			
			
			
			
			
			
			
			trace("angMax: " + angMax);
			trace("angMin: " + angMin);
			trace("dis: " + dis);
			
*/
			//----------------------------------
			
			var shp:Shape = new Shape();
			shp.x = xOff;
			shp.y = yOff;
			
			var g:Graphics = shp.graphics;
			//g.lineStyle(0, 0x00e4ff);
			var prvPoint:Point;
			for (i = 0;i < sh.pts.length;i++) {
				//var p:Number  = Math.abs(sh.angDiff[i])*180/Math.PI / 120;
				var p:Number  = Math.max(0,sh.angDiff[i])*180/Math.PI / 120;
				
				if (i == 0) {
					prvPoint = sh.pts[i];
				}else {
					g.lineStyle(0, 0x00ff00,0.85);
					g.moveTo( prvPoint.x, prvPoint.y);
					g.lineTo( sh.pts[i].x, sh.pts[i].y);
					prvPoint = sh.pts[i];
				}
				
				g.lineStyle();
				var s:int = 2;
				g.beginFill(Color.getColorByTemp(p));
				g.drawRect(sh.pts[i].x - s, sh.pts[i].y -s, 2*s, 2*s);
				g.endFill();
			}
			g.lineStyle(0, 0x00ff00,0.85);
			g.lineTo( sh.pts[0].x, sh.pts[0].y);
			
			g.lineStyle(0, 0x0000ff);
			g.drawRect(0, 0, sh.rect.width, sh.rect.height);
			
	
			//----------------------------------
				
			var bmp:Bitmap = new Bitmap(b);
			bmp.alpha = 0.25;
			bmp.x = xOff;
			bmp.y = yOff;
			stage.addChild(bmp);	
			stage.addChild(shp);	
		}
		
		
		
		
		
		
		
		
		
		
		
		
		/*
		private function initTemp():void {
			trace("sprites: " + bitmaps.length + "x");
			var i:uint = 0;
			var b:BitmapData;
			
			var ext_size:int = 1;
			for (i = 0; i < bitmaps.length; i++) {
				b = bitmaps[i];
				var ext:BitmapData = new BitmapData(b.width + 2 * ext_size, b.height + 2 * ext_size, true, 0x00000000);
				ext.draw(b, new Matrix(1, 0, 0, 1, ext_size, ext_size));
			}
			
			
			var stage:Stage = UiPluginWindow.init(500, 500);
			var dbShape:Shape = new Shape();
			var g:Graphics = dbShape.graphics;
			stage.addChild(dbShape);
			
			
			
			//var first_non_trans:Point=getFirstNonTransparentPixel(bmd).add(new Point(-1,-1));//move back and up one
			
			
			
			
			
			
			
			MarchingSquares.getBlobOutlinePointsClockwise(shapes_collection.shapes[i]);
			
			
			
			
			
			var shapes_collection:ExtractedShapeCollection;
			
			shapes_collection = BitmapShapeExtractor.extractShapes(bitmaps[0]);
			trace("pos shapes: " + shapes_collection.shapes.length);
			trace("neg shapes: " + shapes_collection.negative_shapes.length);
			
			
			
			
			
			
			
			
			
			
			for (i=0; i < shapes_collection.shapes.length; i++) {
				
				var pixels:Vector.<Point> = MarchingSquares.getBlobOutlinePointsClockwise(shapes_collection.shapes[i]);
				//var vs:VectorShape = ShapeOptimizer.getOptimizedVectorShapeFromPoints(pixels);
				
				trace("pix: " + pixels.length);
				
				g.lineStyle(0, 0x0000ff);
				for (var j:int = 0; j < pixels.length; j++) {
					if (j%8 == 0){
						if (j == 0) {
							g.moveTo(pixels[j].x+200, pixels[j].y+64);
						}else {
							g.lineTo(pixels[j].x+200, pixels[j].y+64);
						}
					}
				}
				
				//var vs:VectorShape = ShapeOptimizer.getOptimizedVectorShapeFromPoints(pixels);
				//var points:Vector.<Point> = vs.getPointsVector();
				//positive_shape_points[i] = points;
				
				
				
				
			}
			
			
			
			
			
			
		}
		*/
		
		
		
		
		
		
		
		
		
		
		
	}

}