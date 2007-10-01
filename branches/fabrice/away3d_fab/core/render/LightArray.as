package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import flash.geom.*;

    /** Array of light sources */
    public class LightArray implements ILightConsumer
    {
        private var ambients:Array = [];
        private var directed:Array = [];
        public var points:Array = [];

        public function ambientLight(color:int, ambient:Number):void
        {
            throw new Error("Not implemented");
        }

        public function directedLight(direction:Number3D, color:int, diffuse:Number):void
        {
            throw new Error("Not implemented");
        }

        public function pointLight(source:Matrix3D, color:int, ambient:Number, diffuse:Number, specular:Number):void
        {
            var point:PointLightSource = new PointLightSource();
            point.x = source.tx;
            point.y = source.ty;
            point.z = source.tz;
            point.red = (color & 0xFF0000) >> 16;
            point.green = (color & 0xFF00) >> 8;
            point.blue  = (color & 0xFF);
            point.ambient = ambient;
            point.diffuse = diffuse;
            point.specular = specular;
            points.push(point);
        }
    }
}

