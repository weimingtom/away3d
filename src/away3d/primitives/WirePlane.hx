package away3d.primitives;

	import away3d.arcane;
	import away3d.core.base.*;
    
	use namespace arcane;
	
    /**
    * Creates a 3d wire plane primitive.
    */ 
    class WirePlane extends AbstractWirePrimitive {
        public var height(getHeight, setHeight) : Float;
        public var segmentsH(getSegmentsH, setSegmentsH) : Float;
        public var segmentsW(getSegmentsW, setSegmentsW) : Float;
        public var width(getWidth, setWidth) : Float;
        public var yUp(getYUp, setYUp) : Bool;
        
        var grid:Array<Dynamic>;
    	var _width:Float;
        var _height:Float;
        var _segmentsW:Int;
        var _segmentsH:Int;
        var _yUp:Bool;
        
        function buildWirePlane(width:Float, height:Float, segmentsW:Int, segmentsH:Int, yUp:Bool):Void
        {
            var i:Int;
            var j:Int;

            grid = new Array(segmentsW+1);
            i = 0;
               while (i <= segmentsW)
            {
                grid[i] = new Array(segmentsH+1);
                j = 0;
                while (j <= segmentsH) {
                	if (yUp)
                    	grid[i][j] = createVertex((i / segmentsW - 0.5) * width, 0, (j / segmentsH - 0.5) * height);
                    else
                    	grid[i][j] = createVertex((i / segmentsW - 0.5) * width, (j / segmentsH - 0.5) * height, 0);
                	j++;
                }
            	i++;
               }

            for (i = 0; i < segmentsW; i++)
                for (j = 0; j < segmentsH + 1; j++)
                    addSegment(createSegment(grid[i][j], grid[i+1][j]));

            for (i = 0; i < segmentsW + 1; i++)
                for (j = 0; j < segmentsH; j++)
                    addSegment(createSegment(grid[i][j], grid[i][j+1]));
					

        }
        
    	/**
    	 * Defines the width of the wire plane. Defaults to 100.
    	 */
    	public function getWidth():Float{
    		return _width;
    	}
    	
    	public function setWidth(val:Float):Float{
    		if (_width == val)
    			return;
    		
    		_width = val;
    		_primitiveDirty = true;
    		return val;
    	}
    	
    	/**
    	 * Defines the height of the wire plane. Defaults to 100.
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
    	 * Defines the number of horizontal segments that make up the wire plane. Defaults to 1.
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
    	 * Defines the number of vertical segments that make up the wire plane. Defaults to 1.
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
    	 * Defines whether the coordinates of the wire plane points use a yUp orientation (true) or a zUp orientation (false). Defaults to true.
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
		 * Creates a new <code>buildWirePlane</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */

        public function new(?init:Dynamic = null)
        {
            super(init);

            _width = ini.getNumber("width", 100, {min:0});
            _height = ini.getNumber("height", 100, {min:0});
            var segments:Int = ini.getInt("segments", 1, {min:1});
            _segmentsW = ini.getInt("segmentsW", segments, {min:1});
            _segmentsH = ini.getInt("segmentsH", segments, {min:1});
    		_yUp = ini.getBoolean("yUp", true);
    		
            buildWirePlane(_width, _height, _segmentsW, _segmentsH, _yUp);
            
			type = "WirePlane";
        	url = "primitive";
        }
    	
		/**
		 * @inheritDoc
		 */
    	public override function buildPrimitive():Void
    	{
    		super.buildPrimitive();
    		
            buildWirePlane(_width, _height, _segmentsW, _segmentsH, _yUp);
    	}
        
		/**
		 * Returns the vertex object specified by the grid position of the mesh.
		 * 
		 * @param	w	The horizontal position on the primitive mesh.
		 * @param	h	The vertical position on the primitive mesh.
		 */
        public function vertex(i:Int, j:Int):Vertex
        {
            return grid[i][j];
        }
    }
