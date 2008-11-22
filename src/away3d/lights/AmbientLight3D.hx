package away3d.lights;

    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.light.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.materials.*;
    import away3d.primitives.*;
	
    /**
    * Lightsource that colors all shaded materials evenly from any angle
    */
    class AmbientLight3D extends Object3D, implements ILightProvider, implements IClonable {
        public var ambient(getAmbient, setAmbient) : Float;
        public var color(getColor, setColor) : Int;
        public var debug(getDebug, setDebug) : Bool;
        public var debugPrimitive(getDebugPrimitive, null) : Object3D
		;
        
        var _color:Int;
        var _red:Int;
        var _green:Int;
        var _blue:Int;
        var _ambient:Float;
		var _colorDirty:Bool;
    	var _ambientDirty:Bool;
		var _ls:AmbientLight ;
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
			return val;
		}
		
		/**
		 * Defines a coefficient for the ambient light intensity.
		 */
		public function getAmbient():Float{
			return _ambient;
		}
    	
		public function setAmbient(val:Float):Float{
			_ambient = val;
            _ambientDirty = true;
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
		 * Creates a new <code>AmbientLight3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(?init:Dynamic = null)
        {
            
            _ls = new AmbientLight();
            super(init);
            
            color = ini.getColor("color", 0xFFFFFF);
            ambient = ini.getNumber("ambient", 0.5, {min:0, max:1});
            debug = ini.getBoolean("debug", false);
        }
        
		/**
		 * @inheritDoc
		 */
        public function light(consumer:ILightConsumer):Void
        {
           //update color
			if (_colorDirty) {
				_ls.red = _red;
				_ls.green = _green;
				_ls.blue = _blue;
	            _colorDirty = false;
			}
        	
        	//update ambient
            if (_ambientDirty) {
        		_ambientDirty = false;
	        	_ls.updateAmbientBitmap(_ambient);
        	}
        	
            consumer.ambientLight(_ls);
        }
		
		/**
		 * Duplicates the light object's properties to another <code>AmbientLight3D</code> object
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
        public override function clone(?object:Object3D = null):Object3D
        {
            var light:AmbientLight3D = (cast( object, AmbientLight3D)) || new AmbientLight3D();
            super.clone(light);
            light.color = color;
            light.ambient = ambient;
            light.debug = debug;
            return light;
        }

    }
