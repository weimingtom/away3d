package away3d.core.draw
{
	import away3d.core.base.Shape3D;
	import away3d.core.math.Number3D;
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
		
		public function get orientation():Boolean
		{
			var sv0:ScreenVertex = screenVertices[0];
			var sv1:ScreenVertex = screenVertices[1];
			var sv2:ScreenVertex = screenVertices[2];
			/* sv0.deperspective(view.camera.focus);
			sv1.deperspective(view.camera.focus);
			sv2.deperspective(view.camera.focus); */
			
			var p0:Number3D = new Number3D(sv0.x, sv0.y, sv0.z);
			var p1:Number3D = new Number3D(sv1.x, sv1.y, sv1.z);
			var p2:Number3D = new Number3D(sv2.x, sv2.y, sv2.z);
			
			var d0:Number3D = new Number3D();
			d0.sub(p1, p0);
			var d1:Number3D = new Number3D();
			d1.sub(p2, p0);
			
			var dot:Number = d0.dot(d1);
			trace("DrawShape: " + dot);
			
			return dot < 0;
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