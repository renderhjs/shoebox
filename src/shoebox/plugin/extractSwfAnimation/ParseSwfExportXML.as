package shoebox.plugin.extractSwfAnimation 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import shoebox.plugin.cutSprites.RectPack;
	import shoebox.plugin.extractSwfAnimation.parseSwf.ParseSwfFrames;
	import shoebox.plugin.extractSwfAnimation.parseSwf.properties.ParseSwfTween;
	import shoebox.plugin.extractSwfAnimation.parseSwf.properties.TransformProperty;
	/**
	 * ...
	 * @author renderhjs
	 * Creates a XML file(s) that define the sprite animation
	 */
	public class ParseSwfExportXML{
		public function ParseSwfExportXML() {
			
		}
		private var xml:String = "";
		private var tex:String = "";
		public function exportAnimation(parse:ParseSwfFrames,textureIds:Vector.<int>,rectBnds:Vector.<Rectangle>):String {
			var i:int; var j:int;
			
			xml = "<swf fps=\""+30+"\" length=\""+parse.framesMax+"\" tex=\""+	"spritesheet.png"	+"\">\n";
			
			for (i = 0; i < parse.tweens.length; i++) {
				var obj:DisplayObject = parse.objects[i];
				
				
				var texId:String = "";
				//if (textureIds.indexOf(i) != -1) {
				
				if (textureIds[i] != -1) {
					//texId = "tex=\""+textureIds.indexOf(i).toString()+"\"";
					texId = "tex=\"" + textureIds[i].toString() + "\"";
					texId+= " sx=\""+rectBnds[i].x+"\" sy=\""+rectBnds[i].y+"\"";
				}
				
				
				
				
				
				var tmp:String = "tmp=\""+obj.toString()+","+(obj is DisplayObjectContainer)+"\"";
				
				xml += "\t<elm id=\""+obj.name+"\" parent=\""+parse.objectsParentIds[i]+"\" z=\""+parse.objectsDepth[i]+"\" "+texId+" "+tmp+" >\n";
				
				
				//TWEENS
				if (parse.tweens[i].length == 0) {//no tweens at all, set initial position
					xml += "\t\t<set  at=\""+0+"\" >"+	"visible=0,x=0,y=0,rotation=0,alpha=1,scaleX=1,scaleY=1"	+"</set>\n";
				}else {
					//
					for (j = 0; j < parse.tweens[i].length; j++) {
						var t:ParseSwfTween = parse.tweens[i][j];
						
						if (j == 0) {
							xml += "\t\t<set  at=\""+0+"\" >"+renderTweenProperty(t.tpA)+"</set>\n";
						}
						
						xml += "\t\t<tweenTo  at=\"" + t.fA + "\" length=\"" + (t.fB - t.fA) + "\" >";
						xml += renderTweenProperty(t.tpB);//TWEEN TO PROPERTY
						xml += "</tweenTo>\n";
					}
				}
				
				//trace("obj :" + i+" tweens: "+parse.tweens[i].length);
				
				xml += "\t</elm>\n";
				
			}
			xml+= "\n</swf>";
			return xml;
			//trace("Export Animation:\n"+xml);
		}
		private function renderTweenProperty(t:TransformProperty):String {
			return String("visible="+int(t.visible)+",x=" + t.x +",y="+t.y+",rotation="+renderFloat(t.rotation)+",alpha="+renderFloat(t.alpha)+",scaleX="+renderFloat(t.scaleX)+",scaleY="+renderFloat(t.scaleY) );
			//trace("r: " + t.rotation);
			//return String("visible=" + int(t.visible) + ",x=" + t.x +",y=" + t.y + ",rotation=" + t.rotation + ",alpha=" + renderFloat(t.alpha) + ",scaleX=" + renderFloat(t.scaleX) + ",scaleY=" + renderFloat(t.scaleY) );
			
		}
		private function renderFloat(inp:Number):String {
			return inp.toFixed(2);
			//return String(inp);
		}
		public function exportTextureData(rects:Vector.<RectPack>):String  {
			var i:int;
			
			tex = "<tex>";
			
			for (i = 0; i < rects.length; i++) {
				var r:RectPack = rects[i];
				tex+= "\n\t<rec x=\""+r.x+"\" y=\""+r.y+"\" width=\""+r.width+"\" height=\""+r.height+"\"/>";
			}
			
			tex += "\n</tex>";
			return tex;
			//trace("Export Texture:\n"+tex);
		}
		
		
	}

}