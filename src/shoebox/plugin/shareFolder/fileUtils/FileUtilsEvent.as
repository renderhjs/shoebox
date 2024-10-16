/********************************************************************************************************************************************************************************
* 
* Class Name  	: com.kurst.events.FileImporterEvent
* Version 	  	: 1
* Description 	: FileImporterEvent
* 
********************************************************************************************************************************************************************************
* 
* Author 		: Karim Beyrouti
* Date 			: 
* 
********************************************************************************************************************************************************************************
* 
* EVENTS
*
* 		FileImporterEvent.SELECTED
*			files / file 			
* 
*		FileImporterEvent.CANCLED
* 	
* 
********************************************************************************************************************************************************************************
**********************************************************************************************************************************************************************************/

package shoebox.plugin.shareFolder.fileUtils {
	
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class FileUtilsEvent extends Event {
		
		public static const SELECTED 						: String = 'FileImporterEvent_SELECTED';
		public static const FILE_SELECTED					: String = 'FileImporterEvent_FILE_SELECTED';
		public static const FILE_SELECTED_MULTIPLE			: String = 'FileImporterEvent_FILE_SELECTED_MULTIPLE';
		public static const FILE_SAVE						: String = 'FileImporterEvent_FILE_SAVE';
		public static const CANCLED 						: String = 'FileImporterEvent_CANCLED';

		public static const COPY_PROGRESS 					: String = 'FileImporterEvent_COPY_PROGRESS';
		public static const COPY_COMPLETE 					: String = 'FileImporterEvent_COPY_COMPLETE';

		public static const MOVE_PROGRESS 					: String = 'FileImporterEvent_MOVE_PROGRESS';
		public static const MOVE_COMPLETE 					: String = 'FileImporterEvent_MOVE_COMPLETE';


		public static const QUEUE_COMPLETE 					: String = 'FileImporterEvent_QUEUE_COMPLETE';
		public static const QUEUE_PROGRESS 					: String = 'FileImporterEvent_QUEUE_PROGRESS';

		public static const FILE_ITEM_COPY_COMPLETE 		: String = 'FileImporterEvent_FILE_ITEM_COPY_COMPLETE';
		public static const FILE_ITEM_OPERATION_COMPLETE 	: String = 'FileImporterEvent_FILE_ITEM_OPERATION_COMPLETE';
		
		private var _files			: Array;
		private var _file 			: File;
		private var _targetFile		: File;
		private var _targetFiles	: Array;
		private var _id				: Number;
		private var _queueId		: Number;
		private var _progress		: int;
		private var _total			: int;
		private var _command		: String;
		
		
		public function FileUtilsEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			
			super(type, bubbles, cancelable);
			
		}
		
		public function get files() : Array { return _files; }
		public function set files(files : Array) : void { _files = files; }
		
		public function get file() : File { return _file; }
		public function set file(f : File) : void { _file = f;}
		
		
		public function get newFile() : File { return _targetFile; }
		public function set newFile(f : File) : void { _targetFile = f;}
		
		
		public function get newFiles() : Array { return _targetFiles; }
		public function set newFiles(f : Array) : void { _targetFiles = f;}
		
		
		public function get ID() : Number { return _id; }
		public function set ID( id : Number ) : void { _id = id; }
		
		public function get queueID() : Number { return _queueId; }
		public function set queueID(queueId : Number) : void { _queueId = queueId;
		}
		
		public function get progress() : int {
			return _progress;
		}
		
		public function set progress(progress : int) : void {
			_progress = progress;
		}
		
		public function get total() : int {
			return _total;
		}
		
		public function set total(total : int) : void {
			_total = total;
		}
		
		public function get command() : String {
			return _command;
		}
		
		public function set command(command : String) : void {
			_command = command;
		}
	}
}
