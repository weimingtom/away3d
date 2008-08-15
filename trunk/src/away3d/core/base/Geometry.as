package away3d.core.base
{
    import away3d.animators.skin.*;
    import away3d.containers.*;
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.events.*;
    import away3d.materials.*;
    import away3d.primitives.*;
    
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    
    /**
    * 3d object containing face and segment elements 
    */
    public class Geometry extends EventDispatcher
    {
        use namespace arcane;
		/** @private */
        arcane function getFacesByVertex(vertex:Vertex):Array
        {
            if (_vertfacesDirty)
                findVertFaces();

            return _vertfaces[vertex];
        }
		/** @private */
		arcane function getVertexNormal(vertex:Vertex):Number3D
        {
        	if (_vertfacesDirty)
                findVertFaces();
            
            if (_vertnormalsDirty)
                findVertNormals();
            
            return _vertnormals[vertex];
        }
		/** @private */
        arcane function neighbour01(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            return _neighbour01[face];
        }
		/** @private */
        arcane function neighbour12(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            return _neighbour12[face];
        }
		/** @private */
        arcane function neighbour20(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            return _neighbour20[face];
        }
		/** @private */
        arcane function recalcNeighbours():void
        {
            if (!_neighboursDirty)
            {
                _neighboursDirty = true;
                findNeighbours();
                /*
                var sn01:Dictionary = _neighbour01;
                var sn12:Dictionary = _neighbour12;
                var sn20:Dictionary = _neighbour20;
                for each (var f:Face in faces)
                {
                    if (sn01[f] != _neighbour01[f])
                        throw new Error("Got you!");
                    if (sn12[f] != _neighbour12[f])
                        throw new Error("Got you!");
                    if (sn20[f] != _neighbour20[f])
                        throw new Error("Got you!");
                }
                */
            }
        }
		/** @private */
        arcane function notifyDimensionsChange():void
        {
            if (!hasEventListener(GeometryEvent.DIMENSIONS_CHANGED))
                return;
                
            if (!_dimensionschanged)
                _dimensionschanged = new GeometryEvent(GeometryEvent.DIMENSIONS_CHANGED, this);
                
            dispatchEvent(_dimensionschanged);
        }
        /** @private */
        arcane function notifyRadiusChange():void
        {
            if (!hasEventListener(GeometryEvent.RADIUS_CHANGED))
                return;
                
            if (!_radiuschanged)
                _radiuschanged = new GeometryEvent(GeometryEvent.RADIUS_CHANGED, this);
                
            dispatchEvent(_radiuschanged);
        }
        
        private var _renderTime:int;
        private var _faces:Array = [];
        private var _segments:Array = [];
        private var _vertices:Array;
        private var _verticesDirty:Boolean = true;
        private var _radiusElement:IMeshElement = null;
        private var _radius:Number = 0;
        private var _radiusDirty:Boolean = false;
		private var _maxXElement:IMeshElement = null;
        private var _maxXDirty:Boolean = false;
        private var _maxX:Number = -Infinity;
        private var _minXElement:IMeshElement = null;
        private var _minXDirty:Boolean = false;
        private var _minX:Number = Infinity;
        private var _maxYElement:IMeshElement = null;
        private var _maxYDirty:Boolean = false;
        private var _maxY:Number = -Infinity;
		private var _minYElement:IMeshElement = null;
        private var _minYDirty:Boolean = false;
        private var _minY:Number = Infinity;
        private var _maxZElement:IMeshElement = null;
        private var _maxZDirty:Boolean = false;
        private var _maxZ:Number = -Infinity;
        private var _minZElement:IMeshElement = null;
        private var _minZDirty:Boolean = false;
        private var _minZ:Number = Infinity;
        private var _needNotifyRadiusChange:Boolean = false;
        private var _needNotifyDimensionsChange:Boolean = false;
        private var _dimensionschanged:GeometryEvent;
        private var _radiuschanged:GeometryEvent;
        private var _neighboursDirty:Boolean = true;
        private var _neighbour01:Dictionary;
        private var _neighbour12:Dictionary;
        private var _neighbour20:Dictionary;
        private var _vertfacesDirty:Boolean = true;
        private var _vertfaces:Dictionary;
        private var _vertnormalsDirty:Boolean = true;
		private var _vertnormals:Dictionary;
        private var _fNormal:Number3D;
        private var _fAngle:Number;
        private var _fVectors:Array;
		private var _n01:Face;
		private var _n12:Face;
		private var _n20:Face;
		private var _skinVertex:SkinVertex;
        private var _skinController:SkinController;
        private var clonedvertices:Dictionary;
        private var cloneduvs:Dictionary;
        
        private function launchNotifies():void
        {
            if (_needNotifyRadiusChange)
            {
                _needNotifyRadiusChange = false;
                notifyRadiusChange();
            }
            if (_needNotifyDimensionsChange)
            {
                _needNotifyDimensionsChange = false;
                notifyDimensionsChange();
            }
        }
		
        private function addElement(element:IMeshElement):void
        {
            _verticesDirty = true;
            
            element.addOnVertexChange(onElementVertexChange);
            element.addOnVertexValueChange(onElementVertexValueChange);
            
            rememberElementRadius(element);
			
            launchNotifies();
        }
        
        private function removeElement(element:IMeshElement):void
        {
            forgetElementRadius(element);
			
            element.removeOnVertexValueChange(onElementVertexValueChange);
            element.removeOnVertexChange(onElementVertexChange);
			
            _verticesDirty = true;
			
            launchNotifies();
        }
		
        private function findVertFaces():void
        {
            if (!_vertfacesDirty)
                return;
            
            _vertfaces = new Dictionary();
            for each (var face:Face in faces)
            {
                var v0:Vertex = face.v0;
                if (_vertfaces[v0] == null)
                    _vertfaces[v0] = [face];
                else
                    _vertfaces[v0].push(face);
                var v1:Vertex = face.v1;
                if (_vertfaces[v1] == null)
                    _vertfaces[v1] = [face];
                else
                    _vertfaces[v1].push(face);
                var v2:Vertex = face.v2;
                if (_vertfaces[v2] == null)
                    _vertfaces[v2] = [face];
                else
                    _vertfaces[v2].push(face);
            }
            
            _vertfacesDirty = false;
            _vertnormalsDirty = true;
        }
        
        private function findVertNormals():void
        {
        	if (!_vertnormalsDirty)
                return;
            
            _vertnormals = new Dictionary();
            for each (var v:Vertex in vertices)
            {
            	var vF:Array = _vertfaces[v];
            	var nX:Number = 0;
            	var nY:Number = 0;
            	var nZ:Number = 0;
            	for each (var f:Face in vF)
            	{
	            	_fNormal = f.normal;
	            	_fVectors = new Array();
	            	for each (var fV:Vertex in f.vertices)
	            		if (fV != v)
	            			_fVectors.push(new Number3D(fV.x - v.x, fV.y - v.y, fV.z - v.z, true));
	            	
	            	_fAngle = Math.acos((_fVectors[0] as Number3D).dot(_fVectors[1] as Number3D));
            		nX += _fNormal.x*_fAngle;
            		nY += _fNormal.y*_fAngle;
            		nZ += _fNormal.z*_fAngle;
            	}
            	var vertNormal:Number3D = new Number3D(nX, nY, nZ);
            	vertNormal.normalize();
            	_vertnormals[v] = vertNormal;
            }            
            
            _vertnormalsDirty = false;    
        }

        private function rememberFaceNeighbours(face:Face):void
        {
            if (_neighboursDirty)
                return;
            
            for each (var another:Face in _faces)
            {
                if (face == another)
                    continue;

                if ((face._v0 == another._v2) && (face._v1 == another._v1))
                {
                    _neighbour01[face] = another;
                    _neighbour12[another] = face;
                }

                if ((face._v0 == another._v0) && (face._v1 == another._v2))
                {
                    _neighbour01[face] = another;
                    _neighbour20[another] = face;
                }

                if ((face._v0 == another._v1) && (face._v1 == another._v0))
                {
                    _neighbour01[face] = another;
                    _neighbour01[another] = face;
                }
            
                if ((face._v1 == another._v2) && (face._v2 == another._v1))
                {
                    _neighbour12[face] = another;
                    _neighbour12[another] = face;
                }

                if ((face._v1 == another._v0) && (face._v2 == another._v2))
                {
                    _neighbour12[face] = another;
                    _neighbour20[another] = face;
                }

                if ((face._v1 == another._v1) && (face._v2 == another._v0))
                {
                    _neighbour12[face] = another;
                    _neighbour01[another] = face;
                }
            
                if ((face._v2 == another._v2) && (face._v0 == another._v1))
                {
                    _neighbour20[face] = another;
                    _neighbour12[another] = face;
                }

                if ((face._v2 == another._v0) && (face._v0 == another._v2))
                {
                    _neighbour20[face] = another;
                    _neighbour20[another] = face;
                }

                if ((face._v2 == another._v1) && (face._v0 == another._v0))
                {
                    _neighbour20[face] = another;
                    _neighbour01[another] = face;
                }
            }
        }
        
        private function forgetFaceNeighbours(face:Face):void
        {
            if (_neighboursDirty)
                return;
            
            _n01 = _neighbour01[face];
            if (_n01 != null)
            {
                delete _neighbour01[face];
                if (_neighbour01[_n01] == face)
                    delete _neighbour01[_n01];
                if (_neighbour12[_n01] == face)
                    delete _neighbour12[_n01];
                if (_neighbour20[_n01] == face)
                    delete _neighbour20[_n01];
            }
            _n12 = _neighbour12[face];
            if (_n12 != null)
            {
                delete _neighbour12[face];
                if (_neighbour01[_n12] == face)
                    delete _neighbour01[_n12];
                if (_neighbour12[_n12] == face)
                    delete _neighbour12[_n12];
                if (_neighbour20[_n12] == face)
                    delete _neighbour20[_n12];
            }
            _n20 = _neighbour20[face];
            if (_n20 != null)
            {
                delete _neighbour20[face];
                if (_neighbour01[_n20] == face)
                    delete _neighbour01[_n20];
                if (_neighbour12[_n20] == face)
                    delete _neighbour12[_n20];
                if (_neighbour20[_n20] == face)
                    delete _neighbour20[_n20];
            }
        }

        private function onFaceVertexChange(event:MeshElementEvent):void
        {
            if (!_neighboursDirty)
            {
                var face:Face = event.element as Face;
                forgetFaceNeighbours(face);
                rememberFaceNeighbours(face);
            }

            _vertfacesDirty = true;
        }
        
        private function onFaceMaterialChange(event:FaceEvent):void
        {
        	dispatchEvent(event);
        }
        
        private function onFaceMappingChange(event:FaceEvent):void
        {
        	dispatchEvent(event);
        }
        
		private function rememberElementRadius(element:IMeshElement):void
        {
            var r2:Number = element.radius2;
            if (r2 > _radius*_radius)
            {
                _radius = Math.sqrt(r2);
                _radiusElement = element;
                _radiusDirty = false;
                _needNotifyRadiusChange = true;
            }
            var mxX:Number = element.maxX;
            if (mxX > _maxX)
            {
                _maxX = mxX;
                _maxXElement = element;
                _maxXDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mnX:Number = element.minX;
            if (mnX < _minX)
            {
                _minX = mnX;
                _minXElement = element;
                _minXDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mxY:Number = element.maxY;
            if (mxY > _maxY)
            {
                _maxY = mxY;
                _maxYElement = element;
                _maxYDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mnY:Number = element.minY;
            if (mnY < _minY)
            {
                _minY = mnY;
                _minYElement = element;
                _minYDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mxZ:Number = element.maxZ;
            if (mxZ > _maxZ)
            {
                _maxZ = mxZ;
                _maxZElement = element;
                _maxZDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mnZ:Number = element.minZ;
            if (mnZ < _minZ)
            {
                _minZ = mnZ;
                _minZElement = element;
                _minZDirty = false;
                _needNotifyDimensionsChange = true;
            }
        }

        private function forgetElementRadius(element:IMeshElement):void
        {
            if (element == _radiusElement)
            {
                _radiusElement = null;
                _radiusDirty = true;
                _needNotifyRadiusChange = true;
            }
            if (element == _maxXElement)
            {
                _maxXElement = null;
                _maxXDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _minXElement)
            {
                _minXElement = null;
                _minXDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _maxYElement)
            {
                _maxYElement = null;
                _maxYDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _minYElement)
            {
                _minYElement = null;
                _minYDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _maxZElement)
            {
                _maxZElement = null;
                _maxZDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _minZElement)
            {
                _minZElement = null;
                _minZDirty = true;
                _needNotifyDimensionsChange = true;
            }
        }

        private function onElementVertexChange(event:MeshElementEvent):void
        {
            var element:IMeshElement = event.element;

            forgetElementRadius(element);
            rememberElementRadius(element);

            _verticesDirty = true;

            launchNotifies();
        }

        private function onElementVertexValueChange(event:MeshElementEvent):void
        {
            var element:IMeshElement = event.element;
            forgetElementRadius(element);
            rememberElementRadius(element);
            launchNotifies();
        }
        
		private function cloneVertex(vertex:Vertex):Vertex
        {
            var result:Vertex = clonedvertices[vertex];
            if (result == null)
            {
                result = new Vertex(vertex._x, vertex._y, vertex._z);
                result.extra = (vertex.extra is IClonable) ? (vertex.extra as IClonable).clone() : vertex.extra;
                clonedvertices[vertex] = result;
            }
            return result;
        }
        
        private function cloneUV(uv:UV):UV
        {
            if (uv == null)
                return null;

            var result:UV = cloneduvs[uv];
            if (result == null)
            {
                result = new UV(uv._u, uv._v);
                cloneduvs[uv] = result;
            }
            return result;
        }
         
        /**
         * Instance of the Init object used to hold and parse default property values
         * specified by the initialiser object in the 3d object constructor.
         */
		protected var ini:Init;
    	
    	/**
    	 * Array of vertices used in a skinmesh
    	 */
        public var skinVertices:Array;
        
        /**
        * Array of controller objects used to bind vertices with joints in a skinmesh
        */
        public var skinControllers:Array;
        
		/**
		 * Returns an array of the faces contained in the mesh object.
		 */
        public function get faces():Array
        {
            return _faces;
        }
		
		
		/**
		 * Returns an array of the segments contained in the wiremesh object.
		 */
        public function get segments():Array
        {
            return _segments;
        }
        
		/**
		 * Returns an array of the elements contained in the mesh object.
		 */
        public function get elements():Array
        {
            return _faces.concat(_segments);
        }
                    
        /**
        * Returns an array of the vertices contained in the mesh object
        */
        public function get vertices():Array
        {
            if (_verticesDirty)
            {
                _vertices = [];
                var processed:Dictionary = new Dictionary();
                for each (var element:IMeshElement in elements)
                    for each (var vertex:Vertex in element.vertices)
                        if (!processed[vertex])
                        {
                            _vertices.push(vertex);
                            processed[vertex] = true;
                        }
                _verticesDirty = false;
            }
            return _vertices;
        }
        		
		/**
		 * @inheritDoc
		 */
        public function get boundingRadius():Number
        {
            if (_radiusDirty)
            {
                _radiusElement = null;
                var mr:Number = 0;
                for each (var element:IMeshElement in elements)
                {
                    var r2:Number = element.radius2;
                    if (r2 > mr)
                    {
                        mr = r2;
                        _radiusElement = element;
                    }
                }
                _radius = Math.sqrt(mr);
                _radiusDirty = false;
            }
            return _radius;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get maxX():Number
        {
            if (_maxXDirty)
            {
                _maxXElement = null;
                var extrval:Number = -Infinity;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.maxX;
                    if (val > extrval)
                    {
                        extrval = val;
                        _maxXElement = element;
                    }
                }
                _maxX = extrval;
                _maxXDirty = false;
            }
            return _maxX;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get minX():Number
        {
            if (_minXDirty)
            {
                _minXElement = null;
                var extrval:Number = Infinity;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.minX;
                    if (val < extrval)
                    {
                        extrval = val;
                        _minXElement = element;
                    }
                }
                _minX = extrval;
                _minXDirty = false;
            }
            return _minX;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get maxY():Number
        {
            if (_maxYDirty)
            {
                var extrval:Number = -Infinity;
                _maxYElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.maxY;
                    if (val > extrval)
                    {
                        extrval = val;
                        _maxYElement = element;
                    }
                }
                _maxY = extrval;
                _maxYDirty = false;
            }
            return _maxY;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get minY():Number
        {
            if (_minYDirty)
            {
                var extrval:Number = Infinity;
                _minYElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.minY;
                    if (val < extrval)
                    {
                        extrval = val;
                        _minYElement = element;
                    }
                }
                _minY = extrval;
                _minYDirty = false;
            }
            return _minY;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get maxZ():Number
        {
            if (_maxZDirty)
            {
                var extrval:Number = -Infinity;
                _maxZElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.maxZ;
                    if (val > extrval)
                    {
                        extrval = val;
                        _maxZElement = element;
                    }
                }
                _maxZ = extrval;
                _maxZDirty = false;
            }
            return _maxZ;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get minZ():Number
        {
            if (_minZDirty)
            {
                var extrval:Number = Infinity;
                _minZElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.minZ;
                    if (val < extrval)
                    {
                        extrval = val;
                        _minZElement = element;
                    }
                }
                _minZ = extrval;
                _minZDirty = false;
            }
            return _minZ;
        }
		
		/**
		 * Adds a face object to the mesh object.
		 * 
		 * @param	face	The face object to be added.
		 */
        public function addFace(face:Face):void
        {
            addElement(face);
			
			face.addOnMaterialChange(onFaceMaterialChange);
			face.addOnMappingChange(onFaceMappingChange);
			
            _faces.push(face);
			
			//face._dt.source = face.parent = this;
			//face._dt.create = createDrawTriangle;
			
            rememberFaceNeighbours(face);
        }
		
		/**
		 * Removes a face object from the mesh object.
		 * 
		 * @param	face	The face object to be removed.
		 */
        public function removeFace(face:Face):void
        {
            var index:int = _faces.indexOf(face);
            if (index == -1)
                return;
			
            removeElement(face);
			
            _vertfacesDirty = true;
            forgetFaceNeighbours(face);
            face.removeOnVertexChange(onFaceVertexChange);
			
            _faces.splice(index, 1);
        }
		
		/**
		 * Adds a segment object to the wiremesh object.
		 * 
		 * @param	segment	The segment object to be added.
		 */
        public function addSegment(segment:Segment):void
        {
            addElement(segment);
			
            _segments.push(segment);
            
            //segment._ds.source = segment.parent = this;
            //segment._ds.create = createDrawSegment;
        }
		
		/**
		 * Removes a segment object to the wiremesh object.
		 * 
		 * @param	segment	The segment object to be removed.
		 */
        public function removeSegment(segment:Segment):void
        {
            var index:int = _segments.indexOf(segment);
            if (index == -1)
                return;
			
            removeElement(segment);
			
            _segments.splice(index, 1);
        }
        
		/**
		 * Inverts the geometry of all face objects.
		 * 
		 * @see away3d.code.base.Face#invert()
		 */
        public function invertFaces():void
        {
            for each (var face:Face in _faces)
                face.invert();
        }
		
		/**
		 * Divides a face object into 4 equal sized face objects.
		 * Used to segment a mesh in order to reduce affine persepective distortion.
		 * 
		 * @see away3d.primitives.SkyBox
		 */
        public function quarterFaces():void
        {
            var medians:Dictionary = new Dictionary();
            for each (var face:Face in _faces.concat([]))
            {
                var v0:Vertex = face.v0;
                var v1:Vertex = face.v1;
                var v2:Vertex = face.v2;

                if (medians[v0] == null)
                    medians[v0] = new Dictionary();
                if (medians[v1] == null)
                    medians[v1] = new Dictionary();
                if (medians[v2] == null)
                    medians[v2] = new Dictionary();

                var v01:Vertex = medians[v0][v1];
                if (v01 == null)
                {
                   v01 = Vertex.median(v0, v1);
                   medians[v0][v1] = v01;
                   medians[v1][v0] = v01;
                }
                var v12:Vertex = medians[v1][v2];
                if (v12 == null)
                {
                   v12 = Vertex.median(v1, v2);
                   medians[v1][v2] = v12;
                   medians[v2][v1] = v12;
                }
                var v20:Vertex = medians[v2][v0];
                if (v20 == null)
                {
                   v20 = Vertex.median(v2, v0);
                   medians[v2][v0] = v20;
                   medians[v0][v2] = v20;
                }
                var uv0:UV = face.uv0;
                var uv1:UV = face.uv1;
                var uv2:UV = face.uv2;
                var uv01:UV = UV.median(uv0, uv1);
                var uv12:UV = UV.median(uv1, uv2);
                var uv20:UV = UV.median(uv2, uv0);
                var material:ITriangleMaterial = face.material;
                removeFace(face);
                addFace(new Face(v0, v01, v20, material, uv0, uv01, uv20));
                addFace(new Face(v01, v1, v12, material, uv01, uv1, uv12));
                addFace(new Face(v20, v12, v2, material, uv20, uv12, uv2));
                addFace(new Face(v12, v20, v01, material, uv12, uv20, uv01));
            }
        }
		
		public function findNeighbours():void
        {
            if (!_neighboursDirty)
                return;

            _neighbour01 = new Dictionary();
            _neighbour12 = new Dictionary();
            _neighbour20 = new Dictionary();
            for each (var face:Face in _faces)
            {
                var skip:Boolean = true;
                for each (var another:Face in _faces)
                {
                    if (skip)
                    {
                        if (face == another)
                            skip = false;
                        continue;
                    }

                    if ((face._v0 == another._v2) && (face._v1 == another._v1))
                    {
                        _neighbour01[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v0 == another._v0) && (face._v1 == another._v2))
                    {
                        _neighbour01[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v0 == another._v1) && (face._v1 == another._v0))
                    {
                        _neighbour01[face] = another;
                        _neighbour01[another] = face;
                    }
                
                    if ((face._v1 == another._v2) && (face._v2 == another._v1))
                    {
                        _neighbour12[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v1 == another._v0) && (face._v2 == another._v2))
                    {
                        _neighbour12[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v1 == another._v1) && (face._v2 == another._v0))
                    {
                        _neighbour12[face] = another;
                        _neighbour01[another] = face;
                    }
                
                    if ((face._v2 == another._v2) && (face._v0 == another._v1))
                    {
                        _neighbour20[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v2 == another._v0) && (face._v0 == another._v2))
                    {
                        _neighbour20[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v2 == another._v1) && (face._v0 == another._v0))
                    {
                        _neighbour20[face] = another;
                        _neighbour01[another] = face;
                    }
                }
            }

            _neighboursDirty = false;
        }
        
        public function update(time:int):void
        {
        	if (_renderTime == time)
        		return;
        	
        	_renderTime = time;
        	
        	for each(_skinController in skinControllers)
				_skinController.update();
				
            for each(_skinVertex in skinVertices)
				_skinVertex.update();
        	
        }
		/**
		 * Duplicates the mesh properties to another 3d object.
		 * 
		 * @return						The new object instance with duplicated properties applied.
		 */
        public function clone():Geometry
        {
            var geometry:Geometry = new Geometry();

            clonedvertices = new Dictionary();

            cloneduvs = new Dictionary();
            
            var cloneuv:Function = function(uv:UV):UV
            {
                if (uv == null)
                    return null;

                var result:UV = cloneduvs[uv];
                if (result == null)
                {
                    result = new UV(uv._u, uv._v);
                    cloneduvs[uv] = result;
                }
                return result;
            };
            
            for each (var face:Face in _faces)
                geometry.addFace(new Face(cloneVertex(face._v0), cloneVertex(face._v1), cloneVertex(face._v2), face.material, cloneUV(face._uv0), cloneUV(face._uv1), cloneUV(face._uv2)));

            return geometry;
        }
		
		/**
 		 * update vertex information.
 		 * 
 		 * @param		v						The vertex object to update
 		 * @param		x						The new x value for the vertex
 		 * @param		y						The new y value for the vertex
 		 * @param		z						The new z value for the vertex
		 * @param		refreshNormals	[optional]	Defines whether normals should be recalculated
 		 * 
 		 */
		public function updateVertex(v:Vertex, x:Number, y:Number, z:Number, refreshNormals:Boolean = false):void
		{
			v.setValue(x,y,z);
			
			if(refreshNormals)
				_vertnormalsDirty = true;
		}
		
		/**
 		* Apply the world rotations to mesh local coordinates.
 		* Resets the world rotations to zero.
 		*/
		public function applyRotations(rotationX:Number, rotationY:Number, rotationZ:Number):void
		{
			 
			var x:Number;
			var y:Number;
			var z:Number;
			var x1:Number;
			var y1:Number;
			var z1:Number;
			
			var rad:Number = Math.PI / 180;
			var rotx:Number = rotationX * rad;
			var roty:Number = rotationY * rad;
			var rotz:Number = rotationZ * rad;
			var sinx:Number = Math.sin(rotx);
			var cosx:Number = Math.cos(rotx);
			var siny:Number = Math.sin(roty);
			var cosy:Number = Math.cos(roty);
			var sinz:Number = Math.sin(rotz);
			var cosz:Number = Math.cos(rotz);

			for(var i:int;i<vertices.length;++i){
				 
				x = vertices[i].x;
				y = vertices[i].y;
				z = vertices[i].z;

				y1 = y
				y = y1*cosx+z*-sinx;
				z = y1*sinx+z*cosx;
				
				x1 = x
				x = x1*cosy+z*siny;
				z = x1*-siny+z*cosy;
			
				x1 = x;
				x = x1*cosz+y*-sinz;
				y = x1*sinz+y*cosz;
 
				updateVertex(vertices[i], x, y, z, false);
			}
		}
		
		/**
		 * Default method for adding a radiuschanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnRadiusChange(listener:Function):void
        {
            addEventListener(GeometryEvent.RADIUS_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a radiuschanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnRadiusChange(listener:Function):void
        {
            removeEventListener(GeometryEvent.RADIUS_CHANGED, listener, false);
        }
		
		/**
		 * Default method for adding a dimensionschanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnDimensionsChange(listener:Function):void
        {
            addEventListener(GeometryEvent.DIMENSIONS_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a dimensionschanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnDimensionsChange(listener:Function):void
        {
            removeEventListener(GeometryEvent.DIMENSIONS_CHANGED, listener, false);
        }
		/**
		 * Default method for adding a mappingchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMappingChange(listener:Function):void
        {
            addEventListener(FaceEvent.MAPPING_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a mappingchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMappingChange(listener:Function):void
        {
            removeEventListener(FaceEvent.MAPPING_CHANGED, listener, false);
        }
		
		/**
		 * Default method for adding a materialchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMaterialChange(listener:Function):void
        {
            addEventListener(FaceEvent.MATERIAL_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a materialchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMaterialChange(listener:Function):void
        {
            removeEventListener(FaceEvent.MATERIAL_CHANGED, listener, false);
        }
    }
}
