package away3d.core.base;

    /**
    * Keyframe animation morpher
    */
    class Morpher extends Object3D {
        
        var weight:Float;
        var vertices:Mesh;
    	var _vertices:Array<Dynamic>;
    	var _verticesComp:Array<Dynamic>;
		/**
		 * Creates a new <code>Morpher</code> object.
		 *
		 * @param	vertices	A mesh object used to define the starting vertices.
		 */
        public function new(vertices:Mesh)
        {
            this.vertices = vertices;
        }
		
		/**
		 * resets all vertex objects to 0,0,0
		 */
        public function start():Void
        {
            weight = 0;
            _vertices = vertices.geometry.vertices;
            for (v in _vertices)
            {
                v.reset();
            }
        }
		
		/**
		 * interpolates the vertex objects position values between the current vertex positions and the external vertex positions
		 * 
		 * @param	comp	The external mesh used for interpolating values
		 * @param	k		The increment used on the weighting value 
		 */
        public function mix(comp:Mesh, k:Float):Void
        {
            weight += k;
            _vertices = vertices.geometry.vertices;
            _verticesComp = comp.geometry.vertices;
            
            var length:Int = _vertices.length;
            for (i in 0...length)
            {
                _vertices[i].x += _verticesComp[i].x * k;
                _vertices[i].y += _verticesComp[i].y * k;
                _vertices[i].z += _verticesComp[i].z * k;
            }
        }
		
		/**
		 * resets all vertex objects to the external mesh positions
		 * 
		 * @param	comp	The external mesh used for vertex values
		 */
        public function finish(comp:Mesh):Void
        {
            mix(comp, 1 - weight);
            weight = 1;
        }
    }
