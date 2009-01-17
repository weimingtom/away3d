package away3d.core.base
{
	import away3d.arcane;
	import away3d.core.math.Number3D;
	import away3d.events.ShapeEvent;
	import away3d.materials.IShapeMaterial;
	
	import flash.geom.Point;
	
	use namespace arcane;
	
	/**
    * A shape element used in vector type primitives.
    * 
    * @see away3d.core.base.Sprite3D
    */
	public class Shape3D extends Element
	{
		/** @private */
        arcane var _vertices:Array = [];
        /** @private */
        arcane var _material:IShapeMaterial;
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		//Private variables.
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private var _drawingCommands:Array = [];
		private var _materialchanged:ShapeEvent;
		private var _extrusionFrontVertices:Array = [];
		private var _extrusionBackVertices:Array = [];
		private var _extrusionDepth:Number = 0;
		private var _lastCreatedVertex:Vertex;
		private var _previousCreatedVertex:Vertex;
		private var _lastCreatedVertexIndex:uint;
		private var _previousCreatedVertexIndex:uint;
		private var _contourOrientation:int = 0;
		private var _cullingTolerance:Number = 0;
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		//Public variables.
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public var layerOffset:Number = 0;
		public var name:String;
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		//Constructor.
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function Shape3D()
		{
			
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		//Setters & getters.
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function get cullingTolerance():Number
		{
			return _cullingTolerance;
		}
		public function set cullingTolerance(value:Number):void
		{
			_cullingTolerance = value;
		}
		
		public function get contourOrientation():int
		{
			return _contourOrientation;
		}
		public function set contourOrientation(value:int):void
		{
			_contourOrientation = value;
		}
		
		public function get lastCreatedVertex():Vertex
		{
			return _lastCreatedVertex;
		}
		
		public function get previousCreatedVertex():Vertex
		{
			return _previousCreatedVertex;
		}
		
		public function set extrusionDepth(value:Number):void
		{
			_extrusionDepth = value;
			
			var i:uint;
			for(i = 0; i<_extrusionFrontVertices.length; i++)
				_extrusionFrontVertices[i].z = value;
		}
		public function get extrusionDepth():Number
		{
			return _extrusionDepth;
		}
		
		public function set extrusionFrontVertices(value:Array):void
		{
			_extrusionFrontVertices = value;
		}
		public function set extrusionBackVertices(value:Array):void
		{
			_extrusionBackVertices = value;
		}
		
		public function get drawingCommands():Array
		{
			return _drawingCommands;
		}
		
		public override function get vertices():Array
		{
			return _vertices;
		}
		
		public function get material():IShapeMaterial
		{
			return _material;
		}
		public function set material(value:IShapeMaterial):void
		{
			if(value == _material)
				return;
			
			_material = value;
			
			dispatchEvent(new ShapeEvent(ShapeEvent.MATERIAL_CHANGED, this));
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		//Public methods.
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function calculateOrientationXY():void
		{
			var v0:Vertex = vertices[0];
			var v1:Vertex = vertices[1];
			var v2:Vertex = vertices[2];
			
			var p0:Point = new Point(v0.x, v0.y);
			var p1:Point = new Point(v1.x, v1.y);
			var p2:Point = new Point(v2.x, v2.y);
			
			var area:Number = calculateTriArea(p0, p1, p2);
			
			_contourOrientation = area < 0 ? 1 : -1;
		}
		public function calculateOrientationYZ():void
		{
			var v0:Vertex = vertices[0];
			var v1:Vertex = vertices[1];
			var v2:Vertex = vertices[2];
			
			var p0:Point = new Point(v0.y, v0.z);
			var p1:Point = new Point(v1.y, v1.z);
			var p2:Point = new Point(v2.y, v2.z);
			
			var area:Number = calculateTriArea(p0, p1, p2);
			
			_contourOrientation = area < 0 ? 1 : -1;
		}
		public function calculateOrientationXZ():void
		{
			var v0:Vertex = vertices[0];
			var v1:Vertex = vertices[1];
			var v2:Vertex = vertices[2];
			
			var p0:Point = new Point(v0.x, v0.z);
			var p1:Point = new Point(v1.x, v1.z);
			var p2:Point = new Point(v2.x, v2.z);
			
			var area:Number = calculateTriArea(p0, p1, p2);
			
			_contourOrientation = area < 0 ? 1 : -1;
		}
		private function calculateTriArea(p0:Point, p1:Point, p2:Point):Number
		{
			 return (p0.x*(p2.y - p1.y) + p1.x*(p0.y - p2.y) + p2.x*(p1.y - p0.y))/2;
		}
		
		public function graphicsMoveTo(X:Number, Y:Number, Z:Number):void
		{
			var command:DrawingCommand = new DrawingCommand(DrawingCommand.MOVE, null, null, addVertex(X, Y, Z), 999999, 999999, vertices.length-1);
			_drawingCommands.push(command);
		}
		public function graphicsLineTo(X:Number, Y:Number, Z:Number):void
		{
			var command:DrawingCommand = new DrawingCommand(DrawingCommand.LINE, _previousCreatedVertex, null, addVertex(X, Y, Z), _previousCreatedVertexIndex, 999999, vertices.length-1);
			_drawingCommands.push(command);
		}
		public function graphicsCurveTo(cX:Number, cY:Number, cZ:Number, X:Number, Y:Number, Z:Number):void
		{
			var command:DrawingCommand = new DrawingCommand(DrawingCommand.CURVE, _previousCreatedVertex, addVertex(cX, cY, cZ), addVertex(X, Y, Z), _previousCreatedVertexIndex, vertices.length-2, vertices.length-1);
			_drawingCommands.push(command);
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
		
		public function centerVertices():Number3D
		{
			var vertex:Vertex;	
			var deltaX:Number = 0;
			var deltaY:Number = 0;
			var deltaZ:Number = 0;
			
			for each(vertex in vertices)
			{
				deltaX += vertex.x;
				deltaY += vertex.y;
				deltaZ += vertex.z;
			}
			
			deltaX = deltaX/vertices.length;
			deltaY = deltaY/vertices.length;
			deltaZ = deltaZ/vertices.length;
			
			for each(vertex in vertices)
			{
				vertex.x -= deltaX;
				vertex.y -= deltaY;
				vertex.z -= deltaZ;
			}
			
			return new Number3D(deltaX, deltaY, deltaZ);
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		//Private methods.
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function getTurningAngleAtIndex(index:uint):Number
		{
			var p0:Point = new Point(vertices[index].x, vertices[index].y);
			var p1:Point = new Point(vertices[index + 1].x, vertices[index + 1].y);
			var p2:Point = new Point(vertices[index + 2].x, vertices[index + 2].y);
			
			var d0:Point = p1.subtract(p0);
			var d1:Point = p2.subtract(p1);
			
			var angle:Number = Math.atan2(d1.y, d1.x) - Math.atan2(d0.y, d0.x);
			
			return angle*180/Math.PI;
		}
		
		private function addVertex(X:Number, Y:Number, Z:Number):Vertex
		{
			var vertex:Vertex = new Vertex(X, Y, Z);
			_vertices.push(vertex);
			
			_previousCreatedVertex = _lastCreatedVertex;
			_lastCreatedVertex = vertex;
			_previousCreatedVertexIndex = _lastCreatedVertexIndex;
			_lastCreatedVertexIndex = vertices.length-1;
			
			return vertex;
		}
		
		public function addOnMaterialChange(listener:Function):void
        {	
            addEventListener(ShapeEvent.MATERIAL_CHANGED, listener, false, 0, true);
        }
        public function removeOnMaterialChange(listener:Function):void
        {	
            removeEventListener(ShapeEvent.MATERIAL_CHANGED, listener);
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