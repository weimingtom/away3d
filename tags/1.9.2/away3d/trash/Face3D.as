package away3d.trash
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    
    import flash.geom.Matrix;

    /** Mesh's triangle face */
    public class Face3D
    {
        public var v0:Vertex3D;
        public var v1:Vertex3D;
        public var v2:Vertex3D;

        public var uv0:UV;
        public var uv1:UV;
        public var uv2:UV;
    
        public var material:ITriangleMaterial;

        public var extra:Object;

        public var visible:Boolean = true;

        public function Face3D(v0:Vertex3D, v1:Vertex3D, v2:Vertex3D, material:ITriangleMaterial = null, uv0:UV = null, uv1:UV = null, uv2:UV = null)
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
