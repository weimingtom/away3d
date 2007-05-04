package away3d.core.proto
{
    import away3d.core.proto.*;
    import away3d.core.*;

    public class ObjectContainer3D extends Object3D
    {
        public var children:Array = new Array();
        
        public function ObjectContainer3D(name:String = null, ...childarray)
        {                                       
            super(name);

            for each (var child:Object3D in childarray)
                addChild(child);
        }

        public function addChild(child:Object3D, name:String = null):Object3D
        {
            if (child == null)
                throw new Error("ObjectContainer3D.addChild(null)");
            if (name != null)
                child.name = name;
            children.push(child);
            return child;
        }

        public function removeChild(child:Object3D):void
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
