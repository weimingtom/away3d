package away3d.trash
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;

    /** Mesh's line segment */
    public class Segment3D
    {
        public var v0:Vertex3D;
        public var v1:Vertex3D;

        public var material:ISegmentMaterial;

        public function Segment3D(v0:Vertex3D, v1:Vertex3D, material:ISegmentMaterial = null)
        {
            this.v0 = v0;
            this.v1 = v1;
            this.material = material;
        }

    }
}
