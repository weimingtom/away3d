package away3d.primitives;

	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.materials.*;
	import away3d.primitives.data.*;
    
	use namespace arcane;
	
    /**
    * Creates a 3d cube primitive.
    */ 
    class Cube extends AbstractPrimitive {	
    	public var cubeMaterials(getCubeMaterials, setCubeMaterials) : CubeMaterialsData;	
    	public var depth(getDepth, setDepth) : Float;	
    	public var height(getHeight, setHeight) : Float;	
    	public var width(getWidth, setWidth) : Float;	
    		
    	var _width:Float;
    	var _height:Float;
    	var _depth:Float;
    	var _cubeMaterials:CubeMaterialsData;
    	var _leftFaces:Array<Dynamic> ;
    	var _rightFaces:Array<Dynamic> ;
    	var _bottomFaces:Array<Dynamic> ;
    	var _topFaces:Array<Dynamic> ;
    	var _frontFaces:Array<Dynamic> ;
    	var _backFaces:Array<Dynamic> ;
    	var _cubeFace:Face;
    	var _cubeFaceArray:Array<Dynamic>;
    	var _umin:Float;
    	var _umax:Float;
    	var _vmin:Float;
    	var _vmax:Float;
    	
    	function onCubeMaterialChange(event:MaterialEvent):Void
    	{
    		switch (event.extra) {
    			case "left":
    				_cubeFaceArray = _leftFaces;
    				break;
    			case "right":
    				_cubeFaceArray = _rightFaces;
    				break;
    			case "bottom":
    				_cubeFaceArray = _bottomFaces;
    				break;
    			case "top":
    				_cubeFaceArray = _topFaces;
    				break;
    			case "front":
    				_cubeFaceArray = _frontFaces;
    				break;
    			case "back":
    				_cubeFaceArray = _backFaces;
    				break;
    			default:
    		}
    		
    		for each (_cubeFace in _cubeFaceArray)
    			_cubeFace.material = cast( event.material, ITriangleMaterial);
    	}
    	
        function buildCube(width:Float, height:Float, depth:Float):Void
        {

            var v000:Vertex = createVertex(-width/2, -height/2, -depth/2); 
            var v001:Vertex = createVertex(-width/2, -height/2, +depth/2); 
            var v010:Vertex = createVertex(-width/2, +height/2, -depth/2); 
            var v011:Vertex = createVertex(-width/2, +height/2, +depth/2); 
            var v100:Vertex = createVertex(+width/2, -height/2, -depth/2); 
            var v101:Vertex = createVertex(+width/2, -height/2, +depth/2); 
            var v110:Vertex = createVertex(+width/2, +height/2, -depth/2); 
            var v111:Vertex = createVertex(+width/2, +height/2, +depth/2); 

            var uva:UV = createUV(_umax, _vmax);
            var uvb:UV = createUV(_umin, _vmax);
            var uvc:UV = createUV(_umin, _vmin);
            var uvd:UV = createUV(_umax, _vmin);
            
            //left face
            addFace(_leftFaces[0] = createFace(v000, v010, v001, _cubeMaterials.left, uvd, uva, uvc));
            addFace(_leftFaces[1] = createFace(v010, v011, v001, _cubeMaterials.left, uva, uvb, uvc));
            
            //right face
            addFace(_rightFaces[0] = createFace(v100, v101, v110, _cubeMaterials.right, uvc, uvd, uvb));
            addFace(_rightFaces[1] = createFace(v110, v101, v111, _cubeMaterials.right, uvb, uvd, uva));
            
            //bottom face
            addFace(_bottomFaces[0] = createFace(v000, v001, v100, _cubeMaterials.bottom, uvb, uvc, uva));
            addFace(_bottomFaces[1] = createFace(v001, v101, v100, _cubeMaterials.bottom, uvc, uvd, uva));
            
            //top face
            addFace(_topFaces[0] = createFace(v010, v110, v011, _cubeMaterials.top, uvc, uvd, uvb));
            addFace(_topFaces[1] = createFace(v011, v110, v111, _cubeMaterials.top, uvb, uvd, uva));
            
            //front face
            addFace(_frontFaces[0] = createFace(v000, v100, v010, _cubeMaterials.front, uvc, uvd, uvb));
            addFace(_frontFaces[1] = createFace(v100, v110, v010, _cubeMaterials.front, uvd, uva, uvb));
            
            //back face
            addFace(_backFaces[0] = createFace(v001, v011, v101, _cubeMaterials.back, uvd, uva, uvc));
            addFace(_backFaces[1] = createFace(v101, v011, v111, _cubeMaterials.back, uvc, uva, uvb));
        }
        
    	/**
    	 * Defines the width of the cube. Defaults to 100.
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
    	 * Defines the height of the cube. Defaults to 100.
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
    	 * Defines the depth of the cube. Defaults to 100.
    	 */
    	public function getDepth():Float{
    		return _depth;
    	}
    	
    	public function setDepth(val:Float):Float{
    		if (_depth == val)
    			return;
    		
    		_depth = val;
    		_primitiveDirty = true;
    		return val;
    	}
    	
    	/**
    	 * Defines the face materials of the cube.
    	 */
    	public function getCubeMaterials():CubeMaterialsData{
    		return _cubeMaterials;
    	}
    	
    	public function setCubeMaterials(val:CubeMaterialsData):CubeMaterialsData{
    		if (_cubeMaterials == val)
    			return;
    		
    		if (_cubeMaterials)
    			_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
    		
    		_cubeMaterials = val;
    		
    		_cubeMaterials.addOnMaterialChange(onCubeMaterialChange)
    		return val;
    	}
		/**
		 * Creates a new <code>Cube</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(?init:Dynamic = null)
        {
            
            _leftFaces = [];
            _rightFaces = [];
            _bottomFaces = [];
            _topFaces = [];
            _frontFaces = [];
            _backFaces = [];
            super(init);
            
            _width  = ini.getNumber("width",  100, {min:0});
            _height = ini.getNumber("height", 100, {min:0});
            _depth  = ini.getNumber("depth",  100, {min:0});
            _umin = ini.getNumber("umin", 0, {min:0, max:1});
            _umax = ini.getNumber("umax", 1, {min:0, max:1});
            _vmin = ini.getNumber("vmin", 0, {min:0, max:1});
            _vmax = ini.getNumber("vmax", 1, {min:0, max:1});
            _cubeMaterials  = ini.getCubeMaterials("faces");
            
            if (!_cubeMaterials)
            	_cubeMaterials  = ini.getCubeMaterials("cubeMaterials");
            	
            if (!_cubeMaterials)
            	_cubeMaterials = new CubeMaterialsData();
            
    		_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
    		
    		buildCube(_width, _height, _depth);
    		
    		type = "Cube";
        	url = "primitive";
        }
        
		/**
		 * @inheritDoc
		 */
    	public override function buildPrimitive():Void
    	{
    		super.buildPrimitive();
    		
             buildCube(_width, _height, _depth);
    	}
    } 
