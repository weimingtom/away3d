package away3d.core.draw
{
	import away3d.core.base.Shape3D;
	import away3d.materials.IShapeMaterial;
	
	public class DrawShape extends DrawPrimitive
	{
		public var screenVertices:Array = [];
		public var drawingCommands:Array = [];
		public var material:IShapeMaterial;
		public var shape:Shape3D;
		public var layerOffset:Number;
		public var area:Number;
		
		public function DrawShape()
		{
			
		}
		
		public override function calc():void
		{
			minX = 9999999;
			minY = 9999999;
			minZ = 9999999;
			
			maxX = -9999999;
			maxY = -9999999;
			maxZ = -9999999;
			
			for(var i:uint; i<screenVertices.length; i++)
			{
				var sv:ScreenVertex = screenVertices[i];
				
				if(sv.x > maxX)
					maxX = sv.x;
				if(sv.x < minX)
					minX = sv.x;
					
				if(sv.y > maxY)
					maxY = sv.y;
				if(sv.y < minY)
					minY = sv.y;
				
				if(sv.z > maxZ)
					maxZ = sv.z;
				if(sv.z < minZ)
					minZ = sv.z;
			}
			
			var meanX:Number = (maxX + minX)/2;
			var meanY:Number = (maxY + minY)/2;
			var meanZ:Number = (maxZ + minZ)/2;
			var modulo:Number = Math.sqrt(meanX*meanX + meanY*meanY + meanZ*meanZ);
			screenZ = modulo + layerOffset;
			
			var v0:ScreenVertex = screenVertices[0];
			var v1:ScreenVertex = screenVertices[1];
			var v2:ScreenVertex = screenVertices[2];
			area = -0.5 * (v0.x*(v2.y - v1.y) + v1.x*(v0.y - v2.y) + v2.x*(v1.y - v0.y));
		}
		
		public override function render():void
        {
            material.renderShape(this);
        }
		
		public override function contains(x:Number, y:Number):Boolean
        {   
            return false;
        }
	}
}