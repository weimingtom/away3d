package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;
    
    /** Triangle */ 
    public class Triangle extends Mesh
    {
        private var _a:Vertex;
        private var _b:Vertex;
        private var _c:Vertex;
        private var _face:Face;

        public function get a():Vertex
        {
            return _face.v0;
        }

        public function set a(value:Vertex):void
        {
            _face.v0 = value;
        }

        public function get b():Vertex
        {
            return _face.v1;
        }

        public function set b(value:Vertex):void
        {
            _face.v1 = value;
        }

        public function get c():Vertex
        {
            return _face.v2;
        }

        public function set c(value:Vertex):void
        {
            _face.v2 = value;
        }


        public function Triangle(init:Object = null)
        {
            super(init);
    
            init = Init.parse(init);

            var edge:Number = init.getNumber("edge", 100, {min:0}) / 2;
            var s3:Number = 1 / Math.sqrt(3);

            _face = new Face(new Vertex(0, 2*s3*edge, 0), new Vertex(edge, - s3*edge, 0), new Vertex(-edge, - s3*edge, 0), null, new UV(0, 0), new UV(1, 0), new UV(0, 1));
            addFace(_face);
			
			type = "Triangle";
        	url = "primitive";
        }
    
    }
}
