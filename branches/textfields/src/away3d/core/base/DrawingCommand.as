package away3d.core.base
{
	import flash.geom.Point;
	
	public class DrawingCommand
	{
		public static const MOVE:String = "move";
		public static const LINE:String = "line";
		public static const CURVE:String = "curve";
		
		public var type:String;
		public var p0:Vertex;
		public var p1:Vertex;
		public var p2:Vertex;
		public var p0index:uint;
		public var p1index:uint;
		public var p2index:uint;
		
		public function DrawingCommand(type:String, p0:Vertex,  p1:Vertex,  p2:Vertex, p0index:uint, p1index:uint, p2index:uint)
		{
			this.type = type;
			this.p0 = p0;
			this.p1 = p1;
			this.p2 = p2;
			this.p0index = p0index;
			this.p1index = p1index;
			this.p2index = p2index;
		}
	}
}