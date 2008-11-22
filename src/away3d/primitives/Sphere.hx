package away3d.primitives;

	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.utils.*;
    
	use namespace arcane;
	
    /**
    * Creates a 3d sphere primitive.
    */ 
    class Sphere extends AbstractPrimitive {
        public var radius(getRadius, setRadius) : Float;
        public var segmentsH(getSegmentsH, setSegmentsH) : Float;
        public var segmentsW(getSegmentsW, setSegmentsW) : Float;
        public var yUp(getYUp, setYUp) : Bool;
        
        var grid:Array<Dynamic>;
        var _radius:Float;
        var _segmentsW:Int;
        var _segmentsH:Int;
        var _yUp:Bool;

        function buildSphere(radius:Float, segmentsW:Int, segmentsH:Int, yUp:Bool):Void
        {
            var i:Int;
            var j:Int;

            grid = new Array(segmentsH + 1);

            var bottom:Vertex = yUp? createVertex(0, -radius, 0) : createVertex(0, 0, -radius);
            grid[0] = new Array(segmentsW);
            for (i = 0; i < segmentsW; i++) 
                grid[0][i] = bottom;

            for (j in 1...segmentsH)  
            { 
                var horangle:Int = j / segmentsH * Math.PI;
                var z:Int = -radius * Math.cos(horangle);
                var ringradius:Int = radius * Math.sin(horangle);

                grid[j] = new Array(segmentsW);
                for (i in 0...segmentsW) 
                { 
                    var verangle:Int = 2 * i / segmentsW * Math.PI;
                    var x:Int = ringradius * Math.sin(verangle);
                    var y:Int = ringradius * Math.cos(verangle);
                    
                    if (yUp)
                    	grid[j][i] = createVertex(y, z, x);
                    else
                    	grid[j][i] = createVertex(y, -x, z);
                }
            }

            var top:Vertex = yUp? createVertex(0, radius, 0) : createVertex(0, 0, radius);
            grid[segmentsH] = new Array(segmentsW);
            for (i = 0; i < segmentsW; i++) 
                grid[segmentsH][i] = top;

            for (j = 1; j <= segmentsH; j++) 
                for (i in 0...segmentsW) 
                {
                    var a:Vertex = grid[j][i];
                    var b:Vertex = grid[j][(i-1+segmentsW) % segmentsW];
                    var c:Vertex = grid[j-1][(i-1+segmentsW) % segmentsW];
                    var d:Vertex = grid[j-1][i];
					
					var i2:Int = i;
					if (i == 0) i2 = segmentsW;
					
                    var vab:Int = j / segmentsH;
                    var vcd:Int = (j-1) / segmentsH;
                    var uad:Int = i2 / segmentsW;
                    var ubc:Int = (i2-1) / segmentsW;
                    var uva:UV = createUV(uad,vab);
                    var uvb:UV = createUV(ubc,vab);
                    var uvc:UV = createUV(ubc,vcd);
                    var uvd:UV = createUV(uad,vcd);

                    if (j < segmentsH)  
                        addFace(createFace(a,b,c, null, uva,uvb,uvc));
                    if (j > 1)                
                        addFace(createFace(a,c,d, null, uva,uvc,uvd));
                }
        }
        
    	/**
    	 * Defines the radius of the sphere. Defaults to 100.
    	 */
    	public function getRadius():Float{
    		return _radius;
    	}
    	
    	public function setRadius(val:Float):Float{
    		if (_radius == val)
    			return;
    		
    		_radius = val;
    		_primitiveDirty = true;
    		return val;
    	}
    	
    	/**
    	 * Defines the number of horizontal segments that make up the sphere. Defaults to 8.
    	 */
    	public function getSegmentsW():Float{
    		return _segmentsW;
    	}
    	
    	public function setSegmentsW(val:Float):Float{
    		if (_segmentsW == val)
    			return;
    		
    		_segmentsW = val;
    		_primitiveDirty = true;
    		return val;
    	}
    	
    	/**
    	 * Defines the number of vertical segments that make up the sphere. Defaults to 1.
    	 */
    	public function getSegmentsH():Float{
    		return _segmentsH;
    	}
    	
    	public function setSegmentsH(val:Float):Float{
    		if (_segmentsH == val)
    			return;
    		
    		_segmentsH = val;
    		_primitiveDirty = true;
    		return val;
    	}
    	
    	/**
    	 * Defines whether the coordinates of the sphere points use a yUp orientation (true) or a zUp orientation (false). Defaults to true.
    	 */
    	public function getYUp():Bool{
    		return _yUp;
    	}
    	
    	public function setYUp(val:Bool):Bool{
    		if (_yUp == val)
    			return;
    		
    		_yUp = val;
    		_primitiveDirty = true;
    		return val;
    	}
		
		/**
		 * Creates a new <code>Sphere</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(?init:Dynamic = null)
        {
            super(init);
            
            _radius = ini.getNumber("radius", 100, {min:0});
            _segmentsW = ini.getInt("segmentsW", 8, {min:3});
            _segmentsH = ini.getInt("segmentsH", 6, {min:2});
			_yUp = ini.getBoolean("yUp", true);
			
			buildSphere(_radius, _segmentsW, _segmentsH, _yUp);
			
			type = "Sphere";
        	url = "primitive";
        }
        
		/**
		 * @inheritDoc
		 */
    	public override function buildPrimitive():Void
    	{
    		super.buildPrimitive();
    		
			buildSphere(_radius, _segmentsW, _segmentsH, _yUp);
    	}
        
		/**
		 * Returns the vertex object specified by the grid position of the mesh.
		 * 
		 * @param	w	The horizontal position on the primitive mesh.
		 * @param	h	The vertical position on the primitive mesh.
		 */
        public function vertex(w:Int, h:Int):Vertex
        {
            return grid[h][w];
        }
    }
