package away3d.core.physics
{
	import away3d.core.*;
	import away3d.core.math.*;
	
	public class Particle3D extends CollisionObject3D
	{
		public var radius:Number = 0;
		
		public function Particle3D(init:Object = null)
        {
        	super(init);

            init = Init.parse(init);
            radius = init.getNumber("radius", radius, {min:0});
            maxVelocity = radius;
            maxVelocity2 = maxVelocity*maxVelocity;
        }
        
        public override function updateBoundingBox():void
		{
			oldScenePosition = scenePosition.clone();			
			scenePosition = parent.sceneTransform.transformPoint(position);
			if (radius) {
				minX = scenePosition.x - radius;
				maxX = scenePosition.x + radius;
				minY = scenePosition.y - radius;
				maxY = scenePosition.y + radius;
				minZ = scenePosition.z - radius;
				maxZ = scenePosition.z + radius;
			} else {
				minX = maxX = scenePosition.x;
				minY = maxY = scenePosition.y;
				minZ = maxZ = scenePosition.z;
			}
			if (!useRaycasting)
				return;
			
			if (radius) {
				if (minX > oldScenePosition.x - radius)
					minX = oldScenePosition.x - radius;
				
				if (maxX < oldScenePosition.x + radius)
					maxX = oldScenePosition.x + radius;
				
				if (minY > oldScenePosition.y - radius)
					minY = oldScenePosition.y - radius;
				
				if (maxY < oldScenePosition.y + radius)
					maxY = oldScenePosition.y + radius;
	
				if (minZ > oldScenePosition.z - radius)
					minZ = oldScenePosition.z - radius;
				
				if (maxZ < oldScenePosition.z + radius)
					maxZ = oldScenePosition.z + radius;
			} else {
				if (minX > oldScenePosition.x)
					minX = oldScenePosition.x;
				
				if (maxX < oldScenePosition.x)
					maxX = oldScenePosition.x;
				
				if (minY > oldScenePosition.y)
					minY = oldScenePosition.y;
				
				if (maxY < oldScenePosition.y)
					maxY = oldScenePosition.y;
	
				if (minZ > oldScenePosition.z)
					minZ = oldScenePosition.z;
				
				if (maxZ < oldScenePosition.z)
					maxZ = oldScenePosition.z;				
			}
		}
	}
}