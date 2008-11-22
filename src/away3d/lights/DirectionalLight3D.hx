package away3d.lights;

    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.light.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.materials.ColorMaterial;
    import away3d.primitives.Sphere;
	
    /**
    * Lightsource that colors all shaded materials proportional to the dot product of the offset vector with the normal vector.
    * The scalar value of distance does not affect the resulting light intensity, it is calulated as if the
    * source is an infinite distance away with an infinite brightness.
    */
    class DirectionalLight3D extends Object3D, implements ILightProvider, implements IClonable {
        public var ambient(getAmbient, setAmbient) : Float;
        public var brightness(getBrightness, setBrightness) : Float;
        public var color(getColor, setColor) : Int;
        public var debug(getDebug, setDebug) : Bool;
        public var debugPrimitive(getDebugPrimitive, null) : Object3D
		;
        public var diffuse(getDiffuse, setDiffuse) : Float;
        public var specular(getSpecular, setSpecular) : Float;
        
        var _color:Int;
        var _red:Int;
        var _green:Int;
        var _blue:Int;
        var _ambient:Float;
        var _diffuse:Float;
        var _specular:Float;
        var _brightness:Float;
    	
    	var _colorDirty:Bool;
    	var _ambientDirty:Bool;
    	var _diffuseDirty:Bool;
    	var _specularDirty:Bool;
    	var _brightnessDirty:Bool;
		var _ls:DirectionalLight ;
		var _debugPrimitive:Sphere;
        var _debugMaterial:ColorMaterial;
        var _debug:Bool;
		
		/**
		 * Defines the color of the light object.
		 */
		public function getColor():Int{
			return _color;
		}
		
		public function setColor(val:Int):Int{
			_color = val;
			_red = (_color & 0xFF0000) >> 16;
            _green = (_color & 0xFF00) >> 8;
            _blue  = (_color & 0xFF);
            _colorDirty = true;
            _ambientDirty = true;
            _diffuseDirty = true;
            _specularDirty = true;
			return val;
		}
		
		/**
		 * Defines a coefficient for the ambient light intensity.
		 */
		public function getAmbient():Float{
			return _ambient;
		}
		public function setAmbient(val:Float):Float{
			if (val < 0)
				val  = 0;
			_ambient = val;
            _ambientDirty = true;
			return val;
		}
		
		/**
		 * Defines a coefficient for the diffuse light intensity.
		 */
		public function getDiffuse():Float{
			return _diffuse;
		}
		
		public function setDiffuse(val:Float):Float{
			if (val < 0)
				val  = 0;
			_diffuse = val;
            _diffuseDirty = true;
			return val;
		}
		
		/**
		 * Defines a coefficient for the specular light intensity.
		 */
		public function getSpecular():Float{
			return _specular;
		}
		
		public function setSpecular(val:Float):Float{
			if (val < 0)
				val  = 0;
			_specular = val;
            _specularDirty = true;
			return val;
		}
		
		//TODO: brightness on directional light needs implementing
		/**
		 * Defines a coefficient for the overall light intensity.
		 */
		public function getBrightness():Float{
			return _brightness;
		}
		
		public function setBrightness(val:Float):Float{
			_brightness = val;
            _brightnessDirty = true;
			return val;
		}
        
        /**
        * Toggles debug mode: light object is visualised in the scene.
        */
        public function getDebug():Bool{
        	return _debug;
        }
        
        public function setDebug(val:Bool):Bool{
        	_debug = val;
        	return val;
        }
        
		public function getDebugPrimitive():Object3D
		{
			if (!_debugPrimitive)
				_debugPrimitive = new Sphere();
			
			if (!_debugMaterial) {
				_debugMaterial = new ColorMaterial();
				_debugPrimitive.material = _debugMaterial;
			}
			
            _debugMaterial.color = color;
            
			return _debugPrimitive;
		}
		
		/**
		 * Creates a new <code>DirectionalLight3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(?init:Dynamic = null)
        {
            
            _ls = new DirectionalLight();
            super(init);
            
            color = ini.getColor("color", 0xFFFFFF);
            ambient = ini.getNumber("ambient", 0.5, {min:0, max:1});
            diffuse = ini.getNumber("diffuse", 0.5, {min:0, max:10});
            specular = ini.getNumber("specular", 1, {min:0, max:1});
            brightness = ini.getNumber("brightness", 1);
            debug = ini.getBoolean("debug", false);
            _ls.light = this;
            addOnTransformChange(_ls.updateDirection);
        }
        
		/**
		 * @inheritDoc
		 */
        public function light(consumeer:ILightConsumer):Void
        {
            //update color
			if (_colorDirty) {
				_ls.red = _red;
				_ls.green = _green;
				_ls.blue = _blue;
			}
        	
        	//update ambient diffuse
            if (_ambientDirty || _diffuseDirty || _brightnessDirty)
	        	_ls.updateAmbientDiffuseBitmap(ambient, diffuse);
        	
        	//update ambient
            if (_ambientDirty || _brightnessDirty) {
        		_ambientDirty = false;
	        	_ls.updateAmbientBitmap(ambient);
        	}
            
        	//update diffuse
        	if (_diffuseDirty || _brightnessDirty) {
        		_diffuseDirty = false;
	        	_ls.updateDiffuseBitmap(diffuse);
        	}
        	
        	//update specular
        	if (_specularDirty || _brightnessDirty) {
        		_specularDirty = false;
        		_ls.updateSpecularBitmap(specular);
        	}
        	
            consumeer.directionalLight(_ls);
            
            _colorDirty = false;
            _brightnessDirty = false;
        }
		
		/**
		 * Duplicates the light object's properties to another <code>DirectionalLight3D</code> object
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
        public override function clone(?object:Object3D = null):Object3D
        {
            var light:DirectionalLight3D = (cast( object, DirectionalLight3D)) || new DirectionalLight3D();
            super.clone(light);
            light.color = color;
            light.brightness = brightness;
            light.ambient = ambient;
            light.diffuse = diffuse;
            light.specular = specular;
            light.debug = debug;
            return light;
        }

    }
