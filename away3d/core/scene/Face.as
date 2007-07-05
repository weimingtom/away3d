package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.geom.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;

    /** Mesh's triangle face */
    public class Face extends LazyEventDispatcher
    {
        use namespace arcane;

        arcane var _v0:Vertex;
        arcane var _v1:Vertex;
        arcane var _v2:Vertex;
        arcane var _uv0:UV;
        arcane var _uv1:UV;
        arcane var _uv2:UV;
        arcane var _material:ITriangleMaterial;
        arcane var _extra:Object;
        arcane var _visible:Boolean = true;
        arcane var _texturemapping:Matrix;
        arcane var _normal:Number3D;

        public function get v0():Vertex
        {
            return _v0;
        }

        public function set v0(value:Vertex):void
        {
            if (value == _v0)
                return;

            if (_v0 != null)
                if ((_v0 != _v1) && (_v0 != _v2))
                    _v0.removeOnChange(onVertexChange);

            _v0 = value;

            if (_v2 != null)
                if ((_v0 != _v1) && (_v0 != _v2))
                    _v0.addOnChange(onVertexChange);

            notifyVertexChange();
        }

        public function get v1():Vertex
        {
            return _v1;
        }

        public function set v1(value:Vertex):void
        {
            if (value == _v1)
                return;

            if (_v1 != null)
                if ((_v1 != _v0) && (_v1 != _v2))
                    _v1.removeOnChange(onVertexChange);

            _v1 = value;

            if (_v2 != null)
                if ((_v1 != _v0) && (_v1 != _v2))
                    _v1.addOnChange(onVertexChange);

            notifyVertexChange();
        }

        public function get v2():Vertex
        {
            return _v2;
        }

        public function set v2(value:Vertex):void
        {
            if (value == _v2)
                return;

            if (_v2 != null)
                if ((_v2 != _v1) && (_v2 != _v0))
                    _v2.removeOnChange(onVertexChange);

            _v2 = value;

            if (_v2 != null)
                if ((_v2 != _v1) && (_v2 != _v0))
                    _v2.addOnChange(onVertexChange);

            notifyVertexChange();
        }

        public function get material():ITriangleMaterial
        {
            return _material;
        }

        public function set material(value:ITriangleMaterial):void
        {
            if (value == _material)
                return;

            _material = value;

            _texturemapping = null;

            notifyMaterialChange();
        }

        public function get visible():Boolean
        {
            return _visible;
        }

        public function set visible(value:Boolean):void
        {
            if (value == _visible)
                return;

            _visible = value;

            notifyVisibleChange();
        }

        public function get uv0():UV
        {
            return _uv0;
        }

        public function set uv0(value:UV):void
        {
            if (value == _uv0)
                return;

            if (_uv0 != null)
                if ((_uv0 != _uv1) && (_uv0 != _uv2))
                    _uv0.removeOnChange(onVertexChange);

            _uv0 = value;

            if (_uv0 != null)
                if ((_uv0 != _uv1) && (_uv0 != _uv2))
                    _uv0.addOnChange(onVertexChange);

            notifyUVChange();
        }

        public function get uv1():UV
        {
            return _uv1;
        }

        public function set uv1(value:UV):void
        {
            if (value == _uv1)
                return;

            if (_uv1 != null)
                if ((_uv1 != _uv0) && (_uv1 != _uv2))
                    _uv1.removeOnChange(onVertexChange);

            _uv1 = value;

            if (_uv1 != null)
                if ((_uv1 != _uv0) && (_uv1 != _uv2))
                    _uv1.addOnChange(onVertexChange);

            notifyUVChange();
        }

        public function get uv2():UV
        {
            return _uv2;
        }

        public function set uv2(value:UV):void
        {
            if (value == _uv2)
                return;

            if (_uv2 != null)
                if ((_uv2 != _uv1) && (_uv2 != _uv0))
                    _uv2.removeOnChange(onVertexChange);

            _uv2 = value;

            if (_uv2 != null)
                if ((_uv2 != _uv1) && (_uv2 != _uv0))
                    _uv2.addOnChange(onVertexChange);

            notifyUVChange();
        }

        public function get normal():Number3D
        {
            if (_normal == null)
            {
                var d1x:Number = _v1.x - _v0.x;
                var d1y:Number = _v1.y - _v0.y;
                var d1z:Number = _v1.z - _v0.z;
            
                var d2x:Number = _v2.x - _v0.x;
                var d2y:Number = _v2.y - _v0.y;
                var d2z:Number = _v2.z - _v0.z;
            
                var pa:Number = d1y*d2z - d1z*d2y;
                var pb:Number = d1z*d2x - d1x*d2z;
                var pc:Number = d1x*d2y - d1y*d2x;

                var pdd:Number = Math.sqrt(pa*pa + pb*pb + pc*pc);

                _normal = new Number3D(pa / pdd, pb / pdd, pc / pdd);
            }
            return _normal;
        }

        arcane function rad2():Number
        {
            var rv0:Number = _v0._x*_v0._x + _v0._y*_v0._y + _v0._z*_v0._z;
            var rv1:Number = _v1._x*_v1._x + _v1._y*_v1._y + _v1._z*_v1._z;
            var rv2:Number = _v2._x*_v2._x + _v2._y*_v2._y + _v2._z*_v2._z;

            if (rv0 > rv1)
            {
                if (rv0 > rv2)
                    return rv0;
                else
                    return rv2;
            }
            else
            {
                if (rv1 > rv2)
                    return rv1;
                else        
                    return rv2;
            }
        }

        public function Face(v0:Vertex, v1:Vertex, v2:Vertex, material:ITriangleMaterial = null, uv0:UV = null, uv1:UV = null, uv2:UV = null)
        {
            this.v0 = v0;
            this.v1 = v1;
            this.v2 = v2;
            this.material = material;
            this.uv0 = uv0;
            this.uv1 = uv1;
            this.uv2 = uv2;
        }

        private function onVertexChange(event:Event):void
        {
            _normal = null;
            notifyVertexChange();
        }


        public function addOnUVChange(listener:Function):void
        {
            addEventListener("uvchanged", listener, false, 0, true);
        }
        public function removeOnUVChange(listener:Function):void
        {
            removeEventListener("uvchanged", listener, false);
        }
        private var uvchanged:FaceEvent;
        protected function notifyUVChange():void
        {
            if (!hasEventListener("uvchanged"))
                return;

            if (uvchanged == null)
                uvchanged = new FaceEvent("uvchanged", this);
                
            dispatchEvent(uvchanged);
        }

        public function addOnVertexChange(listener:Function):void
        {
            addEventListener("vertexchanged", listener, false, 0, true);
        }
        public function removeOnVertexChange(listener:Function):void
        {
            removeEventListener("vertexchanged", listener, false);
        }
        private var vertexchanged:FaceEvent;
        protected function notifyVertexChange():void
        {
            if (!hasEventListener("vertexchanged"))
                return;

            if (vertexchanged == null)
                vertexchanged = new FaceEvent("vertexchanged", this);
                
            dispatchEvent(vertexchanged);
        }

        public function addOnMaterialChange(listener:Function):void
        {
            addEventListener("materialchanged", listener, false, 0, true);
        }
        public function removeOnMaterialChange(listener:Function):void
        {
            removeEventListener("materialchanged", listener, false);
        }
        private var materialchanged:FaceEvent;
        protected function notifyMaterialChange():void
        {
            if (!hasEventListener("materialchanged"))
                return;

            if (materialchanged == null)
                materialchanged = new FaceEvent("materialchanged", this);
                
            dispatchEvent(materialchanged);
        }

        public function addOnVisibleChange(listener:Function):void
        {
            addEventListener("visiblechanged", listener, false, 0, true);
        }
        public function removeOnVisibleChange(listener:Function):void
        {
            removeEventListener("visiblechanged", listener, false);
        }
        private var visiblechanged:FaceEvent;
        protected function notifyVisibleChange():void
        {
            if (!hasEventListener("visiblechanged"))
                return;

            if (visiblechanged == null)
                visiblechanged = new FaceEvent("visiblechanged", this);
                
            dispatchEvent(visiblechanged);
        }

    }
}
