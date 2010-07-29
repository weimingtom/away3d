package away3dlite.materials
{
	import away3dlite.core.base.Face;
	import away3dlite.core.base.Mesh;
	
	import flash.display.*;
	
	/**
	 * Quad outline material.
	 */
	public class QuadWireframeMaterial extends WireframeMaterial implements IPathMaterial
	{
		private var _commands:Vector.<int> = new Vector.<int>();
		private var _pathData:Vector.<Number> = new Vector.<Number>();
		private var _graphicsPath:GraphicsPath;
		
		public function collectGraphicsPath(mesh:Mesh):void
		{
			var _screenVertices:Vector.<Number> = mesh.screenVertices;
			var _length:int = _screenVertices.length;
			
			if (_length > 0)
			{
				_commands = new Vector.<int>();
				_pathData = new Vector.<Number>();
				
				var _face:Face;
				var _faces:Vector.<Face> = mesh.faces;
				
				for each (_face in _faces)
				{
					if (_face.length == 4)
					{
						_pathData.push(
							_screenVertices[_face.x0], _screenVertices[_face.y0],
							_screenVertices[_face.x1], _screenVertices[_face.y1],
							_screenVertices[_face.x2], _screenVertices[_face.y2],
							_screenVertices[_face.x3], _screenVertices[_face.y3]);
						_commands.push(1, 2, 2, 2);
					}
					else
					{
						_pathData.push(
							_screenVertices[_face.x0], _screenVertices[_face.y0],
							_screenVertices[_face.x1], _screenVertices[_face.y1],
							_screenVertices[_face.x2], _screenVertices[_face.y2]);
						_commands.push(1, 2, 2);
					}
				}
				_commands.fixed = _pathData.fixed = true;
			}
			
			_graphicsPath.commands = _commands;
			_graphicsPath.data = _pathData;
		}
		
		public function drawGraphicsData(mesh:Mesh, graphic:Graphics):void
		{
			collectGraphicsPath(mesh);
			graphic.drawGraphicsData(graphicsData);
		}
		
		/**
		 * Creates a new <code>QuadWireframeMaterial</code> object.
		 *
		 * @param	color		The color of the material.
		 * @param	alpha		The transparency of the material.
		 * @param	wireColor	The color of the outline.
		 * @param	wireAlpha	The transparency of the outline.
		 * @param	thickness	The thickness of the outline.
		 */
		public function QuadWireframeMaterial(wireColor:* = null, wireAlpha:Number = 1, thickness:Number = 1)
		{
			super(wireColor, wireAlpha, thickness);
			
			_graphicsPath = new GraphicsPath(_commands, _pathData);
			
			graphicsData = Vector.<IGraphicsData>([_graphicsStroke, _graphicsPath]);
			graphicsData.fixed = true;
			
			trianglesIndex = -1;
		}
	}
}