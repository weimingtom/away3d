package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.render.IPrimitiveProvider;

    /** Container node for other objects of the scene */
    public class ObjectContainer3D extends Object3D implements IPrimitiveProvider
    {
        use namespace arcane;

        private var _children:Array = new Array();
		
        public function get children():Array
        {
            return _children;
        }
        
        private var _radiusChild:Object3D = null;
        private var _radiusDirty:Boolean = false;
        private var _radius:Number = 0;

        public override function get radius():Number
        {
            if (_radiusDirty)
            {
                _radiusChild = null;
                var mr:Number = 0;
                for each (var child:Object3D in _children)
                {
                    var r:Number = child.parentradius;
                    if (r > mr)
                    {
                        mr = r;
                        _radiusChild = child;
                    }
                }
                _radius = mr;
                _radiusDirty = false;
            }
            return _radius;
        }

        private var _maxXChild:Object3D = null;
        private var _maxXDirty:Boolean = false;
        private var _maxX:Number = -Infinity;

        public override function get maxX():Number
        {
            if (_maxXDirty)
            {
                _maxXChild = null;
                var extrval:Number = -Infinity;
                for each (var child:Object3D in _children)
                {
                    var val:Number = child.parentmaxX;
                    if (val > extrval)
                    {
                        extrval = val;
                        _maxXChild = child;
                    }
                }
                _maxX = extrval;
                _maxXDirty = false;
            }
            return _maxX;
        }

        private var _minXChild:Object3D = null;
        private var _minXDirty:Boolean = false;
        private var _minX:Number = Infinity;

        public override function get minX():Number
        {
            if (_minXDirty)
            {
                _minXChild = null;
                var extrval:Number = Infinity;
                for each (var child:Object3D in _children)
                {
                    var val:Number = child.parentminX;
                    if (val < extrval)
                    {
                        extrval = val;
                        _minXChild = child;
                    }
                }
                _minX = extrval;
                _minXDirty = false;
            }
            return _minX;
        }

        private var _maxYChild:Object3D = null;
        private var _maxYDirty:Boolean = false;
        private var _maxY:Number = -Infinity;

        public override function get maxY():Number
        {
            if (_maxYDirty)
            {
                var extrval:Number = -Infinity;
                _maxYChild = null;
                for each (var child:Object3D in _children)
                {
                    var val:Number = child.parentmaxY;
                    if (val > extrval)
                    {
                        extrval = val;
                        _maxYChild = child;
                    }
                }
                _maxY = extrval;
                _maxYDirty = false;
            }
            return _maxY;
        }

        private var _minYChild:Object3D = null;
        private var _minYDirty:Boolean = false;
        private var _minY:Number = Infinity;

        public override function get minY():Number
        {
            if (_minYDirty)
            {
                var extrval:Number = Infinity;
                _minYChild = null;
                for each (var child:Object3D in _children)
                {
                    var val:Number = child.parentminY;
                    if (val < extrval)
                    {
                        extrval = val;
                        _minYChild = child;
                    }
                }
                _minY = extrval;
                _minYDirty = false;
            }
            return _minY;
        }

        private var _maxZChild:Object3D = null;
        private var _maxZDirty:Boolean = false;
        private var _maxZ:Number = -Infinity;

        public override function get maxZ():Number
        {
            if (_maxZDirty)
            {
                var extrval:Number = -Infinity;
                _maxZChild = null;
                for each (var child:Object3D in _children)
                {
                    var val:Number = child.parentmaxZ;
                    if (val > extrval)
                    {
                        extrval = val;
                        _maxZChild = child;
                    }
                }
                _maxZ = extrval;
                _maxZDirty = false;
            }
            return _maxZ;
        }

        private var _minZChild:Object3D = null;
        private var _minZDirty:Boolean = false;
        private var _minZ:Number = Infinity;

        public override function get minZ():Number
        {
            if (_minZDirty)
            {
                var extrval:Number = Infinity;
                _minZChild = null;
                for each (var child:Object3D in _children)
                {
                    var val:Number = child.parentminZ;
                    if (val < extrval)
                    {
                        extrval = val;
                        _minZChild = child;
                    }
                }
                _minZ = extrval;
                _minZDirty = false;
            }
            return _minZ;
        }
        
        public function ObjectContainer3D(init:Object = null, ...childarray)
        {
            if (init != null)
                if (init is Object3D)
                {
                    addChild(init as Object3D);
                    init = null;
                }

            super(init);

            for each (var child:Object3D in childarray)
                addChild(child);
        }

        public override function scale(scale:Number):void
        {
            for each (var child:Object3D in children)
            {
                child.x *= scale;
                child.y *= scale;
                child.z *= scale;
                child.scale(scale);
            }
        }
    
        public function addChildren(...childarray):void
        {
            for each (var child:Object3D in childarray)
                addChild(child);
        }

        public function movePivot(dx:Number, dy:Number, dz:Number):void
        {
        	
            for each (var child:Object3D in _children)
            {
                child.x -= dx;
                child.y -= dy;
                child.z -= dz;
            }
            
            var dV:Number3D = new Number3D(dx, dy, dz);
            dV.rotate(dV.clone(), _transform);
            dV.add(dV, position);
            moveTo(dV);
        }

        public function addChild(child:Object3D):void
        {
            if (child == null)
                throw new Error("ObjectContainer3D.addChild(null)");
            if (child.parent == this)
                return;
            child.parent = this;
        }

        public function removeChild(child:Object3D):void
        {
            if (child == null)
                throw new Error("ObjectContainer3D.removeChild(null)");
            if (child.parent != this)
                return;
            child.parent = null;
        }

        arcane function internalAddChild(child:Object3D):void
        {
            _children.push(child);

            child.addOnTransformChange(onChildChange);
            child.addOnRadiusChange(onChildChange);

            rememberChild(child);

            launchNotifies();
        }

        arcane function internalRemoveChild(child:Object3D):void
        {
            var index:int = children.indexOf(child);
            if (index == -1)
                return;

            forgetChild(child);

            child.removeOnTransformChange(onChildChange);
            child.removeOnRadiusChange(onChildChange);

            _children.splice(index, 1);

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

        private function onChildChange(event:Object3DEvent):void
        {
            var child:Object3D = event.object;

            forgetChild(child);
            rememberChild(child);

            launchNotifies();
        }
        
        private function forgetChild(child:Object3D):void
        {
            if (child == _radiusChild)
            {
                _radiusChild = null;
                _radiusDirty = true;
                _needNotifyRadiusChange = true;
            }
            if (child == _maxXChild)
            {
                _maxXChild = null;
                _maxXDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (child == _minXChild)
            {
                _minXChild = null;
                _minXDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (child == _maxYChild)
            {
                _maxYChild = null;
                _maxYDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (child == _minYChild)
            {
                _minYChild = null;
                _minYDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (child == _maxZChild)
            {
                _maxZChild = null;
                _maxZDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (child == _minZChild)
            {
                _minZChild = null;
                _minZDirty = true;
                _needNotifyDimensionsChange = true;
            }
        }

        private function rememberChild(child:Object3D):void
        {
            var r:Number = child.parentradius;
            if (r > _radius)
            {
                _radius = r;
                _radiusChild = child;
                _radiusDirty = false;
                _needNotifyRadiusChange = true;
            }
            var mxX:Number = child.parentmaxX;
            if (mxX > _maxX)
            {
                _maxX = mxX;
                _maxXChild = child;
                _maxXDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mnX:Number = child.parentminX;
            if (mnX < _minX)
            {
                _minX = mnX;
                _minXChild = child;
                _minXDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mxY:Number = child.parentmaxY;
            if (mxY > _maxY)
            {
                _maxY = mxY;
                _maxYChild = child;
                _maxYDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mnY:Number = child.parentminY;
            if (mnY < _minY)
            {
                _minY = mnY;
                _minYChild = child;
                _minYDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mxZ:Number = child.parentmaxZ;
            if (mxZ > _maxZ)
            {
                _maxZ = mxZ;
                _maxZChild = child;
                _maxZDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mnZ:Number = child.parentminZ;
            if (mnZ < _minZ)
            {
                _minZ = mnZ;
                _minZChild = child;
                _minZDirty = false;
                _needNotifyDimensionsChange = true;
            }
        }

        public function getChildByName(name:String):Object3D
        {
            for each (var child:Object3D in children)
                if (child.name == name)
                    return child;

            return null;
        }
    
        public function removeChildByName(name:String):void
        {
            removeChild(getChildByName(name));
        }

        public override function traverse(traverser:Traverser):void
        {
            if (traverser.match(this))
            {
                traverser.enter(this);
                traverser.apply(this);
                for each (var child:Object3D in children)
                    child.traverse(traverser);
                traverser.leave(this);
            }
        }

        public override function clone(object:* = null):*
        {
            var container:ObjectContainer3D = object || new ObjectContainer3D();
            super.clone(container);

            for each (var child:Object3D in children)
                container.addChild(child.clone());
                
            return container;
        }

    }
}
