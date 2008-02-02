package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    
    import flash.geom.*;

    /** Point light source */
    public class PointLightSource
    {
        public var x:Number;
        public var y:Number;
        public var z:Number;
        public var light:Light3D;
        public var red:Number;
        public var green:Number;
        public var blue:Number;
        public var ambient:Number;
        public var diffuse:Number;
        public var specular:Number;
    }
}

