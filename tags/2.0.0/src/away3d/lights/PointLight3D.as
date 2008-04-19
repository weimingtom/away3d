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
    public class PointLight3D extends Object3D implements ILightProvider, IPrimitiveProvider, IClonable
    {
    	internal var _bitmap:BitmapData;
        public var color:int;
        public var ambient:Number;
        public var diffuse:Number;
        public var specular:Number;
        public var brightness:Number;
        public var debug:Boolean;
		
		public var _ls:PointLightSource = new PointLightSource();
		
		public function get width():Number
        {
            return _bitmap.width;
        }

        public function get height():Number
        {
            return _bitmap.height;
        }
        
        public function get bitmap():BitmapData
        {
        	if (_bitmap == null) {
        		_bitmap = new BitmapData(256, 256, false, 0x000000);
        		var shape:Shape = new Shape();
        		var matrix:Matrix = new Matrix();
        		matrix.createGradientBox(256, 256, 0, 0, 0);
        		shape.graphics.beginGradientFill(GradientType.RADIAL, [0xFFFFFF, 0x000000], [1, 1], [0, 255], matrix);
        		shape.graphics.drawCircle(127, 127, 127);
        		_bitmap.draw(shape);
        		
        	}
        	return _bitmap;
        }
        
        public function PointLight3D(init:Object = null)
        {
            super(init);

            init = Init.parse(init);
            
			_bitmap = init.getBitmap("bitmap");
            color = init.getColor("color", 0xFFFFFF);
            ambient = init.getNumber("ambient", 1);
            diffuse = init.getNumber("diffuse", 1);
            specular = init.getNumber("specular", 1);
            brightness = init.getNumber("brightness", 1);
            debug = init.getBoolean("debug", false);
        }

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
