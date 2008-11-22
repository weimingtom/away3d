package away3d.core.base;

    import away3d.arcane;
    import away3d.events.*;
    
    import flash.events.EventDispatcher;
    
    use namespace arcane;
    
	 /**
	 * Dispatched when the vertex of a 3d element changes.
	 * 
	 * @eventType away3d.events.ElementEvent
	 */
	/*[Event(name="vertexChanged",type="away3d.events.ElementEvent")]*/
    
	 /**
	 * Dispatched when the vertex value of a 3d element changes.
	 * 
	 * @eventType away3d.events.ElementEvent
	 */
	/*[Event(name="vertexvalueChanged",type="away3d.events.ElementEvent")]*/
    
	 /**
	 * Dispatched when the visiblity of a 3d element changes.
	 * 
	 * @eventType away3d.events.ElementEvent
	 */
	/*[Event(name="visibleChanged",type="away3d.events.ElementEvent")]*/
	
	/**
	 * Basic 3d element object
     * Not intended for direct use - use <code>Segment</code> or <code>Face</code>.
	 */
    class Element extends EventDispatcher {
		public var maxX(getMaxX, null) : Float
        ;
		public var maxY(getMaxY, null) : Float
        ;
		public var maxZ(getMaxZ, null) : Float
        ;
		public var minX(getMinX, null) : Float
        ;
		public var minY(getMinY, null) : Float
        ;
		public var minZ(getMinZ, null) : Float
        ;
		public var radius2(getRadius2, null) : Float
        ;
		public var vertices(getVertices, null) : Array<Dynamic>
        ;
		public var visible(getVisible, setVisible) : Bool;
		/** @private */
        public function new() {
        _visible = true;
        }
        
		/** @private */
        arcane var _visible:Bool ;
		/** @private */
        arcane function notifyVertexChange():Void
        {
            if (!hasEventListener(ElementEvent.VERTEX_CHANGED))
                return;
			
            if (_vertexchanged == null)
                _vertexchanged = new ElementEvent(ElementEvent.VERTEX_CHANGED, this);
            
            dispatchEvent(_vertexchanged);
        }
		/** @private */
        arcane function notifyVertexValueChange():Void
        {
            if (!hasEventListener(ElementEvent.VERTEXVALUE_CHANGED))
                return;
			
            if (_vertexvaluechanged == null)
                _vertexvaluechanged = new ElementEvent(ElementEvent.VERTEXVALUE_CHANGED, this);
            
            dispatchEvent(_vertexvaluechanged);
        }
		/** @private */
        arcane function notifyVisibleChange():Void
        {
            if (!hasEventListener(ElementEvent.VISIBLE_CHANGED))
                return;
			
            if (_visiblechanged == null)
                _visiblechanged = new ElementEvent(ElementEvent.VISIBLE_CHANGED, this);
            
            dispatchEvent(_visiblechanged);
        }
		
		var _vertexchanged:ElementEvent;
		var _vertexvaluechanged:ElementEvent;
		var _visiblechanged:ElementEvent;
		
		public var vertexDirty:Bool;
		
    	/**
    	 * An optional untyped object that can contain used-defined properties.
    	 */
        public var extra:Dynamic;
        
    	/**
    	 * Defines the parent 3d object of the segment.
    	 */
		public var parent:Geometry;
		
		/**
		 * Returns an array of vertex objects that make up the 3d element.
		 */
        public function getVertices():Array<Dynamic>
        {
            throw new Error("Not implemented");
        }
        
		/**
		 * Determines whether the 3d element is visible in the scene.
		 */
        public function getVisible():Bool{
            return _visible;
        }
		
        public function setVisible(value:Bool):Bool{
            if (value == _visible)
                return;

            _visible = value;

            notifyVisibleChange();
        	return value;
           }
		
		/**
		 * Returns the squared bounding radius of the 3d element
		 */
        public function getRadius2():Float
        {
            var maxr:Int = 0;
            for (vertex in vertices)
            {
                var r:Int = vertex._x*vertex._x + vertex._y*vertex._y + vertex._z*vertex._z;
                if (r > maxr)
                    maxr = r;
            }
            return maxr;
        }
		
		/**
		 * Returns the maximum x value of the 3d element
		 */
        public function getMaxX():Float
        {
            return Math.sqrt(radius2);
        }
		
		/**
		 * Returns the minimum x value of the 3d element
		 */
        public function getMinX():Float
        {
            return -Math.sqrt(radius2);
        }
		
		/**
		 * Returns the maximum y value of the 3d element
		 */
        public function getMaxY():Float
        {
            return Math.sqrt(radius2);
        }
		
		/**
		 * Returns the minimum y value of the 3d element
		 */
        public function getMinY():Float
        {
            return -Math.sqrt(radius2);
        }
		
		/**
		 * Returns the maximum z value of the 3d element
		 */
        public function getMaxZ():Float
        {
            return Math.sqrt(radius2);
        }
		
		/**
		 * Returns the minimum z value of the 3d element
		 */
        public function getMinZ():Float
        {
            return -Math.sqrt(radius2);
        }
		
		/**
		 * Default method for adding a vertexchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnVertexChange(listener:Dynamic):Void
        {
            addEventListener(ElementEvent.VERTEX_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a vertexchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnVertexChange(listener:Dynamic):Void
        {
            removeEventListener(ElementEvent.VERTEX_CHANGED, listener, false);
        }
		
		/**
		 * Default method for adding a vertexvaluechanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnVertexValueChange(listener:Dynamic):Void
        {
            addEventListener(ElementEvent.VERTEXVALUE_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a vertexvaluechanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnVertexValueChange(listener:Dynamic):Void
        {
            removeEventListener(ElementEvent.VERTEXVALUE_CHANGED, listener, false);
        }
		
		/**
		 * Default method for adding a visiblechanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnVisibleChange(listener:Dynamic):Void
        {
            addEventListener(ElementEvent.VISIBLE_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a visiblechanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnVisibleChange(listener:Dynamic):Void
        {
            removeEventListener(ElementEvent.VISIBLE_CHANGED, listener, false);
        }


    }
