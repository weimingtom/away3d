package away3d.core.proto
{
    import away3d.core.proto.*;
    import away3d.core.*;

    /** Container node for other objects of the scene */
    public class ObjectContainer3D extends Object3D
    {
        public var children:Array = new Array();
        
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

        public function addChildren(...childarray):void
        {
            for each (var child:Object3D in childarray)
                addChild(child);
        }

        public function addChild(child:Object3D):Object3D
        {
            if (child == null)
                throw new Error("ObjectContainer3D.addChild(null)");
            if (child._parent == this)
                return child;
            children.push(child);
            child._parent = this;
            return child; // I think we don't need it - AZ
        }

        public function removeChild(child:Object3D):void
        {
            if (child._parent != this)
                throw new Error("Child doesn't belong to container");
            var index:int = children.indexOf(child);
            if (index == -1)
                throw new Error("Child not found in children list");
            children.splice(index, 1);
            child._parent = null;
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
