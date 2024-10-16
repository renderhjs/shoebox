/********************************************************************************************************************************************************************************
* 
* Class Name  	: FileImporter
* Version 	  	: 1
* Description 	: Air File / Folder selection / import
* 
********************************************************************************************************************************************************************************
* 
* Author 		: Karim Beyrouti
* Date 			: 17/08/09
* 
********************************************************************************************************************************************************************************
* 
* METHODS
*
********************************************************************************************
* 
*	copyFileArrayToFolder( fileArray : Array , targetFolder : File , overwrite : Boolean = false , id : Object = '' ) : Boolean
*
*	    FileUtilsEvent.COPY_COMPLETE
*	        event.total
*	        event.progress
*	        event.id
*	        
*	    FileUtilsEvent.COPY_PROGRESS
*	        event.total
*	        event.progress        
*	        event.id
*	            
********************************************************************************************
*	            
*	moveFileArrayToFolder( fileArray : Array , targetFolder : File , overwrite : Boolean = false , id : Object = '' ) : Boolean {
*	
*	    FileUtilsEvent.MOVE_COMPLETE
*	        event.total
*	        event.progress
*	        event.id
*	        
*	    FileUtilsEvent.MOVE_PROGRESS
*	        event.total
*	        event.progress        
*	        event.id
*	       
********************************************************************************************
*	        
*	selectFolder( ) : void 
*	
*	    FileUtilsEvent.SELECTED
*	        event.file
*	    FileUtilsEvent.CANCEL
*	        event.command
*	        
********************************************************************************************
*	        
*	importFilesInAllSubFolders( _extensions : Array = null ) : void 
*	
*	    FileUtilsEvent.SELECTED
*	        event.files ( file array )
*	    FileUtilsEvent.CANCEL
*	        event.command
*	        
********************************************************************************************
*	        
*	importFilesInFolder( _extensions : Array = null ) : void 
*	
*	    FileUtilsEvent.SELECTED
*	        event.files ( file array )
*	    FileUtilsEvent.CANCEL
*	        event.command
*	        
********************************************************************************************
*	        
*	filesInFolder( dir : File ) : Array 
*	
********************************************************************************************
*	
*	filesInFolders( dir : File , recurse : Boolean = false ) : Array
*	
********************************************************************************************
* 
* PROPERTIES
* 
* 		maxFiles : int ( get / set )
* 
********************************************************************************************************************************************************************************
**********************************************************************************************************************************************************************************/

