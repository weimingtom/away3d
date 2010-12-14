package away3dlite.animators.bones
{
	import away3dlite.core.base.Mesh;

	import flash.geom.*;

	public class SkinVertex
	{
		private var _i:int;
		private var _position:Vector3D = new Vector3D();
		private var _output:Vector3D;
		private var _startIndices:Vector.<int> = new Vector.<int>();
		private var _vertices:Vector.<Number>;
		private var _baseVertex:Vector3D;

		public var weights:Vector.<Number> = new Vector.<Number>();

		public var controllers:Vector.<SkinController> = new Vector.<SkinController>();

		private static var _instances:Vector.<SkinVertex> = new Vector.<SkinVertex>();
		private var _mesh:Mesh;

		public function SkinVertex()
		{
		}

		public function get baseVertex():Vector3D
		{
			return _baseVertex;
		}

		public function get mesh():Mesh
		{
			return _mesh;
		}

		public function updateVertices(startIndex:int, vertices:Vector.<Number>, mesh:Mesh = null):Boolean
		{
			_baseVertex = new Vector3D(vertices[startIndex], vertices[startIndex + 1], vertices[startIndex + 2]);

			// remove duplicate vertices based on position
			if (mesh)
			{
				for each (var sv:SkinVertex in _instances)
				{
					if (sv._mesh == mesh && sv.baseVertex.equals(_baseVertex))
					{
						sv._startIndices.push(startIndex);
						return false;
					}
				}
				_mesh = mesh;
			}

			_startIndices.push(startIndex);
			_vertices = vertices;
			_instances.push(this);

			return true;
		}

		public function update():void
		{
			if (_mesh && !_mesh.visible)
				return;

			//reset values
			_output = new Vector3D();

			_i = weights.length;
			while (_i--)
			{
				_position = controllers[int(_i)].transformMatrix3D.transformVector(_baseVertex);
				_position.scaleBy(weights[int(_i)]);
				_output = _output.add(_position);
			}
			var _startIndex:int;
			for each (_startIndex in _startIndices)
			{
				_vertices[int(_startIndex)] = _output.x;
				_vertices[int(_startIndex + 1)] = _output.y;
				_vertices[int(_startIndex + 2)] = _output.z;
			}
		}

		public function clone():SkinVertex
		{
			var skinVertex:SkinVertex = new SkinVertex();
			skinVertex.weights = weights;
			skinVertex.controllers = controllers;

			return skinVertex;
		}
	}
}
