/********************************************************************************************************************************************************************************
* 
* Class Name  	: com.kurst.events.eventDispatcher
* Version 	  	: 1
* Description 	: Event Dispatcher Class
* 
********************************************************************************************************************************************************************************
* 
* Author 		: Karim Beyrouti
* Date 			: 03/01/08
* 
********************************************************************************************************************************************************************************
* 
* METHODS
* 
* 		addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true)
* 		dispatchEvent(evt:Event):Boolean
* 		hasEventListener(type:String):Boolean
* 		removeEventListener(type:String, listener:Function, useCapture:Boolean = false)
* 		willTrigger(type:String):Boolean
* 
********************************************************************************************************************************************************************************
* TODO			:
*********************************************************************************************************************************************************************************
* NOTES			:
**********************************************************************************************************************************************************************************/

package shoebox.plugin.shareFolder.fileUtils {

	import flash.events.IEventDispatcher;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.display.Sprite
               
	public class eventDispatcher implements IEventDispatcher{

				
		private var dispatcher:EventDispatcher;
		
		public function eventDispatcher() {
			dispatcher = new EventDispatcher(this);
		}

		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void{
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
			   
		public function dispatchEvent(evt:Event):Boolean{
			return dispatcher.dispatchEvent(evt);
		}
		
		public function hasEventListener(type:String):Boolean{
			return dispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
					   
		public function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}

	}
	
}
