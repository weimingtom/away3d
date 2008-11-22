package away3d.materials;

	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	use namespace arcane;
	
	/**
	 * Color material with environment shading.
	 */
	class EnviroColorMaterial extends EnviroShader, implements ITriangleMaterial {
		public var color(getColor, setColor) : UInt;
		public var reflectiveness(null, setReflectiveness) : Float;
		
		var _color:UInt;
		var _red:Float;
		var _green:Float;
		var _blue:Float;
		var _colorMap:BitmapData;
		
        function setColorTranform():Void
        {
            _colorTransform = new ColorTransform(_red*_reflectiveness, _green*_reflectiveness, _blue*_reflectiveness, 1, (1-_reflectiveness)*_red*255, (1-_reflectiveness)*_green*255, (1-_reflectiveness)*_blue*255, 0);
            _colorMap = _bitmap.clone();
            _colorMap.colorTransform(_colorMap.rect, _colorTransform);
        }
        
        /**
        * Defines the color of the material.
        */
        public function getColor():UInt{
            return _color;
        }
        
		public function setColor(val:UInt):UInt{
            _color = val;
            _red = ((_color & 0xFF0000) >> 16)/255;
            _green = ((_color & 0x00FF00) >> 8)/255;
            _blue = (_color & 0x0000FF)/255;
            setColorTranform();
        	return val;
           }
        
		/**
		 * @inheritDoc
		 */
        public override function setReflectiveness(val:Float):Float{
            _reflectiveness = val;
            setColorTranform();
        	return val;
           }
		
		/**
		 * Creates a new <code>EnviroColorMaterial</code> object.
		 * 
		 * @param	color				A string, hex value or colorname representing the color of the material.
		 * @param	enviroMap			The bitmapData object to be used as the material's environment map.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function new(color:Dynamic, enviroMap:BitmapData, ?init:Dynamic = null)
		{            
			super(enviroMap, init);
			
            this.color = Cast.trycolor(color);
		}
    	
    	/**
    	 * Sends the material data coupled with data from the DrawTriangle primitive to the render session.
    	 */
		public function renderTriangle(tri:DrawTriangle):Void
		{
			tri.source.session.renderTriangleBitmap(_colorMap, getMapping(cast( tri.source, Mesh), tri.face), tri.v0, tri.v1, tri.v2, smooth, false);
			
			if (debug)
                tri.source.session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
		}
	}
