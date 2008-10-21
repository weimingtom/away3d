package away3d.core.base
{
	import away3d.core.arcane;
	import away3d.events.ShapeEvent;
	import away3d.materials.IMaterial;
	import away3d.materials.IShapeMaterial;
	import away3d.materials.ShapeMaterial;
	
	/**
    * A shape element used in vector type primitives.
    * 
    * @see away3d.core.base.Sprite3D
    */
	public class Shape3D extends Element
	{
		use namespace arcane;
		
		/** @private */
        arcane var _vertices:Array = [];
        /** @private */
        arcane var _material:IShapeMaterial;
		
		private var _drawingCommands:Array = [];
		private var _materialchanged:ShapeEvent;
		
		public function Shape3D()
		{
			_material = new ShapeMaterial();
			
			graphicsMoveTo(0, 0, 0);
		}
		
		public function graphicsMoveTo(X:Number, Y:Number, Z:Number):void
		{
			addVertex(X, Y, Z);
			_drawingCommands.push(0);
		}
		public function graphicsLineTo(X:Number, Y:Number, Z:Number):void
		{
			addVertex(X, Y, Z);
			_drawingCommands.push(1);
		}
		public function graphicsCurveTo(cX:Number, cY:Number, cZ:Number, X:Number, Y:Number, Z:Number):void
		{
			addVertex(cX, cY, cZ);
			addVertex(X, Y, Z);
			_drawingCommands.push(2);
		}
		
		public override function get vertices():Array
		{
			return _vertices;
		}
		private function addVertex(X:Number, Y:Number, Z:Number):void
		{
			var vertex:Vertex = new Vertex(X, Y, Z);
			_vertices.push(vertex);
		}
		
		public function get material():IShapeMaterial
		{
			return _material;
		}
		public function set material(value:IShapeMaterial):void
		{
			_material = value;
		}
		
		public function get drawingCommands():Array
		{
			return _drawingCommands;
		}
		
		/** @private */
        arcane function notifyMaterialChange():void
        {
        	if(!hasEventListener(ShapeEvent.MATERIAL_CHANGED))
            	return;

            if(_materialchanged == null)
            	_materialchanged = new ShapeEvent(ShapeEvent.MATERIAL_CHANGED, this);
                
            dispatchEvent(_materialchanged);
        }
	}
}