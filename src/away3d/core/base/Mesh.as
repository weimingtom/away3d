package away3d.core.base
{
    import away3d.animators.data.*;
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
    
    import flash.utils.Dictionary;
    
    /**
    * 3d object containing face and segment elements 
    */
    public class Mesh extends Object3D implements IPrimitiveProvider
    {
        use namespace arcane;
        /** @private */
        arcane var screenVertices:Dictionary = new Dictionary(true);
        /** @private */
        arcane var drawTriangles:Dictionary = new Dictionary(true);
        /** @private */
        arcane var drawSegments:Dictionary = new Dictionary(true);
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
		/** @private */
        arcane function createDrawSegment(material:ISegmentMaterial, projection:Projection, v0:ScreenVertex, v1:ScreenVertex):DrawSegment
        {
            if (_dsStore.length) {
            	_dsActive.push(_seg = _dsStore.pop());
            	_seg.create = createDrawSegment;
        	} else {
            	_dsActive.push(_seg = new DrawSegment());
	            _seg.source = this;
	            _seg.create = createDrawSegment;
            }
            _seg.material = material;
            _seg.projection = projection;
            _seg.v0 = v0;
            _seg.v1 = v1;
            _seg.calc();
            return _seg;
        }
        
		private var _geometry:Geometry;
		private var _material:IMaterial;
		private var _triangleMaterial:ITriangleMaterial;
		private var _segmentMaterial:ISegmentMaterial;
		private var _scenevertnormalsDirty:Boolean = true;
		private var _scenevertnormals:Dictionary;
		private var _n01:Face;
		private var _n12:Face;
		private var _n20:Face;
        private var _screenVertex:ScreenVertex;
        private var _priArray:Array;
        private var _pri:DrawPrimitive;
		private var _tri:DrawTriangle;
		private var _seg:DrawSegment;
        private var _backmat:ITriangleMaterial;
        private var _backface:Boolean;
        private var _uvmaterial:Boolean;
        private var _vt:ScreenVertex;
		private var _dtStore:Array = new Array();
        private var _dtActive:Array = new Array();
        private var _dsStore:Array = new Array();
        private var _dsActive:Array = new Array();
        
		private function onMaterialResize(event:MaterialEvent):void
		{
			for each (var face:Face in _geometry.faces)
        		if (face._material == null)
        			if (drawTriangles[face])
						(drawTriangles[face] as DrawTriangle).texturemapping = null;
		}
        
        private function onFaceMaterialChange(event:FaceEvent):void
		{
			if (drawTriangles[event.face])
				(drawTriangles[event.face] as DrawTriangle).texturemapping = null;
		}
        
        private function onFaceMappingChange(event:FaceEvent):void
		{
			if (drawTriangles[event.face])
				(drawTriangles[event.face] as DrawTriangle).texturemapping = null;
		}
        
        private function onDimensionsChange(event:GeometryEvent):void
        {
        	notifyDimensionsChange();
        }
        
        protected override function updateDimensions():void
        {
        	//update bounding radius
        	var vertices:Array = geometry.vertices.concat();
        	
        	if (!vertices.length)
        		return;
        	
        	var mradius:Number = 0;
        	var vradius:Number;
            var num:Number3D = new Number3D();
            for each (var vertex:Vertex in vertices) {
            	num.sub(vertex.position, _pivotPoint);
                vradius = num.modulo2;
                if (mradius < vradius)
                    mradius = vradius;
            }
            if (mradius)
           		_boundingRadius = Math.sqrt(mradius);
           	else
           		_boundingRadius = 0;
             
            //update max/min X
            vertices.sortOn("x", Array.DESCENDING | Array.NUMERIC);
            _maxX = vertices[0].x;
            _minX = vertices[vertices.length - 1].x;
            
            //update max/min Y
            vertices.sortOn("y", Array.DESCENDING | Array.NUMERIC);
            _maxY = vertices[0].y;
            _minY = vertices[vertices.length - 1].y;
            
            //update max/min Z
            vertices.sortOn("z", Array.DESCENDING | Array.NUMERIC);
            _maxZ = vertices[0].z;
            _minZ = vertices[vertices.length - 1].z;
            
            super.updateDimensions();
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
		 * Elements use their furthest point from the camera when z-sorting
		 */
        public var pushback:Boolean;
		
		/**
		 * Elements use their nearest point to the camera when z-sorting
		 */
        public var pushfront:Boolean;
        
		/**
		 * String defining the source of the mesh.
		 * 
		 * If the mesh has been created internally, the string is used to display the package name of the creating object.
		 * Used to display information in the stats panel
		 * 
		 * @see away3d.core.stats.Stats
		 */
       	public var url:String;
		
		/**
		 * String defining the type of class used to generate the mesh.
		 * Used to display information in the stats panel
		 * 
		 * @see away3d.core.stats.Stats
		 */
       	public var type:String;
       	
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
        * Placeholder for md2 frame indexes
        */
        public var indexes:Array;
        
		/**
		 * Returns an array of the vertices contained in the mesh object.
		 */
        public function get vertices():Array
        {
            return _geometry.vertices;
        }
                
		/**
		 * Returns an array of the faces contained in the mesh object.
		 */
        public function get faces():Array
        {
            return _geometry.faces;
        }
				
		/**
		 * Returns an array of the segments contained in the mesh object.
		 */
        public function get segments():Array
        {
            return _geometry.segments;
        }
		         
        /**
        * Defines the geometry object used for the mesh.
        */
        public function get geometry():Geometry
        {
        	return _geometry;
        }
        
        public function set geometry(val:Geometry):void
        {
        	if (_geometry == val)
                return;
            
            if (_geometry != null) {
            	_geometry.removeOnMappingChange(onFaceMappingChange);
            	_geometry.removeOnMaterialChange(onFaceMaterialChange);
            	_geometry.removeOnDimensionsChange(onDimensionsChange);
            }
            
        	_geometry = val;
        	
            if (_geometry != null) {
            	_geometry.addOnMappingChange(onFaceMappingChange);
            	_geometry.addOnMaterialChange(onFaceMaterialChange);
            	_geometry.addOnDimensionsChange(onDimensionsChange);
            }
        }
            
		/**
		 * Defines the material used to render the faces and segments in the geometry object.
		 * Individual material settings on faces and segments will override this setting.
		 * 
		 * @see away3d.core.base.Face#material
		 */
        public function get material():IMaterial
        {
        	return _material;
        }
        
        public function set material(val:IMaterial):void
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
	        	for each (var face:Face in _geometry.faces)
	        		if (face._material == null)
	        			if (drawTriangles[face])
							(drawTriangles[face] as DrawTriangle).texturemapping = null;
	        			
	        if (_material is ITriangleMaterial)
	        	_triangleMaterial = _material as ITriangleMaterial;
	        if (_material is ISegmentMaterial)
	        	_segmentMaterial = _material as ISegmentMaterial;
        }
		
		/**
		 * Indicates the current frame of animation
		 */
        public function get frame():int
        {
            return geometry.frame;
        }
        
        public function set frame(value:int):void
        {
        	geometry.frame = value;
        }
        
		/**
		 * Indicates whether the animation has a cycle event listener
		 */
		public function get hasCycleEvent():Boolean
        {
        	return geometry.hasCycleEvent;
        }
        
		/**
		 * Indicates whether the animation has a sequencedone event listener
		 */
		public function get hasSequenceEvent():Boolean
        {
			return geometry.hasSequenceEvent;
        }
        
		/**
		 * Determines the frames per second at which the animation will run.
		 */
		public function set fps(fps:int):void
		{
			geometry.fps = fps;
		}
		
		/**
		 * Determines whether the animation will loop.
		 */
		public function set loop(loop:Boolean):void
		{
			geometry.loop = loop;
		}
        
        /**
        * Determines whether the animation will smooth motion (interpolate) between frames.
        */
		public function set smooth(smooth:Boolean):void
		{
			geometry.smooth = smooth;
		}
		
		/**
		 * Indicates whether the animation is currently running.
		 */
		public function get isRunning():Boolean
		{
			return geometry.isRunning;
		}
		
		/**
		 * Creates a new <code>BaseMesh</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function Mesh(init:Object = null)
        {
            super(init);
                
            geometry = new Geometry();
            
            material = ini.getMaterial("material");
            outline = ini.getSegmentMaterial("outline");
            back = ini.getMaterial("back");
            bothsides = ini.getBoolean("bothsides", false);
            pushback = ini.getBoolean("pushback", false);
            pushfront = ini.getBoolean("pushfront", false);
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
            _geometry.addFace(face);
        }
		
		/**
		 * Removes a face object from the mesh object.
		 * 
		 * @param	face	The face object to be removed.
		 */
        public function removeFace(face:Face):void
        {
            _geometry.removeFace(face);
        }
		
		/**
		 * Inverts the geometry of all face objects.
		 * 
		 * @see away3d.code.base.Face#invert()
		 */
        public function invertFaces():void
        {
            _geometry.invertFaces();
        }
		
		/**
		 * Adds a segment object to the mesh object.
		 * 
		 * @param	segment	The segment object to be added.
		 */
        public function addSegment(segment:Segment):void
        {
            _geometry.addSegment(segment);
        }
		
		/**
		 * Removes a segment object from the mesh object.
		 * 
		 * @param	segment	The segment object to be removed.
		 */
        public function removeSegment(segment:Segment):void
        {
            _geometry.removeSegment(segment);
        }
        
		/**
		 * Divides all face object into 4 equal sized face objects.
		 * Used to segment a mesh in order to reduce affine persepective distortion.
		 * 
		 * @see away3d.primitives.SkyBox
		 */
        public function quarterFaces():void
        {
            _geometry.quarterFaces();
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
        	
        	if (this.session.view.camera.sceneTransformed || scene.updateSession[this.session]) {
        		_priArray = new Array();
	        	_dtStore = _dtStore.concat(_dtActive);
	        	_dtActive = new Array();
	            
	            geometry.update(projection.time);
				
	            _backmat = back || _triangleMaterial;
				
				for each (var vertex:Vertex in _geometry.vertices) {
					
					if (!(_screenVertex = screenVertices[vertex]))
						_screenVertex = screenVertices[vertex] = new ScreenVertex();
					
					vertex.project(_screenVertex, projection);
				}
				
	            for each (var face:Face in _geometry.faces)
	            {
	                if (!face._visible)
	                    continue;
					
					//project each Vertex to a ScreenVertex
					if (!(_tri = drawTriangles[face])) {
						_tri = drawTriangles[face] = new DrawTriangle();
						_tri.source = this;
						_tri.create = createDrawTriangle;
						_tri.face = face;
					}
					
					_tri.v0 = screenVertices[face._v0];
					_tri.v1 = screenVertices[face._v1];
					_tri.v2 = screenVertices[face._v2];					
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
	                //if (_tri.maxZ < 0)
	                //    continue;
					
					//determine if _triangle is facing towards or away from camera
	                _backface = _tri.area < 0;
					
					//if _triangle facing away, check for backface material
	                if (_backface) {
	                    if (!bothsides)
	                        continue;
	                    _tri.material = face._back;
	                    if (_tri.material == null)
	                    	_tri.material = face._material;
	                } else
	                    _tri.material = face._material;
					
					//determine the material of the _triangle
	                if (_tri.material == null)
	                    if (_backface)
	                        _tri.material = _backmat;
	                    else
	                        _tri.material = _triangleMaterial;
					
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
	                    _n01 = _geometry.neighbour01(face);
	                    if (_n01 == null || _n01.front(projection) <= 0)
	                    	consumer.primitive(createDrawSegment(outline, projection, _tri.v0, _tri.v1));
						
	                    _n12 = _geometry.neighbour12(face);
	                    if (_n12 == null || _n12.front(projection) <= 0)
	                    	consumer.primitive(createDrawSegment(outline, projection, _tri.v1, _tri.v2));
						
	                    _n20 = _geometry.neighbour20(face);
	                    if (_n20 == null || _n20.front(projection) <= 0)
	                    	consumer.primitive(createDrawSegment(outline, projection, _tri.v2, _tri.v0));
						
	                    if (_tri.material == null)
	                    	continue;
	                }
	                _tri.projection = projection;
	                _priArray.push(_tri);
	                consumer.primitive(_tri);
	            }
	            
	            for each (var segment:Segment in geometry.segments)
	            {
	            	if (!(_seg = drawSegments[segment])) {
						_seg = drawSegments[segment] = new DrawSegment();
						_seg.create = createDrawSegment;
						_seg.source = this;
	            	}
	            	
	            	_seg.v0 = screenVertices[segment._v0];
					_seg.v1 = screenVertices[segment._v1];
	    
	                if (!_seg.v0.visible)
	                    continue;
					
	                if (!_seg.v1.visible)
	                    continue;
					
	                _seg.calc();
					
	                if (_seg.maxZ < 0)
	                    continue;
					
	                _seg.material = segment.material || _segmentMaterial;
					
	                if (_seg.material == null)
	                    continue;
					
	                if (!_seg.material.visible)
	                    continue;
	                
	                _seg.projection = projection;
	                _priArray.push(_seg);
	                consumer.primitive(_seg);
	            }
	        } else {
	        	for each (_pri in _priArray)
	        		consumer.primitive(_pri);
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
            mesh.debugbb = debugbb;
			
			mesh.geometry = geometry.clone();
			
            return mesh;
        }
		
		/**
		 * Plays a sequence of frames
		 * 
		 * @param	sequence	The animationsequence to play
		 */
        public function play(sequence:AnimationSequence):void
        {
        	geometry.play(sequence);
        }
        
		/**
		 * Starts playing the animation at the specified frame.
		 * 
		 * @param	value		A number representing the frame number.
		 */
		public function gotoAndPlay(value:int):void
		{
			geometry.gotoAndPlay(value);
		}
		
		/**
		 * Brings the animation to the specifed frame and stops it there.
		 * 
		 * @param	value		A number representing the frame number.
		 */
		public function gotoAndStop(value:int):void
		{
			geometry.gotoAndStop(value);
		}
		
		/**
		 * Passes an array of animationsequence objects to be added to the animation.
		 * 
		 * @param	playlist				An array of animationsequence objects.
		 * @param	loopLast	[optional]	Determines whether the last sequence will loop. Defaults to false.
		 */
		public function setPlaySequences(playlist:Array, loopLast:Boolean = false):void
		{
			geometry.setPlaySequences(playlist, loopLast);
		}
		
		/**
		 * Default method for adding a sequencedone event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function addOnSequenceDone(listener:Function):void
        {
            geometry.addOnSequenceDone(listener);
        }
		
		/**
		 * Default method for removing a sequencedone event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function removeOnSequenceDone(listener:Function):void
        {
            geometry.removeOnSequenceDone(listener);
        }
		
		/**
		 * Default method for adding a cycle event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function addOnCycle(listener:Function):void
        {
			geometry.addOnCycle(listener);
        }
		
		/**
		 * Default method for removing a cycle event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function removeOnCycle(listener:Function):void
        {
			geometry.removeOnCycle(listener);
        }
 		
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

            for each (var face:Face in _geometry.faces)
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
				for each (f in _geometry.faces)
				
					auv.push((round)? refuvs[f._uv0].toFixed(4)+","+refuvs[f._uv1].toFixed(4)+","+refuvs[f._uv2].toFixed(4) : refuvs[f._uv0]+","+refuvs[f._uv1]+","+refuvs[f._uv2]);
				
				for(var i:int = 0; i< indexes.length;i++){
					ind = indexes[i];
					source += "\t\t\tf("+ind[0]+","+ind[1]+","+ind[2]+","+auv[i]+");\n";
				}
				
			} else{
				for each (f in _geometry.faces)
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
				
				for (var framename:String in geometry.framenames){
					tmpnames.push(framename);
				}
				
				tmpnames.sort(); 
				var fr:Frame;
				for (i = 0;i<tmpnames.length;i++){
					avp = new Array();
					fr = geometry.frames[geometry.framenames[tmpnames[i]]];
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

            for each (var face:Face in _geometry.faces)
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

            for each (var f:Face in _geometry.faces)
                result.appendChild(<face v0={refvertices[f._v0]} v1={refvertices[f._v1]} v2={refvertices[f._v2]} uv0={refuvs[f._uv0]} uv1={refuvs[f._uv1]} uv2={refuvs[f._uv2]}/>);

            return result;
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
			_geometry.updateVertex(v, x, y, z, refreshNormals);
		}
		
		
		/**
 		* Apply the local rotations to the geometry without altering the appearance of the mesh
 		*/
		public function applyRotations():void
		{
			_geometry.applyRotations(rotationX, rotationY, rotationZ);
			
            rotationX = 0;
            rotationY = 0;
            rotationZ = 0;    
		}
		
		/**
 		* Apply the given position to the geometry without altering the appearance of the mesh
 		*/
		public function applyPosition(dx:Number, dy:Number, dz:Number):void
		{
			_geometry.applyPosition(dx, dy, dz);
			var dV:Number3D = new Number3D(dx, dy, dz);
            dV.rotate(dV, _transform);
            dV.add(dV, position);
            moveTo(dV.x, dV.y, dV.z);  
		}
		
    }
}
