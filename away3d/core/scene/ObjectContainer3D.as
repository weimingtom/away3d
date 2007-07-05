package away3d.core.scene
{
    import away3d.core.*;

    /** Container node for other objects of the scene */
    public class ObjectContainer3D extends Object3D
    {
        use namespace arcane;

        arcane var _children:Array = new Array();

        public function get children():Array
        {
            return _children;
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
            //internalAddChild(child);
            child.parent = this;
        }

        public function internalAddChild(child:Object3D):void
        {
            children.push(child);
        }

        public function removeChild(child:Object3D):void
        {
            if (child == null)
                throw new Error("ObjectContainer3D.removeChild(null)");
            if (child.parent != this)
                return;
            //internalRemoveChild(child);
            child.parent = null;
        }

        arcane function internalRemoveChild(child:Object3D):void
        {
            var index:int = children.indexOf(child);
            if (index == -1)
                return;
            children.splice(index, 1);
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
