package away3d.core.utils
{
	import away3d.core.base.*;
	import away3d.materials.*;
	
	import flash.geom.*;
	
	public class SegmentVO extends ElementVO
	{
		public var v0:Vertex;
		
        public var v1:Vertex;
        
		public var material:ISegmentMaterial;
		
		public var segment:Segment;
	}
}