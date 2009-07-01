package away3d.core.utils
{
	import away3d.core.base.*;
	import away3d.materials.*;
	
	import flash.geom.*;
	
	public class SegmentVO
	{
		public var generated:Boolean;
		
		public var vertices:Array = new Array();
		
		public var startIndex:int;
		
		public var endIndex:int;
		
		public var v0:Vertex;
		
        public var v1:Vertex;
        
		public var material:ISegmentMaterial;
		
		//public var segment:Segment;
	}
}