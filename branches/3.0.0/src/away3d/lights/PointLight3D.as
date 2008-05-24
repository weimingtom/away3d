package away3d.lights
{
    import away3d.core.draw.*;
    import away3d.materials.*;
    import away3d.core.math.*;
    import away3d.core.base.*;
    import away3d.core.light.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
    import flash.geom.Matrix;
	
    /**
    * Lightsource that colors all shaded materials proportional to the dot product of the distance vector with the normal vector.
    * The scalar value of the distance is used to calulate intensity using the inverse square law of attenuation.
    */
    public class PointLight3D extends Object3D implements ILightProvider, IPrimitiveProvider, IClonable
    {
		private var _ls:PointLight = new PointLight();
        
        /**
        * Toggles debug mode: light object is visualised in the scene.
        */
        public var debug:Boolean;
		
		/**
		 * Defines the color of the light object.
		 */
        public var color:int;
		
		/**
		 * Defines a coefficient for the ambient light intensity.
		 */
        public var ambient:Number;
		
		/**
		 * Defines a coefficient for the diffuse light intensity.
		 */
        public var diffuse:Number;
		
		/**
		 * Defines a coefficient for the specular light intensity.
		 */
        public var specular:Number;
		
		/**
		 * Defines a coefficient for the overall light intensity.
		 */
        public var brightness:Number;
		
		/**
		 * Creates a new <code>PointLight3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function PointLight3D(init:Object = null)
        {
            super(init);
            
            color = ini.getColor("color", 0xFFFFFF);
            ambient = ini.getNumber("ambient", 1);
            diffuse = ini.getNumber("diffuse", 1);
            specular = ini.getNumber("specular", 1);
            brightness = ini.getNumber("brightness", 1);
            debug = ini.getBoolean("debug", false);
        }
        
		/**
		 * @inheritDoc
		 */
        public function light(consumer:ILightConsumer):void
        {
            _ls.x = viewTransform.tx;
            _ls.y = viewTransform.ty;
            _ls.z = viewTransform.tz;
            _ls.light = this;
            _ls.red = (color & 0xFF0000) >> 16;
            _ls.green = (color & 0xFF00) >> 8;
            _ls.blue  = (color & 0xFF);
            _ls.ambient = ambient*brightness;
            _ls.diffuse = diffuse*brightness;
            _ls.specular = specular*brightness;
            consumer.pointLight(_ls);
        }
        
		/**
		 * @inheritDoc
		 */
        override public function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void
        {
        	super.primitives(consumer, session);

            if (!debug)
                return;

            var v:Vertex = new Vertex(0, 0, 0);
            var vp:ScreenVertex = v.project(projection);
            if (!vp.visible)
                return;

            var tri:DrawTriangle = new DrawTriangle();
            tri.v0 = new ScreenVertex(vp.x + 3, vp.y + 2, vp.z);
            tri.v1 = new ScreenVertex(vp.x - 3, vp.y + 2, vp.z);
            tri.v2 = new ScreenVertex(vp.x, vp.y - 3, vp.z);
            tri.calc();
            tri.source = this;
            tri.projection = projection;
            tri.material = new ColorMaterial(color);
            consumer.primitive(tri);

        }
		
		/**
		 * Duplicates the light object's properties to another <code>PointLight3D</code> object
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
        public override function clone(object:* = null):*
        {
            var light:PointLight3D = object || new PointLight3D();
            super.clone(light);
            light.color = color;
            light.ambient = ambient;
            light.diffuse = diffuse;
            light.specular = specular;
            light.debug = debug;
            return light;
        }

    }
}
