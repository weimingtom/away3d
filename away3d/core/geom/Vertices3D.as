package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.geom.*;
    import away3d.core.proto.*;
    
    // The Vertices3D class lets you create and manipulate groups of vertices.
    public class Vertices3D extends Object3D
    {
        public var vertices:Array = new Array();
        public var maxradius:Number = -1;
        public var minradius:Number = 0;

        protected function calcMaxRadius():void
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

        public function Vertices3D(name:String = null, init:Object = null)
        {
            super(name, init);
        }
    }
}
