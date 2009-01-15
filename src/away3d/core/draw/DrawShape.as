package away3d.core.draw
{
	import away3d.core.base.Shape3D;
	import away3d.materials.IShapeMaterial;
	
	import flash.geom.Point;
	
	public class DrawShape extends DrawPrimitive
	{
		public var screenVertices:Array = [];
		public var drawingCommands:Array = [];
		public var material:IShapeMaterial;
		public var shape:Shape3D;
		public var layerOffset:Number;
		public var contourOrientation:Boolean;
		
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
		}
		
		public function calculateContourOrientation():void
		{
			var acum:Number = 0;
			var pointer:uint;
			while(Math.abs(acum) < 360 && pointer + 2 < screenVertices.length - 1)
			{
				var delta:Number = getTurningAngleAtIndex(pointer);
				
				if(Math.abs(delta) < 180)
					acum += delta;
				
				pointer++;
			}
			
			contourOrientation = acum < 0 ? true : false;
			
			if(shape.contourOrientation)
				contourOrientation = !contourOrientation;
		}
		private function getTurningAngleAtIndex(index:uint):Number
		{
			var p0:Point = new Point(screenVertices[index].x, screenVertices[index].y);
			var p1:Point = new Point(screenVertices[index + 1].x, screenVertices[index + 1].y);
			var p2:Point = new Point(screenVertices[index + 2].x, screenVertices[index + 2].y);
			
			var d0:Point = p1.subtract(p0);
			var d1:Point = p2.subtract(p1);
			
			var angle:Number = Math.atan2(d1.y, d1.x) - Math.atan2(d0.y, d0.x);
			
			return angle*180/Math.PI;
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