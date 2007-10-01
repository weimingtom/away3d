package away3d.core.physics
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.geom.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
	import away3d.core.physics.*
    import flash.geom.*;

    public class ReactionTraverser extends Traverser
    {
		public var objects:Array;
		public var particle:Particle3D;
		public var surface:Face3D;
		
        public function ReactionTraverser()
        {
        }
        
		public override function enter(node:Object3D):void
        {
			node.project();
        }
        
        public override function apply(node:Object3D):void
        {
        	  updateBoundingBox(node);
        }
        
		public function updateBoundingBox(node:CollisionObject3D):void
        {        	
        	if (node is Vertices3D) {
				objects = (node as Vertices3D).particles;
				for each (particle in objects) {
					particle.updateBoundingBox();
				}
				if (node is Mesh3D) {
					objects = (node as Mesh3D).surfaces;
					for each (surface in objects) {
						surface.updateBoundingBox();
					}
				}
        	}
			node.updateBoundingBox();
        }
        
    }
}
