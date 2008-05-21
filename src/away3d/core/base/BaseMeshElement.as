package away3d.core.base
{
    import away3d.core.*;
    import away3d.events.*;
    
    import flash.events.EventDispatcher;
    
	 /**
	 * Dispatched when the vertex of a 3d element changes.
	 * 
	 * @eventType away3d.events.MeshElementEvent
	 */
	[Event(name="vertexchanged",type="away3d.events.MeshElementEvent")]
    
	 /**
	 * Dispatched when the vertex value of a 3d element changes.
	 * 
	 * @eventType away3d.events.MeshElementEvent
	 */
	[Event(name="vertexvaluechanged",type="away3d.events.MeshElementEvent")]
    
	 /**
	 * Dispatched when the visiblity of a 3d element changes.
	 * 
	 * @eventType away3d.events.MeshElementEvent
	 */
	[Event(name="visiblechanged",type="away3d.events.MeshElementEvent")]
	
	/**
	 * Basic 3d element object
     * Not intended for direct use - use <code>Segment</code> or <code>Face</code>.
	 */
    public class BaseMeshElement extends EventDispatcher implements IMeshElement
    {
        use namespace arcane;
		/** @private */
        arcane var _visible:Boolean = true;
		/** @private */
        arcane function notifyVertexChange():void
        {
            if (!hasEventListener(MeshElementEvent.VERTEX_CHANGED))
                return;

            if (_vertexchanged == null)
                _vertexchanged = new MeshElementEvent(MeshElementEvent.VERTEX_CHANGED, this);
                
            dispatchEvent(_vertexchanged);
        }
		/** @private */
        arcane function notifyVertexValueChange():void
        {
            if (!hasEventListener(MeshElementEvent.VERTEXVALUE_CHANGED))
                return;

            if (_vertexvaluechanged == null)
                _vertexvaluechanged = new MeshElementEvent(MeshElementEvent.VERTEXVALUE_CHANGED, this);
                
            dispatchEvent(_vertexvaluechanged);
        }
		/** @private */
        arcane function notifyVisibleChange():void
        {
            if (!hasEventListener(MeshElementEvent.VISIBLE_CHANGED))
                return;

            if (_visiblechanged == null)
                _visiblechanged = new MeshElementEvent(MeshElementEvent.VISIBLE_CHANGED, this);
                
            dispatchEvent(_visiblechanged);
        }
		
		private var _vertexchanged:MeshElementEvent;
		private var _vertexvaluechanged:MeshElementEvent;
		private var _visiblechanged:MeshElementEvent;
		
		/**
		 * Returns an array of vertex objects that make up the 3d element.
		 */
        public function get vertices():Array
        {
            throw new Error("Not implemented");
        }
        
		/**
		 * @inheritDoc
		 */
        public function get visible():Boolean
        {
            return _visible;
        }
		
        public function set visible(value:Boolean):void
        {
            if (value == _visible)
                return;

            _visible = value;

            notifyVisibleChange();
        }
        
		/**
		 * @inheritDoc
		 */
        public function get radius2():Number
        {
            var maxr:Number = 0;
            for each (var vertex:Vertex in vertices)
            {
                var r:Number = vertex._x*vertex._x + vertex._y*vertex._y + vertex._z*vertex._z;
                if (r > maxr)
                    maxr = r;
            }
            return maxr;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get maxX():Number
        {
            return Math.sqrt(radius2);
        }
        
		/**
		 * @inheritDoc
		 */
        public function get minX():Number
        {
            return -Math.sqrt(radius2);
        }
        
		/**
		 * @inheritDoc
		 */
        public function get maxY():Number
        {
            return Math.sqrt(radius2);
        }
        
		/**
		 * @inheritDoc
		 */
        public function get minY():Number
        {
            return -Math.sqrt(radius2);
        }
        
		/**
		 * @inheritDoc
		 */
        public function get maxZ():Number
        {
            return Math.sqrt(radius2);
        }
        
		/**
		 * @inheritDoc
		 */
        public function get minZ():Number
        {
            return -Math.sqrt(radius2);
        }
        
		/**
		 * @inheritDoc
		 */
        public function addOnVertexChange(listener:Function):void
        {
            addEventListener(MeshElementEvent.VERTEX_CHANGED, listener, false, 0, true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function removeOnVertexChange(listener:Function):void
        {
            removeEventListener(MeshElementEvent.VERTEX_CHANGED, listener, false);
        }
        
		/**
		 * @inheritDoc
		 */
        public function addOnVertexValueChange(listener:Function):void
        {
            addEventListener(MeshElementEvent.VERTEXVALUE_CHANGED, listener, false, 0, true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function removeOnVertexValueChange(listener:Function):void
        {
            removeEventListener(MeshElementEvent.VERTEXVALUE_CHANGED, listener, false);
        }
        
		/**
		 * @inheritDoc
		 */
        public function addOnVisibleChange(listener:Function):void
        {
            addEventListener(MeshElementEvent.VISIBLE_CHANGED, listener, false, 0, true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function removeOnVisibleChange(listener:Function):void
        {
            removeEventListener(MeshElementEvent.VISIBLE_CHANGED, listener, false);
        }


    }
}
