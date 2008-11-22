package away3d.loaders;

	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.events.*;
	
	import flash.events.EventDispatcher;
	
	use namespace arcane;
	
	class AbstractParser extends EventDispatcher {
		public var parsedChunks(getParsedChunks, null) : Int
		;
		public var totalChunks(getTotalChunks, null) : Int
		;
		/** @private */
    	public function new() {
    	_totalChunks = 0;
    	_parsedChunks = 0;
    	}
    	
		/** @private */
    	arcane var _totalChunks:Int ;
        /** @private */
    	arcane var _parsedChunks:Int ;
		/** @private */
    	arcane var _parsesuccess:ParserEvent;
		/** @private */
    	arcane var _parseerror:ParserEvent;
		/** @private */
    	arcane var _parseprogress:ParserEvent;
		/** @private */
    	arcane function notifyProgress():Void
		{
			if (!_parseprogress)
        		_parseprogress = new ParserEvent(ParserEvent.PARSE_PROGRESS, this, container);
        	
        	dispatchEvent(_parseprogress);
		}
		/** @private */
    	arcane function notifySuccess():Void
		{
			if (!_parsesuccess)
        		_parsesuccess = new ParserEvent(ParserEvent.PARSE_SUCCESS, this, container);
        	
        	dispatchEvent(_parsesuccess);
		}
		/** @private */
    	arcane function notifyError():Void
		{
			if (!_parseerror)
        		_parseerror = new ParserEvent(ParserEvent.PARSE_ERROR, this, container);
        	
        	dispatchEvent(_parseerror);
		}
		
        /**
        * 3d container object used for storing the parsed 3ds object.
        */
		public var container:Object3D;
		
    	/**
    	 * Returns the total number of data chunks parsed
    	 */
		public function getParsedChunks():Int
		{
			return _parsedChunks;
		}
    	
    	/**
    	 * Returns the total number of data chunks available
    	 */
		public function getTotalChunks():Int
		{
			return _totalChunks;
		}
        
		/**
		 * Processes the next chunk in the parser
		 */
		public function parseNext():Void
        {
        	notifySuccess();
        }
	}
