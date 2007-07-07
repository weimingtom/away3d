package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.math.*;

    /** Container node for other objects of the scene */
    public class ObjectContainer3D extends Object3D
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
                var mr:Number = 0;
                _radiusChild = null;
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

        public function scale(scale:Number):void
        {
            for each (var child:Object3D in children)
            {
                child.x *= scale;
                child.y *= scale;
                child.z *= scale;
                if (child is ObjectContainer3D)
                    (child as ObjectContainer3D).scale(scale);
            }
        }
    
        public function addChildren(...childarray):void
        {
            for each (var child:Object3D in childarray)
                addChild(child);
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
            children.push(child);

            child.addOnTransformChange(onChildChange);
            child.addOnRadiusChange(onChildChange);

            rememberChild(child);
        }

        arcane function internalRemoveChild(child:Object3D):void
        {
            var index:int = children.indexOf(child);
            if (index == -1)
                return;

            forgetChild(child);

            child.removeOnTransformChange(onChildChange);
            child.removeOnRadiusChange(onChildChange);

            children.splice(index, 1);
        }

        private function onChildChange(event:Object3DEvent):void
        {
            var child:Object3D = event.object;

            forgetChild(child);
            rememberChild(child);
        }
        
        private function forgetChild(child:Object3D):void
        {
            if (child == _radiusChild)
            {
                _radiusChild = null;
                _radiusDirty = true;
                notifyRadiusChange();
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
                notifyRadiusChange();
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
            traverser.apply(this);

            for each (var child:Object3D in children)
                if (traverser.match(child))
                {
                    traverser.enter(child);
                    child.traverse(traverser);
                    traverser.leave();
                }
        }

    }
}
