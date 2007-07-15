package away3d.core.physics
{
	import away3d.core.*;
	import away3d.core.proto.*;
	import away3d.core.geom.*;
	import away3d.core.math.*;
	import away3d.core.physics.*;
	import flash.net.ObjectEncoding;
	
	import away3d.objects.*;
	
	public final class CollisionDetection
	{
		public function CollisionDetection()
		{
		}
		
		public static function findInnerCollisions(node:Object3D):void
		{
			if (node is ObjectContainer3D) {
				findInnerBoundsCollisions((node as ObjectContainer3D).children, solveContainerContainer);
    		} else if (node is Vertices3D){
    			findInnerBoundsCollisions((node as Vertices3D).particles, solveParticleParticle);
    			if (node is Mesh3D){
    				var n:Mesh3D = (node as Mesh3D);
    				findInterBoundsCollisions(n.particles, n.surfaces, solveParticleSurface);
    				//findInterBoundsCollisions(n.surfaces, solveSurfaceSurface);
    			}
    		}
		}

		public static function findInterCollisions(node1:Object3D, node2:Object3D):void
		{
			var n1:ObjectContainer3D;
			var n2:Object3D;
			var n3:Vertices3D;
			var n4:Vertices3D;
			if (node1 is ObjectContainer3D) {
				n1 = (node1 as ObjectContainer3D);
				n2 = node2;
			} else if (node2 is ObjectContainer3D) {
				n1 = (node2 as ObjectContainer3D)
				n2 = node1;
			} else {
				//eventuality if neither node1 or node2 is ObjectContainer3D
				if (node1 is Vertices3D && node2 is Vertices3D) {
					n3 = node1 as Vertices3D;
					n4 = node2 as Vertices3D;
	    			findInterBoundsCollisions(n3.particles, n4.particles, solveParticleParticle);
	    			if (n3 is Mesh3D) {
	    				findInterBoundsCollisions(n4.particles, (n3 as Mesh3D).surfaces, solveParticleSurface);
	    				if (n4 is Mesh3D) {
	    					findInterBoundsCollisions(n3.particles, (n4 as Mesh3D).surfaces, solveParticleSurface);
	    					//findInterBoundsCollisions((n3 as Mesh3D).surfaces, (n4 as Mesh3D).surfaces, solveSurfaceSurface);	    					
	    				}
	    			} else if (n4 is Mesh3D) {
	    				findInterBoundsCollisions(n3.particles, (n4 as Mesh3D).surfaces, solveParticleSurface);	    				
	    			}
				} 
				
				return;
			}
			
			//eventuality if either node1 or node2 is ObjectContainer3D
			if (n2 is ObjectContainer3D) {
				findInterBoundsCollisions(n1.children, (n2 as ObjectContainer3D).children, solveContainerContainer);				
			} else if (n2 is Vertices3D) {
    			findInterBoundsCollisions(n1.children, (n2 as Vertices3D).particles, solveContainerParticle);
    			if (n2 is Mesh3D) {
    				findInterBoundsCollisions(n1.children, (n2 as Mesh3D).surfaces, solveContainerSurface);
    			}
			}
		}
		
		public static function findInnerBoundsCollisions(objects:Array, solveFunc:Function):void
		{
			if (objects.length < 2)
				return;
			//TODO: something here needs to be ordered
			var length:Number = objects.length;
			var i:Number = 0;
			var j:Number = 0;
			var obj1:CollisionObject3D;
			var obj2:CollisionObject3D;
			while(i < length){
				obj1 = objects[i];
				if (obj1.collidable && obj1.active){
					j = i;
					while(++j < length){
						obj2 = objects[j];
						if (obj2.collidable && obj2.active){
							if (obj1.minX > obj2.maxX || obj1.maxX < obj2.minX){
								continue;
							}
							if (obj1.minY > obj2.maxY || obj1.maxY < obj2.minY){
								continue;
							}
							if (obj1.minZ < obj2.maxZ && obj1.maxZ > obj2.minZ){
								solveFunc(obj1, obj2);
							}
						}
					}
				}
				i++;
			}
		}
		
		public static function findInterBoundsCollisions(objects1:Array, objects2:Array, solveFunc:Function):void
		{
			if (objects1.length == 0 || objects2.length == 0)
				return;
			//TODO: something here needs to be ordered. Possibly all bounding boxes that require solving?
			
			var object1:CollisionObject3D;
			var object2:CollisionObject3D;
			for each (object1 in objects1){
				if (object1.collidable && object1.active){
					for each (object2 in objects2){
						if (object2.collidable && object2.active){
							if (object1.minX > object2.maxX || object1.maxX < object2.minX){
								continue;
							}
							if (object1.minY > object2.maxY || object1.maxY < object2.minY){
								continue;
							}
							if (object1.minZ < object2.maxZ && object1.maxZ > object2.minZ){
								solveFunc(object1, object2);
							}
						}
					}
				}
			}
		}
		
		public static function findInterBoundsCollision(objects:Array, object:CollisionObject3D, solveFunc:Function):void
		{
			if (objects.length == 0)
				return;
			//TODO: something here needs to be ordered. Possibly all bounding boxes that require solving?
			
			var obj:CollisionObject3D;
			for each (obj in objects){
				if (obj.collidable && obj.active){
					if (obj.minX > object.maxX || obj.maxX < object.minX){
						continue;
					}
					if (obj.minY > object.maxY || obj.maxY < object.minY){
						continue;
					}
					if (obj.minZ < object.maxZ && obj.maxZ > object.minZ){
						solveFunc(obj, object);
					}
				}
			}
		}
		
		public static function solveParticleParticle(particle1:Particle3D, particle2:Particle3D):void
		{
			//find movable objects
			var obj1:CollisionObject3D = findMovableObject(particle1);
			var fixed1:Boolean = (obj1 == null);
			
			var obj2:CollisionObject3D = findMovableObject(particle2);
			var fixed2:Boolean = (obj2 == null);
								
			if (fixed1 && fixed2){
				return;
			}
			
			var totalRadius:Number = particle1.radius + particle2.radius;
			var distance:Number3D = Number3D.sub(particle1.scenePosition, particle2.scenePosition);
			var mod:Number = distance.modulo;
			if (totalRadius > mod){
				var penetration:Number = totalRadius - mod;
				distance.normalize();
				var inertia1:Number = 0.5;
				var inertia2:Number = 0.5;
				if (fixed1 || fixed2){
					inertia1 = 1;
					inertia2 = 1;
				} else if (obj1.mass != obj2.mass){
					var inertiaTotal:Number = obj1.mass + obj2.mass;
					inertia1 = obj1.mass/inertiaTotal;
					inertia2 = obj2.mass/inertiaTotal;
				}
				if (!fixed1)
					obj1.thrust(Number3D.scale(distance, penetration*inertia1));
				
				if (!fixed2)
					obj2.thrust(Number3D.scale(distance, -penetration*inertia2));
				
				particle1.lastCollision.setProperties(particle2, distance, penetration);
				particle2.lastCollision.setProperties(particle1, Number3D.scale(distance, -1), penetration);
			}
		}
		
		public static function solveParticleSurface(particle:Particle3D, surface:Face3D, raycastFlag:Boolean = false):void
		{
			if (particle == null || surface == null){
				return;
			}
			if (particle.useRaycasting && !raycastFlag){
				//solveParticleSurfaceRaycast(particle, surface);
				return;
			}
			//find movable objects
			var obj1:CollisionObject3D = findMovableObject(particle);
			var fixed1:Boolean = (obj1 is Scene3D);
			
			var obj2:CollisionObject3D = findMovableObject(surface);
			var fixed2:Boolean = (obj2 is Scene3D);
								
			if (fixed1 && fixed2){
				return;
			}
			var physicalCollision:Boolean = (obj1.reactionMode == ReactionModes.PHYSICAL || obj2.reactionMode == ReactionModes.PHYSICAL)
			var totalRadius:Number = particle.radius;
			var position:Number3D = particle.scenePosition;
			var v0:Number3D = surface.v0.scenePosition;
			var v1:Number3D = surface.v1.scenePosition;
			var v2:Number3D = surface.v2.scenePosition;
			//using Barycentrics coords to test if point is inside triangle (Moller’s algorithm)
			var U:Number3D = surface.a;
			var V:Number3D = surface.b;
			var T:Number3D = Number3D.sub(position, v0);
			var D:Number3D = surface.normal;
			
			var p:Number3D = Number3D.cross(D, V);
			var q:Number3D = Number3D.cross(T, U);
			
			var s:Number = Number3D.dot(p, U);
			//var t:Number = Number3D.dot(q, V)/s;
			var u:Number = Number3D.dot(p, T)/s;
			var v:Number = Number3D.dot(q, D)/s;
			
			var point:Number3D;
			if (u < 0) {
				u = 0;
				v = Number3D.dot(T, V)/V.modulo2;
				if (v < 0) v = 0;
				else if (v > 1) v = 1;
				point = Number3D.add(v0, Number3D.scale(V, v));
			} else if (v < 0) {
				v = 0;
				u = Number3D.dot(T, U)/U.modulo2;
				if (u < 0) u = 0;
				else if (u > 1) u = 1;
				point = Number3D.add(v0, Number3D.scale(U, u));
			} else if (v + u > 1) {
				var X:Number3D = Number3D.sub(v2, v1);
				var Y:Number3D = Number3D.sub(position, v1);
				v = Number3D.dot(Y, X)/X.modulo2;
				if (v < 0) v = 0;
				else if (v > 1) v = 1;
				u = 1 - v;
				point = Number3D.add(v1, Number3D.scale(X, v));
			} else {
				point = Number3D.add(v0, Number3D.add(Number3D.scale(U, u), Number3D.scale(V, v)));
			}
			
			
			var distance:Number3D = Number3D.sub(position, point);
			var mod:Number = distance.modulo;
			if (totalRadius > mod){
				var penetration:Number = totalRadius - mod;
				distance.normalize();
				var thrust1:Number = 0.5*penetration;
				var thrust2:Number = -0.5*penetration;
				var par1:Number, par2:Number, perp1:Number, perp2:Number;
				var plane1:Number3D, plane2:Number3D;
				if (physicalCollision) {
					//calc bounce components
					var bounce:Number = Collision.calcBounce(obj1, obj2);
					var bounce1:Number = Number3D.dot(distance, obj1.velocity);
					var bounce2:Number = Number3D.dot(distance, obj2.velocity);
					
					//calc friction components
					plane1 = Number3D.sub(obj1.velocity, Number3D.scale(distance, bounce1));
					plane1.normalize();
					plane2 = Number3D.sub(obj2.velocity, Number3D.scale(distance, bounce2));
					plane2.normalize();
					
					var friction:Number = Collision.calcFriction(obj1, obj2);
					var friction1:Number = Number3D.dot(plane1, obj1.velocity);
					var friction2:Number = Number3D.dot(plane2, obj2.velocity);
					
					if (fixed1 || fixed2){
						//set resulting velocity
						par1 = friction1*friction;
						par2 = friction2*friction;
						perp1 = -bounce1*bounce;
						perp2 = -bounce2*bounce;
						//set resulting movement
						thrust1 = perp1 + penetration;// - 2*Number3D.dot(distance, obj1.acceleration)*penetration/bounce1;
						thrust2 = perp2 - penetration;// - 2*Number3D.dot(distance, obj2.acceleration)*penetration/bounce2;
					} else {
						var velocityTotal:Number = Math.abs(bounce1 - bounce2);
						thrust1 = penetration*bounce1/velocityTotal;
						thrust2 = penetration*bounce2/velocityTotal;
						var m1:Number = obj1.mass;
						var m2:Number = obj2.mass;
						//set resulting velocity
						if (m1 == m2) {
							perp1 = bounce2*bounce;
							perp2 = bounce1*bounce;
						} else {
							var mTotal:Number = m1 + m2;
							var mDifference:Number = m1 - m2;
							perp1 = (bounce1*mDifference/mTotal + bounce2*2*m2/mTotal)*bounce;
							perp2 = (bounce1*2*m1/mTotal - bounce2*mDifference/mTotal)*bounce;
						}
						//set resulting movement
						thrust1 += perp1;
						thrust2 += perp2;
					}
				} else if (fixed1 || fixed2){
					thrust1 = penetration;
					thrust2 = -penetration;
				}
				if (!fixed1) {
					obj1.thrust(Number3D.scale(distance, thrust1));
					if (physicalCollision) obj1.velocity = Number3D.add(Number3D.scale(distance, perp1), Number3D.scale(plane1, par1));
				}
				if (!fixed2) {
					obj2.thrust(Number3D.scale(distance, thrust2));
					if (physicalCollision) obj2.velocity = Number3D.add(Number3D.scale(distance, perp2), Number3D.scale(plane2, par2));
				}
				particle.lastCollision.setProperties(surface, distance, penetration);
				surface.lastCollision.setProperties(particle, Number3D.scale(distance, -1), penetration);
			}
		}
		
		public static function solveContainerContainer(container1:Object3D, container2:Object3D):void
		{
			findInterCollisions(container1, container2);
		}
				
		public static function solveContainerParticle(container:Object3D, particle:Particle3D):void
		{
			var solveFunc:Function;
			if (container is ObjectContainer3D) {
				findInterBoundsCollision((container as ObjectContainer3D).children, particle, solveContainerParticle);
			} else if (container is Vertices3D) {
				findInterBoundsCollision((container as Vertices3D).particles, particle, solveParticleParticle);
				if (container is Mesh3D) {
					findInterBoundsCollisions([particle], (container as Mesh3D).surfaces, solveParticleSurface);				
				}
			}
		}
					
		public static function solveContainerSurface(container:Object3D, surface:Face3D):void
		{
			var solveFunc:Function;
			if (container is ObjectContainer3D) {
				findInterBoundsCollision((container as ObjectContainer3D).children, surface, solveContainerSurface);
			} else if (container is Vertices3D) {
				findInterBoundsCollision((container as Vertices3D).particles, surface, solveParticleSurface);
				if (container is Mesh3D) {
					//findInterBoundsCollisions((container as Mesh3D).surfaces, surface, solveSurfaceSurface);				
				}
			}
		}
		
		public static function findMovableObject(o:CollisionObject3D):CollisionObject3D
		{
			while (o.fixed)
				if ((o = o.parent) is Scene3D) 
					return o;
			return o;
		}
	}
}