package away3d.lights
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.materials.*;
    import away3d.core.math.*;
    import away3d.core.base.*;
    import away3d.core.light.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
    import flash.geom.Matrix;
	
    /** Light source */ 
    public class AmbientLight3D extends Object3D implements ILightProvider, IPrimitiveProvider, IClonable
    {
        internal var _color:int;
        internal var _red:int;
        internal var _green:int;
        internal var _blue:int;
        internal var _ambient:Number;
		
		internal var _colorDirty:Boolean;
    	internal var _ambientDirty:Boolean;
    	
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
			_ambient = val;
            _ambientDirty = true;
		}
		
		public function get ambient():Number
		{
			return _ambient;
		}
		
		public var _ls:AmbientLightSource = new AmbientLightSource();
		
        public function AmbientLight3D(init:Object = null)
        {
            super(init);

            init = Init.parse(init);
            
            color = init.getColor("color", 0xFFFFFF);
            ambient = init.getNumber("ambient", 0.5, {min:0, max:1});
            debug = init.getBoolean("debug", false);
            _ls.light = this;
        }

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
        		_ambientDirty = false
	        	_ls.updateAmbientBitmap(_ambient);
        	}
        	
            consumer.ambientLight(_ls);
        }

        override public function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void
        {
        	super.primitives(consumer, session);

        }

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
