package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    
    import flash.events.Event;
    import flash.geom.*;
    import flash.utils.*;

    /** Mesh's triangle face */
    public class Face extends BaseMeshElement
    {
        use namespace arcane;

        public var extra:Object;

        //public static var defaultExtraClass:Class;

        arcane var _v0:Vertex;
        arcane var _v1:Vertex;
        arcane var _v2:Vertex;
        arcane var _uv0:UV;
        arcane var _uv1:UV;
        arcane var _uv2:UV;
        arcane var _material:ITriangleMaterial;
        arcane var _back:ITriangleMaterial;
        arcane var _dt:DrawTriangle = new DrawTriangle();
        private var _normal:Number3D;
		
		public var parent:Mesh;
		
        public override function get vertices():Array
        {
            return [_v0, _v1, _v2];
        }
		
		public function get uvs():Array
        {
            return [_uv0, _uv1, _uv2];
        }
        
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
                    _v0.removeOnChange(onVertexValueChange);

            _v0 = value;

            if (_v0 != null)
                if ((_v0 != _v1) && (_v0 != _v2))
                    _v0.addOnChange(onVertexValueChange);

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
                    _v1.removeOnChange(onVertexValueChange);

            _v1 = value;

            if (_v1 != null)
                if ((_v1 != _v0) && (_v1 != _v2))
                    _v1.addOnChange(onVertexValueChange);

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
                    _v2.removeOnChange(onVertexValueChange);

            _v2 = value;

            if (_v2 != null)
                if ((_v2 != _v1) && (_v2 != _v0))
                    _v2.addOnChange(onVertexValueChange);

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
			
            notifyMaterialChange();
        }

        public function get back():ITriangleMaterial
        {
            return _back;
        }

        public function set back(value:ITriangleMaterial):void
        {
            if (value == _back)
                return;

            _back = value;

            // notifyBackChange(); TODO
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
                    _uv0.removeOnChange(onUVChange);

            _uv0 = value;

            if (_uv0 != null)
                if ((_uv0 != _uv1) && (_uv0 != _uv2))
                    _uv0.addOnChange(onUVChange);
			
            notifyMappingChange();
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
                    _uv1.removeOnChange(onUVChange);

            _uv1 = value;

            if (_uv1 != null)
                if ((_uv1 != _uv0) && (_uv1 != _uv2))
                    _uv1.addOnChange(onUVChange);
			
            notifyMappingChange();
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
                    _uv2.removeOnChange(onUVChange);

            _uv2 = value;

            if (_uv2 != null)
                if ((_uv2 != _uv1) && (_uv2 != _uv0))
                    _uv2.addOnChange(onUVChange);
			
            notifyMappingChange();
        }
		
		internal var a:Number;
		internal var b:Number;
		internal var c:Number;
		internal var s:Number;
		
        public function get area():Number
        {
            // not quick enough
            a = v0.position.distance(v1.position);
            b = v1.position.distance(v2.position);
            c = v2.position.distance(v0.position);
            s = (a + b + c) / 2;
            return Math.sqrt(s*(s - a)*(s - b)*(s - c));
        }
        
        public function get normal():Number3D
        {
            if (!_normal) {
            	_normal = new Number3D();
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

                _normal.x = pa / pdd;
                _normal.y = pb / pdd;
                _normal.z = pc / pdd;
            }
            return _normal;
        }
		
        public override function get radius2():Number
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

        public function get maxU():Number
        {
            if (_uv0._u > _uv1._u)
            {
                if (_uv0.u > _uv2._u)
                    return _uv0._u;
                else
                    return _uv2._u;
            }
            else
            {
                if (_uv1._u > _uv2._u)
                    return _uv1._u;
                else
                    return _uv2._u;
            }
        }
        
        public function get minU():Number
        {
            if (_uv0._u < _uv1._u)
            {
                if (_uv0._u < _uv2._u)
                    return _uv0._u;
                else
                    return _uv2._u;
            }
            else
            {
                if (_uv1._u < _uv2._u)
                    return _uv1._u;
                else
                    return _uv2._u;
            }
        }
        
        public function get maxV():Number
        {
            if (_uv0._v > _uv1._v)
            {
                if (_uv0._v > _uv2._v)
                    return _uv0._v;
                else
                    return _uv2._v;
            }
            else
            {
                if (_uv1._v > _uv2._v)
                    return _uv1._v;
                else
                    return _uv2._v;
            }
        }
        
        public function get minV():Number
        {
            if (_uv0._v < _uv1._v)
            {
                if (_uv0._v < _uv2._v)
                    return _uv0._v;
                else
                    return _uv2._v;
            }
            else
            {
                if (_uv1._v < _uv2._v)
                    return _uv1._v;
                else
                    return _uv2._v;
            }
        }
        
        public override function get maxX():Number
        {
            if (_v0._x > _v1._x)
            {
                if (_v0._x > _v2._x)
                    return _v0._x;
                else
                    return _v2._x;
            }
            else
            {
                if (_v1._x > _v2._x)
                    return _v1._x;
                else
                    return _v2._x;
            }
        }
        
        public override function get minX():Number
        {
            if (_v0._x < _v1._x)
            {
                if (_v0._x < _v2._x)
                    return _v0._x;
                else
                    return _v2._x;
            }
            else
            {
                if (_v1._x < _v2._x)
                    return _v1._x;
                else
                    return _v2._x;
            }
        }
        
        public override function get maxY():Number
        {
            if (_v0._y > _v1._y)
            {
                if (_v0._y > _v2._y)
                    return _v0._y;
                else
                    return _v2._y;
            }
            else
            {
                if (_v1._y > _v2._y)
                    return _v1._y;
                else
                    return _v2._y;
            }
        }
        
        public override function get minY():Number
        {
            if (_v0._y < _v1._y)
            {
                if (_v0._y < _v2._y)
                    return _v0._y;
                else
                    return _v2._y;
            }
            else
            {
                if (_v1._y < _v2._y)
                    return _v1._y;
                else
                    return _v2._y;
            }
        }
        
        public override function get maxZ():Number
        {
            if (_v0._z > _v1._z)
            {
                if (_v0._z > _v2._z)
                    return _v0._z;
                else
                    return _v2._z;
            }
            else
            {
                if (_v1._z > _v2._z)
                    return _v1._z;
                else
                    return _v2._z;
            }
        }
        
        public override function get minZ():Number
        {
            if (_v0._z < _v1._z)
            {
                if (_v0._z < _v2._z)
                    return _v0._z;
                else
                    return _v2._z;
            }
            else
            {
                if (_v1._z < _v2._z)
                    return _v1._z;
                else
                    return _v2._z;
            }
        }

        public function invert():void
        {
            var v1:Vertex = this._v1;
            var v2:Vertex = this._v2;
            var uv1:UV = this._uv1;
            var uv2:UV = this._uv2;

            this._v1 = v2;
            this._v2 = v1;
            this._uv1 = uv2;
            this._uv2 = uv1;
			
            notifyVertexChange();
            notifyMappingChange();
        }
        
        arcane var _mappingmaterial:IUVMaterial;
		arcane var _bitmapRect:Rectangle;
		
        arcane function front(projection:Projection):Number
        {
            var sv0:ScreenVertex = _v0.project(projection);
            var sv1:ScreenVertex = _v1.project(projection);
            var sv2:ScreenVertex = _v2.project(projection);
                
            return (sv0.x*(sv2.y - sv1.y) + sv1.x*(sv0.y - sv2.y) + sv2.x*(sv1.y - sv0.y));
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
            _dt.face = this;
            
            //if (defaultExtraClass != null)
            //    extra = new defaultExtraClass(this);
        }

        private function onVertexChange(event:Event):void
        {
            _normal = null;
            notifyVertexChange();
        }

        private function onVertexValueChange(event:Event):void
        {
            _normal = null;
            notifyVertexValueChange();
        }

        private function onUVChange(event:Event):void
        {
            notifyMappingChange();
        }

        public function addOnMappingChange(listener:Function):void
        {
            addEventListener("mappingchanged", listener, false, 0, true);
        }
        public function removeOnMappingChange(listener:Function):void
        {
            removeEventListener("mappingchanged", listener, false);
        }
        private var mappingchanged:FaceEvent;
        protected function notifyMappingChange():void
        {
        	_dt.texturemapping = null;
			
            if (!hasEventListener("mappingchanged"))
                return;

            if (mappingchanged == null)
                mappingchanged = new FaceEvent("mappingchanged", this);
                
            dispatchEvent(mappingchanged);
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
        	_dt.texturemapping = null;
        	
            if (!hasEventListener("materialchanged"))
                return;

            if (materialchanged == null)
                materialchanged = new FaceEvent("materialchanged", this);
                
            dispatchEvent(materialchanged);
        }

    }
}
