package away3d.primitives;

	import away3d.arcane;
    import away3d.core.base.*;
    
	use namespace arcane;
	
    /**
    * Creates a 3d wire cylinder primitive.
    */ 
    class WireCylinder extends AbstractWirePrimitive {
        public var height(getHeight, setHeight) : Float;
        public var radius(getRadius, setRadius) : Float;
        public var segmentsH(getSegmentsH, setSegmentsH) : Float;
        public var segmentsW(getSegmentsW, setSegmentsW) : Float;
        public var yUp(getYUp, setYUp) : Bool;
        
        var grid:Array<Dynamic>;
        var _radius:Float;
        var _height:Float;
        var _segmentsW:Int;
        var _segmentsH:Int;
        var _yUp:Bool;
        
        function buildWireCylinder(radius:Float, height:Float, segmentsW:Int, segmentsH:Int, yUp:Bool):Void
        {
            var i:Int;
            var j:Int;

            height /= 2;
            segmentsH += 2;

            grid = new Array(segmentsH + 1);

            var bottom:Vertex = yUp? createVertex(0, -height, 0) : createVertex(0, 0, -height);
            grid[0] = new Array(segmentsW);
            for (i = 0; i < segmentsW; i++) 
                grid[0][i] = bottom;

            for (j in 1...segmentsH)  
            { 
                var z:Int = -height + 2 * height * (j-1) / (segmentsH-2);

                grid[j] = new Array(segmentsW);
                for (i in 0...segmentsW) 
                { 
                    var verangle:Int = 2 * i / segmentsW * Math.PI;
                    var x:Int = radius * Math.sin(verangle);
                    var y:Int = radius * Math.cos(verangle);
                    
                    if (yUp)
                    	grid[j][i] = createVertex(y, z, x);
                    else
                    	grid[j][i] = createVertex(y, -x, z);
                }
            }

            var top:Vertex = yUp? createVertex(0, height, 0) : createVertex(0, 0, height);
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

                    addSegment(createSegment(a, d));
                    addSegment(createSegment(b, c));
                    if (j < segmentsH)  
                        addSegment(createSegment(a, b));
                }
        }
        
    	/**
    	 * Defines the radius of the wire cylinder. Defaults to 100.
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
    	 * Defines the height of the wire cylinder. Defaults to 200.
    	 */
    	public function getHeight():Float{
    		return _height;
    	}
    	
    	public function setHeight(val:Float):Float{
    		if (_height == val)
    			return;
    		
    		_height = val;
    		_primitiveDirty = true;
    		return val;
    	}
    	
    	/**
    	 * Defines the number of horizontal segments that make up the wire cylinder. Defaults to 8.
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
    	 * Defines the number of vertical segments that make up the wire cylinder. Defaults to 1.
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
    	 * Defines whether the coordinates of the wire cylinder points use a yUp orientation (true) or a zUp orientation (false). Defaults to true.
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
		 * Creates a new <code>WireCylinder</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(?init:Dynamic = null)
        {
            super(init);

            _radius = ini.getNumber("radius", 100, {min:0});
            _height = ini.getNumber("height", 200, {min:0});
            _segmentsW = ini.getInt("segmentsW", 8, {min:3});
            _segmentsH = ini.getInt("segmentsH", 1, {min:1});
			_yUp = ini.getBoolean("yUp", true);
			
			buildWireCylinder(_radius, _height, _segmentsW, _segmentsH, _yUp);
			
			type = "WireCylinder";
        	url = "primitive";
        }
        
		/**
		 * @inheritDoc
		 */
    	public override function buildPrimitive():Void
    	{
    		super.buildPrimitive();
    		
            buildWireCylinder(_radius, _height, _segmentsW, _segmentsH, _yUp);
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
