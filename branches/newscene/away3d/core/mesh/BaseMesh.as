package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.render.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    
    import away3d.objects.*;

    import flash.utils.Dictionary;
    
    /** Base mesh constisting of elements */
    public class BaseMesh extends Object3D
    {
        use namespace arcane;

        public function get elements():Array
        {
            throw new Error("Not implemented");
        }

        private var _vertices:Array;
        private var _verticesDirty:Boolean = true;

        public function get vertices():Array
        {
            if (_verticesDirty)
            {
                _vertices = [];
                var processed:Dictionary = new Dictionary();
                for each (var element:IMeshElement in elements)
                    for each (var vertex:Vertex in element.vertices)
                        if (!processed[vertex])
                        {
                            _vertices.push(vertex);
                            processed[vertex] = true;
                        }
                _verticesDirty = false;
            }
            return _vertices;
        }

        private var _radiusElement:IMeshElement = null;
        private var _radiusDirty:Boolean = false;
        private var _radius:Number = 0;

        public override function get radius():Number
        {
            if (_radiusDirty)
            {
                var mr:Number = 0;
                _radiusElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var r2:Number = element.radius2;
                    if (r2 > mr)
                    {
                        mr = r2;
                        _radiusElement = element;
                    }
                }
                _radius = Math.sqrt(mr);
                _radiusDirty = false;
            }
            return _radius;
        }

        public var material:IMaterial;
        public var pushback:Boolean;
        public var pushfront:Boolean;

        public function BaseMesh(init:Object = null)
        {
            super(init);

            init = Init.parse(init);
            
            material = init.getMaterial("material");
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

        protected function scaleXYZ(scaleX:Number, scaleY:Number, scaleZ:Number):void
        {
            for each (var vertex:Vertex in vertices)
            {
                vertex.x *= scaleX;
                vertex.y *= scaleY;
                vertex.z *= scaleZ;
            }
        }

        protected function addElement(element:IMeshElement):void
        {
            _verticesDirty = true;
                              
            element.addOnVertexChange(onElementVertexChange);
            element.addOnVertexValueChange(onElementVertexValueChange);
                                                
            rememberElementRadius(element);
        }

        protected function removeElement(element:IMeshElement):void
        {
            forgetElementRadius(element);

            element.removeOnVertexValueChange(onElementVertexValueChange);
            element.removeOnVertexChange(onElementVertexChange);

            _verticesDirty = true;
        }

        private function rememberElementRadius(element:IMeshElement):void
        {
            var r2:Number = element.radius2;
            if (r2 > _radius*_radius)
            {
                _radius = Math.sqrt(r2);
                _radiusElement = element;
                _radiusDirty = false;
                notifyRadiusChange();
            }
        }

        private function forgetElementRadius(element:IMeshElement):void
        {
            if (element == _radiusElement)
            {
                _radiusElement = null;
                _radiusDirty = true;
                notifyRadiusChange();
            }
        }

        private function onElementVertexChange(event:MeshElementEvent):void
        {
            var element:IMeshElement = event.element;

            forgetElementRadius(element);
            rememberElementRadius(element);

            _verticesDirty = true;
        }

        private function onElementVertexValueChange(event:MeshElementEvent):void
        {
            var element:IMeshElement = event.element;

            forgetElementRadius(element);
            rememberElementRadius(element);
        }

        private function clear():void
        {
            throw new Error("Not implemented");
        }
    }
}
