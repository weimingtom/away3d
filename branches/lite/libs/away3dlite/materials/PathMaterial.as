package away3dlite.materials
{
	import away3dlite.core.base.Mesh;

	import flash.display.*;

	/**
	 * Path material.
	 */
	public class PathMaterial extends WireframeMaterial implements IPathMaterial
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
				_commands = new Vector.<int>(_length / 2, true);
				_pathData = new Vector.<Number>(_length, true);

				_commands[0] = 1;
				_pathData[0] = _screenVertices[0];
				_pathData[1] = _screenVertices[1];

				var i:int = 0;
				var j:int;
				_length *= .5;
				while (++i < _length)
				{
					_commands[i] = 2;
					j = int(2 * i);
					_pathData[j] = _screenVertices[j];
					j = int(j + 1);
					_pathData[j] = _screenVertices[j];
				}
			}

			_graphicsPath.commands = _commands;
			_graphicsPath.data = _pathData;
		}

		public function drawGraphicsData(mesh:Mesh, graphic:Graphics):void
		{
			graphic.drawGraphicsData(graphicsData);
		}

		/**
		 * Creates a new <code>LineMaterial</code> object.
		 *
		 * @param	color		The color of the material.
		 * @param	alpha		The transparency of the material.
		 * @param	thickness	The thickness of the outline.
		 */
		public function PathMaterial(color:* = null, alpha:Number = 1, thickness:Number = 1)
		{
			super(color, alpha, thickness);

			_graphicsPath = new GraphicsPath(_commands, _pathData);

			graphicsData = Vector.<IGraphicsData>([_graphicsStroke, _graphicsPath]);
			graphicsData.fixed = true;

			trianglesIndex = -1;
		}
	}
}