package shoebox.plugin.shareFolder.fileUtils 
{
	/**
	 * ...
	 * @author Karim Beyrouti
	 * http://code.google.com/p/kurstcode/source/browse/trunk/libs/com/kurst/air/file/CFile.as?r=2
	 */

	import flash.filesystem.File;
	import shoebox.plugin.PluginHelper;

	public class CFile extends File {

		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		private var _total 		: int ;
		private var _position 	: int ;
		private var _id		 	: Object ;
		private var _target		: File;
		
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		public function CFile(path : String = null) {
			path = PluginHelper.getSysPath(path);
			super(path);
			
		}

		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-GET/SET----------------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------

		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		public function get total() : int {
			return _total;
		}
		
		public function set total(total : int) : void {
			_total = total;
		}
		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		public function get progress() : int {
			return _position;
		}
		
		public function set progress(position : int) : void {
			_position = position;
		}
		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		public function get id() : Object {
			return _id;
		}
		
		public function set id( o : Object ) : void {
			_id = o;
		}
		/**
		* @method 
		* @tooltip
		* @param
		* @return
		*/
		public function get newFile() : File {
			return _target;
		}
		
		public function set newFile( o : File ) : void {
			_target = o;
		}
		
		
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-PUBLIC-----------------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
			
		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-PRIVATE----------------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------

		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-PUBLIC-----------------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------


		//------------------------------------------------------------------------------------------------------------------------------------------------------------
		//-EVENT HANDLERS-------------------------------------------------------------------------------------------------------------------------------------------
		//------------------------------------------------------------------------------------------------------------------------------------------------------------

	}
	
		
}