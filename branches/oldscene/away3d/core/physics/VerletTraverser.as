package away3d.core.physics
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.geom.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
	import away3d.core.physics.*
    import flash.geom.*;
    import away3d.objects.*;

    public class VerletTraverser extends Traverser
    {
		public var dt:Number;
		public var dp:Number3D;
		public var objects:Array;
		public var particle:Particle3D;
		public var surface:Face3D;
		
        public function VerletTraverser(dt:Number)
        {
            this.dt = dt;
        }
        
        public override function match(node:Object3D):Boolean
        {
        	return (!node.immovable && node.active);
        }
        
		public override function enter(node:Object3D):void
        {
        	integrate(node);
        }
        
		public function integrate(node:CollisionObject3D):void
        {
        	if (!node.fixed) {
				node.dt2 = dt*dt;
				dp = Number3D.scale(Number3D.add(Number3D.sub(node.position, node.oldPosition), Number3D.scale(node.acceleration, dt)), 1 - node.drag)
				node.oldPosition = node.position.clone();
				node.position = Number3D.add(node.position, dp);
				//node.acceleration = new Number3D();
				node.velocity = Number3D.sub(node.position, node.oldPosition);
				node.velocity2 = node.velocity.modulo2;
				
				if (node.detectionMode == DetectionModes.LIMIT_VELOCITY){
					if (node.velocity2 > node.maxVelocity2){
						node.velocity.normalize(node.maxVelocity);
					}
					node.useRaycasting = false;
				} else if (node.detectionMode == DetectionModes.HYBRID_RAYCAST){
					node.useRaycasting = (node.velocity2 > node.maxVelocity2)
				}
        	}
        	if (node is Object3D) {
        		(node as Object3D).project();
	        	if (node is Vertices3D) {
					objects = (node as Vertices3D).particles;
					for each (particle in objects) {
						integrate(particle);
						particle.updateBoundingBox();
					}
					if (node is Mesh3D) {
						objects = (node as Mesh3D).surfaces;
						for each (surface in objects) {
							integrate(surface.v0);
							integrate(surface.v1);
							integrate(surface.v2);
							surface.updateBoundingBox();
						}
					}
	        	}
        	}
        }
        
        public override function leave(node:Object3D):void
        {
        	node.updateBoundingBox();
        	node.transformUpdate = false;
        }
    }
}
