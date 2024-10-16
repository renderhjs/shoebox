package shoebox.plugin.extractSwfAnimation.parseSwf
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MorphShape;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.StaticText;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import flash.utils.setTimeout;
	import shoebox.plugin.extractSwfAnimation.parseSwf.properties.ParseSwfPropertyIds;
	import shoebox.plugin.extractSwfAnimation.parseSwf.properties.ParseSwfTween;
	import shoebox.plugin.extractSwfAnimation.parseSwf.properties.TransformProperty;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class ParseSwfFrames
	{
		
		public var frames:Vector.<Vector.<TransformProperty>> = new Vector.<Vector.<TransformProperty>>();
		//public var objects:Vector.<TransformProperty> = new Vector.<TransformProperty>();
		public var objects:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		public var objectsParentIds:Vector.<int> = new Vector.<int>();
		public var objectsDepth:Vector.<int> = new Vector.<int>();
		//public var library:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		public var tweens:Vector.<Vector.<ParseSwfTween>> = new Vector.<Vector.<ParseSwfTween>>();
		
		private var main:DisplayObject;
		private var fnDone:Function;
		public var framesMax:int = 7;
		private var framesCount:int = 0;
		
		
		
		
		
		public function ParseSwfFrames(main:DisplayObject,framesMax:int, fnDone:Function) {
			this.main = main;
			this.framesMax = framesMax;
			this.fnDone = fnDone;
			
			frames = new Vector.<Vector.<TransformProperty>>();
		
			
			framesCount = 0;
			//objects = new Vector.<TransformProperty>();
			objects = new Vector.<DisplayObject>();
			objectsParentIds = new Vector.<int>();
			objectsDepth	 = new Vector.<int>();
			//setTimeout(startDelayed, 500);
			startDelayed();
		}
		
		private function startDelayed():void {
			//(main as MovieClip).gotoAndPlay(1);
			main.addEventListener(Event.ENTER_FRAME, fnEnterFrame);
			main.addEventListener(Event.RENDER, fnRenderUpdate);
			 //stage.invalidate()
			fnGrabFrame();
		}
		private function fnRenderUpdate(e:Event):void {
			
			fnGrabFrame();
		}
		private function fnEnterFrame(e:Event):void {
			
			
			if (framesCount < framesMax) {
				if ( main.stage != null){
					main.stage.invalidate();//force a RENDER EVENT UPDATE AFTER THIS PRE-RENDER ENTER FRAME
				}else {
					fnGrabFrame();//stage render late event not available
				}
			}
			//fnGrabFrame();
			
		}
		private function end():void {
			main.removeEventListener(Event.ENTER_FRAME, fnEnterFrame);
			main.removeEventListener(Event.RENDER, fnRenderUpdate);
			
			fnDone();
		}
		
		
		
		
		private function fnGrabFrame():void {
			if (framesCount < framesMax) {
				//trace("_____________");
				//trace("f# "+framesCount);
				
				//stage.invalidate();
				frames[framesCount] = new Vector.<TransformProperty>();
				parseFrameState(main,true);//true as in root
				
				//UIDUtil
				
				framesCount++;
				if (framesCount == framesMax) {
					fnProcessTweens();
					end();
				}
			}
		}
		

		//[obj][nr][prop]
		
		
		private function fnProcessTweens():void {
			tweens = new Vector.<Vector.<ParseSwfTween>>();
			var tween:ParseSwfTween;
			
			
			var o:int;
			var f:int;
			var a:int;
			
			for (o = 0; o < objects.length; o++) {//OBJECTS
				tweens[o] = new Vector.<ParseSwfTween>();//TWEEN ARRAY
				
				var diffVars:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();//ONE DIFF VECTOR FOR EACH FRAME AND EACH OBJECT
				var vis:Vector.<Boolean> = new Vector.<Boolean>();
				//var tweenLastState:int = 0;//0=invisible, 1=start tween, 2=end tween
				
				tween = new ParseSwfTween();//start a new Tween Object
				
				
				for (f = 0; f < frames.length; f++) {//FRAMES
					diffVars[f] = new Vector.<Number>();
					
					var setPoint:Boolean = false;//set tween point like in flash on the timeline (starts or end a tween)
					
					var visA:int = fnPrcIsVisibleId(o,f);//visible now
					var visB:int = fnPrcIsVisibleId(o,f+1);//visible next
					
					vis[f] = (visA > -1);//Wether its visible or hidden

					for (a = 0; a < ParseSwfPropertyIds.countVars; a++) {//ATTRIBUTE
					
						diffVars[f][a] = 0;//DEFAULT VALUE
					
						if ( visA!=-1 && visB!=-1){
							var A:Number = ParseSwfPropertyIds.getValue(a,frames[f + 0][visA]);//FRAME -1
							var B:Number = ParseSwfPropertyIds.getValue(a,frames[f + 1][visB]);//FRAME NOW
							diffVars[f][a] = B - A;
						}
						if (f > 0){
							var diffMix:Number = diffVars[f][a] - diffVars[f-1][a];
							//if (Math.abs(diffMix) > 1.5) {//ONLY IF THERE IS A NOTICEABLE DIFFERENCE
							if (Math.abs(diffMix) > 0.5) {//ONLY IF THERE IS A NOTICEABLE DIFFERENCE
								setPoint = true;
							}
							if (vis[f] && !vis[f - 1]) {//was INIVIBLE BUT BECAME VISIBLE
								setPoint = true;
							}
						}
						if (f == 0 && vis[f]) {//VISIBLE FRAME ON START
							setPoint = true;
						}
						if (f == (frames.length-1) && vis[f]) {//VISIBLE FRAME AT END
							setPoint = true;
						}
					}
					if (setPoint) {
						//trace("\tOBJ: " + o + " tween  @F:" + (f + 1));
						
						if (tween.fA == -1) {
							tween.setA(f, frames[f][visA]);//assgins frame and Transform property
						}else {
							tween.setB(f, frames[f][visA]);
							tweens[o].push(tween);
							
							tween = new ParseSwfTween();//RESET
							
							if (visB != -1) {//IF NEXT FRAME IS NOT INVISIBLE, START ANOTHER TWEEN RIGHT NOW
								tween.setA(f, frames[f][visA]);
							}
							
						}
					}
				}
				//
				
				
				
				
			}
			
			
		}
		
		private function fnPrcIsVisibleId(oId:int, f:int):int {
			if (f < frames.length) {
				for (var i:int = 0; i < frames[f].length ; i++) {
					if ( frames[f][i].id == oId) {//OBJECT i IS AVAILABLE ON THIS FRAME
						return i;
					}
				}
			}
			return -1;
		}
		
		
		
		/*
		private var tween:ParseSwfTween;
		private function fnProcessTweens():void {
			var o:int;
			var f:int;
			var k:int;
			
			tweens = new Vector.<Vector.<ParseSwfTween>>();
			
			
			for (o = 0; o < library.length; o++) {//OBJECTS
				var diffVars:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
				
				//trace("fnProcessTweens, obj : " + o,objects[o].name);
				tweens[o] = new Vector.<ParseSwfTween>();//TWEEN ARRAY
				
				tween = new ParseSwfTween();//current or last Tween
				var vis:Vector.<Boolean> = new Vector.<Boolean>();
				var lastOKey:int = -1;
				for (f = 0; f < frames.length; f++) {//FRAMES
					
					diffVars[f] = new Vector.<Number>();//for every Frame store all prop diff vars
					
					var oKey:int = -1;
					for (k = 0; k < frames[f].length; k++) {//OBJECTS IN FRAME
						if ( frames[f][k].id == o) {//OBJECT i IS AVAILABLE ON THIS FRAME
							oKey = k;
							break;
						}
					}
					vis[f] = (oKey != -1);//if visible
					
					
					
					for (k = 0; k < ParseSwfPropertyIds.countVars; k++) {//PROPERTIES
						
						if (f > 0 && oKey != -1 && lastOKey != -1) {//AVAILABLE
							var A:Number = fnGetCompareVal(k, frames[f - 1][lastOKey]);//FRAME -1
							var B:Number = fnGetCompareVal(k, frames[f - 0][oKey]);//FRAME NOW
							var diff:Number = B - A;
							diffVars[f][k] = diff;
						}else {
							diffVars[f][k] = 0;
						}
						
						
						var diffMix:Number = 0;
						
						if (f > 0 && oKey != -1){
							diffMix = diffVars[f][k] - diffVars[f - 1][k];//difference of the last value difference
							if (vis[f - 1] == false) {//if former frame was invisible
								diffMix = -50000;
							}
							
							
							
						}
						
						
						//if (diffDiff > Math.abs(diff) * 0.2) {
						var tA:TransformProperty;
						var tB:TransformProperty;//
						
						if (vis[f]) {
							tA = frames[f][oKey];
						}
						if (f > 0 && lastOKey != -1) {
							tB = frames[f - 1][lastOKey];
						}
						
						
//						trace("#" + f, "@[" + ParseSwfPropertyIds.string(k) + "]  diff:" + Number(diffVars[f][k]).toFixed(2) + "\tdV: " + diffMix.toFixed(2) + ", vis: " + vis[f]);
							
							
							
						if (f == 0 && oKey != -1) {//first frame and visible
							tween.setA(0, tA);
							//break;//BREAK LOOP OF PROPERTIES
						}else if (f == frames.length-1) {//LAST FRAME
							if (oKey != -1) {//visible, end TWEEN HERE
								tween.setB(f, tA);//END HERE
							}else {
								
							}
							pushTween(o, tween);//PUSH IF POSSIBLE AT THIS POINT
							
						}else if (f > 0) {
							
							if (vis[f] && !vis[f - 1]) {//SWITCH TO VISIBLE
								tween.setA(f-1, tA);//SHOULD IT BE REALLY -1 ???
							}else if (!vis[f] && vis[f - 1]) {//SWITCH TO INVISBLE
								tween.setB(f - 1, tB);
							}else {
								//chyeck if frame differences... happenend
								
								trace("#" + f, "@[" + ParseSwfPropertyIds.string(k) + "]  diff:" + Number(diffVars[f][k]).toFixed(2) + "\tdV: " + diffMix.toFixed(2) + ", vis: " + vis[f]);
								
								var continues:Boolean = false;
								//CHECK IF CONTINOUS TWEEN?
								if (tweens[o].length > 0 && vis[f]) {
									if (tweens[o][ tweens[o].length - 1].fB == f - 1) {//if last tween end frame was previous frame
										continues = true;
										tween = new ParseSwfTween();
										tween.setA(f - 1, tB);
										trace("continues: " + f);
									}
								}
								
								if (Math.abs(diffMix) > 1.5 && f> 1) {
									tween.setB(f , tA);//END TWEEN, AND START A NEW ONE?
									pushTween(o, tween);//PUSH IF POSSIBLE AT THIS POINT
									//tween.setA(f , tA);//START ANOTHER NEW ONE?
								}
								
								
								
							}
							
							
							
							
							
						}
					}
					
					lastOKey = oKey;//cache, so we can look up perhaps in the next frame??

					pushTween(o, tween);//PUSH IF POSSIBLE AT THIS POINT
							
				}
			}
			
			trace("\ntweens.. "+tweens.length)
			for (o = 0; o < tweens.length; o++) {//OBJECTS
				trace("\tobj " + o + " ..tween: " + tweens[o].length + "x");
			}
			
			
		}
		private function pushTween(oId:int, tween:ParseSwfTween):void {
			if (tween.fA != -1 && tween.fB != -1) {
				tweens[oId].push(tween);
				tween = new ParseSwfTween();
			}
		}
*/

		/*
		var xA:Number = fnGetCompareVal(ParseSwfPropertyIds.x, frames[j-1][idx]);
		var xB:Number = fnGetCompareVal(ParseSwfPropertyIds.y, frames[j	 ][idx]);
		var xD:Number = xB - xA;//difference
		if (xD > 0) {//value increased
			
		}else if (xD < 0) {//value decreased
			
		}else if (xD == 0){//unchanged
			
		}*/

		
		/*
		
		private function fnGetCompareVal(id:int, tp:TransformProperty ):Number {
			
			
			switch (id){
				case ParseSwfPropertyIds.x:
					return tp.x;
				case ParseSwfPropertyIds.y:
					return tp.y;
				case ParseSwfPropertyIds.alpha:
					return tp.alpha;
				case ParseSwfPropertyIds.rotation:
					return tp.rotation;
					break;
			}
			return 0;
		}
		*/
		
		
		
		
		
		
		
		
		
		
		
		
		
		private function getParentId(id:int):int {
			var o:DisplayObject = objects[id].parent;
			if (o != null) {
				var idx:int = objects.indexOf(o);
				return idx;
			}
			return -1;
		}
		
		private function collectAndGetId(d:DisplayObject,root:Boolean):int {
			/*
			var b:ByteArray = new ByteArray();
			b.writeObject(o);
			*/
			
			var idx:int = objects.indexOf(d);
			if (!root){//its not the root object
				var tr:TransformProperty;
				
				if (idx == -1) {//NOT EXISTING PUSH TO INDEX
					
					var A:String = getQualifiedClassName(d);//more Flash IDE alike
					var B:String = getQualifiedSuperclassName(d);//more simplified
					var C:String = Object(d).constructor //getDefinitionByName(Class(getDefinitionByName((d))));//more simplified
					var D:String = typeof(d) //getDefinitionByName(Class(getDefinitionByName((d))));//more simplified
					//var E:String = describeType(d) //getDefinitionByName(Class(getDefinitionByName((d))));//more simplified
					var E:String = describeType(d).@name //getDefinitionByName(Class(getDefinitionByName((d))));//more simplified
					var F:String = d.getRect(d).toString(); //getDefinitionByName(Class(getDefinitionByName((d))));//more simplified
					
					
					
					
					
					//Class(getDefinitionByName((d)))
					trace("OBJ " +	A	+"\t"+ B +"\t"+ C+"\t"+ D );
					trace("\t\t"+F );
					//return ;
					
					objects.push(d);
					idx = objects.length - 1;
					
					objectsParentIds[idx] = getParentId(idx);//grab the parent now while we still can
					objectsDepth[idx] = m_depthCount;
				}
				
				tr = new TransformProperty(idx, d);
				frames[frames.length - 1].push( tr );
				
				if (d.name.indexOf("instance250") != -1) {
					trace(" No. = "+d.name+" ,sx/sy: " + tr.x,tr.y+", scale: "+tr.scaleX,"vis: "+tr.visible);
				}
			
				
				//trace("\tTR PUSH: @" + (frames.length) + " = " + frames[frames.length - 1].length);
			}else {
				//trace("TR ?? PUSH: @" + (frames.length),root);
				//trace("UNKOWN ID: " + d);
				//trace("ROOT: " + d.name);
				idx = -1;
			}
			
			
			
			//trace("TR ?? PUSH  #"+(frames.length));
			return idx;
		}
		private var m_depthCount:int;
		private function parseFrameState(d:DisplayObject, root:Boolean = false ):void {
			
			if (root) {
				m_depthCount = 0;//START OVER
			}else {
				m_depthCount++;
			}
			
			if (d != null){
				var n:String = d.name;
				var bnds:Rectangle = d.getBounds(d.parent);
				
				var uId:int = collectAndGetId(d,root && d as DisplayObjectContainer);
				
				//trace("2. pos: " + d.x,d.y);
				
				if (d is DisplayObjectContainer) {
					//trace("1. ct: " + uId);
					var c:DisplayObjectContainer = d as DisplayObjectContainer;
					//;
					
					//trace("DIR : #" + (frames.length) + " num = " + c.numChildren+": ");
					for (var i:int = 0; i < c.numChildren ; i++) {
						
						if ( c.getChildAt(i) == null) {
							trace("NULL CHILD !?! DEBUG!!! A " + i + ".) " + c.getChildAt(i));
						}
						

						parseFrameState( c.getChildAt(i),false );
					}
				}else {
					
					//CHECK WHAT IS GOING ON
					
					
					
					//trace("1. dc: id: '" + uId+"'\t"+d.toString());
					//trace("\t2. bnds: " + bnds.x,bnds.y,bnds.width,bnds.height);
					if (d is StaticText) {
						var st:StaticText = d as StaticText;
						//trace("\t3. txt=\""+st.text+"\"");
					
					}else if (d is Bitmap) {
						//trace("\t3. Bmp");
					}else if (d is Shape) {
						//trace("\t3. Shape");
					}else if (d is MorphShape) {
						//trace("\t3. MorphShape");
					}
					
				}
			}
		}
		
	}

}