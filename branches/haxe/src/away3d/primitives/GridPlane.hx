package away3d.primitives;

	import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.utils.*;
    
	use namespace arcane;
	
    /**
    * Creates a 3d grid primitive.
    */ 
    class GridPlane extends AbstractWirePrimitive {
    	public var height(getHeight, setHeight) : Float;
    	public var segmentsH(getSegmentsH, setSegmentsH) : Float;
    	public var segmentsW(getSegmentsW, setSegmentsW) : Float;
    	public var width(getWidth, setWidth) : Float;
    	public var yUp(getYUp, setYUp) : Bool;
    	
    	var _width:Float;
        var _height:Float;
        var _segmentsW:Int;
        var _segmentsH:Int;
        var _yUp:Bool;
        
        function buildPlane(width:Float, height:Float, segmentsW:Int, segmentsH:Int, yUp:Bool):Void
        {
        	var i:Int;
        	var j:Int;
        	
        	if (yUp) {
	            for (i = 0; i <= segmentsW; i++)
	                addSegment(createSegment(createVertex((i/segmentsW - 0.5)*width, 0, -0.5*height), createVertex((i/segmentsW - 0.5)*width, 0, 0.5*height)));
	
	            for (j = 0; j <= segmentsH; j++)
	                addSegment(createSegment(createVertex(-0.5*width, 0, (j/segmentsH - 0.5)*height), createVertex(0.5*width, 0, (j/segmentsH - 0.5)*height)));
        	} else {
        		for (i = 0; i <= segmentsW; i++)
	                addSegment(createSegment(createVertex((i/segmentsW - 0.5)*width, -0.5*height, 0), createVertex((i/segmentsW - 0.5)*width, 0.5*height, 0)));
	
	            for (j = 0; j <= segmentsH; j++)
	                addSegment(createSegment(createVertex(-0.5*width, (j/segmentsH - 0.5)*height, 0), createVertex(0.5*width, (j/segmentsH - 0.5)*height, 0)));
	       
        	}
		}
		
    	/**
    	 * Defines the width of the grid. Defaults to 100.
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
    	 * Defines the height of the grid. Defaults to 100.
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
    	 * Defines the number of horizontal segments that make up the grid. Defaults to 1.
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
    	 * Defines the number of vertical segments that make up the grid. Defaults to 1.
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
    	 * Defines whether the coordinates of the grid points use a yUp orientation (true) or a zUp orientation (false). Defaults to true.
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
		 * Creates a new <code>GridPlane</code> object.
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
    		
			buildPlane(_width, _height, _segmentsW, _segmentsH, _yUp);
			
	   		type = "GridPlane";
        	url = "primitive";
        }
		
		/**
		 * @inheritDoc
		 */
    	public override function buildPrimitive():Void
    	{
    		super.buildPrimitive();
    		
            buildPlane(_width, _height, _segmentsW, _segmentsH, _yUp);
    	}
    }