package shoebox.plugin.shareFolder.fileUtils {

	//import com.kurst.air.file.CFile;
	//import com.kurst.air.file.FileQueue;
	//import com.kurst.events.CEventDispatcher;
	//import com.kurst.events.FileUtilsEvent;
	import flash.events.FileListEvent;

	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	public class FileUtils extends CEventDispatcher {

		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		private const COMMAND_selectFile						: String = 'selectFile';
		private const COMMAND_selectFileMultiple				: String = 'selectFileMultiple';
		private const COMMAND_saveFile							: String = 'saveFile';
		private const COMMAND_selectFolder						: String = 'selectFolder';
		private const COMMAND_importFilesInAllSubFolders		: String = 'importFilesInAllSubFolders';
		private const COMMAND_importFilesInFolder				: String = 'importFilesInFolder';
		private const COMMAND_void								: String = '';
		
		private var MAX_FILES 			: int 		= 10000;
		private var directory			: File;
		private var fileList 			: Array ;
		private var extensions 			: Array;
		private var queueCollection		: Object;
		private var _browseOperation	: String = '';
		private var _processFiles		: Array;
		

		//------------------------------------------------------------------------------------------------------------------------------------------------------------		
			
		function FileUtils() {
			
			super();
			queueCollection = new Object();
			directory = new File();
			directory.addEventListener( Event.CANCEL , BrowseActionCancled , false , 0 , true ); 
			
		}

		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-PUBLIC-----------------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------

		public function createFolder( target : File ) : void {
			
			if ( ! target.isDirectory )
				target.parent.createDirectory();
			else 
				target.createDirectory();
			
			
			
		}
		/**
		* @method copyFileArrayToFolder( fileArray : Array , targetFolder : File , overwrite : Boolean = false ) : Boolean
		* @tooltip start copying files to a target folder
		* @param fileArray 		: Array 	- array containing files ( flash.filesystem.File )
		* @param targetFolder 	: File 		- folder to copy files to 
		* @param overwrite 		: Boolean	- Overwrite any existing file with the same name 
		* @param id				: Object	- ID of operation
		* @return True if operation is successfully started / False otherwise
		*/
		public function copyFileArrayToFolder( fileArray : Array , targetFolder : File , overwrite : Boolean = false , id : Object = '' , newNameArray : Array = null ) : Boolean {
			
			_processFiles			= new Array;
			
			var filetmp		: File
			var file 		: CFile;
			var dest 		: CFile;
			
			if ( targetFolder.isDirectory ) {
				
				for ( var c : int = 0 ; c < fileArray.length ; c++ ){
					
					filetmp 		= fileArray[ c ] as File;
					file 			= new CFile( filetmp.nativePath );
					
					
					dest			= ( newNameArray == null ) ? new CFile( targetFolder.nativePath + '/' + file.name ) : new CFile( targetFolder.nativePath + '/' + newNameArray[c] );
				
					file.newFile	= dest;
					file.total 		= fileArray.length;
					file.progress	= c + 1;
					file.id			= id;
					
					if ( c == fileArray.length -1 ) {
						
						file.addEventListener( Event.COMPLETE , fileCopiedHandler , false , 0 , true );
						
					} else {
						
						file.addEventListener( Event.COMPLETE , fileCopiedProgressHandler , false , 0 , true );
						
					}
					
					_processFiles.push( dest );
		
					try {
						file.copyToAsync( dest , overwrite );
					} catch ( error : Error ) {
						 trace("Error:" + error.message);
					}
					
					
				}
				
			} else { return false; }
			
			return true;
		}
		/**
		* @method moveFileArrayToFolder( fileArray : Array , targetFolder : File , overwrite : Boolean = false , id : Object = '' ) : Boolean
		* @tooltip start moving files to a target folder
		* @param fileArray 		: Array 	- array containing files ( flash.filesystem.File )
		* @param targetFolder 	: File 		- folder to copy files to 
		* @param overwrite 		: Boolean	- Overwrite any existing file with the same name 
		* @param id				: Object	- ID of operation
		* @return True if operation is successfully started / False otherwise
		*/
		public function moveFileArrayToFolder( fileArray : Array , targetFolder : File , overwrite : Boolean = false , id : Object = '' ) : Boolean {
			
			var filetmp		: File
			var file 		: CFile;
			var dest 		: CFile;
			
			if ( targetFolder.isDirectory ) {
				
				for ( var c : int = 0 ; c < fileArray.length ; c++ ){
					
					filetmp 		= fileArray[ c ] as File;
					file 			= new CFile( filetmp.nativePath );
					dest 			= new CFile( targetFolder.nativePath + '/' + file.name );
				
					file.total 		= fileArray.length;
					file.progress	= c + 1;
					file.id			= id;
					
					if ( c == fileArray.length -1 ) {
						
						file.addEventListener( Event.COMPLETE , fileMovedHandler , false , 0 , true );
						
					} else {
						
						file.addEventListener( Event.COMPLETE , fileMovedProgressHandler , false , 0 , true );
						
					}
					

					try {
						file.moveToAsync( dest , overwrite );
					} catch ( error : Error ) {
						trace("Error:" + error.message);
					}

				}
				
			} else { return false; }
			
			return true;
			
		}
		/**
		* @method selectFolder
		* @tooltip select a folder
		*/
		public function selectFolder( ) : void {

			_browseOperation = COMMAND_selectFolder;
			
			var d : File = new File();
			
				d.browseForDirectory( '' );
				d.addEventListener( Event.SELECT , directorySelected, false , 0 , true );
				d.addEventListener(Event.CANCEL, canceledBrowse, false , 0 , true );
			
		}
		/**
		* @method selectFile
		* @tooltip select a file
		* @param title 				: String		- title of dialogue window 
		* @param typeDescription 	: String 		- Description of acceptable file types.
		* @param typeFilter 		: Array			- Array of valid file extensions.
		*/
		public function selectFile( title : String , typeDescription : String , typeFilter : Array , multiple : Boolean = false ) : void {

			var fileTypeString : String = ''
			
			for ( var i : String in typeFilter )
				fileTypeString += typeFilter[i] + ';';

			var ff : FileFilter = new FileFilter( typeDescription , fileTypeString);
			var d : File = new File();
			
			if ( multiple ){
							
				_browseOperation = COMMAND_selectFileMultiple;
				
				d.browseForOpenMultiple( title, [ff] );
				d.addEventListener( FileListEvent.SELECT_MULTIPLE , fileSelectedMultiple, false , 0 , true );
				
			} else {
		
				_browseOperation = COMMAND_selectFile;
						
				d.browseForOpen( title, [ff] );
				d.addEventListener( Event.SELECT , fileSelected, false , 0 , true );
				
			}
			
			d.addEventListener(Event.CANCEL, canceledBrowse, false , 0 , true );
		}
		/**
		* @method saveFile
		* @tooltip dialogue selection to save a file. 
		* @param title 				: String		- title of dialogue window 
		*/
		public function saveFile( title : String ) : void {
			
			_browseOperation = COMMAND_saveFile;
			
			var d : File = new File();
				d.browseForSave( title );
				d.addEventListener( Event.SELECT , fileSelectedForSave, false , 0 , true );
				d.addEventListener(Event.CANCEL, canceledBrowse, false , 0 , true );
				
			
		}
		/**
		* @method importFilesInAllSubFolders( _extensions : Array = null ) : void
		* @tooltip import all files in all sub folders
		* @param  _extensions 	: 		Array 		- Extensions of files to import
		*/
		public function importFilesInAllSubFolders( _extensions : Array = null ) : void {
			
			_browseOperation = COMMAND_importFilesInAllSubFolders;
			
			extensions 	= _extensions;
				
			var d : File = new File();
			
				d.browseForDirectory( '' );
				d.addEventListener( Event.SELECT , importFilesInAllSubFoldersSelected , false , 0 , true );
				
		}
		/**
		* @method importFilesInFolder( _extensions : Array = null ) : void
		* @tooltip import all files in a folder
		* @param  _extensions 	: 		Array 		- Extensions of files to import
		*/
		public function importFilesInFolder( _extensions : Array = null ) : void {
			
			_browseOperation = COMMAND_importFilesInFolder;
			
			fileList 	= new Array ();
			extensions 	= _extensions;
			
			var d : File = new File();
			
				d.browseForDirectory( '' );
				d.addEventListener(Event.SELECT , importFilesInFolderSelected , false , 0 , true );
				
		}

		//------------------------------------------------------------------------------------------------------------------------------------------------------------

		/**
		* @method filesInFolder( dir : File ) : Array 
		* @tooltip
		* @param
		* @return
		*/
		public function filesInFolder( dir : File ) : Array {
			
		    if ( !dir.isDirectory 
		    		|| dir.isHidden 
		    		|| !dir.exists 
		    		|| dir.name.search(/^\..*$/) != -1) return [];
		    
		    try{
		    	
			    var listing : Array 			= dir.getDirectoryListing();
			    var extensionFound : Boolean 	= false;
	
			    for each(var f:File in listing) {
			    	
			    	extensionFound = ( extensions == null ) ? true : false;
			    	
			    	for ( var i : String in extensions ) 
			    		if ( f.extension == extensions[i] ) extensionFound = true;
			    		
			        if ( fileList.length >= MAX_FILES ) break;
			        if ( f.isHidden || !f.exists || f.name.search(/^\..*$/) != -1 ) continue;
			        if ( ! f.isDirectory && extensionFound ) fileList.push( f.clone() );
			        
		    	}
		    
		    } catch ( e : Error ) { trace( e.message ); }
		    
		    return fileList;
		    
		}
		/**
		* @method filesInFolders( dir : File , recurse : Boolean = false ) : Array
		* @tooltip
		* @param
		* @return
		*/
		public function filesInFolders( dir : File , recurse : Boolean = false ) : Array {
			
		    if ( ! recurse ) fileList = new Array();
			
		    if ( !dir.isDirectory 
		    		|| dir.isHidden 
		    		|| !dir.exists 
		    		|| dir.name.search(/^\..*$/) != -1) return [];
		    
		    try{
		    	
			    var listing : Array 			= dir.getDirectoryListing();
			    var extensionFound : Boolean 	= false;
			    
			    for each(var f:File in listing) {
			    	
			    	extensionFound = ( extensions == null ) ? true : false;
			    	
			    	for ( var i : String in extensions ) 
			    		if ( f.extension == extensions[i] ) extensionFound = true;
			    		
			        if ( fileList.length >= MAX_FILES ) break;
			        if ( f.isHidden || !f.exists || f.name.search(/^\..*$/) != -1 ) continue;
			        
			        if ( f.isDirectory ) {
			            filesInFolders( f , true );
			        } else if ( extensionFound ) { fileList.push( f ); }
			        
			        
			    }
			    
			} catch ( e : Error ) { trace( e.message ); } 
			
		    if ( ! recurse ) return fileList;
		    
		    return [];
		}
		
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-PRIVATE----------------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-GET/SET----------------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
	
		/**
		* @method maxFiles
		* @tooltip
		* @param
		* @return
		*/
		public function get maxFiles() : int { return MAX_FILES; }
		public function set maxFiles( mAX_FILES : int) : void { MAX_FILES = mAX_FILES; }
		
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-EVENT HANDLERS-------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------

		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		private function queueProgress( e : FileUtilsEvent ) : void {
			
			var fue : FileUtilsEvent
				fue						= new FileUtilsEvent( FileUtilsEvent.QUEUE_PROGRESS , true );
				fue.queueID 			= e.ID
				fue.file				= e.file;
				fue.total				= e.total;
				fue.progress			= e.progress;
			dispatchEvent( fue  );

				
		}
		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		private function queueComplete( e : FileUtilsEvent ) : void {

			var fue : FileUtilsEvent
				fue 					= new FileUtilsEvent( FileUtilsEvent.QUEUE_COMPLETE , true );
				fue.queueID 			=  e.ID
				
			dispatchEvent( fue );

			
		}
		/**
		* @method fileCopiedHandler
		* @tooltip
		* @param
		* @return
		*/
		private function fileCopiedHandler( e : Event ) : void {
			
			var f : CFile = e.currentTarget as CFile
				f.removeEventListener(Event.COMPLETE , fileCopiedHandler );
								
			var fue : FileUtilsEvent = new FileUtilsEvent( FileUtilsEvent.COPY_COMPLETE , true )
				fue.total 		= f.total;
				fue.progress 	= f.progress
				fue.newFile		= f.newFile;
				fue.newFiles	= _processFiles;
				
			dispatchEvent( fue );
			
			_processFiles = null;
			
			
			
		}
		/**
		* @method fileCopiedHandler
		* @tooltip
		* @param
		* @return
		*/
		private function fileCopiedProgressHandler( e : Event ) : void {
						
			var f : CFile = e.currentTarget as CFile
				f.removeEventListener(Event.COMPLETE , fileCopiedHandler );
		
			var fue : FileUtilsEvent = new FileUtilsEvent( FileUtilsEvent.COPY_PROGRESS , true )
				fue.total 		= f.total;
				fue.progress 	= f.progress;
				fue.newFile		= f.newFile;
			
			dispatchEvent( fue );
			
			
		}
		/**
		* @method fileCopiedHandler
		* @tooltip
		* @param
		* @return
		*/
		private function fileMovedHandler( e : Event ) : void {
			
			var f : CFile = e.currentTarget as CFile
				f.removeEventListener(Event.COMPLETE , fileMovedHandler );
								
			var fue : FileUtilsEvent = new FileUtilsEvent( FileUtilsEvent.MOVE_COMPLETE , true )
				fue.total 		= f.total;
				fue.progress 	= f.progress
				
			dispatchEvent( fue );
			
			
		}
		/**
		* @method fileCopiedHandler
		* @tooltip
		* @param
		* @return
		*/
		private function fileMovedProgressHandler( e : Event ) : void {
			
			var f : CFile = e.currentTarget as CFile
				f.removeEventListener(Event.COMPLETE , fileMovedProgressHandler );
		
			var fue : FileUtilsEvent = new FileUtilsEvent( FileUtilsEvent.MOVE_PROGRESS , true )
				fue.total 		= f.total;
				fue.progress 	= f.progress
			
			dispatchEvent( fue );
			
		}
		/**
		* @method BrowseActionCancled
		* @tooltip
		* @param
		* @return
		*/
		private function BrowseActionCancled( e : Event ) : void {

			directory.removeEventListener(Event.SELECT, directorySelected );
			directory.removeEventListener(Event.SELECT, importFilesInFolderSelected );
			directory.removeEventListener(Event.SELECT, importFilesInAllSubFoldersSelected );

			var d : File = e.currentTarget as File
				d.removeEventListener(Event.SELECT, directorySelected );
				d.removeEventListener(Event.SELECT, importFilesInFolderSelected );
				d.removeEventListener(Event.SELECT, importFilesInAllSubFoldersSelected );

			dispatchEvent( new FileUtilsEvent( FileUtilsEvent.CANCLED ) );
			
		}
		/**
		* @method directorySelected
		* @tooltip
		* @param
		* @return
		*/
		private function directorySelected( e : Event ) : void {
			
			_browseOperation = '';
			
			var d : File = e.currentTarget as File;
				d.removeEventListener( Event.SELECT, directorySelected );
				d.removeEventListener(Event.CANCEL, canceledBrowse );
				
			var fie : FileUtilsEvent 	= new FileUtilsEvent( FileUtilsEvent.SELECTED )
				fie.file 				= new File( ( e.target as File ).nativePath );
			dispatchEvent( fie );
				
		}
		/**
		* @method importFilesInAllSubFoldersSelected
		* @tooltip
		* @param
		* @return
		*/
		private function fileSelectedMultiple( event : FileListEvent ) : void {
		
			_browseOperation = '';

			var fileArray : Array = new Array();
				
		    for (var i:uint = 0; i < event.files.length; i++)
		    	fileArray.push( new File( event.files[i].nativePath ) );


			var d : File 				= event.currentTarget as File;
				d.removeEventListener( FileListEvent.SELECT_MULTIPLE, fileSelectedMultiple );
				d.removeEventListener( Event.CANCEL, canceledBrowse );
				
			var fie : FileUtilsEvent 	= new FileUtilsEvent( FileUtilsEvent.FILE_SELECTED_MULTIPLE );
				fie.files = fileArray;
			dispatchEvent( fie );

			
		}
		/**
		* @method importFilesInAllSubFoldersSelected
		* @tooltip
		* @param
		* @return
		*/
		private function fileSelected( e : Event ) : void {
			
			_browseOperation = '';
			
			var d : File = e.currentTarget as File;
				d.removeEventListener( Event.SELECT, fileSelected );
				d.removeEventListener( Event.CANCEL, canceledBrowse );
				
			var fie : FileUtilsEvent 	= new FileUtilsEvent( FileUtilsEvent.FILE_SELECTED);
				fie.file 				= new File( ( e.target as File ).nativePath );
			dispatchEvent( fie );
			
		}
		/**
		* @method importFilesInAllSubFoldersSelected
		* @tooltip
		* @param
		* @return
		*/
		private function fileSelectedForSave( e : Event ) : void {
			
			_browseOperation = '';
			
			var d : File = e.currentTarget as File;
				d.removeEventListener( Event.SELECT, fileSelectedForSave );
				d.removeEventListener( Event.CANCEL, canceledBrowse );
				
			var fie : FileUtilsEvent 	= new FileUtilsEvent( FileUtilsEvent.FILE_SAVE);
				fie.file 				= new File( ( e.target as File ).nativePath );
			dispatchEvent( fie );
			
		}
		/**
		* @method importFilesInAllSubFoldersSelected
		* @tooltip
		* @param
		* @return
		*/
		private function importFilesInAllSubFoldersSelected( e : Event ) : void {
			
			_browseOperation = '';
			
			var d : File = e.currentTarget as File;
				d.removeEventListener( Event.SELECT, importFilesInAllSubFoldersSelected );
				d.removeEventListener(Event.CANCEL, canceledBrowse );
				
			var fie : FileUtilsEvent 	= new FileUtilsEvent( FileUtilsEvent.SELECTED )
			try {
				var a : Array				= filesInFolders( e.target as File );
					fie.files 				= a
			} catch ( e : Error ) {
				
				fie.files 					= []
			}
			
			dispatchEvent( fie );
				
		}
		/**
		* @method importFilesInFolderSelected
		* @tooltip
		* @param
		* @return
		*/
		private function importFilesInFolderSelected( e : Event ) : void {

			_browseOperation = COMMAND_void;
			
			var d : File = e.currentTarget as File;
				d.removeEventListener( Event.SELECT, importFilesInFolderSelected );
				d.removeEventListener(Event.CANCEL, canceledBrowse );
				
			var targetFolder : File 	= e.target as File;
			
			var fie : FileUtilsEvent 	= new FileUtilsEvent(FileUtilsEvent.SELECTED)
				fie.files 				= filesInFolder( targetFolder );
			dispatchEvent( fie );
			
		}
		/**
		* @method canceledBrowse
		* @tooltip
		* @param
		* @return
		*/
		private function canceledBrowse( e : Event ) : void {
			
			var f : File = e.currentTarget as File  
				f.removeEventListener(Event.CANCEL, canceledBrowse ); 
				
			switch ( _browseOperation ){
				
				case COMMAND_selectFileMultiple : 
					f.removeEventListener( FileListEvent.SELECT_MULTIPLE , fileSelectedMultiple );		
					break;
					
				case COMMAND_selectFolder :
					f.removeEventListener( Event.SELECT , directorySelected );
					break;
					
				case COMMAND_importFilesInAllSubFolders :
					f.removeEventListener( Event.SELECT , importFilesInAllSubFoldersSelected  );
					break;
					
				case COMMAND_importFilesInFolder :
					f.removeEventListener(Event.SELECT , importFilesInFolderSelected  );
					break;

				case COMMAND_saveFile :		
					f.removeEventListener( Event.SELECT , fileSelectedForSave );
					break;			
				case COMMAND_selectFile :
					f.removeEventListener( Event.SELECT , fileSelected );
					break;
				
			}
			
			var fie : FileUtilsEvent 	= new FileUtilsEvent( FileUtilsEvent.CANCLED )
				fie.command				= _browseOperation;
			dispatchEvent( fie );
			
			_browseOperation = COMMAND_void;
				
			
		}
		
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-PUBLIC - QUEUE FUNCTIONS ----------------------------------------------------------------------------------------------------------------------------------
		//
		// These functions are buggy - Error Message :
		//
		//	Error #2044: Unhandled IOErrorEvent:. text=Error #3012: Cannot delete file or directory.
		//	at flash.filesystem::File/getDirectoryListing()
		//	at com.kurst.air::FileUtils/filesInFolders()[/Volumes/2020/Work/FlashDev/kurstClasses_AS3/flex/kurst/src/com/kurst/air/FileUtils.as:265]
		//	at com.kurst.air::FileUtils/importFilesInAllSubFoldersSelected()[/Volumes/2020/Work/FlashDev/kurstClasses_AS3/flex/kurst/src/com/kurst/air/FileUtils.as:460]
		//
		// This happens on second copy after changing the targetFolder. This seems to be a AIR Bug, which a few people
		// have come accross... Use copyFileArrayToFolder instead of queue operations
		//------------------------------------------------------------------------------------------------------------------------------------------------------------

		/**
		* @method
		* @tooltip
		* @param
		* @return
		*/
		public function fileArrayToQueue( fileArray : Array , queueName:String = 'default'  ) : Boolean {
			
			trace('FileUtils.fileArrayToQueue: Failed Testing');
			return getQueueByName( queueName ).addFileArray( fileArray );
		}
		/**
		* @method
		* @tooltip
		* @param
		* @return
		*/
		public function copyQueueToFolder(  destinationPath : File , overwrite:Boolean = false ,queueName:String = 'default'  ) : Boolean {
			
			trace('FileUtils.copyQueueToFolder: Failed Testing');
			
			var queue	: FileQueue = getQueueByName( queueName );
			var success : Boolean 	= queue.copy( destinationPath , overwrite);
			
			if ( success ){

				queue.removeEventListener( FileUtilsEvent.QUEUE_COMPLETE , queueComplete );
				queue.removeEventListener( FileUtilsEvent.QUEUE_PROGRESS , queueProgress );
				
				queue.addEventListener( FileUtilsEvent.QUEUE_COMPLETE , queueComplete , false , 0 , true )
				queue.addEventListener( FileUtilsEvent.QUEUE_PROGRESS , queueProgress , false , 0 , true );
				
			}
			
			return success;
		}
		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		public function getQueueByName ( name : String = 'default') : FileQueue {
			
			if ( queueCollection[ name ] == null ) {
			
				queueCollection[ name ] = new FileQueue( name ); 
				
			} 
			
			return queueCollection[ name ];
			
		}
		

	}
}