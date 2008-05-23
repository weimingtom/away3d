package away3d.lights
{
    import away3d.core.draw.*;
    import away3d.core.base.*;
    import away3d.core.light.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
	
    /**
    * Lightsource that colors all shaded materials evenly from any angle
    */
    public class AmbientLight3D extends Object3D implements ILightProvider, IPrimitiveProvider, IClonable
    {
        private var _color:int;
        private var _red:int;
        private var _green:int;
        private var _blue:int;
        private var _ambient:Number;
		private var _colorDirty:Boolean;
    	private var _ambientDirty:Boolean;
		private var _ls:AmbientLight = new AmbientLight();
    	
        //TODO: add debug graphics for ambient light
        /**
        * Toggles debug mode: light object is visualised in the scene.
        */
        public var debug:Boolean;
		
		/**
		 * Defines the color of the light object.
		 */
		public function get color():int
		{
			return _color;
		}
		
		public function set color(val:int):void
		{
			_color = val;
			_red = (_color & 0xFF0000) >> 16;
            _green = (_color & 0xFF00) >> 8;
            _blue  = (_color & 0xFF);
            _colorDirty = true;
		}
		
		/**
		 * Defines a coefficient for the ambient light intensity.
		 */
		public function get ambient():Number
		{
			return _ambient;
		}
    	
		public function set ambient(val:Number):void
		{
			_ambient = val;
            _ambientDirty = true;
		}
		
		/**
		 * Creates a new <code>AmbientLight3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function AmbientLight3D(init:Object = null)
        {
            super(init);
            
            color = ini.getColor("color", 0xFFFFFF);
            ambient = ini.getNumber("ambient", 0.5, {min:0, max:1});
            debug = ini.getBoolean("debug", false);
            _ls.light = this;
        }
        
		/**
		 * @inheritDoc
		 */
        public function light(consumer:ILightConsumer):void
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
		 * @inheritDoc
		 */
        override public function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void
        {
        	super.primitives(consumer, session);

        }
		
		/**
		 * Duplicates the light object's properties to another <code>AmbientLight3D</code> object
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
        public override function clone(object:* = null):*
        {
            var light:AmbientLight3D = object || new AmbientLight3D();
            super.clone(light);
            light.color = color;
            light.ambient = ambient;
            light.debug = debug;
            return light;
        }

    }
}
