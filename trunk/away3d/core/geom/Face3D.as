package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    
    import flash.geom.Matrix;
    import away3d.core.physics.CollisionObject3D;

	/** Mesh's triangle face */
    public class Face3D extends CollisionObject3D
    {
        public var v0:Vertex3D;
        public var v1:Vertex3D;
        public var v2:Vertex3D;

        public var uv0:NumberUV;
        public var uv1:NumberUV;
        public var uv2:NumberUV;
    
        public var material:ITriangleMaterial;

        public var extra:Object;

        public var visible:Boolean = true;
		public var normal:Number3D;
		public var a:Number3D;
		public var b:Number3D;
		
        public function Face3D(v0:Vertex3D, v1:Vertex3D, v2:Vertex3D, material:ITriangleMaterial = null, uv0:NumberUV = null, uv1:NumberUV = null, uv2:NumberUV = null)
        {
        	super();
            this.v0 = v0;
            this.v1 = v1;
            this.v2 = v2;
            this.material = material;
            this.uv0 = uv0;
            this.uv1 = uv1;
            this.uv2 = uv2;
        }

        public var texturemapping:Matrix;

		public function massOnSurface(u:Number, v:Number):Number
		{
			if (_immovable)
				return 0;
			
			return(v0.mass*(1 - (u+v)) + v1.mass*u + v2.mass*v);
		}
		
		public override function updateBoundingBox():void
		{
            
			v0.updateBoundingBox();
			v1.updateBoundingBox();
			v2.updateBoundingBox();
			
			a = Number3D.sub(v1.scenePosition, v0.scenePosition);
            b = Number3D.sub(v2.scenePosition, v0.scenePosition);
            normal = Number3D.cross(a, b);
            normal.normalize();
            			
			minX = 1000000;
			maxX = -1000000;
			minY = 1000000;
			maxY = -1000000;
			minZ = 1000000;
			maxZ = -1000000;
			
			if (minX > v0.minX) minX = v0.minX;
			if (minX > v1.minX) minX = v1.minX;
			if (minX > v2.minX) minX = v2.minX;
			if (maxX < v0.maxX) maxX = v0.maxX;
			if (maxX < v1.maxX) maxX = v1.maxX;
			if (maxX < v2.maxX) maxX = v2.maxX;
			
			if (minY > v0.minY) minY = v0.minY;
			if (minY > v1.minY) minY = v1.minY;
			if (minY > v2.minY) minY = v2.minY;
			if (maxY < v0.maxY) maxY = v0.maxY;
			if (maxY < v1.maxY) maxY = v1.maxY;
			if (maxY < v2.maxY) maxY = v2.maxY;
						
			if (minZ > v0.minZ) minZ = v0.minZ;
			if (minZ > v1.minZ) minZ = v1.minZ;
			if (minZ > v2.minZ) minZ = v2.minZ;
			if (maxZ < v0.maxZ) maxZ = v0.maxZ;
			if (maxZ < v1.maxZ) maxZ = v1.maxZ;
			if (maxZ < v2.maxZ) maxZ = v2.maxZ;
		}
    }
}
