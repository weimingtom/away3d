package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    
    import away3d.objects.*;

    import flash.utils.Dictionary;
    
    /** Mesh constisting of faces and segments */
    public class Mesh extends Object3D implements IPrimitiveProvider
    {
        use namespace arcane;

        private var _faces:Array = [];

        public function get faces():Array
        {
            return _faces;
        }

        private var _vertices:Array;
        private var _verticesDirty:Boolean = true;

        public function get vertices():Array
        {
            if (_verticesDirty)
            {
                _vertices = [];
                var processed:Dictionary = new Dictionary();
                for each (var face:Face in _faces)
                {
                    if (!processed[face.v0])
                    {
                        _vertices.push(face.v0);
                        processed[face.v0] = true;
                    }
                    if (!processed[face.v1])
                    {
                        _vertices.push(face.v1);
                        processed[face.v1] = true;
                    }
                    if (!processed[face.v2])
                    {
                        _vertices.push(face.v2);
                        processed[face.v2] = true;
                    }
                }
                _verticesDirty = false;
            }
            return _vertices;
        }

        private var _neighboursDirty:Boolean = true;
        private var _neighbour01:Dictionary; 
        private var _neighbour12:Dictionary; 
        private var _neighbour20:Dictionary; 

        private function findNeighbours():void
        {
            if (!_neighboursDirty)
                return;

            _neighbour01 = new Dictionary();
            _neighbour12 = new Dictionary();
            _neighbour20 = new Dictionary();
            for each (var face:Face in _faces)
            {
                var skip:Boolean = true;
                for each (var another:Face in _faces)
                {
                    if (skip)
                    {
                        if (face == another)
                            skip = false;
                        continue;
                    }

                    if ((face._v0 == another._v2) && (face._v1 == another._v1))
                    {
                        _neighbour01[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v0 == another._v0) && (face._v1 == another._v2))
                    {
                        _neighbour01[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v0 == another._v1) && (face._v1 == another._v0))
                    {
                        _neighbour01[face] = another;
                        _neighbour01[another] = face;
                    }
                
                    if ((face._v1 == another._v2) && (face._v2 == another._v1))
                    {
                        _neighbour12[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v1 == another._v0) && (face._v2 == another._v2))
                    {
                        _neighbour12[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v1 == another._v1) && (face._v2 == another._v0))
                    {
                        _neighbour12[face] = another;
                        _neighbour01[another] = face;
                    }
                
                    if ((face._v2 == another._v2) && (face._v0 == another._v1))
                    {
                        _neighbour20[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v2 == another._v0) && (face._v0 == another._v2))
                    {
                        _neighbour20[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v2 == another._v1) && (face._v0 == another._v0))
                    {
                        _neighbour20[face] = another;
                        _neighbour01[another] = face;
                    }
                }
            }

            _neighboursDirty = false;
        }
         
        private var _radiusFace:Face = null;
        private var _radiusDirty:Boolean = false;
        private var _radius:Number = 0;

        public override function get radius():Number
        {
            if (_radiusDirty)
            {
                var mr:Number = 0;
                _radiusFace = null;
                for each (var face:Face in _faces)
                {
                    var r2:Number = face.rad2();
                    if (r2 > mr)
                    {
                        mr = r2;
                        _radiusFace = face;
                    }
                }
                _radius = Math.sqrt(mr);
                _radiusDirty = false;
            }
            return _radius;
        }

        public var material:IMaterial;
        public var outline:ISegmentMaterial;
        public var back:ITriangleMaterial;

        public var bothsides:Boolean;
        public var pushback:Boolean;
        public var pushfront:Boolean;

        private var boundingsphere:Sphere;
    
        public function Mesh(init:Object = null)
        {
            super(init);

            init = Init.parse(init);
            
            material = init.getMaterial("material") || new WireColorMaterial();
            outline = init.getMaterial("outline");
            back = init.getMaterial("back") || (material as ITriangleMaterial);
            bothsides = init.getBoolean("bothsides", false);
            pushback = init.getBoolean("pushback", false);
            pushfront = init.getBoolean("pushfront", false);
        }
    
        public function scale(scale:Number):void
        {
            scaleXYZ(scale, scale, scale);
        }

        public function scaleX(scaleX:Number):void
        {
            if (scaleX != 1)
                scaleXYZ(scaleX, 1, 1);
        }
    
        public function scaleY(scaleY:Number):void
        {
            if (scaleY != 1)
                scaleXYZ(1, scaleY, 1);
        }
    
        public function scaleZ(scaleZ:Number):void
        {
            if (scaleZ != 1)
                scaleXYZ(1, 1, scaleZ);
        }

        public function scaleXYZ(scaleX:Number, scaleY:Number, scaleZ:Number):void
        {
            var processed:Dictionary = new Dictionary();
            for each (var face:Face in _faces)
            {
                if (!processed[face.v0])
                {
                    face.v0.x *= scaleX;
                    face.v0.y *= scaleY;
                    face.v0.z *= scaleZ;
                    processed[face.v0] = true;
                }
                if (!processed[face.v1])
                {
                    face.v1.x *= scaleX;
                    face.v1.y *= scaleY;
                    face.v1.z *= scaleZ;
                    processed[face.v1] = true;
                }
                if (!processed[face.v2])
                {
                    face.v2.x *= scaleX;
                    face.v2.y *= scaleY;
                    face.v2.z *= scaleZ;
                    processed[face.v2] = true;
                }
            }
        }


        public function addFace(face:Face):void
        {
            _faces.push(face);
            _verticesDirty = true;
                              
            face.addOnVertexChange(onFaceVertexChange);
            face.addOnVertexValueChange(onFaceVertexValueChange);
                                                
            rememberFaceRadius(face);
            rememberFaceNeighbours(face);
        }

        public function removeFace(face:Face):void
        {
            var index:int = _faces.indexOf(face);
            if (index == -1)
                return;

            forgetFaceNeighbours(face);
            forgetFaceRadius(face);

            face.removeOnVertexValueChange(onFaceVertexValueChange);
            face.removeOnVertexChange(onFaceVertexChange);

            _faces.splice(index, 1);
            _verticesDirty = true;
        }

        private function rememberFaceRadius(face:Face):void
        {
            var r2:Number = face.rad2();
            if (r2 > _radius*_radius)
            {
                _radius = Math.sqrt(r2);
                _radiusFace = face;
                _radiusDirty = false;
                notifyRadiusChange();
            }
        }

        private function forgetFaceRadius(face:Face):void
        {
            if (face == _radiusFace)
            {
                _radiusFace = null;
                _radiusDirty = true;
                notifyRadiusChange();
            }
        }

        private function rememberFaceNeighbours(face:Face):void
        {
            if (_neighboursDirty)
                return;
            
            for each (var another:Face in _faces)
            {
                if (face == another)
                    continue;

                if ((face._v0 == another._v2) && (face._v1 == another._v1))
                {
                    _neighbour01[face] = another;
                    _neighbour12[another] = face;
                }

                if ((face._v0 == another._v0) && (face._v1 == another._v2))
                {
                    _neighbour01[face] = another;
                    _neighbour20[another] = face;
                }

                if ((face._v0 == another._v1) && (face._v1 == another._v0))
                {
                    _neighbour01[face] = another;
                    _neighbour01[another] = face;
                }
            
                if ((face._v1 == another._v2) && (face._v2 == another._v1))
                {
                    _neighbour12[face] = another;
                    _neighbour12[another] = face;
                }

                if ((face._v1 == another._v0) && (face._v2 == another._v2))
                {
                    _neighbour12[face] = another;
                    _neighbour20[another] = face;
                }

                if ((face._v1 == another._v1) && (face._v2 == another._v0))
                {
                    _neighbour12[face] = another;
                    _neighbour01[another] = face;
                }
            
                if ((face._v2 == another._v2) && (face._v0 == another._v1))
                {
                    _neighbour20[face] = another;
                    _neighbour12[another] = face;
                }

                if ((face._v2 == another._v0) && (face._v0 == another._v2))
                {
                    _neighbour20[face] = another;
                    _neighbour20[another] = face;
                }

                if ((face._v2 == another._v1) && (face._v0 == another._v0))
                {
                    _neighbour20[face] = another;
                    _neighbour01[another] = face;
                }
            }
        }

        private function forgetFaceNeighbours(face:Face):void
        {
            if (_neighboursDirty)
                return;
            
            var n01:Face = _neighbour01[face];
            if (n01 != null)
            {
                delete _neighbour01[face];
                if (_neighbour01[n01] == face)
                    delete _neighbour01[n01];
                if (_neighbour12[n01] == face)
                    delete _neighbour12[n01];
                if (_neighbour20[n01] == face)
                    delete _neighbour20[n01];
            }
            var n12:Face = _neighbour12[face];
            if (n12 != null)
            {
                delete _neighbour12[face];
                if (_neighbour01[n12] == face)
                    delete _neighbour01[n12];
                if (_neighbour12[n12] == face)
                    delete _neighbour12[n12];
                if (_neighbour20[n12] == face)
                    delete _neighbour20[n12];
            }
            var n20:Face = _neighbour20[face];
            if (n20 != null)
            {
                delete _neighbour20[face];
                if (_neighbour01[n20] == face)
                    delete _neighbour01[n20];
                if (_neighbour12[n20] == face)
                    delete _neighbour12[n20];
                if (_neighbour20[n20] == face)
                    delete _neighbour20[n20];
            }
        }

        private function onFaceVertexChange(event:FaceEvent):void
        {
            var face:Face = event.face;

            forgetFaceRadius(face);
            forgetFaceNeighbours(face);
            rememberFaceNeighbours(face);
            rememberFaceRadius(face);

            _verticesDirty = true;
        }

        private function onFaceVertexValueChange(event:FaceEvent):void
        {
            var face:Face = event.face;

            forgetFaceRadius(face);
            rememberFaceRadius(face);
        }

        private function clear():void
        {
            for each (var face:Face in _faces.concat([]))
                removeFace(face);
        }

        public function quarterFaces():void
        {
            var medians:Dictionary = new Dictionary();
            for each (var face:Face in _faces.concat([]))
            {
                var v0:Vertex = face.v0;
                var v1:Vertex = face.v1;
                var v2:Vertex = face.v2;

                if (medians[v0] == null)
                    medians[v0] = new Dictionary();
                if (medians[v1] == null)
                    medians[v1] = new Dictionary();
                if (medians[v2] == null)
                    medians[v2] = new Dictionary();

                var v01:Vertex = medians[v0][v1];
                if (v01 == null)
                {
                   v01 = Vertex.median(v0, v1);
                   medians[v0][v1] = v01;
                   medians[v1][v0] = v01;
                }
                var v12:Vertex = medians[v1][v2];
                if (v12 == null)
                {
                   v12 = Vertex.median(v1, v2);
                   medians[v1][v2] = v12;
                   medians[v2][v1] = v12;
                }
                var v20:Vertex = medians[v2][v0];
                if (v20 == null)
                {
                   v20 = Vertex.median(v2, v0);
                   medians[v2][v0] = v20;
                   medians[v0][v2] = v20;
                }
                var uv0:UV = face.uv0;
                var uv1:UV = face.uv1;
                var uv2:UV = face.uv2;
                var uv01:UV = UV.median(uv0, uv1);
                var uv12:UV = UV.median(uv1, uv2);
                var uv20:UV = UV.median(uv2, uv0);
                var material:ITriangleMaterial = face.material;
                removeFace(face);
                addFace(new Face(v0, v01, v20, material, uv0, uv01, uv20));
                addFace(new Face(v01, v1, v12, material, uv01, uv1, uv12));
                addFace(new Face(v20, v12, v2, material, uv20, uv12, uv2));
                addFace(new Face(v12, v20, v01, material, uv12, uv20, uv01));
            }
        }

        public function primitives(projection:Projection, consumer:IPrimitiveConsumer):void
        {
            //if (boundingsphere == null)
            //{
                //boundingsphere = new Sphere(new WireColorMaterial(0xFFFFFF, 0xFFFFFF, 0.1, 0.1), {segmentsW:16, segmentsH:12, radius:radius});
                //throw new Error(radius);
            //}

            //boundingsphere.primitives(projection, consumer);

            if (outline != null)
                findNeighbours();

            var tri:DrawTriangle;
            var ntri:DrawTriangle;
            var trimat:ITriangleMaterial = (material is ITriangleMaterial) ? (material as ITriangleMaterial) : null;
            var transparent:ITriangleMaterial = TransparentMaterial.INSTANCE;
            for each (var face:Face in _faces)
            {
                if (!face.visible)
                    continue;

                if (tri == null)
                    if (outline == null)
                        tri = new DrawTriangle();
                    else
                        tri = new DrawBorderTriangle();

                tri.v0 = face._v0.project(projection);
                tri.v1 = face._v1.project(projection);
                tri.v2 = face._v2.project(projection);

                if (!tri.v0.visible)
                    continue;

                if (!tri.v1.visible)
                    continue;

                if (!tri.v2.visible)
                    continue;

                tri.calc();

                if (tri.maxZ < 0)
                    continue;

                var backface:Boolean = tri.area <= 0;

                if (backface)
                    if (!bothsides)
                        continue;

                tri.material = face._material || trimat;

                if (backface)
                {
                    if (back != null)
                    {
                        if (!back.visible)
                            continue;

                        tri.material = back;
                    }
                }

                if (tri.material == null)
                    continue;

                if (!tri.material.visible)
                {
                    if (outline == null)
                        continue;

                    tri.material = transparent;
                }

                if (pushback)
                    tri.screenZ = tri.maxZ;

                if (pushfront)
                    tri.screenZ = tri.minZ;

                tri.uv0 = face._uv0;
                tri.uv1 = face._uv1;
                tri.uv2 = face._uv2;

                tri.texturemapping = face.mapping;

                if (backface)
                {
                    // Make cleaner
                    tri.texturemapping = null;

                    var vt:ScreenVertex = tri.v1;
                    tri.v1 = tri.v2;
                    tri.v2 = vt;

                    var uvt:UV = tri.uv1;
                    tri.uv1 = tri.uv2;
                    tri.uv2 = uvt;

                    tri.area = -tri.area;
                }

                if ((outline != null) && (!backface))
                {
                    var btri:DrawBorderTriangle = tri as DrawBorderTriangle;
                    if (ntri == null)
                        ntri = new DrawTriangle();

                    var n01:Face = _neighbour01[face];
                    if (n01 != null)
                    {
                        ntri.v0 = n01._v0.project(projection);
                        ntri.v1 = n01._v1.project(projection);
                        ntri.v2 = n01._v2.project(projection);
                        ntri.calc();
    
                        if (ntri.area <= 0)
                            btri.s01material = outline;
                    }
                    else
                        btri.s01material = outline;

                    var n12:Face = _neighbour12[face];
                    if (n12 != null)
                    {
                        ntri.v0 = n12._v0.project(projection);
                        ntri.v1 = n12._v1.project(projection);
                        ntri.v2 = n12._v2.project(projection);
                        ntri.calc();

                        if (ntri.area <= 0)
                            btri.s12material = outline;
                    }
                    else
                        btri.s12material = outline;

                    var n20:Face = _neighbour20[face];
                    if (n20 != null)
                    {
                        ntri.v0 = n20._v0.project(projection);
                        ntri.v1 = n20._v1.project(projection);
                        ntri.v2 = n20._v2.project(projection);
                        ntri.calc();
    
                        if (ntri.area <= 0)
                            btri.s20material = outline;
                    }
                    else
                        btri.s20material = outline;
                }

                tri.source = this;
                tri.face = face;
                tri.projection = projection;
                consumer.primitive(tri);
                tri = null;
            }
        }
    }
}
