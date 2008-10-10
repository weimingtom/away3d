package away3d.core.draw
{
	import away3d.materials.IShapeMaterial;
	
	/* Li */
	public class DrawShape extends DrawPrimitive
	{
		private var _screenVertices:Array = [];
		private var _drawingCommands:Array = [];
		private var _material:IShapeMaterial;
		
		public function DrawShape()
		{
			
		}
		
		public function addDrawingCommand(type:int):void
		{
			_drawingCommands.push(type);
		}
		
		public function addScreenVertex(sv:ScreenVertex):void
		{
			_screenVertices.push(sv);
		}
		
		public function set material(mat:IShapeMaterial):void
		{
			_material = mat;
		}
		
		public function get material():IShapeMaterial
		{
			return _material;
		}
		
		public function get screenVertices():Array
		{
			return _screenVertices;
		}
		
		public function get drawingCommands():Array
		{
			return _drawingCommands;
		}
		
		/**
		 * @inheritDoc
		 */
        public override function render():void
        {
            material.renderShape(this);
        }
		
		public override function clear():void
		{
			_screenVertices = [];
			_drawingCommands = [];
		}
		
		public override function contains(x:Number, y:Number):Boolean
        {   
            return false;
        }
	}
}