package away3d.core.physics
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.geom.*;
    import away3d.core.proto.*;
    import away3d.core.physics.*;
    import away3d.core.draw.*;

    import flash.geom.*;

    public class AccelerateTraverser extends Traverser
    {
		public var acceleration:Number3D;
		public var accelerations:Array;
		public var objects:Array;
		public var child:Object3D;
		public var vertex:Vertex3D;;
		public var face:Face3D;
		
        public function AccelerateTraverser(accelerations:Array)
        {
        	this.accelerations = accelerations;
        }
        
        public override function match(node:Object3D):Boolean
        {
        	return (!node.immovable && node.active);
        }
        
        public override function enter(node:Object3D):void
        {
        	accelerations = node.accelerations;
        }
        
		public override function apply(node:Object3D):void
        {
        	for each (acceleration in accelerations) {
				applyAccelerations(node);
	        }
        }
        
        public override function leave(node:Object3D):void
        {
        	accelerations = (node.parent as ObjectContainer3D).accelerations;
        }
        
        public function applyAccelerations(node:CollisionObject3D):void
        {
    		if (node.fixed) {
				if (node is ObjectContainer3D) {
		        	objects = (node as ObjectContainer3D).children;
					for each (child in objects)
						apply(child);
				} else if (node is Vertices3D) {
					objects = (node as Vertices3D).particles;
					for each (vertex in objects)
						applyAccelerations(vertex);
					if (node is Mesh3D) {
						objects = (node as Mesh3D).surfaces;
						for each (face in objects)
							applyAccelerations(face);
					}
				}
			} else {
				 node.acceleration = acceleration;
		   	}
        	
        }
    }
}
