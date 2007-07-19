package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.render.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;
    
    import away3d.objects.*;

    import flash.utils.Dictionary;
    
    /** Mesh constisting of faces and segments */
    public class Mesh extends BaseMesh implements IPrimitiveProvider
    {
        use namespace arcane;

        private var _faces:Array = [];

        public function get faces():Array
        {
            return _faces;
        }

        public override function get elements():Array
        {
            return _faces;
        }

        private var _neighboursDirty:Boolean = true;
        private var _neighbour01:Dictionary; 
        private var _neighbour12:Dictionary; 
        private var _neighbour20:Dictionary; 
       
        arcane function forceRecalcNeighbours():void
        {
            _neighboursDirty = true;
            findNeighbours();
        }

        arcane function neighbour01(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            return _neighbour01[face];
        }

        arcane function neighbour12(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            return _neighbour12[face];
        }

        arcane function neighbour20(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            return _neighbour20[face];
        }

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
         
        public var material:ITriangleMaterial;
        public var outline:ISegmentMaterial;
        public var back:ITriangleMaterial;

        public var bothsides:Boolean;
        public var debugbb:Boolean;

        public function Mesh(init:Object = null)
        {
            super(init);

            init = Init.parse(init);
            
            material = init.getMaterial("material");
            outline = init.getSegmentMaterial("outline");
            back = init.getMaterial("back") || material;
            bothsides = init.getBoolean("bothsides", false);
            debugbb = init.getBoolean("debugbb", false);

            if ((material == null) && (outline == null))
                material = new WireColorMaterial();
        }

        public function addFace(face:Face):void
        {
            addElement(face);

            _faces.push(face);

            face.addOnVertexChange(onFaceVertexChange);
            rememberFaceNeighbours(face);
        }

        public function removeFace(face:Face):void
        {
            var index:int = _faces.indexOf(face);
            if (index == -1)
                return;

            removeElement(face);

            forgetFaceNeighbours(face);
            face.removeOnVertexChange(onFaceVertexChange);

            _faces.splice(index, 1);
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

        private function onFaceVertexChange(event:MeshElementEvent):void
        {
            var face:Face = event.element as Face;

            forgetFaceNeighbours(face);
            //removeElement(face);
            //addElement(face);
            rememberFaceNeighbours(face);
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

        private var _debugboundingbox:WireCube;

        public function primitives(projection:Projection, consumer:IPrimitiveConsumer):void
        {
            if (outline != null)
                if (_neighboursDirty)
                    findNeighbours();

            if (debugbb)
            {
                if (_debugboundingbox == null)
                    _debugboundingbox = new WireCube({material:"#white"});
                _debugboundingbox.v000.x = minX;
                _debugboundingbox.v001.x = minX;
                _debugboundingbox.v010.x = minX;
                _debugboundingbox.v011.x = minX;
                _debugboundingbox.v100.x = maxX;
                _debugboundingbox.v101.x = maxX;
                _debugboundingbox.v110.x = maxX;
                _debugboundingbox.v111.x = maxX;
                _debugboundingbox.v000.y = minY;
                _debugboundingbox.v001.y = minY;
                _debugboundingbox.v010.y = maxY;
                _debugboundingbox.v011.y = maxY;
                _debugboundingbox.v100.y = minY;
                _debugboundingbox.v101.y = minY;
                _debugboundingbox.v110.y = maxY;
                _debugboundingbox.v111.y = maxY;
                _debugboundingbox.v000.z = minZ;
                _debugboundingbox.v001.z = maxZ;
                _debugboundingbox.v010.z = minZ;
                _debugboundingbox.v011.z = maxZ;
                _debugboundingbox.v100.z = minZ;
                _debugboundingbox.v101.z = maxZ;
                _debugboundingbox.v110.z = minZ;
                _debugboundingbox.v111.z = maxZ;
                if (_faces.length > 0)
                    _debugboundingbox.primitives(projection, consumer);
            }

            var tri:DrawTriangle;
            var ntri:DrawTriangle;
            var transparent:ITriangleMaterial = TransparentMaterial.INSTANCE;
            for each (var face:Face in _faces)
            {
                if (!face._visible)
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

                tri.material = face._material || material;

                if (backface)
                    if (back != null)
                        tri.material = back;

                if (tri.material != null)
                    if (!tri.material.visible)
                        tri.material = null;

                if (outline == null)
                    if (tri.material == null)
                        continue;

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

                    if (btri.material == null)
                    {
                        if ((btri.s01material == null) && (btri.s12material == null) && (btri.s20material == null))
                            continue;
                        else
                            btri.material = transparent;
                    }
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
