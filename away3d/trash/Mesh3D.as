package away3d.trash
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.render.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    import away3d.core.utils.*;
    
    import flash.geom.*;
    import flash.utils.*;
    
    /** Mesh constisting of faces and segments */
    public class Mesh3D extends Vertices3D implements IPrimitiveProvider
    {
        use namespace arcane;
            
        public var faces:Array = [];
        public var segments:Array = [];

        public var material:IMaterial;

        public var bothsides:Boolean;
        public var pushback:Boolean;
        public var pushfront:Boolean;
    
        public function Mesh3D(material:IMaterial, init:Object = null)
        {
            super(init);

            init = Init.parse(init);

            bothsides = init.getBoolean("bothsides", false);
            pushback = init.getBoolean("pushback", false);
            pushfront = init.getBoolean("pushfront", false);

            this.material = material || new WireColorMaterial();
        }
    
        public function asMesh():Mesh
        {
            var result:Mesh = new Mesh({material:material});
            var vm:Dictionary = new Dictionary();
            for each (var v:Vertex3D in vertices)
                vm[v] = new Vertex(v.x, v.y, v.z);
            for each (var f:Face3D in faces)
                result.addFace(new Face(vm[f.v0], vm[f.v1], vm[f.v2], f.material, f.uv0, f.uv1, f.uv2));
            return result;
        }

        public function inverseFaces():void
        {
            for each (var face:Face3D in faces)
            {
                var vt:Vertex3D = face.v1;
                face.v1 = face.v2;
                face.v2 = vt;

                var uvt:UV = face.uv1;
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
                var uv0:UV = face.uv0;
                var uv1:UV = face.uv1;
                var uv2:UV = face.uv2;
                var uv01:UV = UV.median(uv0, uv1);
                var uv12:UV = UV.median(uv1, uv2);
                var uv20:UV = UV.median(uv2, uv0);
                var material:ITriangleMaterial = face.material;
                faces.push(new Face3D(v0, v01, v20, material, uv0, uv01, uv20));
                faces.push(new Face3D(v01, v1, v12, material, uv01, uv1, uv12));
                faces.push(new Face3D(v20, v12, v2, material, uv20, uv12, uv2));
                faces.push(new Face3D(v12, v20, v01, material, uv12, uv20, uv01));
            }    
        }

        override public function primitives(projection:Projection, consumer:IPrimitiveConsumer, session:RenderSession):void
        {
        	super.primitives(projection, consumer, session);
        	
            var tri:DrawTriangle;
            var trimat:ITriangleMaterial = (material is ITriangleMaterial) ? (material as ITriangleMaterial) : null;
            for each (var face:Face3D in faces)
            {
                if (!face.visible)
                    continue;

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
                
                if (pushback)
                    tri.screenZ = tri.maxZ;

                if (pushfront)
                    tri.screenZ = tri.minZ;

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

                if (tri.area <= 0)
                {
                    // Make cleaner
                    tri.texturemapping = null;
                    var vt:ScreenVertex = tri.v1;
                    tri.v1 = tri.v2;
                    tri.v2 = vt;

                    var uvt:UV = tri.uv1;
                    tri.uv1 = tri.uv2;
                    tri.uv2 = uvt;
                }

                tri.object = this;
                tri.face = null; //face;
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

                seg.object = this;
                seg.projection = projection;
                consumer.primitive(seg);
                seg = null;
            }
        }
                
        public function insideShape(shape1:Array, shape2:Array):Boolean
        {
            var flag:Boolean;
            var p:Point, p1:Number, p2:Number, s1:Point, s2:Point;
            for each (p in shape1) {
                flag = true;
                for (p2=0;p2<shape2.length;p2++) {
                    p1 = (p2 == 0)? shape2.length - 1 : p2 - 1;
                    s1 = shape2[p1];
                    s2 = shape2[p2];
                    if ((s1.x*s2.y - s1.y*s2.x - p.x*s2.y + p.y*s2.x + p.x*s1.y - p.y*s1.x) < -0.5) flag = false;
                }
                if (flag) return true;
            }
            for each (p in shape2) {
                flag = true;
                for (p2=0;p2<shape1.length;p2++) {
                    p1 = (p2 == 0)? shape1.length - 1 : p2 - 1;
                    s1 = shape1[p1];
                    s2 = shape1[p2];
                    if ((s1.x*s2.y - s1.y*s2.x - p.x*s2.y + p.y*s2.x + p.x*s1.y - p.y*s1.x) < -0.5) flag = false;
                }
                if (flag) return true;
            }
            return flag;
        }
    }
}
