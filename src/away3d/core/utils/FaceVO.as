package away3d.core.utils
{
	import away3d.core.base.*;
	import away3d.materials.*;
	
	public class FaceVO
	{
		
        public var v0:Vertex;
		
        public var v1:Vertex;
		
        public var v2:Vertex;
		
        public var uv0:UV;
		
        public var uv1:UV;
		
        public var uv2:UV;
		
		public var material:ITriangleMaterial;
		
		public var back:ITriangleMaterial;
		
		public var face:Face;
	}
}