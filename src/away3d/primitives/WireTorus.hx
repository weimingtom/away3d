package away3d.primitives;

	import away3d.arcane;
    import away3d.core.base.*;
    
	use namespace arcane;
	
    /**
    * Creates a 3d wire torus primitive.
    */ 
    class WireTorus extends AbstractWirePrimitive {
        public var radius(getRadius, setRadius) : Float;
        public var segmentsR(getSegmentsR, setSegmentsR) : Float;
        public var segmentsT(getSegmentsT, setSegmentsT) : Float;
        public var tube(getTube, setTube) : Float;
        public var yUp(getYUp, setYUp) : Bool;
        
        var grid:Array<Dynamic>;
        var _radius:Float;
        var _tube:Float;
        var _segmentsR:Int;
        var _segmentsT:Int;
        var _yUp:Bool;
        
        function buildWireTorus(radius:Float, tube:Float, segmentsR:Int, segmentsT:Int, yUp:Bool):Void
        {
            var i:Int;
            var j:Int;

            grid = new Array(segmentsR);
            for (i in 0...segmentsR)
            {
                grid[i] = new Array(segmentsT);
                for (j in 0...segmentsT)
                {
                    var u:Int = i / segmentsR * 2 * Math.PI;
                    var v:Int = j / segmentsT * 2 * Math.PI;
                    
                    if (yUp)
                    	grid[i][j] = createVertex((radius + tube*Math.cos(v))*Math.cos(u), tube*Math.sin(v), (radius + tube*Math.cos(v))*Math.sin(u));
                    else
                    	grid[i][j] = createVertex((radius + tube*Math.cos(v))*Math.cos(u), -(radius + tube*Math.cos(v))*Math.sin(u), tube*Math.sin(v));
                }
            }

            for (i = 0; i < segmentsR; i++)
                for (j in 0...segmentsT)
                {
                    addSegment(createSegment(grid[i][j], grid[(i+1) % segmentsR][j]));
                    addSegment(createSegment(grid[i][j], grid[i][(j+1) % segmentsT]));
                }
				
			type = "WireTorus";
        	url = "primitive";
				
        }
        
    	/**
    	 * Defines the overall radius of the wire torus. Defaults to 100.
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
    	 * Defines the tube radius of the wire torus. Defaults to 40.
    	 */
    	public function getTube():Float{
    		return _tube;
    	}
    	
    	public function setTube(val:Float):Float{
    		if (_tube == val)
    			return;
    		
    		_tube = val;
    		_primitiveDirty = true;
    		return val;
    	}
    	
    	/**
    	 * Defines the number of radial segments that make up the wire torus. Defaults to 8.
    	 */
    	public function getSegmentsR():Float{
    		return _segmentsR;
    	}
    	
    	public function setSegmentsR(val:Float):Float{
    		if (_segmentsR == val)
    			return;
    		
    		_segmentsR = val;
    		_primitiveDirty = true;
    		return val;
    	}
    	
    	/**
    	 * Defines the number of tubular segments that make up the wire torus. Defaults to 6.
    	 */
    	public function getSegmentsT():Float{
    		return _segmentsT;
    	}
    	
    	public function setSegmentsT(val:Float):Float{
    		if (_segmentsT == val)
    			return;
    		
    		_segmentsT = val;
    		_primitiveDirty = true;
    		return val;
    	}
    	
    	/**
    	 * Defines whether the coordinates of the wire torus points use a yUp orientation (true) or a zUp orientation (false). Defaults to true.
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
		 * Creates a new <code>WireTorus</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(?init:Dynamic = null)
        {
            super(init);

            _radius = ini.getNumber("radius", 100, {min:0});
            _tube = ini.getNumber("tube", 40, {min:0, max:radius});
            _segmentsR = ini.getInt("segmentsR", 8, {min:3});
            _segmentsT = ini.getInt("segmentsT", 6, {min:3});
			_yUp = ini.getBoolean("yUp", true);
			
			buildWireTorus(_radius, _tube, _segmentsR, _segmentsT, _yUp);
			
			type = "WireTorus";
        	url = "primitive";
        }
        
		/**
		 * @inheritDoc
		 */
    	public override function buildPrimitive():Void
    	{
    		super.buildPrimitive();
    		
            buildWireTorus(_radius, _tube, _segmentsR, _segmentsT, _yUp);
    	}
        
		/**
		 * Returns the vertex object specified by the grid position of the mesh.
		 * 
		 * @param	r	The radial position on the primitive mesh.
		 * @param	t	The tubular position on the primitive mesh.
		 */
        public function vertex(r:Int, t:Int):Vertex
        {
            return grid[t][r];
        }
    }
