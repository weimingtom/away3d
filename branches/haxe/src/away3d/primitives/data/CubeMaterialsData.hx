package away3d.primitives.data;

	import away3d.core.utils.Init;
	import away3d.events.*;
	import away3d.materials.*;
	
	import flash.events.EventDispatcher;
    
	 /**
	 * Dispatched when the cube materials object has one of it's materials updated.
	 * 
	 * @eventType away3d.events.MaterialEvent
	 */
	/*[Event(name="materialchanged",type="away3d.events.MaterialEvent")]*/
	
	/**
	 * Data structure for individual materials on the sides of a cube.
	 * 
	 * @see away3d.primitives.Cube
	 * @see away3d.primitives.Skybox
	 */
	class CubeMaterialsData extends EventDispatcher {
		public var back(getBack, setBack) : ITriangleMaterial;
		public var bottom(getBottom, setBottom) : ITriangleMaterial;
		public var front(getFront, setFront) : ITriangleMaterial;
		public var left(getLeft, setLeft) : ITriangleMaterial;
		public var right(getRight, setRight) : ITriangleMaterial;
		public var top(getTop, setTop) : ITriangleMaterial;
		
		var _materialchanged:MaterialEvent;
		var _left:ITriangleMaterial;
		var _right:ITriangleMaterial;
		var _bottom:ITriangleMaterial;
		var _top:ITriangleMaterial;
		var _front:ITriangleMaterial;
		var _back:ITriangleMaterial;
		 
		function notifyMaterialChange(material:ITriangleMaterial, faceString:String):Void
		{
            if (!hasEventListener(MaterialEvent.MATERIAL_CHANGED))
                return;
                
          //if (!_materialchanged)
            _materialchanged = new MaterialEvent(MaterialEvent.MATERIAL_CHANGED, material);
            /*else
            	_materialchanged.material = material; */
            
            _materialchanged.extra = faceString;
            
            dispatchEvent(_materialchanged);
		}
		
        /**
        * Instance of the Init object used to hold and parse default property values
        * specified by the initialiser object in the 3d object constructor.
        */
		var ini:Init;
		
    	/**
    	 * Defines the material applied to the left side of the cube.
    	 */
    	public function getLeft():ITriangleMaterial{
    		return _left;
    	}
    	
    	public function setLeft(val:ITriangleMaterial):ITriangleMaterial{
    		if (_left == val)
    			return;
    		
    		_left = val;
    		
    		notifyMaterialChange(_left, "left");
    		return val;
    	}
    	
    	/**
    	 * Defines the material applied to the right side of the cube.
    	 */
    	public function getRight():ITriangleMaterial{
    		return _right;
    	}
    	
    	public function setRight(val:ITriangleMaterial):ITriangleMaterial{
    		if (_right == val)
    			return;
    		
    		_right = val;
    		
    		notifyMaterialChange(_right, "right");
    		return val;
    	}
		
    	/**
    	 * Defines the material applied to the bottom side of the cube.
    	 */
    	public function getBottom():ITriangleMaterial{
    		return _bottom;
    	}
    	
    	public function setBottom(val:ITriangleMaterial):ITriangleMaterial{
    		if (_bottom == val)
    			return;
    		
    		_bottom = val;
    		
    		notifyMaterialChange(_bottom, "bottom");
    		return val;
    	}
		
    	/**
    	 * Defines the material applied to the top side of the cube.
    	 */
    	public function getTop():ITriangleMaterial{
    		return _top;
    	}
    	
    	public function setTop(val:ITriangleMaterial):ITriangleMaterial{
    		if (_top == val)
    			return;
    		
    		_top = val;
    		
    		notifyMaterialChange(_top, "top");
    		return val;
    	}
		
    	/**
    	 * Defines the material applied to the front side of the cube.
    	 */
    	public function getFront():ITriangleMaterial{
    		return _front;
    	}
    	
    	public function setFront(val:ITriangleMaterial):ITriangleMaterial{
    		if (_front == val)
    			return;
    		
    		_front = val;
    		
    		notifyMaterialChange(_front, "front");
    		return val;
    	}
		
    	/**
    	 * Defines the material applied to the back side of the cube.
    	 */
    	public function getBack():ITriangleMaterial{
    		return _back;
    	}
    	
    	public function setBack(val:ITriangleMaterial):ITriangleMaterial{
    		if (_back == val)
    			return;
    		
    		_back = val;
    		
    		notifyMaterialChange(_back, "back");
    		return val;
    	}
    	
		/**
		 * Creates a new <code>CubeMaterialsData</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(?init:Dynamic = null)
        {
        	ini = Init.parse(init);
        	
        	_left = ini.getMaterial("left");
        	_right = ini.getMaterial("right");
        	_bottom = ini.getMaterial("bottom");
        	_top = ini.getMaterial("top");
        	_front = ini.getMaterial("front");
        	_back = ini.getMaterial("back");
        }
        
		/**
		 * Default method for adding a materialChanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMaterialChange(listener:Dynamic):Void
        {
            addEventListener(MaterialEvent.MATERIAL_CHANGED, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a materialChanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMaterialChange(listener:Dynamic):Void
        {
            removeEventListener(MaterialEvent.MATERIAL_CHANGED, listener, false);
        }
	}
