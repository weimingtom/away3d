package away3d.lights
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.light.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.events.Object3DEvent;
    import away3d.materials.*;
    
    import flash.display.*;
	
    /** Light source */ 
    public class DirectionalLight3D extends Object3D implements ILightProvider, IPrimitiveProvider, IClonable
    {
        internal var _color:int;
        internal var _red:int;
        internal var _green:int;
        internal var _blue:int;
        internal var _ambient:Number;
        internal var _diffuse:Number;
        internal var _specular:Number;
        internal var _brightness:Number;
    	
    	internal var _colorDirty:Boolean;
    	internal var _ambientDirty:Boolean;
    	internal var _diffuseDirty:Boolean;
    	internal var _specularDirty:Boolean;
    	internal var _brightnessDirty:Boolean;
    	
        public var debug:Boolean;
		
		public function set color(val:int):void
		{
			_color = val;
			_red = (_color & 0xFF0000) >> 16;
            _green = (_color & 0xFF00) >> 8;
            _blue  = (_color & 0xFF);
            _colorDirty = true;
		}
		
		public function get color():int
		{
			return _color;
		}
		
		public function set ambient(val:Number):void
		{
			if (val < 0)
				val  = 0;
			_ambient = val;
            _ambientDirty = true;
		}
		
		public function get ambient():Number
		{
			return _ambient;
		}
				
		public function set diffuse(val:Number):void
		{
			if (val < 0)
				val  = 0;
			_diffuse = val;
            _diffuseDirty = true;
		}
		
		public function get diffuse():Number
		{
			return _diffuse;
		}
		
		public function set specular(val:Number):void
		{
			if (val < 0)
				val  = 0;
			_specular = val;
            _specularDirty = true;
		}
		
		public function get specular():Number
		{
			return _specular;
		}
		
		public function set brightness(val:Number):void
		{
			_brightness = val;
            _brightnessDirty = true;
		}
		
		public function get brightness():Number
		{
			return _brightness;
		}
		
		public var _ls:DirectionalLightSource = new DirectionalLightSource();
        
        public function DirectionalLight3D(init:Object = null)
        {
            super(init);

            init = Init.parse(init);
            
            color = init.getColor("color", 0xFFFFFF);
            ambient = init.getNumber("ambient", 0.5, {min:0, max:1});
            diffuse = init.getNumber("diffuse", 0.5, {min:0, max:10});
            specular = init.getNumber("specular", 1, {min:0, max:1});
            brightness = init.getNumber("brightness", 1);
            debug = init.getBoolean("debug", false);
            _ls.light = this;
            addOnTransformChange(_ls.updateDirection);
        }
		
        public function light(consumer:ILightConsumer):void
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
        		_ambientDirty = false
	        	_ls.updateAmbientBitmap(ambient);
        	}
            
        	//update diffuse
        	if (_diffuseDirty || _brightnessDirty) {
        		_diffuseDirty = false
	        	_ls.updateDiffuseBitmap(diffuse);
        	}
        	
        	//update specular
        	if (_specularDirty || _brightnessDirty) {
        		_specularDirty = false;
        		_ls.updateSpecularBitmap(specular);
        	}
        	
            consumer.directionalLight(_ls);
            
            _colorDirty = false;
            _brightnessDirty = false;
        }

        override public function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void
        {
        	super.primitives(consumer, session);

        }

        public override function clone(object:* = null):*
        {
            var light:DirectionalLight3D = object || new DirectionalLight3D();
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
}
