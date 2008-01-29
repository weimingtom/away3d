package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    
    import flash.geom.*;

    /** Array of light sources */
    public class LightArray implements ILightConsumer
    {
        public var ambients:Array;
        public var directed:Array;
        public var points:Array;
		
        public function ambientLight(color:int, ambient:Number):void
        {
            throw new Error("Not implemented");
        }

        public function directedLight(direction:Number3D, color:int, diffuse:Number):void
        {
            throw new Error("Not implemented");
        }

		internal var point:PointLightSource;
		
        public function pointLight(source:Matrix3D, light:Light3D, color:int, ambient:Number, diffuse:Number, specular:Number):void
        {
            point = light._ls;
            point.x = source.tx;
            point.y = source.ty;
            point.z = source.tz;
            point.light = light;
            point.red = (color & 0xFF0000) >> 16;
            point.green = (color & 0xFF00) >> 8;
            point.blue  = (color & 0xFF);
            point.ambient = ambient;
            point.diffuse = diffuse;
            point.specular = specular;
            points.push(point);
        }
        
        public function clear():void
        {
        	ambients = [];
	        directed = [];
	        points = [];
        }
    }
}

