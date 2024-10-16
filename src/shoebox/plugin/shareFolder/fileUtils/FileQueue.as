/********************************************************************************************************************************************************************************
* 
* Class Name  	: 
* Version 	  	: 
* Description 	: 
* 
********************************************************************************************************************************************************************************
* 
* Author 		: Karim Beyrouti
* Date 			: 
* 
********************************************************************************************************************************************************************************
* 
* METHODS
* 
*
* PROPERTIES
* 
*
* EVENTS
* 
* 
********************************************************************************************************************************************************************************
* 				:
*
*
*********************************************************************************************************************************************************************************
* NOTES			:
**********************************************************************************************************************************************************************************/

package shoebox.plugin.shareFolder.fileUtils {

	//import com.kurst.events.CEventDispatcher;
	//import com.kurst.events.FileUtilsEvent;
	
	import flash.filesystem.File;

	public class FileQueue extends CEventDispatcher {

		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		private var files 				: Array;
		private var _ID					: Number; 		
		private static var QUEUE_ID 	: Number 	= 0; 
		private var pointer				: int		= 0;
		private var _busy				: Boolean	= false;
		
		private var _overwrite			: Boolean;
		private var _name				: String;
				
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		public function FileQueue( __name : String ) {
			
			super();
			
			files 		= new Array();
			_ID 		= QUEUE_ID ++;
			_name 		= __name
			
		}

		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-PUBLIC-----------------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
	

		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		public function copy( destinationPath : File , overwrite : Boolean = false ) : Boolean {
			
			if ( _busy ) return false;
			
			pointer 	= 0;
			_overwrite 	= overwrite
			var f : FileItem
			
			for ( var c : int = 0 ; c < files.length ; c ++ ){
				
				f 			= 	files[c];
				f.target 	= 	destinationPath
				
				if ( c == 0 )
					copyFile( f , overwrite )
					
								
			}
			
			_busy = true;
			return true;
		}
		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		public function addFileArray( a: Array ) : Boolean {
			
			if ( busy ) return false;
			
			var fi : FileItem
			
			for ( var c : int = 0 ; c < a.length ; c ++ ){
				
				fi = new FileItem( a[c] as File );
				
				files.push( fi );
				
			}
			
			return true;
		}
		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		public function addFile( s : File ) : Boolean {
			
			if ( busy ) return false;
			
			var fi : FileItem 	= new FileItem( s );
				fi.queueID 		= _ID;
				
			files.push( fi );
			
			return true;
			
		}
		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		public function addFileItem( fi : FileItem ) : Boolean {
			
			if ( busy ) return false;
			
			fi.queueID = _ID;
			files.push( fi );
			
			return true;
			
		}
		
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-PRIVATE----------------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------

		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		private function copyFile( f : FileItem , overwrite : Boolean = false ) : void {
			
			f.addEventListener( FileUtilsEvent.FILE_ITEM_OPERATION_COMPLETE, operationComplete , false , 0 , true );
			f.copy( overwrite );
			
		}
		
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-PUBLIC-----------------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------

		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-GET/SET----------------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------

		public function get name() : String { return _name;}
		public function set name(name : String) : void { _name = name;}
		
		public function get busy() : Boolean { return _busy; }
		public function set busy(busy : Boolean) : void { _busy = busy; }
		
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-EVENT HANDLERS-------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------

		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		private function operationComplete( e : FileUtilsEvent ) : void {
			
			var fue : FileUtilsEvent
				fue						= new FileUtilsEvent( FileUtilsEvent.QUEUE_PROGRESS , true);
				fue.queueID 			= _ID;
				fue.file				= e.file;
				fue.total				= files.length - 1
				fue.progress			= pointer + 1;
			dispatchEvent( fue  );
						
			if ( pointer < files.length - 1){

				pointer ++;
				copyFile( files[ pointer ] , _overwrite )
				
			} else {
				
				_busy 									= false;
				
				var fueCompleteEvent : FileUtilsEvent 	= new FileUtilsEvent( FileUtilsEvent.QUEUE_COMPLETE , true );
					fueCompleteEvent.queueID 			= _ID;
				dispatchEvent( fueCompleteEvent );
				
			}
		}
		

	}
}