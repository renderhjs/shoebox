package shoebox.app.gui.settings 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import tools.BmpSliceDraw;
	import tools.txtTools.TxtTools;
	/**
	 * ...
	 * @author renderhjs
	 */
	public class UiSettingsVariableItem extends Sprite{
		[Embed(source="../../../../../src/assets/slice_settingsItemLabel_3x.png")]
		private var embd_bmp0:Class;
		[Embed(source="../../../../../src/assets/slice_settingsItemValue_3x.png")]
		private var embd_bmp1:Class;
		private var sliceLbl:BmpSliceDraw = new BmpSliceDraw((new embd_bmp0()).bitmapData);
		private var sliceVal:BmpSliceDraw = new BmpSliceDraw((new embd_bmp1()).bitmapData);
		
		private var txtLabel:TextField = TxtTools.getTxt();
		public var txtValue:TextField = TxtTools.getTxt();
		
		private var widthB:int = 0;
		public var type:String = "";
		public var data:Object = null;
		
		public function UiSettingsVariableItem(label:String, value:Object, type:String, widthA:int, widthB:int):void {
			this.widthB = widthB;
			this.type = type;
			this.data = value;
			if ((value as Array) != null && value != "") {
				this.type = "array";
			}
			
			
			
			
			
			
			
			var sW:int = 3;//space in width
			var sTxt:int = 4;//space in width
			TxtTools.formatBasic(txtLabel, 11, 0x767676);
			//TxtTools.formatBasic(txtValue, 12, 0xffffff);
			//TxtTools.formatInput(txtValue, widthB);
			
			addChild(txtLabel);
			addChild(txtValue);
			
			txtLabel.y = txtValue.y = -2;//shift up
			txtLabel.x = sTxt;
			txtValue.x = widthA+sTxt;
			
			txtLabel.text = label;
			txtValue.text = String(value);
			
			
			
			
			
			if (type == "number") {
				txtValue.restrict = "0-9.,";
			}else if (type == "boolean") {
				txtValue.restrict = "falsetrue10!";
			}
			
			reFormat();
			
			if (label == "varNamesSplit"){
				trace("\nvarNamesSplit:");
				trace("type.. " + type);
				trace("value >" + value+"<");
				trace("txtValue.text >" + txtValue.text+"<");
				trace("String(value) >" + String(value)+"<");
				
			}
			
			
			
			txtValue.autoSize = TextFieldAutoSize.NONE;
			txtValue.height += 4;
			
			
			//trace("type: [" + type+"]");
			
			
			var g:Graphics = graphics;
			g.clear();
			sliceLbl.draw(g, 0, 0, widthA-sW);
			sliceVal.draw(g, widthA, 0, widthB);
		}
		
		
		public function parseDataFromTxtString():Object {
			var obj:Object = null;
			var raw:String = txtValue.text;
			var a:Array = [];
			
			if (type == "number") {
				raw = raw.split(",").join(".");//in case EU , characters were used
				if (Number(raw)){//not NaN
					obj = Number(raw);//try to parse it as number
				}else {
					obj = 0;
				}
			}else if (type == "boolean") {
				a = ["true", "!false", "1","!0"];
				if (a.indexOf(raw) != -1 ) {
					obj = true;
				}else {
					a = ["false", "!true", "0", "!1"];
					if (a.indexOf(raw) != -1 ) {
						obj = false;
					}
				}
			}else if (type == "string") {
				obj = raw;//just take over the way it is
			}else if (type == "array") {
				obj = raw.split(",");
			}
			return obj;
		}
		
		
		
		
		
		
		
		
		
		
		
		public function reFormat():void {
			TxtTools.formatBasic(txtValue, 12, 0xffffff);
			TxtTools.formatInput(txtValue, widthB);
			
			TxtTools.formatKeywordsColor(txtValue, ["*","#"], 0xff8a2b);//asterix and other key words
			TxtTools.formatKeywordsColor(txtValue, ["0","1","2","3","4","5","6","7","8","9"], 0x37bee0);//numbers = blue
			//TxtTools.formatKeywordsColor(txtValue, [".jpg",".png",".gif",".xml",".txt"], 0x8b8b8b);//make a bit darker
			TxtTools.formatKeywordsColor(txtValue, [".jpg",".png",".gif",".xml",".txt","/","\\"], 0x52ab1b);//make a bit darker
			TxtTools.formatKeywordsColor(txtValue, ["true","false"], 0xfffcc6);//make a bit darker
			
			
			
			
		}
		
	}

}