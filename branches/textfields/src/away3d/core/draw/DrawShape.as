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
		
		public function DrawShape()
		{
			
		}
		
		public override function calc():void
		{
			minX = minY = minZ = 999999;
			maxX = maxY = maxZ = -999999;
			
			for(var i:uint; i<screenVertices.length; i++)
			{
				var sv:ScreenVertex = screenVertices[i];
				
				if(sv.x > maxX)
				maxX = sv.x;
				else if(sv.x < minX)
					minX = sv.x;
					
				if(sv.y > maxY)
					maxY = sv.y;
				else if(sv.y < minY)
					minY = sv.y;
				
				if(sv.z > maxZ)
					maxZ = sv.z;
				else if(sv.z < minZ)
					minZ = sv.z;
			}
			
			screenZ = (maxZ + minZ)/2 + layerOffset;
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