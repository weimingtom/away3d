package away3d.core.base;

    import away3d.arcane;
    import away3d.core.draw.*;
    import away3d.core.utils.*;
    import away3d.events.*;
    import away3d.materials.*;
    
    import flash.events.Event;
    
    use namespace arcane;
    
	 /**
	 * Dispatched when the material of the segment changes.
	 * 
	 * @eventType away3d.events.FaceEvent
	 */
	/*[Event(name="materialchanged",type="away3d.events.FaceEvent")]*/
	
    /**
    * A line element used in the wiremesh and mesh object
    * 
    * @see away3d.core.base.WireMesh
    * @see away3d.core.base.Mesh
    */
    class Segment extends Element {
		public var material(getMaterial, setMaterial) : ISegmentMaterial;
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
		public var v0(getV0, setV0) : Vertex;
		public var v1(getV1, setV1) : Vertex;
		public var vertices(getVertices, null) : Array<Dynamic>
        ;
		/** @private */
        
		/** @private */
        arcane var _v0:Vertex;
		/** @private */
        arcane var _v1:Vertex;
		/** @private */
        arcane var _material:ISegmentMaterial;
		/** @private */
        //arcane var _ds:DrawSegment = new DrawSegment();
		/** @private */
        arcane function notifyMaterialChange():Void
        {
            if (!hasEventListener(SegmentEvent.MATERIAL_CHANGED))
                return;

            if (_materialchanged == null)
                _materialchanged = new SegmentEvent(SegmentEvent.MATERIAL_CHANGED, this);
                
            dispatchEvent(_materialchanged);
        }
        
        var _materialchanged:SegmentEvent;
		
		//TODO: simplify vertex changed events
		/*
        private function onVertexChange(event:Event):void
        {
            notifyVertexChange();
        }
		*/
		
        function onVertexValueChange(event:Event):Void
        {
            notifyVertexValueChange();
        }
		
		/**
		 * Returns an array of vertex objects that are used by the segment.
		 */
        public override function getVertices():Array<Dynamic>
        {
            return [_v0, _v1];
        }
		
		/**
		 * Defines the v0 vertex of the segment.
		 */
        public function getV0():Vertex{
            return _v0;
        }

        public function setV0(value:Vertex):Vertex{
            if (value == _v0)
                return;

            if (_v0 != null)
                if (_v0 != _v1)
                    _v0.removeOnChange(onVertexValueChange);

            _v0 = value;

            if (_v0 != null)
                if (_v0 != _v1)
                    _v0.addOnChange(onVertexValueChange);

            notifyVertexChange();
        	return value;
           }
		
		/**
		 * Defines the v1 vertex of the segment.
		 */
        public function getV1():Vertex{
            return _v1;
        }

        public function setV1(value:Vertex):Vertex{
            if (value == _v1)
                return;

            if (_v1 != null)
                if (_v1 != _v0)
                    _v1.removeOnChange(onVertexValueChange);

            _v1 = value;

            if (_v1 != null)
                if (_v1 != _v0)
                    _v1.addOnChange(onVertexValueChange);

            notifyVertexChange();
        	return value;
           }
		
		/**
		 * Defines the material of the segment.
		 */
        public function getMaterial():ISegmentMaterial{
            return _material;
        }

        public function setMaterial(value:ISegmentMaterial):ISegmentMaterial{
            if (value == _material)
                return;

            _material = value;

            notifyMaterialChange();
        	return value;
           }
		
		/**
		 * Returns the squared bounding radius of the face.
		 */
        public override function getRadius2():Float
        {
            var rv0:Int = _v0._x*_v0._x + _v0._y*_v0._y + _v0._z*_v0._z;
            var rv1:Int = _v1._x*_v1._x + _v1._y*_v1._y + _v1._z*_v1._z;

            if (rv0 > rv1)
                return rv0;
            else
                return rv1;
        }
        
    	/**
    	 * Returns the maximum x value of the segment
    	 * 
    	 * @see		away3d.core.base.Vertex#x
    	 */
        public override function getMaxX():Float
        {
            if (_v0._x > _v1._x)
                return _v0._x;
            else
                return _v1._x;
        }
        
    	/**
    	 * Returns the minimum x value of the face
    	 * 
    	 * @see		away3d.core.base.Vertex#x
    	 */
        public override function getMinX():Float
        {
            if (_v0._x < _v1._x)
                return _v0._x;
            else
                return _v1._x;
        }
        
    	/**
    	 * Returns the maximum y value of the segment
    	 * 
    	 * @see		away3d.core.base.Vertex#y
    	 */
        public override function getMaxY():Float
        {
            if (_v0._y > _v1._y)
                return _v0._y;
            else
                return _v1._y;
        }
        
    	/**
    	 * Returns the minimum y value of the face
    	 * 
    	 * @see		away3d.core.base.Vertex#y
    	 */
        public override function getMinY():Float
        {
            if (_v0._y < _v1._y)
                return _v0._y;
            else
                return _v1._y;
        }
        
    	/**
    	 * Returns the maximum z value of the segment
    	 * 
    	 * @see		away3d.core.base.Vertex#z
    	 */
        public override function getMaxZ():Float
        {
            if (_v0._z > _v1._z)
                return _v0._z;
            else
                return _v1._z;
        }
        
    	/**
    	 * Returns the minimum y value of the face
    	 * 
    	 * @see		away3d.core.base.Vertex#y
    	 */
        public override function getMinZ():Float
        {
            if (_v0._z < _v1._z)
                return _v0._z;
            else
                return _v1._z;
        }
    	
		/**
		 * Creates a new <code>Segment</code> object.
		 *
		 * @param	v0						The first vertex object of the segment
		 * @param	v1						The second vertex object of the segment
		 * @param	material	[optional]	The material used by the segment to render
		 */
        public function new(v0:Vertex, v1:Vertex, ?material:ISegmentMaterial = null)
        {
            this.v0 = v0;
            this.v1 = v1;
            this.material = material;
            
            vertexDirty = true;
        }
		
		/**
		 * Default method for adding a materialchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMaterialChange(listener:Dynamic):Void
        {
            addEventListener(SegmentEvent.MATERIAL_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a materialchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMaterialChange(listener:Dynamic):Void
        {
            removeEventListener(SegmentEvent.MATERIAL_CHANGED, listener, false);
        }
    }
