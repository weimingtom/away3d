package away3d.core.base
{
	import away3d.core.arcane;
	import away3d.events.ShapeEvent;
	import away3d.materials.IShapeMaterial;
	
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
		
		public var layerOffset:Number = 0;
		
		public function Shape3D()
		{
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
		public function graphicsDrawRect(sX:Number, sY:Number, sZ:Number, W:Number, H:Number):void
		{
			graphicsMoveTo(sX, sY, sZ);
			graphicsLineTo(sX + W, sY, sZ);
			graphicsLineTo(sX + W, sY + H, sZ);
			graphicsLineTo(sX, sY + H, sZ);
			graphicsLineTo(sX, sY, sZ);
		}
		public function graphicsDrawRoundRect(sX:Number, sY:Number, sZ:Number, W:Number, H:Number, hR:Number, vR:Number):void
		{
			graphicsMoveTo(sX + hR, sY, sZ);
			graphicsLineTo(sX + W - hR, sY, sZ);
			graphicsCurveTo(sX + W, sY, sZ, sX + W, sY + vR, sZ);
			graphicsLineTo(sX + W, sY + H - vR, sZ);
			graphicsCurveTo(sX + W, sY + H, sZ, sX + W - hR, sY + H, sZ);
			graphicsLineTo(sX + hR, sY + H, sZ);
			graphicsCurveTo(sX, sY + H, sZ, sX, sY + H - vR, sZ);
			graphicsLineTo(sX, sY + vR, sZ);
			graphicsCurveTo(sX, sY, sZ, sX + hR, sY, sZ);
		}
		public function graphicsDrawPolygon(points:Array):void
		{
			graphicsMoveTo(points[0].x, points[0].y, points[0].z);
			
			for(var i:uint = 1; i<points.length; i++)
				graphicsLineTo(points[i].x, points[i].y, points[i].z);
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