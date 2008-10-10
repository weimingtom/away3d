package away3d.core.base
{
	import away3d.core.arcane;
	import away3d.events.ShapeEvent;
	import away3d.materials.IShapeMaterial;
	import away3d.materials.ShapeMaterial;
	
	/* Li */
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
			_material = new ShapeMaterial(0xFF0000);
			
			graphicsMoveTo(0, 0);
		}
		
		public function graphicsMoveTo(X:Number, Y:Number):void
		{
			addVertex(X, Y, 0);
			_drawingCommands.push(0);
		}
		
		public function graphicsLineTo(X:Number, Y:Number):void
		{
			addVertex(X, Y, 0);
			_drawingCommands.push(1);
		}
		
		public function graphicsCurveTo(cX:Number, cY:Number, X:Number, Y:Number):void
		{
			addVertex(cX, cY, 0);
			addVertex(X, Y, 0);
			_drawingCommands.push(2);
		}
		
		private function addVertex(X:Number, Y:Number, Z:Number):void
		{
			var vertex:Vertex = new Vertex(X, Y, Z);
			_vertices.push(vertex);
		}
		
		public override function get vertices():Array
		{
			return _vertices;
		}
		
		public function get material():IShapeMaterial
		{
			return _material;
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