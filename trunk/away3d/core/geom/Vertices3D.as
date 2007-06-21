package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.geom.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    
    /** Abstract class for objects based on the set of vertices */
    public class Vertices3D extends Object3D
    {
        public var vertices:Array = [];
        public var particle:Vertex3D;
       	public var particles:Array = [];
        public var maxradius:Number = -1;
        public var minradius:Number = 0;
        public var xMin:Number = 1000000;
        public var xMax:Number = -1000000;
        public var yMin:Number = 1000000;
        public var yMax:Number = -1000000;
        public var zMin:Number = 1000000;
        public var zMax:Number = -1000000;
        public var width:Number = 100;
        public var height:Number = 100;
        public var depth:Number = 100;
        public var length:Number;
        public var wrap:Boolean = true;
/*
        public function get radius():Number
        {
            if (maxradius < 0)
            {
                var mrs:Number = 0;
                for each (var v:Vertex3D in vertices)
                {
                    var sd:Number = v.x*v.x + v.y*v.y + v.z*v.z;
                    if (sd > mrs)
                        mrs = sd;
                }
                maxradius = Math.sqrt(mrs);
            }
            return maxradius;
        }
*/
        public function Vertices3D(init:Object = null)
        {
            super(init);
        }
		
		public override function updateBoundingBox():void
		{
			minX = 1000000;
			maxX = -1000000;
			minY = 1000000;
			maxY = -1000000;
			minZ = 1000000;
			maxZ = -1000000;
			for each (particle in particles) {
				if (minX > particle.minX)
					minX = particle.minX;
				
				if (minY > particle.minY)
					minY = particle.minY;
				
				if (minZ > particle.minZ)
					minZ = particle.minZ;
				
				if (maxX < particle.maxX)
					maxX = particle.maxX;
				
				if (maxY < particle.maxY)
					maxY = particle.maxY;
				
				if (maxZ < particle.maxZ)
					maxZ = particle.maxZ;
			}
		}
		
		public function addVertex3D(vertex:Vertex3D):Vertex3D
		{
            if (vertex == null)
                throw new Error("Vertices3D.addVertex(null)");
            if (vertex.parent == this)
                return vertex;
            vertex.parent = null;
            vertices.push(vertex);
            vertex._parent = this;
            vertex.scenePosition = sceneTransform.transformPoint(vertex.position);
            
            //specail case for immovable
			if (_immovable)
				vertex.immovable = true;
			
			if (inheritAttributes){
				vertex.detectionMode = detectionMode;
				vertex.reactionMode = reactionMode;
				vertex.magnetic = magnetic;
				vertex.friction = friction;
				vertex.bounce = bounce;
				vertex.traction = traction;
				vertex.drag = drag;
			}
            return vertex;	
		}
    }
}
