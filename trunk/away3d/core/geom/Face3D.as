package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    
    import flash.geom.Matrix;

    public class Face3D
    {
        public var v0:Vertex3D;
        public var v1:Vertex3D;
        public var v2:Vertex3D;

        public var uv0:NumberUV;
        public var uv1:NumberUV;
        public var uv2:NumberUV;
    
        public var material:ITriangleMaterial;

        public var facelight:Array;

        public function Face3D(v0:Vertex3D, v1:Vertex3D, v2:Vertex3D, material:ITriangleMaterial = null, uv0:NumberUV = null, uv1:NumberUV = null, uv2:NumberUV = null)
        {
            this.v0 = v0;
            this.v1 = v1;
            this.v2 = v2;
            this.material = material;
            this.uv0 = uv0;
            this.uv1 = uv1;
            this.uv2 = uv2;
        }

        public var texturemapping:Matrix;


    }
}
