package away3d.core.clip
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.draw.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	/**
	 * Dispatched when the clipping properties of a clipping object update.
	 * 
	 * @eventType away3d.events.ClipEvent
	 * 
	 * @see #maxX
	 * @see #minX
	 * @see #maxY
	 * @see #minY
	 * @see #maxZ
	 * @see #minZ
	 */
	[Event(name="clipUpdated",type="away3d.events.ClipEvent")]
	
	use namespace arcane;
    /**
    * Base clipping class for no clipping.
    */
    public class Clipping extends EventDispatcher
    {
    	/** @private */
        arcane function internalRemoveView(view:View3D):void
        {
        	view.removeEventListener(ViewEvent.UPDATE_CLIPPING, onUpdate);
        }
		/** @private */
        arcane function internalAddView(view:View3D):void
        {
        	view.addEventListener(ViewEvent.UPDATE_CLIPPING, onUpdate);
        }
    	private var _clippingClone:Clipping;
    	private var _loaderInfo:LoaderInfo;
    	private var _stage:Stage;
    	private var _stageWidth:Number;
    	private var _stageHeight:Number;
    	private var _zeroPoint:Point = new Point(0, 0);
		private var _globalPoint:Point;
		private var _minX:Number;
		private var _minY:Number;
		private var _minZ:Number;
		private var _maxX:Number;
		private var _maxY:Number;
		private var _maxZ:Number;
		private var _miX:Number;
		private var _miY:Number;
		private var _maX:Number;
		private var _maY:Number;
		
		private var _clippingupdated:ClippingEvent;
		
		private function onUpdate(event:ViewEvent):void
		{
			//determine screen clipping
			if (event.view.stage)
				event.view._screenClip = screen(event.view);
		}
		
		private function onScreenUpdate(event:ClippingEvent):void
		{
			dispatchEvent(event);
		}
		
        private function notifyClippingUpdate():void
        {
            if (!hasEventListener(ClippingEvent.CLIPPING_UPDATED))
                return;
			
            if (_clippingupdated == null)
                _clippingupdated = new ClippingEvent(ClippingEvent.CLIPPING_UPDATED, this);
                
            dispatchEvent(_clippingupdated);
        }
        
        protected var _ini:Init;
		
    	/**
    	 * Minimum allowed x value for primitives
    	 */
    	public function get minX():Number
		{
			return _minX;
		}
		
		public function set minX(value:Number):void
		{
			if (_minX == value)
				return;
			
			_minX = value;
			
			notifyClippingUpdate();
		}
    	
    	/**
    	 * Minimum allowed y value for primitives
    	 */
        public function get minY():Number
		{
			return _minY;
		}
		
		public function set minY(value:Number):void
		{
			if (_minY == value)
				return;
			
			_minY = value;
			
			notifyClippingUpdate();
		}
    	
    	/**
    	 * Minimum allowed z value for primitives
    	 */
        public function get minZ():Number
		{
			return _minZ;
		}
		
		public function set minZ(value:Number):void
		{
			if (_minZ == value)
				return;
			
			_minZ = value;
			
			notifyClippingUpdate();
		}
        
    	/**
    	 * Maximum allowed x value for primitives
    	 */
        public function get maxX():Number
		{
			return _maxX;
		}
		
		public function set maxX(value:Number):void
		{
			if (_maxX == value)
				return;
			
			_maxX = value;
			
			notifyClippingUpdate();
		}
    	
    	/**
    	 * Maximum allowed y value for primitives
    	 */
        public function get maxY():Number
		{
			return _maxY;
		}
		
		public function set maxY(value:Number):void
		{
			if (_maxY == value)
				return;
			
			_maxY = value;
			
			notifyClippingUpdate();
		}
    	
    	/**
    	 * Maximum allowed z value for primitives
    	 */
        public function get maxZ():Number
		{
			return _maxZ;
		}
		
		public function set maxZ(value:Number):void
		{
			if (_maxZ == value)
				return;
			
			_maxZ = value;
			
			notifyClippingUpdate();
		}
        
		/**
		 * Creates a new <code>Clipping</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function Clipping(init:Object = null)
        {
        	_ini = Init.parse(init) as Init;
        	
        	minX = _ini.getNumber("minX", -Infinity);
        	minY = _ini.getNumber("minY", -Infinity);
        	minZ = _ini.getNumber("minZ", -Infinity);
        	maxX = _ini.getNumber("maxX", Infinity);
        	maxY = _ini.getNumber("maxY", Infinity);
        	maxZ = _ini.getNumber("maxZ", Infinity);
        }
        
		/**
		 * Checks a drawing primitive for clipping.
		 * 
		 * @param	pri	The drawing primitive being checked.
		 * @return		The clipping result - false for clipped, true for non-clipped.
		 */
        public function check(pri:DrawPrimitive):Boolean
        {
            return true;
        }
		
		/**
		 * Checks a bounding rectangle for clipping.
		 * 
		 * @param	minX	The x value for the left side of the rectangle.
		 * @param	minY	The y value for the top side of the rectangle.
		 * @param	maxX	The x value for the right side of the rectangle.
		 * @param	maxY	The y value for the bottom side of the rectangle.
		 * @return		The clipping result - false for clipped, true for non-clipped.
		 */
        public function rect(minX:Number, minY:Number, maxX:Number, maxY:Number):Boolean
        {
            return true;
        }

		/**
		 * Returns a clipping object initilised with the edges of the flash movie as the clipping bounds.
		 */
        public function screen(container:Sprite):Clipping
        {
        	if (!_clippingClone) {
        		_clippingClone = clone();
        		_clippingClone.addOnClippingUpdate(onScreenUpdate);
        	}
        	
        	_stage = container.stage;
        	_loaderInfo = container.loaderInfo;
        	
        	if (_stage.scaleMode == StageScaleMode.NO_SCALE) {
        		_stageWidth = _stage.stageWidth;
        		_stageHeight = _stage.stageHeight;
        	} else if (_stage.scaleMode == StageScaleMode.EXACT_FIT) {
        		_stageWidth = _loaderInfo.width;
        		_stageHeight = _loaderInfo.height;
        	} else if (_stage.scaleMode == StageScaleMode.SHOW_ALL) {
        		if (_stage.stageWidth/_loaderInfo.width < _stage.stageHeight/_loaderInfo.height) {
        			_stageWidth = _loaderInfo.width;
        			_stageHeight = _stage.stageHeight*_stageWidth/_stage.stageWidth;
        		} else {
        			_stageHeight = _loaderInfo.height;
        			_stageWidth = _stage.stageWidth*_stageHeight/_stage.stageHeight;
        		}
        	} else if (_stage.scaleMode == StageScaleMode.NO_BORDER) {
        		if (_stage.stageWidth/_loaderInfo.width > _stage.stageHeight/_loaderInfo.height) {
        			_stageWidth = _loaderInfo.width;
        			_stageHeight = _stage.stageHeight*_stageWidth/_stage.stageWidth;
        		} else {
        			_stageHeight = _loaderInfo.height;
        			_stageWidth = _stage.stageWidth*_stageHeight/_stage.stageHeight;
        		}
        	}
        		
        	
        	switch(_stage.align)
        	{
        		case StageAlign.TOP_LEFT:
	            	_zeroPoint.x = 0;
	            	_zeroPoint.y = 0;
	                _globalPoint = container.globalToLocal(_zeroPoint);
	                
	                _maX = (_miX = _globalPoint.x) + _stageWidth;
	                _maY = (_miY = _globalPoint.y) + _stageHeight;
	                break;
	            case StageAlign.TOP_RIGHT:
	            	_zeroPoint.x = _loaderInfo.width;
	            	_zeroPoint.y = 0;
	                _globalPoint = container.globalToLocal(_zeroPoint);
	                
	                _miX = (_maX = _globalPoint.x) - _stageWidth;
	                _maY = (_miY = _globalPoint.y) + _stageHeight;
	                break;
	            case StageAlign.BOTTOM_LEFT:
	            	_zeroPoint.x = 0;
	            	_zeroPoint.y = _loaderInfo.height;
	                _globalPoint = container.globalToLocal(_zeroPoint);
	                _maX = (_miX = _globalPoint.x) + _stageWidth;
	                _miY = (_maY = _globalPoint.y) - _stageHeight;
	                break;
	            case StageAlign.BOTTOM_RIGHT:
	            	_zeroPoint.x = _loaderInfo.width;
	            	_zeroPoint.y = _loaderInfo.height;
	                _globalPoint = container.globalToLocal(_zeroPoint);
	                
	                _miX = (_maX = _globalPoint.x) - _stageWidth;
	                _miY = (_maY = _globalPoint.y) - _stageHeight;
	                break;
	            case StageAlign.TOP:
	            	_zeroPoint.x = _loaderInfo.width/2;
	            	_zeroPoint.y = 0;
	                _globalPoint = container.globalToLocal(_zeroPoint);
	                
	                _miX = _globalPoint.x - _stageWidth/2;
	                _maX = _globalPoint.x + _stageWidth/2;
	                _maY = (_miY = _globalPoint.y) + _stageHeight;
	                break;
	            case StageAlign.BOTTOM:
	            	_zeroPoint.x = _loaderInfo.width/2;
	            	_zeroPoint.y = _loaderInfo.height;
	                _globalPoint = container.globalToLocal(_zeroPoint);
	                
	                _miX = _globalPoint.x - _stageWidth/2;
	                _maX = _globalPoint.x + _stageWidth/2;
	                _miY = (_maY = _globalPoint.y) - _stageHeight;
	                break;
	            case StageAlign.LEFT:
	            	_zeroPoint.x = 0;
	            	_zeroPoint.y = _loaderInfo.height/2;
	                _globalPoint = container.globalToLocal(_zeroPoint);
	                
	                _maX = (_miX = _globalPoint.x) + _stageWidth;
	                _miY = _globalPoint.y - _stageHeight/2;
	                _maY = _globalPoint.y + _stageHeight/2;
	                break;
	            case StageAlign.RIGHT:
	            	_zeroPoint.x = _loaderInfo.width;
	            	_zeroPoint.y = _loaderInfo.height/2;
	                _globalPoint = container.globalToLocal(_zeroPoint);
	                
	                _miX = (_maX = _globalPoint.x) - _stageWidth;
	                _miY = _globalPoint.y - _stageHeight/2;
	                _maY = _globalPoint.y + _stageHeight/2;
	                break;
	            default:
	            	_zeroPoint.x = _loaderInfo.width/2;
	            	_zeroPoint.y = _loaderInfo.height/2;
	                _globalPoint = container.globalToLocal(_zeroPoint);
	            	
	                _miX = _globalPoint.x - _stageWidth/2;
	                _maX = _globalPoint.x + _stageWidth/2;
	                _miY = _globalPoint.y - _stageHeight/2;
	                _maY = _globalPoint.y + _stageHeight/2;
        	}
        	
	
            if (minX == -Infinity)
            	_clippingClone.minX = _miX;
            else
            	_clippingClone.minX = _minX;
            
            if (maxX == Infinity)
            	_clippingClone.maxX = _maX;
            else
            	_clippingClone.maxX = _maxX;
            
            if (minY == -Infinity)
            	_clippingClone.minY = _miY;
            else
            	_clippingClone.minY = _minY;
            
            if (maxY == Infinity)
            	_clippingClone.maxY = _maY;
            else
            	_clippingClone.maxY = _maxY;
            	
            return _clippingClone;
        }
		
		public function clone(object:Clipping = null):Clipping
        {
        	var clipping:Clipping = object || new Clipping();
        	
        	clipping.minX = minX;
        	clipping.minY = minY;
        	clipping.minZ = minZ;
        	clipping.maxX = maxX;
        	clipping.maxY = maxY;
        	clipping.maxZ = maxZ;
        	
        	return clipping;
        }
        
        /**
		 * Used to trace the values of a rectangle clipping object.
		 * 
		 * @return A string representation of the rectangle clipping object.
		 */
        public override function toString():String
        {
        	return "{minX:" + minX + " maxX:" + maxX + " minY:" + minY + " maxY:" + maxY + " minZ:" + minZ + " maxZ:" + maxZ + "}";
        }
        
		/**
		 * Default method for adding a clippingUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnClippingUpdate(listener:Function):void
        {
            addEventListener(ClippingEvent.CLIPPING_UPDATED, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a clippingUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnClippingUpdate(listener:Function):void
        {
            removeEventListener(ClippingEvent.CLIPPING_UPDATED, listener, false);
        }
        
    }
}