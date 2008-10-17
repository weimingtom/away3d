package away3d.core.draw
{
	import away3d.core.base.Shape3D;
	import away3d.materials.IShapeMaterial;
	
	public class DrawShape extends DrawPrimitive
	{
		private var _screenVertices:Array = [];
		private var _screenVerticesX:Array = [];
		private var _screenVerticesY:Array = [];
		private var _screenVerticesZ:Array = [];
		private var _drawingCommands:Array = [];
		private var _material:IShapeMaterial;
		private var _shape:Shape3D;
		
		public function DrawShape()
		{
			
		}
		
		public override function calc():void
		{
			/* _screenVerticesX.sort(Array.DESCENDING);
			_screenVerticesY.sort(Array.DESCENDING); */
			_screenVerticesZ.sort(Array.DESCENDING);
			
			/* minX = _screenVerticesX[_screenVerticesX.length - 1];
			maxX = _screenVerticesX[0];
			minY = _screenVerticesY[_screenVerticesY.length - 1];
			maxY = _screenVerticesY[0]; */
			minZ = _screenVerticesZ[_screenVerticesZ.length - 1];
			maxZ = _screenVerticesZ[0];
			
			//Short way.
			screenZ = (maxZ + minZ)/2;
			
			//Long way.
			/* var acumZ:Number = 0;
			for(var i:uint; i<_screenVerticesZ.length; i++)
			{
				acumZ += _screenVerticesZ[i];
			}
			screenZ = acumZ/_screenVerticesZ.length; */
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
		
		public function get screenVertices():Array
		{
			return _screenVertices;
		}
		public function addScreenVertex(sv:ScreenVertex):void
		{
			_screenVertices.push(new ScreenVertex(sv.x, sv.y, sv.z));
			
			_screenVerticesX.push(sv.x);
			_screenVerticesY.push(sv.y);
			_screenVerticesZ.push(sv.z);
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
			
			_screenVerticesX = [];
			_screenVerticesY = [];
			_screenVerticesZ = [];
		}
		
		public override function contains(x:Number, y:Number):Boolean
        {   
            return false;
        }
	}
}