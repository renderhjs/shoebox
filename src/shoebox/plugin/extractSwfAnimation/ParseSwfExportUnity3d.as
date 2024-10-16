package shoebox.plugin.extractSwfAnimation 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import tweenTex.TweenTexTransform;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class ParseSwfExportUnity3d{
		
		public function ParseSwfExportUnity3d() {
			
		}
		private var rect:Vector.<Rectangle> = new Vector.<Rectangle>();
		
		
		
		public function exportUnityCode(className:String, aniXml:String, recXml:String, tex:BitmapData):String {
			var i:int;var j:int;
			
			//RECTANGLE DATA
			var r:XML = new XML(recXml);
			for (i = 0; i < r.rec.length() ; i++) {
				rect.push(new Rectangle(r.rec[i].@x,r.rec[i].@y,r.rec[i].@width,r.rec[i].@height));
			}
			
			//
			
			var o:String = "";//output
			
			
			o = "using UnityEngine;\nusing System.Collections;\nusing System.Collections.Generic;\n\n";
			o += "public class "+className+" : TexTween {\n\tvoid Start () {\n\t\tinit();\n\t\tTransform t;\n\n";
			
			var a:XML = new XML(aniXml);
			
			//length = Number(a.@length);
			//fps = Number(a.@fps);
			
			for (i = 0; i < a.elm.length() ; i++) {
				var idTex:int = a.elm[i].@tex == undefined ? -1 : int(a.elm[i].@tex);
				var id:String = a.elm[i].@id;
				var z:int = Number(a.elm[i].@z);
				
				o += "\t\tt = addTransform(\""+id+"\","+z+");\n";
				
				
				if (idTex > -1) {//is a texture sprite
					var rTex:Rectangle = rect[idTex];
					
					o += "\t\taddTexture(t,"+(Number(a.elm[i].@sx))+"f,"+(Number(a.elm[i].@sy))+"f,"+rTex.width+"f,"+rTex.height+"f,new Rect("+(rTex.x/tex.width)+"f,"+(rTex.y/tex.height)+"f,"+(rTex.width/tex.width)+"f,"+(rTex.height/tex.height)+"f));\n";
				}
				
				
				//PARENTING
				if (a.elm[i].@parent != undefined) {
					var prnt:int = Number(a.elm[i].@parent);
					if (prnt > -1) {
						//sprt[prnt].addChild(s);
						o += "\t\tt.parent = obj["+prnt+"];\n";
					}else {
						o += "\t\tt.parent = transform;\n";
						//addChild(s);
					}
				}
				
				
				//TRANSFORM-SETS AND TWEENS
				
				//FIRST TRANSFORM
				if (a.elm[i].set.length() > 0) {
					if (String(a.elm[i].set[0]) != ""){
						var tr:TweenTexTransform = new TweenTexTransform(a.elm[i].set[0]);
						//setTransform(t, x,y,rot,alp,scalx,scaly,vis);
						o += "\t\tsetTransform(t,"+tr.x+"f,"+tr.y+"f,"+tr.rotation+"f,"+tr.alpha+"f,"+tr.scaleX+"f,"+tr.scaleY+"f,"+tr.visible+");\n";
					}/*else {
						o += "\t\tsetTransform(t,"+0+"f,"+0+"f,"+0+"f,"+1+"f,"+1+"f,"+1+"f,true);\n";
					}*/
				}
			}
			
			o += "\t}\n}";
			
			return o;
		}
		
	}

}