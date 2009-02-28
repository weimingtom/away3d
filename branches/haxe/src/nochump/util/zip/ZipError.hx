package nochump.util.zip;

import flash.errors.IOError;


/**
 * Thrown during the creation or input of a zip file.
 */
class ZipError extends IOError  {
	
	

	public function new(?message:String="", ?id:Int=0) {
		
		
		super(message, id);
	}

}

