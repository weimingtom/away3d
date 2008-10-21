package away3d.core.draw
{
	import away3d.core.base.Shape3D;
	import away3d.materials.IShapeMaterial;
	
	public class DrawShape extends DrawPrimitive
	{
		private var _screenVertices:Array = [];
		private var _drawingCommands:Array = [];
		private var _material:IShapeMaterial;
		private var _shape:Shape3D;
		private var _screenZOffset:Number;
		
		public function DrawShape()
		{
			minX = 0;
			maxX = 0;
			minY = 0;
			maxY = 0;
			minZ = 0;
			maxZ = 0;
		}
		
		public override function calc():void
		{
			//NOTE: Min and Max values are calculated in addScreenVertex();
			
			//Short way.
			//screenZ = (maxZ + minZ)/2 + _screenZOffset;
			
			//Long way.
			var zAcum:Number = 0;
			for(var i:uint; i<_screenVertices.length; i++)
				zAcum += _screenVertices[i].z;
			screenZ = zAcum/_screenVertices.length + _screenZOffset;
		}
		
		public function get screenVertices():Array
		{
			return _screenVertices;
		}
		public function addScreenVertex(sv:ScreenVertex):void
		{
			_screenVertices.push(new ScreenVertex(sv.x, sv.y, sv.z));
			
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
		
		public function get drawingCommands():Array
		{
			return _drawingCommands;
		}
		public function set drawingCommands(value:Array):void
		{
			_drawingCommands = value;
		}
		
		public override function render():void
        {
            material.renderShape(this);
        }
		
		public override function clear():void
		{
			_screenVertices = [];
		}
		
		public override function contains(x:Number, y:Number):Boolean
        {   
            return false;
        }
        
        public function set shape(value:Shape3D):void
		{
			_shape = value;
		}
		
		public function get material():IShapeMaterial
		{
			return _material;
		}
		public function set material(mat:IShapeMaterial):void
		{
			_material = mat;
		}
		
		public function set screenZOffset(value:Number):void
		{
			_screenZOffset = value;
		}
	}
}