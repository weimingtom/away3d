package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;
    
    import flash.events.Event;

    /** Mesh's segment */
    public class Segment extends BaseMeshElement
    {
        use namespace arcane;

        public var extra:Object;

        arcane var _v0:Vertex;
        arcane var _v1:Vertex;
        arcane var _material:ISegmentMaterial;
        arcane var _ds:DrawSegment = new DrawSegment();
		
		public var parent:BaseMesh;
		
        public override function get vertices():Array
        {
            return [_v0, _v1];
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
                if (_v0 != _v1)
                    _v0.removeOnChange(onVertexValueChange);

            _v0 = value;

            if (_v0 != null)
                if (_v0 != _v1)
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
                if (_v1 != _v0)
                    _v1.removeOnChange(onVertexValueChange);

            _v1 = value;

            if (_v1 != null)
                if (_v1 != _v0)
                    _v1.addOnChange(onVertexValueChange);

            notifyVertexChange();
        }

        public function get material():ISegmentMaterial
        {
            return _material;
        }

        public function set material(value:ISegmentMaterial):void
        {
            if (value == _material)
                return;

            _material = value;

            notifyMaterialChange();
        }

        public override function get radius2():Number
        {
            var rv0:Number = _v0._x*_v0._x + _v0._y*_v0._y + _v0._z*_v0._z;
            var rv1:Number = _v1._x*_v1._x + _v1._y*_v1._y + _v1._z*_v1._z;

            if (rv0 > rv1)
                return rv0;
            else
                return rv1;
        }

        public override function get maxX():Number
        {
            if (_v0._x > _v1._x)
                return _v0._x;
            else
                return _v1._x;
        }
        
        public override function get minX():Number
        {
            if (_v0._x < _v1._x)
                return _v0._x;
            else
                return _v1._x;
        }
        
        public override function get maxY():Number
        {
            if (_v0._y > _v1._y)
                return _v0._y;
            else
                return _v1._y;
        }
        
        public override function get minY():Number
        {
            if (_v0._y < _v1._y)
                return _v0._y;
            else
                return _v1._y;
        }
        
        public override function get maxZ():Number
        {
            if (_v0._z > _v1._z)
                return _v0._z;
            else
                return _v1._z;
        }
        
        public override function get minZ():Number
        {
            if (_v0._z < _v1._z)
                return _v0._z;
            else
                return _v1._z;
        }

        public function Segment(v0:Vertex, v1:Vertex, material:ISegmentMaterial = null)
        {
            this.v0 = v0;
            this.v1 = v1;
            this.material = material;
        }

        private function onVertexChange(event:Event):void
        {
            notifyVertexChange();
        }

        private function onVertexValueChange(event:Event):void
        {
            notifyVertexValueChange();
        }

        public function addOnMaterialChange(listener:Function):void
        {
            addEventListener("materialchanged", listener, false, 0, true);
        }
        public function removeOnMaterialChange(listener:Function):void
        {
            removeEventListener("materialchanged", listener, false);
        }
        private var materialchanged:SegmentEvent;
        protected function notifyMaterialChange():void
        {
            if (!hasEventListener("materialchanged"))
                return;

            if (materialchanged == null)
                materialchanged = new SegmentEvent("materialchanged", this);
                
            dispatchEvent(materialchanged);
        }

    }
}
