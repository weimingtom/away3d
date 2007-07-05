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

        arcane var _faces:Array = [];

        public function get faces():Array
        {
            return _faces;
        }

        arcane var _neighbours:Boolean;
        arcane var _neighbour01:Dictionary; 
        arcane var _neighbour12:Dictionary; 
        arcane var _neighbour20:Dictionary; 

        arcane function findNeighbours():void
        {
            if (_neighbours)
                return;

            _neighbours = true;
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
        }
         
        arcane var _radiusFace:Face = null;
        arcane var _radiusDirty:Boolean = false;
        arcane var _radius:Number = 0;

        public function get radius():Number
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
            outline = init.getMaterial("outline") || new WireframeMaterial(0xFFFF00, 1, 2); // should be null
            back = init.getMaterial("back") || (material as ITriangleMaterial);
            bothsides = init.getBoolean("bothsides", false);
            pushback = init.getBoolean("pushback", false);
            pushfront = init.getBoolean("pushfront", false);
        }
    
        public function addFace(face:Face):void
        {
            _faces.push(face);
                              
            face.addOnVertexChange(onFaceVertexChange);

            rememberFace(face);
        }

        public function removeFace(face:Face):void
        {
            var index:int = _faces.indexOf(face);
            if (index == -1)
                return;

            forgetFace(face);

            face.removeOnVertexChange(onFaceVertexChange);

            _faces.splice(index, 1);
        }

        private function forgetFace(face:Face):void
        {
            if (face == _radiusFace)
            {
                _radiusFace = null;
                _radiusDirty = true;
            }

            if (_neighbours)
            {
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
        }

        private function rememberFace(face:Face):void
        {
            var r2:Number = face.rad2();
            if (r2 > _radius*_radius)
            {
                _radius = Math.sqrt(r2);
                _radiusFace = face;
                _radiusDirty = false;
            }

            if (_neighbours)
            {
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
        }

        private function onFaceVertexChange(event:FaceEvent):void
        {
            var face:Face = event.face;

            forgetFace(face);
            rememberFace(face);
        }

        public function primitives(projection:Projection, consumer:IPrimitiveConsumer):void
        {
            //if (boundingsphere == null)
            {
                boundingsphere = new Sphere(new WireColorMaterial(0xFFFFFF, 0xFFFFFF, 0.1, 0.1), {segmentsW:16, segmentsH:12, radius:radius});
                //throw new Error(radius);
            }

            //boundingsphere.primitives(projection, consumer);

            if (outline != null)
                findNeighbours();

            var tri:DrawTriangle;
            var ntri:DrawTriangle;
            var trimat:ITriangleMaterial = (material is ITriangleMaterial) ? (material as ITriangleMaterial) : null;
            for each (var face:Face in faces)
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

                tri.material = face._material || trimat;

                if (tri.material == null)
                    continue;

                if (!tri.material.visible)
                    continue;

                var backface:Boolean = tri.area <= 0;

                if (backface)
                {
                    if (!bothsides)
                        continue;

                    if (back != null)
                    {
                        if (!back.visible)
                            continue;

                        tri.material = back;
                    }
                }

                if (pushback)
                    tri.screenZ = tri.maxZ;

                if (pushfront)
                    tri.screenZ = tri.minZ;

                tri.uv0 = new NumberUV(face.uv0.u, face.uv0.v);
                tri.uv1 = new NumberUV(face.uv1.u, face.uv1.v);
                tri.uv2 = new NumberUV(face.uv2.u, face.uv2.v);

                if (tri.uv0 != null)
                {
                    if (face._texturemapping == null)
                        if (tri.material is IUVMaterial)
                            face._texturemapping = tri.transformUV(tri.material as IUVMaterial);
                    tri.texturemapping = face._texturemapping;
                }

                if (backface)
                {
                    //if (tri.texturemapping != null)
                    {
                        // Make cleaner
                        tri.texturemapping = null;
                        var vt:Vertex2D = tri.v1;
                        tri.v1 = tri.v2;
                        tri.v2 = vt;

                        var uvt:NumberUV = tri.uv1;
                        tri.uv1 = tri.uv2;
                        tri.uv2 = uvt;
                    }
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
