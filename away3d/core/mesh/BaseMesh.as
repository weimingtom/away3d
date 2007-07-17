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
                _radiusElement = null;
                var mr:Number = 0;
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

        private var _maxXElement:IMeshElement = null;
        private var _maxXDirty:Boolean = false;
        private var _maxX:Number = -Infinity;

        public override function get maxX():Number
        {
            if (_maxXDirty)
            {
                _maxXElement = null;
                var extrval:Number = -Infinity;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.maxX;
                    if (val > extrval)
                    {
                        extrval = val;
                        _maxXElement = element;
                    }
                }
                _maxX = extrval;
                _maxXDirty = false;
            }
            return _maxX;
        }

        private var _minXElement:IMeshElement = null;
        private var _minXDirty:Boolean = false;
        private var _minX:Number = Infinity;

        public override function get minX():Number
        {
            if (_minXDirty)
            {
                _minXElement = null;
                var extrval:Number = Infinity;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.minX;
                    if (val < extrval)
                    {
                        extrval = val;
                        _minXElement = element;
                    }
                }
                _minX = extrval;
                _minXDirty = false;
            }
            return _minX;
        }

        private var _maxYElement:IMeshElement = null;
        private var _maxYDirty:Boolean = false;
        private var _maxY:Number = -Infinity;

        public override function get maxY():Number
        {
            if (_maxYDirty)
            {
                var extrval:Number = -Infinity;
                _maxYElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.maxY;
                    if (val > extrval)
                    {
                        extrval = val;
                        _maxYElement = element;
                    }
                }
                _maxY = extrval;
                _maxYDirty = false;
            }
            return _maxY;
        }

        private var _minYElement:IMeshElement = null;
        private var _minYDirty:Boolean = false;
        private var _minY:Number = Infinity;

        public override function get minY():Number
        {
            if (_minYDirty)
            {
                var extrval:Number = Infinity;
                _minYElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.minY;
                    if (val < extrval)
                    {
                        extrval = val;
                        _minYElement = element;
                    }
                }
                _minY = extrval;
                _minYDirty = false;
            }
            return _minY;
        }

        private var _maxZElement:IMeshElement = null;
        private var _maxZDirty:Boolean = false;
        private var _maxZ:Number = -Infinity;

        public override function get maxZ():Number
        {
            if (_maxZDirty)
            {
                var extrval:Number = -Infinity;
                _maxZElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.maxZ;
                    if (val > extrval)
                    {
                        extrval = val;
                        _maxZElement = element;
                    }
                }
                _maxZ = extrval;
                _maxZDirty = false;
            }
            return _maxZ;
        }

        private var _minZElement:IMeshElement = null;
        private var _minZDirty:Boolean = false;
        private var _minZ:Number = Infinity;

        public override function get minZ():Number
        {
            if (_minZDirty)
            {
                var extrval:Number = Infinity;
                _minZElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.minZ;
                    if (val < extrval)
                    {
                        extrval = val;
                        _minZElement = element;
                    }
                }
                _minZ = extrval;
                _minZDirty = false;
            }
            return _minZ;
        }

        public var pushback:Boolean;
        public var pushfront:Boolean;

        public function BaseMesh(init:Object = null)
        {
            super(init);

            init = Init.parse(init);
            
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

            launchNotifies();
        }

        protected function removeElement(element:IMeshElement):void
        {
            forgetElementRadius(element);

            element.removeOnVertexValueChange(onElementVertexValueChange);
            element.removeOnVertexChange(onElementVertexChange);

            _verticesDirty = true;

            launchNotifies();
        }

        private var _needNotifyRadiusChange:Boolean = false;
        private var _needNotifyDimensionsChange:Boolean = false;

        private function launchNotifies():void
        {
            if (_needNotifyRadiusChange)
            {
                _needNotifyRadiusChange = false;
                notifyRadiusChange();
            }
            if (_needNotifyDimensionsChange)
            {
                _needNotifyDimensionsChange = false;
                notifyDimensionsChange();
            }
        }

        private function rememberElementRadius(element:IMeshElement):void
        {
            var r2:Number = element.radius2;
            if (r2 > _radius*_radius)
            {
                _radius = Math.sqrt(r2);
                _radiusElement = element;
                _radiusDirty = false;
                _needNotifyRadiusChange = true;
            }
            var mxX:Number = element.maxX;
            if (mxX > _maxX)
            {
                _maxX = mxX;
                _maxXElement = element;
                _maxXDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mnX:Number = element.minX;
            if (mnX < _minX)
            {
                _minX = mnX;
                _minXElement = element;
                _minXDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mxY:Number = element.maxY;
            if (mxY > _maxY)
            {
                _maxY = mxY;
                _maxYElement = element;
                _maxYDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mnY:Number = element.minY;
            if (mnY < _minY)
            {
                _minY = mnY;
                _minYElement = element;
                _minYDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mxZ:Number = element.maxZ;
            if (mxZ > _maxZ)
            {
                _maxZ = mxZ;
                _maxZElement = element;
                _maxZDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mnZ:Number = element.minZ;
            if (mnZ < _minZ)
            {
                _minZ = mnZ;
                _minZElement = element;
                _minZDirty = false;
                _needNotifyDimensionsChange = true;
            }
        }

        private function forgetElementRadius(element:IMeshElement):void
        {
            if (element == _radiusElement)
            {
                _radiusElement = null;
                _radiusDirty = true;
                _needNotifyRadiusChange = true;
            }
            if (element == _maxXElement)
            {
                _maxXElement = null;
                _maxXDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _minXElement)
            {
                _minXElement = null;
                _minXDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _maxYElement)
            {
                _maxYElement = null;
                _maxYDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _minYElement)
            {
                _minYElement = null;
                _minYDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _maxZElement)
            {
                _maxZElement = null;
                _maxZDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _minZElement)
            {
                _minZElement = null;
                _minZDirty = true;
                _needNotifyDimensionsChange = true;
            }
        }

        private function onElementVertexChange(event:MeshElementEvent):void
        {
            var element:IMeshElement = event.element;

            forgetElementRadius(element);
            rememberElementRadius(element);

            _verticesDirty = true;

            launchNotifies();
        }

        private function onElementVertexValueChange(event:MeshElementEvent):void
        {
            var element:IMeshElement = event.element;

            forgetElementRadius(element);
            rememberElementRadius(element);

            launchNotifies();
        }

        private function clear():void
        {
            throw new Error("Not implemented");
        }
    }
}
