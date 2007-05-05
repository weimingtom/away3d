package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;

    public class Mesh3D extends Vertices3D implements IPrimitiveProvider
    {
        public var faces:Array = [];
        public var segments:Array = [];

        public var material:IMaterial;

        public var bothsides:Boolean = false;
    
        public function Mesh3D(material:IMaterial, name:String = null, init:Object = null)
        {
            super(name, init);
    
            if (init)
            {
                bothsides = init.bothsides || false;
            }

            this.material = material || new WireColorMaterial();
        }
    
        public function inverseFaces():void
        {
            for each (var face:Face3D in faces)
            {
                var vt:Vertex3D = face.v1;
                face.v1 = face.v2;
                face.v2 = vt;

                var uvt:NumberUV = face.uv1;
                face.uv1 = face.uv2;
                face.uv2 = uvt;
            }    
        }

        public function quarterFaces():void
        {
            var oldfaces:Array = faces;
            faces = [];
            for each (var face:Face3D in oldfaces)
            {
                var v0:Vertex3D = face.v0;
                var v1:Vertex3D = face.v1;
                var v2:Vertex3D = face.v2;
                var v01:Vertex3D = Vertex3D.median(v0, v1);
                var v12:Vertex3D = Vertex3D.median(v1, v2);
                var v20:Vertex3D = Vertex3D.median(v2, v0);
                var uv0:NumberUV = face.uv0;
                var uv1:NumberUV = face.uv1;
                var uv2:NumberUV = face.uv2;
                var uv01:NumberUV = NumberUV.median(uv0, uv1);
                var uv12:NumberUV = NumberUV.median(uv1, uv2);
                var uv20:NumberUV = NumberUV.median(uv2, uv0);
                var material:ITriangleMaterial = face.material;
                faces.push(new Face3D(v0, v01, v20, material, uv0, uv01, uv20));
                faces.push(new Face3D(v01, v1, v12, material, uv01, uv1, uv12));
                faces.push(new Face3D(v20, v12, v2, material, uv20, uv12, uv2));
                faces.push(new Face3D(v12, v20, v01, material, uv12, uv20, uv01));
            }    
        }

        public function primitives(projection:Projection, consumer:IPrimitiveConsumer):void
        {
            var tri:DrawTriangle;
            var trimat:ITriangleMaterial = (material is ITriangleMaterial) ? (material as ITriangleMaterial) : null;
            for each (var face:Face3D in faces)
            {
                tri = tri || new DrawTriangle();

                tri.v0 = face.v0.project(projection);
                tri.v1 = face.v1.project(projection);
                tri.v2 = face.v2.project(projection);

                if (!tri.v0.visible)
                    continue;

                if (!tri.v1.visible)
                    continue;

                if (!tri.v2.visible)
                    continue;

                tri.calc();

                if (tri.maxZ < 0)
                    continue;

                tri.material = face.material || trimat;

                if (tri.material == null)
                    continue;

                if (!tri.material.visible)
                    continue;

                if ((!bothsides) && (tri.area <= 0))
                    continue;

                tri.uv0 = face.uv0;
                tri.uv1 = face.uv1;
                tri.uv2 = face.uv2;

                if (tri.uv0 != null)
                {
                    if (face.texturemapping == null)
                        if (tri.material is IUVMaterial)
                            face.texturemapping = tri.transformUV(tri.material as IUVMaterial);
                    tri.texturemapping = face.texturemapping;
                }

                tri.source = this;
                tri.projection = projection;
                consumer.primitive(tri);
                tri = null;
            }

            var seg:DrawSegment;
            var segmat:ISegmentMaterial = (material is ISegmentMaterial) ? (material as ISegmentMaterial) : null;
            for each (var segment:Segment3D in segments)
            {
                seg = seg || new DrawSegment();

                seg.v0 = segment.v0.project(projection);
                seg.v1 = segment.v1.project(projection);
    
                if (!seg.v0.visible)
                    continue;

                if (!seg.v1.visible)
                    continue;

                seg.calc();

                if (seg.maxZ < 0)
                    continue;

                seg.material = segment.material || segmat;

                if (seg.material == null)
                    continue;

                if (!seg.material.visible)
                    continue;

                seg.source = this;
                seg.projection = projection;
                consumer.primitive(seg);
                seg = null;
            }

        }
    }
}
