package away3d.core.base
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.events.*;
    import away3d.materials.*;
    import away3d.primitives.*;
    
    import flash.utils.Dictionary;
    
    /**
    * 3d object containing face and segment elements 
    */
    public class Mesh extends BaseMesh implements IPrimitiveProvider
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
		arcane function getSceneVertexNormal(vertex:Vertex):Number3D
        {
        	if (_vertfacesDirty)
                findVertFaces();
            
            if (_vertnormalsDirty)
                findVertNormals();
                
        	if (_scenevertnormalsDirty)
                findSceneVertNormals();
            
            return _scenevertnormals[vertex];
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
		arcane function createDrawTriangle(face:Face, material:ITriangleMaterial, projection:Projection, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex, uv0:UV, uv1:UV, uv2:UV):DrawTriangle
		{
			if (_dtStore.length) {
            	_dtActive.push(_tri = _dtStore.pop());
            	_tri.texturemapping = null;
            	_tri.create = createDrawTriangle;
   			} else {
            	_dtActive.push(_tri = new DrawTriangle());
	            _tri.source = this;
		        _tri.create = createDrawTriangle;
            }
            _tri.face = face;
            _tri.material = material;
            _tri.projection = projection;
            _tri.v0 = v0;
            _tri.v1 = v1;
            _tri.v2 = v2;
            _tri.uv0 = uv0;
            _tri.uv1 = uv1;
            _tri.uv2 = uv2;
            _tri.calc();
            return _tri;
		}
		
        private var _faces:Array = [];
		private var _material:ITriangleMaterial;
        private var _neighboursDirty:Boolean = true;
        private var _neighbour01:Dictionary;
        private var _neighbour12:Dictionary;
        private var _neighbour20:Dictionary;
        private var _vertfacesDirty:Boolean = true;
        private var _vertfaces:Dictionary;
        private var _vertnormalsDirty:Boolean = true;
		private var _vertnormals:Dictionary;
		private var _scenevertnormalsDirty:Boolean = true;
		private var _scenevertnormals:Dictionary;
        private var _fNormal:Number3D;
        private var _fAngle:Number;
        private var _fVectors:Array;
		private var _n01:Face;
		private var _n12:Face;
		private var _n20:Face;
        private var _debugboundingbox:WireCube;
		private var _tri:DrawTriangle;
        private var _backmat:ITriangleMaterial;
        private var _backface:Boolean;
        private var _uvmaterial:Boolean;
        private var _vt:ScreenVertex;
		private var _dtStore:Array = new Array();
        private var _dtActive:Array = new Array();
        
		private function onMaterialResize(event:MaterialEvent):void
		{
			for each (var face:Face in _faces)
        		if (face._material == null)
        			face._dt.texturemapping = null;
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
		
		private function findSceneVertNormals():void
		{
			if (!_scenevertnormalsDirty)
                return;
            
            _scenevertnormals = new Dictionary();
            //TODO: refresh scene normals
            /*
            for each (var v:Vertex in vertices)
            {
            	
            }
            */
            _scenevertnormalsDirty = false;
		}


        private function findNeighbours():void
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
        
        //TODO: create effective dispose mechanism for meshs
		/*
        private function clear():void
        {
            for each (var face:Face in _faces.concat([]))
                removeFace(face);
        }
        */
        
        /**
        * Defines a segment material to be used for outlining the 3d object.
        */
        public var outline:ISegmentMaterial;
        
        /**
        * Defines a triangle material to be used for the backface of all faces in the 3d object.
        */
        public var back:ITriangleMaterial;
		
		/**
		 * Indicates whether both the front and reverse sides of a face should be rendered.
		 */
        public var bothsides:Boolean;
        
        /**
        * Indicates whether a debug bounding box should be rendered around the 3d object.
        */
        public var debugbb:Boolean;
		
		/**
		 * Returns an array of the faces contained in the mesh object.
		 */
        public function get faces():Array
        {
            return _faces;
        }
		
		/**
		 * Returns an array of the elements contained in the mesh object.
		 */
        public override function get elements():Array
        {
            return _faces;
        }
		
		/**
		 * Defines the material used to render the faces in the mesh object.
		 * Individual material settings on faces will override this setting.
		 * 
		 * @see away3d.core.base.Face#material
		 */
        public function get material():ITriangleMaterial
        {
        	return _material;
        }
        
        public function set material(val:ITriangleMaterial):void
        {
        	if (_material == val)
                return;
            
            if (_material != null && _material is IUVMaterial)
            	(_material as IUVMaterial).removeOnResize(onMaterialResize);
            
        	_material = val;
        	
        	if (_material != null && _material is IUVMaterial)
            	(_material as IUVMaterial).addOnResize(onMaterialResize);
        	
        	//reset texturemapping (if applicable)
        	if (_material is IUVMaterial || _material is ILayerMaterial)
	        	for each (var face:Face in _faces)
	        		if (face._material == null)
	        			face._dt.texturemapping = null;
        }
    	
		/**
		 * Creates a new <code>BaseMesh</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function Mesh(init:Object = null)
        {
            super(init);
            
            material = ini.getMaterial("material");
            outline = ini.getSegmentMaterial("outline");
            back = ini.getMaterial("back");
            bothsides = ini.getBoolean("bothsides", false);
            debugbb = ini.getBoolean("debugbb", false);

            if ((material == null) && (outline == null))
                material = new WireColorMaterial();
        }
		
		/**
		 * Adds a face object to the mesh object.
		 * 
		 * @param	face	The face object to be added.
		 */
        public function addFace(face:Face):void
        {
            addElement(face);

            _faces.push(face);
			
			face._dt.source = face.parent = this;
			face._dt.create = createDrawTriangle;
			
            face.addOnVertexChange(onFaceVertexChange);
            rememberFaceNeighbours(face);
            _vertfacesDirty = true;
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
		
		/**
		 * Moves the origin point of the mesh without moving the contents.
		 * 
		 * @param	dx		The amount of movement along the local x axis.
		 * @param	dy		The amount of movement along the local y axis.
		 * @param	dz		The amount of movement along the local z axis.
		 */
        public function movePivot(dx:Number, dy:Number, dz:Number):void
        {
        	//if (_transformDirty)
        	//	updateTransform();
            var nd:Boolean = _neighboursDirty;
            _neighboursDirty = true;
            for each (var vertex:Vertex in vertices)
            {
                vertex.x -= dx;
                vertex.y -= dy;
                vertex.z -= dz;
            }
            
            var dV:Number3D = new Number3D(dx, dy, dz);
            dV.rotate(dV.clone(), _transform);
            dV.add(dV, position);
            moveTo(dV);
            _neighboursDirty = nd;
        }
        
		/**
		 * @inheritDoc
		 * 
    	 * @see	away3d.core.traverse.PrimitiveTraverser
    	 * @see	away3d.core.draw.DrawTriangle
    	 * @see	away3d.core.draw.DrawSegment
		 */
        override public function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void
        {
        	super.primitives(consumer, session);
        	
        	_dtStore = _dtStore.concat(_dtActive);
        	_dtActive = new Array();
        	
            if (outline != null)
                if (_neighboursDirty)
                    findNeighbours();

            if (debugbb)
            {
                if (_debugboundingbox == null)
                    _debugboundingbox = new WireCube({material:"#white"});
                _debugboundingbox.v000.x = minX;
                _debugboundingbox.v001.x = minX;
                _debugboundingbox.v010.x = minX;
                _debugboundingbox.v011.x = minX;
                _debugboundingbox.v100.x = maxX;
                _debugboundingbox.v101.x = maxX;
                _debugboundingbox.v110.x = maxX;
                _debugboundingbox.v111.x = maxX;
                _debugboundingbox.v000.y = minY;
                _debugboundingbox.v001.y = minY;
                _debugboundingbox.v010.y = maxY;
                _debugboundingbox.v011.y = maxY;
                _debugboundingbox.v100.y = minY;
                _debugboundingbox.v101.y = minY;
                _debugboundingbox.v110.y = maxY;
                _debugboundingbox.v111.y = maxY;
                _debugboundingbox.v000.z = minZ;
                _debugboundingbox.v001.z = maxZ;
                _debugboundingbox.v010.z = minZ;
                _debugboundingbox.v011.z = maxZ;
                _debugboundingbox.v100.z = minZ;
                _debugboundingbox.v101.z = maxZ;
                _debugboundingbox.v110.z = minZ;
                _debugboundingbox.v111.z = maxZ;
                if (_faces.length > 0)
                    _debugboundingbox.primitives(consumer, session);
            }
            
            _backmat = back || material;
			
            for each (var face:Face in _faces)
            {
                if (!face._visible)
                    continue;
				
				//project each Vertex to a ScreenVertex
				_tri = face._dt;
                _tri.v0 = face._v0.project(projection);
                _tri.v1 = face._v1.project(projection);
                _tri.v2 = face._v2.project(projection);
				
				//check each ScreenVertex is visible
                if (!_tri.v0.visible)
                    continue;

                if (!_tri.v1.visible)
                    continue;

                if (!_tri.v2.visible)
                    continue;
				
				//calculate Draw_triangle properties
                _tri.calc();
				
				//check _triangle is not behind the camera
                if (_tri.maxZ < 0)
                    continue;
				
				//determine if _triangle is facing towards or away from camera
                _backface = _tri.area < 0;
				
				//if _triangle facing away, check for backface material
                if (_backface) {
                    if (!bothsides)
                        continue;
                    _tri.material = face._back;
                } else
                    _tri.material = face._material;
				
				//determine the material of the _triangle
                if (_tri.material == null)
                    if (_backface)
                        _tri.material = _backmat;
                    else
                        _tri.material = _material;
				
				//do not draw material if visible is false
                if (_tri.material != null)
                    if (!_tri.material.visible)
                        _tri.material = null;
				
				//if there is no material and no outline, continue
                if (outline == null)
                    if (_tri.material == null)
                        continue;
				
                if (pushback)
                    _tri.screenZ = _tri.maxZ;

                if (pushfront)
                    _tri.screenZ = _tri.minZ;
				
				_uvmaterial = (_tri.material is IUVMaterial || _tri.material is ILayerMaterial);
				
				//swap ScreenVerticies if _triangle facing away from camera
                if (_backface) {
                    // Make cleaner
                    _vt = _tri.v1;
                    _tri.v1 = _tri.v2;
                    _tri.v2 = _vt;
					
                    _tri.area = -_tri.area;
                    
                    if (_uvmaterial) {
						//pass accross uv values
		                _tri.uv0 = face._uv0;
		                _tri.uv1 = face._uv2;
		                _tri.uv2 = face._uv1;
                    }
                } else if (_uvmaterial) {
					//pass accross uv values
	                _tri.uv0 = face._uv0;
	                _tri.uv1 = face._uv1;
	                _tri.uv2 = face._uv2;
                }
                
                //check if face swapped direction
                if (_tri.backface != _backface) {
                	_tri.backface = _backface;
                	_tri.texturemapping = null;
                }
                
                if (outline != null && !_backface)
                {
                    _n01 = _neighbour01[face];
                    if (_n01 == null || _n01.front(projection) <= 0)
                    	consumer.primitive(createDrawSegment(outline, projection, _tri.v0, _tri.v1));

                    _n12 = _neighbour12[face];
                    if (_n12 == null || _n12.front(projection) <= 0)
                    	consumer.primitive(createDrawSegment(outline, projection, _tri.v1, _tri.v2));

                    _n20 = _neighbour20[face];
                    if (_n20 == null || _n20.front(projection) <= 0)
                    	consumer.primitive(createDrawSegment(outline, projection, _tri.v2, _tri.v0));

                    if (_tri.material == null)
                    	continue;
                }
                _tri.projection = projection;
                consumer.primitive(_tri);
            }
        }
		
		/**
		 * Duplicates the mesh properties to another 3d object.
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied. The default is <code>Mesh</code>.
		 * @return						The new object instance with duplicated properties applied.
		 */
        public override function clone(object:* = null):*
        {
            var mesh:Mesh = object || new Mesh();
            super.clone(mesh);
            mesh.material = material;
            mesh.outline = outline;
            mesh.back = back;
            mesh.bothsides = bothsides;
            mesh.debugbb = debugbb;

            var clonedvertices:Dictionary = new Dictionary();
            var clonevertex:Function = function(vertex:Vertex):Vertex
            {
                var result:Vertex = clonedvertices[vertex];
                if (result == null)
                {
                    result = new Vertex(vertex._x, vertex._y, vertex._z);
                    result.extra = (vertex.extra is IClonable) ? (vertex.extra as IClonable).clone() : vertex.extra;
                    clonedvertices[vertex] = result;
                }
                return result;
            };

            var cloneduvs:Dictionary = new Dictionary();
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
                mesh.addFace(new Face(clonevertex(face._v0), clonevertex(face._v1), clonevertex(face._v2), face.material, cloneuv(face._uv0), cloneuv(face._uv1), cloneuv(face._uv2)));

            return mesh;
        }
		
 		public var indexes:Array;
 		
 		/**
 		 * Returns a formatted string containing a self contained AS3 class definition that can be used to re-create the mesh.
 		 * 
 		 * @param	classname	[optional]	Defines the class name used in the output string. Defaults to <code>Away3DObject</code>.
 		 * @param	packagename	[optional]	Defines the package name used in the output string. Defaults to no package.
 		 * @param	round		[optional]	Rounds all values to 4 decimal places. Defaults to false.
 		 * @param	animated	[optional]	Defines whether animation data should be saved. Defaults to false.
 		 * 
 		 * @return	A string to be pasted into a new .as file
 		 */
 		public function asAS3Class(classname:String = null, packagename:String = "", round:Boolean = false, animated:Boolean = false):String
        {
            classname = classname || name || "Away3DObject";
			
			var importextra:String  = (animated)? "\timport flash.utils.Dictionary;\n" : ""; 
            var source:String = "package "+packagename+"\n{\n\timport away3d.core.base.*;\n\timport away3d.core.utils.*;\n"+importextra+"\n\tpublic class "+classname+" extends Mesh\n\t{\n";
            source += "\t\tprivate var varr:Array = [];\n\t\tprivate var uvarr:Array = [];\n\t\tprivate var scaling:Number;\n";
			
			if(animated){
				source += "\t\tprivate var fnarr:Array = [];\n\n";
				source += "\n\t\tprivate function v():void\n\t\t{\n";
				source += "\t\t\tfor(var i:int = 0;i<vcount;i++){\n\t\t\t\tvarr.push(new Vertex(0,0,0));\n\t\t\t}\n\t\t}\n\n";
			} else{
				source += "\n\t\tprivate function v(x:Number,y:Number,z:Number):void\n\t\t{\n";
				source += "\t\t\tvarr.push(new Vertex(x*scaling, y*scaling, z*scaling));\n\t\t}\n\n";
			}
            source += "\t\tprivate function uv(u:Number,v:Number):void\n\t\t{\n";
            source += "\t\t\tuvarr.push(new UV(u,v));\n\t\t}\n\n";
            source += "\t\tprivate function f(vn0:int, vn1:int, vn2:int, uvn0:int, uvn1:int, uvn2:int):void\n\t\t{\n";
            source += "\t\t\taddFace(new Face(varr[vn0],varr[vn1],varr[vn2], null, uvarr[uvn0],uvarr[uvn1],uvarr[uvn2]));\n\t\t}\n\n";
            source += "\t\tpublic function "+classname+"(init:Object = null)\n\t\t{\n\t\t\tsuper(init);\n\t\t\tinit = Init.parse(init);\n\t\t\tscaling = init.getNumber(\"scaling\", 1);\n\t\t\tbuild();\n\t\t\ttype = \".as\";\n\t\t}\n\n";
            source += "\t\tprivate function build():void\n\t\t{\n";
				
			var refvertices:Dictionary = new Dictionary();
            var verticeslist:Array = [];
            var remembervertex:Function = function(vertex:Vertex):void
            {
                if (refvertices[vertex] == null)
                {
                    refvertices[vertex] = verticeslist.length;
                    verticeslist.push(vertex);
                }
            };

            var refuvs:Dictionary = new Dictionary();
            var uvslist:Array = [];
            var rememberuv:Function = function(uv:UV):void
            {
                if (uv == null)
                    return;

                if (refuvs[uv] == null)
                {
                    refuvs[uv] = uvslist.length;
                    uvslist.push(uv);
                }
            };

            for each (var face:Face in _faces)
            {
                remembervertex(face._v0);
                remembervertex(face._v1);
                remembervertex(face._v2);
                rememberuv(face._uv0);
                rememberuv(face._uv1);
                rememberuv(face._uv2);
            }
 			
			var uv:UV;
			var v:Vertex;
			var myPattern:RegExp;
			var myPattern2:RegExp;
			
			if(animated){
				myPattern = new RegExp("vcount","g");
				source = source.replace(myPattern, verticeslist.length);
				source += "\n\t\t\tv();\n\n";					
					
			} else{
				for each (v in verticeslist)
					source += (round)? "\t\t\tv("+v._x.toFixed(4)+","+v._y.toFixed(4)+","+v._z.toFixed(4)+");\n" : "\t\t\tv("+v._x+","+v._y+","+v._z+");\n";				
			}
			 
			for each (uv in uvslist)
				source += (round)? "\t\t\tuv("+uv._u.toFixed(4)+","+uv._v.toFixed(4)+");\n"  :  "\t\t\tuv("+uv._u+","+uv._v+");\n";

			if(round){
				var tmp:String;
				myPattern2 = new RegExp(".0000","g");
			}
			
			var f:Face;	
			if(animated){
				var ind:Array;
				var auv:Array = [];
				for each (f in _faces)
				
					auv.push((round)? refuvs[f._uv0].toFixed(4)+","+refuvs[f._uv1].toFixed(4)+","+refuvs[f._uv2].toFixed(4) : refuvs[f._uv0]+","+refuvs[f._uv1]+","+refuvs[f._uv2]);
				
				for(var i:int = 0; i< indexes.length;i++){
					ind = indexes[i];
					source += "\t\t\tf("+ind[0]+","+ind[1]+","+ind[2]+","+auv[i]+");\n";
				}
				
			} else{
				for each (f in _faces)
					source += "\t\t\tf("+refvertices[f._v0]+","+refvertices[f._v1]+","+refvertices[f._v2]+","+refuvs[f._uv0]+","+refuvs[f._uv1]+","+refuvs[f._uv2]+");\n";
			}

			if(round) source = source.replace(myPattern2,"");
			
			if(animated){
				var afn:Array = new Array();
				var avp:Array;
				var tmpnames:Array = new Array();
				i= 0;
				var y:int = 0;
				source += "\n\t\t\tframes = new Dictionary();\n";
            	source += "\t\t\tframenames = new Dictionary();\n";
				source += "\t\t\tvar oFrames:Object = new Object();\n";
				
				myPattern = new RegExp(" ","g");
				
				for (var framename:String in framenames){
					tmpnames.push(framename);
				}
				
				tmpnames.sort(); 
				var fr:Frame;
				for (i = 0;i<tmpnames.length;i++){
					avp = new Array();
					fr = frames[framenames[tmpnames[i]]];
					if(tmpnames[i].indexOf(" ") != -1) tmpnames[i] = tmpnames[i].replace(myPattern,"");
					afn.push("\""+tmpnames[i]+"\"");
					source += "\n\t\t\toFrames."+tmpnames[i]+"=[";
					for(y = 0; y<verticeslist.length ;y++){
						if(round){
							avp.push(fr.vertexpositions[y].x.toFixed(4));
							avp.push(fr.vertexpositions[y].y.toFixed(4));
							avp.push(fr.vertexpositions[y].z.toFixed(4));
						} else{
							avp.push(fr.vertexpositions[y].x);
							avp.push(fr.vertexpositions[y].y);
							avp.push(fr.vertexpositions[y].z);
						}
					}
					if(round){
						tmp = avp.toString();
						tmp = tmp.replace(myPattern2,"");
						source += tmp +"];\n";
					} else{
						source += avp.toString() +"];\n";
					}
				}
				
				source += "\n\t\t\tfnarr = ["+afn.toString()+"];\n";
				source += "\n\t\t\tvar y:int;\n";
				source += "\t\t\tvar z:int;\n";
				source += "\t\t\tvar frame:Frame;\n";
				source += "\t\t\tfor(var i:int = 0;i<fnarr.length; i++){\n";
				source += "\t\t\t\ttrace(\"[ \"+fnarr[i]+\" ]\");\n";
				source += "\t\t\t\tframe = new Frame();\n";
				source += "\t\t\t\tframenames[fnarr[i]] = i;\n";
				source += "\t\t\t\tframes[i] = frame;\n";
				source += "\t\t\t\tz=0;\n";
				source += "\t\t\t\tfor (y = 0; y < oFrames[fnarr[i]].length; y+=3){\n";
				source += "\t\t\t\t\tvar vp:VertexPosition = new VertexPosition(varr[z]);\n";
				source += "\t\t\t\t\tz++;\n";
				source += "\t\t\t\t\tvp.x = oFrames[fnarr[i]][y]*scaling;\n";
				source += "\t\t\t\t\tvp.y = oFrames[fnarr[i]][y+1]*scaling;\n";
				source += "\t\t\t\t\tvp.z = oFrames[fnarr[i]][y+2]*scaling;\n";
				source += "\t\t\t\t\tframe.vertexpositions.push(vp);\n";
				source += "\t\t\t\t}\n";
				source += "\t\t\t\tif (i == 0)\n";
				source += "\t\t\t\t\tframe.adjust();\n";
				source += "\t\t\t}\n";
				
			}
			source += "\n\t\t}\n\t}\n}";
			//here a setClipboard to avoid Flash slow trace window might be beter...
            return source;
        }
 		
 		/**
 		 * Returns an xml representation of the mesh
 		 * 
 		 * @return	An xml object containing mesh information
 		 */
        public function asXML():XML
        {
            var result:XML = <mesh></mesh>;

            var refvertices:Dictionary = new Dictionary();
            var verticeslist:Array = [];
            var remembervertex:Function = function(vertex:Vertex):void
            {
                if (refvertices[vertex] == null)
                {
                    refvertices[vertex] = verticeslist.length;
                    verticeslist.push(vertex);
                }
            };

            var refuvs:Dictionary = new Dictionary();
            var uvslist:Array = [];
            var rememberuv:Function = function(uv:UV):void
            {
                if (uv == null)
                    return;

                if (refuvs[uv] == null)
                {
                    refuvs[uv] = uvslist.length;
                    uvslist.push(uv);
                }
            };

            for each (var face:Face in _faces)
            {
                remembervertex(face._v0);
                remembervertex(face._v1);
                remembervertex(face._v2);
                rememberuv(face._uv0);
                rememberuv(face._uv1);
                rememberuv(face._uv2);
            }

            var vn:int = 0;
            for each (var v:Vertex in verticeslist)
            {
                result.appendChild(<vertex id={vn} x={v._x} y={v._y} z={v._z}/>);
                vn++;
            }

            var uvn:int = 0;
            for each (var uv:UV in uvslist)
            {
                result.appendChild(<uv id={uvn} u={uv._u} v={uv._v}/>);
                uvn++;
            }

            for each (var f:Face in _faces)
                result.appendChild(<face v0={refvertices[f._v0]} v1={refvertices[f._v1]} v2={refvertices[f._v2]} uv0={refuvs[f._uv0]} uv1={refuvs[f._uv1]} uv2={refuvs[f._uv2]}/>);

            return result;
        }
    }
}
