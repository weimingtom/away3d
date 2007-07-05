package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.geom.*;
    import away3d.core.scene.*;
    
    /** Abstract class for objects based on the set of vertices */
    public class Vertices3D extends Object3D
    {
        public var vertices:Array = [];
        public var maxradius:Number = -1;
        public var minradius:Number = 0;
        public var xMin:Number = 1000000;
        public var xMax:Number = -1000000;
        public var yMin:Number = 1000000;
        public var yMax:Number = -1000000;
        public var zMin:Number = 1000000;
        public var zMax:Number = -1000000;
        public var width:Number = 100;
        public var height:Number = 100;
        public var depth:Number = 100;
        public var length:Number;
        public var wrap:Boolean = true;
/*
        public function get radius():Number
        {
            if (maxradius < 0)
            {
                var mrs:Number = 0;
                for each (var v:Vertex3D in vertices)
                {
                    var sd:Number = v.x*v.x + v.y*v.y + v.z*v.z;
                    if (sd > mrs)
                        mrs = sd;
                }
                maxradius = Math.sqrt(mrs);
            }
            return maxradius;
        }
*/
        public function Vertices3D(init:Object = null)
        {
            super(init);
        }
    }
}
