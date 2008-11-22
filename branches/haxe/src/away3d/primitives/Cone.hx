package away3d.primitives;

	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.utils.*;
    
	use namespace arcane;
	
    /**
    * Creates a 3d cone primitive.
    */ 
    class Cone extends AbstractPrimitive {
        public var height(getHeight, setHeight) : Float;
        public var openEnded(getOpenEnded, setOpenEnded) : Bool;
        public var radius(getRadius, setRadius) : Float;
        public var segmentsH(getSegmentsH, setSegmentsH) : Float;
        public var segmentsW(getSegmentsW, setSegmentsW) : Float;
        public var yUp(getYUp, setYUp) : Bool;
        
        var grid:Array<Dynamic>;
        var jMin:Int;
        var _radius:Float;
        var _height:Float;
        var _segmentsW:Int;
        var _segmentsH:Int;
        var _openEnded:Bool;
        var _yUp:Bool;
        
        function buildCone(radius:Float, height:Float, segmentsW:Int, segmentsH:Int, openEnded:Bool, yUp:Bool):Void
        {
            var i:Int;
            var j:Int;

            height /= 2;

            grid = new Array();
			
			
			if (!openEnded) {
				jMin = 1;
	            segmentsH += 1;
	            var bottom:Vertex = yUp? createVertex(0, -height, 0) : createVertex(0, 0, -height);
	            grid[0] = new Array(segmentsW);
	            for (i = 0; i < segmentsW; i++) 
	                grid[0][i] = bottom;
			} else {
				jMin = 0;
			}
			
            j = jMin; 
               while (j < segmentsH)  
            { 
                var z:Int = -height + 2 * height * (j-jMin) / (segmentsH-jMin);

                grid[j] = new Array(segmentsW);
                for (i in 0...segmentsW) 
                { 
                    var verangle:Int = 2 * i / segmentsW * Math.PI;
                    var ringradius:Int = radius * (segmentsH-j)/(segmentsH-jMin);
                    var x:Int = ringradius * Math.sin(verangle);
                    var y:Int = ringradius * Math.cos(verangle);
                    
                    if (yUp)
                    	grid[j][i] = createVertex(y, z, x);
                    else
                    	grid[j][i] = createVertex(y, -x, z);
                }
            	j++; 
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
                    if (j > jMin)                
                        addFace(createFace(a,c,d, null, uva,uvc,uvd));
                }
        }
        
    	/**
    	 * Defines the radius of the cone base. Defaults to 100.
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
    	 * Defines the height of the cone. Defaults to 200.
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
    	 * Defines the number of horizontal segments that make up the cone. Defaults to 8.
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
    	 * Defines the number of vertical segments that make up the cone. Defaults to 1.
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
    	 * Defines whether the end of the cone is left open (true) or closed (false). Defaults to false.
    	 */
    	public function getOpenEnded():Bool{
    		return _openEnded;
    	}
    	
    	public function setOpenEnded(val:Bool):Bool{
    		if (_openEnded == val)
    			return;
    		
    		_openEnded = val;
    		_primitiveDirty = true;
    		return val;
    	}
    	
    	/**
    	 * Defines whether the coordinates of the cone points use a yUp orientation (true) or a zUp orientation (false). Defaults to true.
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
		 * Creates a new <code>Cone</code> object.
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
			_openEnded = ini.getBoolean("openEnded", false);
			_yUp = ini.getBoolean("yUp", true);
			
			buildCone(_radius, _height, _segmentsW, _segmentsH, _openEnded, _yUp);
			
            type = "Cone";
        	url = "primitive";
        }
        
		/**
		 * @inheritDoc
		 */
    	public override function buildPrimitive():Void
    	{
    		super.buildPrimitive();
    		
            buildCone(_radius, _height, _segmentsW, _segmentsH, _openEnded, _yUp);
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
