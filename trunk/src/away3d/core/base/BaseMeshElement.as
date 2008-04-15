package away3d.core.base
{
    import away3d.core.*;
    import away3d.materials.*;
    import away3d.core.math.*;
    import away3d.core.base.*
    import away3d.core.utils.*;
    import away3d.events.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;

    public class BaseMeshElement extends LazyEventDispatcher implements IMeshElement
    {
        use namespace arcane;

        arcane var _visible:Boolean = true;

        public function get vertices():Array
        {
            throw new Error("Not implemented");
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

        public function get radius2():Number
        {
            var maxr:Number = 0;
            for each (var vertex:Vertex in vertices)
            {
                var r:Number = vertex._x*vertex._x + vertex._y*vertex._y + vertex._z*vertex._z;
                if (r > maxr)
                    maxr = r;
            }
            return maxr;
        }

        public function get maxX():Number
        {
            return Math.sqrt(radius2);
        }
        
        public function get minX():Number
        {
            return -Math.sqrt(radius2);
        }
        
        public function get maxY():Number
        {
            return Math.sqrt(radius2);
        }
        
        public function get minY():Number
        {
            return -Math.sqrt(radius2);
        }
        
        public function get maxZ():Number
        {
            return Math.sqrt(radius2);
        }
        
        public function get minZ():Number
        {
            return -Math.sqrt(radius2);
        }
        
        public function addOnVertexChange(listener:Function):void
        {
            addEventListener("vertexchanged", listener, false, 0, true);
        }
        public function removeOnVertexChange(listener:Function):void
        {
            removeEventListener("vertexchanged", listener, false);
        }
        private var vertexchanged:MeshElementEvent;
        protected function notifyVertexChange():void
        {
            if (!hasEventListener("vertexchanged"))
                return;

            if (vertexchanged == null)
                vertexchanged = new MeshElementEvent("vertexchanged", this);
                
            dispatchEvent(vertexchanged);
        }

        public function addOnVertexValueChange(listener:Function):void
        {
            addEventListener("vertexvaluechanged", listener, false, 0, true);
        }
        public function removeOnVertexValueChange(listener:Function):void
        {
            removeEventListener("vertexvaluechanged", listener, false);
        }
        private var vertexvaluechanged:MeshElementEvent;
        protected function notifyVertexValueChange():void
        {
            if (!hasEventListener("vertexvaluechanged"))
                return;

            if (vertexvaluechanged == null)
                vertexvaluechanged = new MeshElementEvent("vertexvaluechanged", this);
                
            dispatchEvent(vertexvaluechanged);
        }

        public function addOnVisibleChange(listener:Function):void
        {
            addEventListener("visiblechanged", listener, false, 0, true);
        }
        public function removeOnVisibleChange(listener:Function):void
        {
            removeEventListener("visiblechanged", listener, false);
        }
        private var visiblechanged:MeshElementEvent;
        protected function notifyVisibleChange():void
        {
            if (!hasEventListener("visiblechanged"))
                return;

            if (visiblechanged == null)
                visiblechanged = new MeshElementEvent("visiblechanged", this);
                
            dispatchEvent(visiblechanged);
        }

    }
}
