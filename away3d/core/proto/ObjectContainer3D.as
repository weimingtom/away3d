package away3d.core.proto
{
	import away3d.core.physics.*;
    import away3d.core.proto.*;
    import away3d.core.math.*;
    import away3d.core.*;

    /** Container node for other objects of the scene */
    public class ObjectContainer3D extends Object3D
    {
    	public var child:Object3D;
        public var children:Array = new Array();
		
        public function ObjectContainer3D(init:Object = null, ...childarray)
        {
            if (init != null && init is Object3D) {
                childarray.push(init);
                init = null;
            }
            super(init);

           	for each (child in childarray)
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
            if (child.parent == this)
                return child;
            child.parent = null;
            children.push(child);
            child._parent = this;
            child.sceneTransform = Matrix3D.multiply(sceneTransform, child.transform);
            child.scenePosition = sceneTransform.transformPoint(child.position);
            
            //special case for immovable
			if (_immovable)
				child.immovable = true;
			
			if (inheritAttributes){
				child.detectionMode = detectionMode;
				child.reactionMode = reactionMode;
				child.magnetic = magnetic;
				child.friction = friction;
				child.bounce = bounce;
				child.traction = traction;
				child.drag = drag;
			}
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
            for each (child in children) {
                if (traverser.match(child))
                {
                    traverser.enter(child);
                    child.traverse(traverser);
                    traverser.leave(child);
                }
            }
            traverser.apply(this);
        }
        
        public override function thrust(val:Number3D):void
		{
			super.thrust(val);
			for each (child in children) 
				updateBoundingBox();
			updateBoundingBox();
		}
        
		public override function updateBoundingBox():void
		{
			minX = 1000000;
			maxX = -1000000;
			minY = 1000000;
			maxY = -1000000;
			minZ = 1000000;
			maxZ = -1000000;
			for each (child in children) {
				if (minX > child.minX)
					minX = child.minX;
				
				if (minY > child.minY)
					minY = child.minY;
				
				if (minZ > child.minZ)
					minZ = child.minZ;
				
				if (maxX < child.maxX)
					maxX = child.maxX;
				
				if (maxY < child.maxY)
					maxY = child.maxY;
				
				if (maxZ < child.maxZ)
					maxZ = child.maxZ;
			}
		}
    }
}
