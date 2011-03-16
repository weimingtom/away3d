package away3dlite.core.render
{
	import away3dlite.arcane;
	import away3dlite.containers.*;
	import away3dlite.core.IDestroyable;
	import away3dlite.core.base.*;
	import away3dlite.core.clip.*;
	import away3dlite.core.culler.FrustumCuller;
	
	import flash.display.*;
	import flash.utils.getTimer;

	use namespace arcane;

	/**
	 * @author robbateman
	 */
	public class Renderer implements IDestroyable
	{
		/** @private */
		protected var _isDestroyed:Boolean;

		/** @private */
		arcane function setView(view:View3D):void
		{
			_view = view;
			_view_graphics = _view.graphics;
			_view_graphics_drawGraphicsData = _view.graphics.drawGraphicsData;
			_zoom = _view.camera.zoom;
			_focus = _view.camera.focus;

			_culler = new FrustumCuller(_view.camera);
		}

		public var useFloatZSort:Boolean = false;

		//---------------------------------------------------
		// Members not required if we use only Float ZSorting

		private var k:int;
		private var q0:Vector.<int>;
		private var np0:Vector.<int>;
		/** @private */
		protected var q1:Vector.<int>;

		//---------------------------------------------------

		private var _screenVertexArrays:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		private var _screenVertices:Vector.<Number>;
		private var _screenPointVertexArrays:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
		private var _screenPointVertices:Vector.<int>;
		private var _index:int;
		private var _indexX:int;
		private var _indexY:int;
		/** @private */
		protected var np1:Vector.<int>;
		/** @private */
		protected var _view:View3D;
		/** @private */
		protected var _scene:Scene3D;
		/** @private */
		protected var _face:Face;
		/** @private */
		protected var _faces:Vector.<Face> = new Vector.<Face>();
		/** @private */
		protected var _sort:Vector.<int> = new Vector.<int>();
		/** @private */
		protected var _faceStore:Vector.<int> = new Vector.<int>();
		/** @private */
		protected var _clipping:Clipping;
		/** @private */
		protected var _screenZ:int;
		/** @private */
		protected var _pointFace:Face;
		/** @private */
		protected var _ind:Vector.<int>;
		/** @private */
		protected var _vert:Vector.<Number>;
		/** @private */
		protected var _uvt:Vector.<Number>;
		/** @private */
		protected var _triangles:GraphicsTrianglePath = new GraphicsTrianglePath();
		/** @private */
		protected var _view_graphics:Graphics;
		/** @private */
		protected var _view_graphics_drawGraphicsData:Function;
		/** @private */
		protected var _culler:FrustumCuller;
		/** @private */
		private var _zoom:Number;
		/** @private */
		private var _focus:Number;
		/** @private */
		protected var _renderables:Array;

		/** @private */
		protected var _ctime:int = 0;
		protected var _otime:int = 0;

		/**
		 * Determines whether 3d objects are sorted in the view. Defaults to true.
		 */
		public var sortObjects:Boolean = true;

		/**
		 * Determines whether 3d objects are culled in the view. Defaults to false.
		 */
		public var cullObjects:Boolean = false;

		/** @private */
		protected function sortFaces(i:int = 0, j:int = 0):void
		{
			var _faces_length_1:int = int(_faces.length + 1);
			var _Face_calculateZIntFromZ:Function = Face.calculateZIntFromZ;
			if (!useFloatZSort)
			{
				q0 = new Vector.<int>(256, true);
				q1 = new Vector.<int>(256, true);
				np0 = new Vector.<int>(_faces_length_1, true);
				np1 = new Vector.<int>(_faces_length_1, true);

				i = 0;
				j = 0;

				for each (_face in _faces)
				{
					np0[int(i + 1)] = q0[k = (255 & (_sort[int(i)] = _face.calculateScreenZInt()))];
					q0[int(k)] = int(++i);
				}

				i = 256;
				while (i--)
				{
					j = q0[int(i)];
					while (j)
					{
						np1[int(j)] = q1[k = (65280 & _sort[int(j - 1)]) >> 8];
						j = np0[q1[int(k)] = j];
					}
				}
			}
			else
			{
				np1 = new Vector.<int>(_faces_length_1, true);
				var _sortFaceDatas:Array = [];

				//z-axis, for sort-based production
				i = 1;
				for each (_face in _faces)
				{
					var z:Number = _face.calculateScreenZ();
					_sort[int(i - 1)] = _Face_calculateZIntFromZ(z);
					if (z > 0)
						_sortFaceDatas[int(j++)] = new SortFaceData(int(i), z);
					i++;
				}

				//z-axis sort
				_sortFaceDatas = _sortFaceDatas.sortOn("z", 16);

				//Put the sorted indices inside a Vector
				j = 0;
				for each (var _sortFaceData:SortFaceData in _sortFaceDatas)
					np1[int(j++)] = _sortFaceData.i;
				np1[int(j++)] = 0;

				_sortFaceDatas = null;
			}
		}

		/** @private */
		protected function collectPointFace(x:Number, y:Number):void
		{
			if (_screenPointVertexArrays.length == 0)
				return;

			var pointCount:int;
			var pointTotal:int;
			var pointCountX:int;
			var pointCountY:int;
			var i:int = _faces.length;
			while (i--)
			{
				if (_screenZ < _sort[int(i)] && (_face = _faces[int(i)]).mesh.mouseEnabled)
				{
					_screenPointVertices = _screenPointVertexArrays[int(_face.mesh._vertexId)];

					if (_screenPointVertices.length == 0)
						continue;

					if (_face.length == 4)
					{
						pointTotal = 4;
						pointCount = _screenPointVertices[_face.i0] + _screenPointVertices[_face.i1] + _screenPointVertices[_face.i2] + _screenPointVertices[_face.i3];
					}
					else
					{
						pointTotal = 3;
						pointCount = _screenPointVertices[_face.i0] + _screenPointVertices[_face.i1] + _screenPointVertices[_face.i2];
					}
					pointCountX = (pointCount >> 4);
					pointCountY = (pointCount & 15);
					if (pointCountX && pointCountX < pointTotal && pointCountY && pointCountY < pointTotal)
					{
						//flagged for edge detection
						var vertices:Vector.<Number> = _face.mesh._screenVertices;
						if (!vertices)
							return;
						var v0x:Number = vertices[_face.x0];
						var v0y:Number = vertices[_face.y0];
						var v1x:Number = vertices[_face.x1];
						var v1y:Number = vertices[_face.y1];
						var v2x:Number = vertices[_face.x2];
						var v2y:Number = vertices[_face.y2];

						if ((v0x * (y - v1y) + v1x * (v0y - y) + x * (v1y - v0y)) < -0.001)
							continue;

						if ((x * (v2y - v1y) + v1x * (y - v2y) + v2x * (v1y - y)) < -0.001)
							continue;

						if (_face.length == 4)
						{
							var v3x:Number = vertices[_face.x3];
							var v3y:Number = vertices[_face.y3];

							if ((v3x * (v2y - y) + x * (v3y - v2y) + v2x * (y - v3y)) < -0.001)
								continue;

							if ((v0x * (v3y - y) + x * (v0y - v3y) + v3x * (y - v0y)) < -0.001)
								continue;

						}
						else if ((v0x * (v2y - y) + x * (v0y - v2y) + v2x * (y - v0y)) < -0.001)
						{
							continue;
						}

						_screenZ = _sort[int(i)];
						_pointFace = _face;
					}
				}
			}
		}

		/** @private */
		protected function collectScreenVertices(mesh:Mesh):void
		{
			mesh._vertexId = _screenVertexArrays.length;
			_screenVertexArrays.push(mesh._screenVertices);
		}

		/** @private */
		protected function collectPointVertices(x:Number, y:Number):void
		{
			_screenPointVertexArrays.fixed = false;
			_screenPointVertexArrays.length = _screenVertexArrays.length;
			_screenPointVertexArrays.fixed = true;

			var i:int = _screenVertexArrays.length;

			while (i--)
			{
				_screenVertices = _screenVertexArrays[int(i)];
				_screenPointVertices = _screenPointVertexArrays[int(i)] = new Vector.<int>(_index = _screenVertices.length / 2, true);

				while (_index--)
				{
					_indexY = (_indexX = _index * 2) + 1;

					if (_screenVertices[int(_indexX)] < x)
						_screenPointVertices[int(_index)] += 0x10;

					if (_screenVertices[int(_indexY)] < y)
						_screenPointVertices[int(_index)] += 0x1;
				}
			}
		}

		/**
		 * Creates a new <code>Renderer</code> object.
		 */
		function Renderer()
		{
			_ind = _triangles.indices = new Vector.<int>();
			_vert = _triangles.vertices = new Vector.<Number>();
			_uvt = _triangles.uvtData = new Vector.<Number>();
		}

		/**
		 * Returns the face object directly under the given point.
		 *
		 * @param x		The x coordinate of the point.
		 * @param y		The y coordinate of the point.
		 */
		public function getFaceUnderPoint(x:Number, y:Number):Face
		{
			x;
			y;
			return null;
		}

		/** @private */
		protected function drawParticles(screenZ:Number = NaN):void
		{
			if (_renderables.length == 0)
				return;

			var _particle:IRenderable;
			var _particleIndex:int = 0;
			var _view_x:Number = _view.x;
			var _view_y:Number = _view.y;

			_view_graphics.lineStyle();

			if (isNaN(screenZ))
			{
				// just draw
				for each (_particle in _renderables)
					_particle.render(_view_x, _view_y, _view_graphics, _zoom, _focus);
			}
			else
			{
				// draw particle that behind screenZ
				while ((_particle = _renderables[int(_particleIndex++)]) && _particle.screenZ > screenZ)
					_particle.render(_view_x, _view_y, _view_graphics, _zoom, _focus);

				if (_particleIndex >= 2)
					_renderables = _renderables.slice(_particleIndex - 1, _renderables.length);
			}
		}

		/**
		 * Renders the contents of the scene to the view.
		 *
		 * @see awa3dlite.containers.Scene3D
		 * @see awa3dlite.containers.View3D
		 */
		public function render():void
		{
			_scene = _view.scene;

			_clipping = _view.screenClipping;

			_pointFace = null;

			_screenVertexArrays.length = 0;

			// particles
			_renderables = [];

			// culling
			if (cullObjects && _scene.isDirty)
				_culler.update();

			// reset
			_scene.isDirty = false;

			// animated
			_ctime = getTimer();
		}

		public function get destroyed():Boolean
		{
			return _isDestroyed;
		}

		public function destroy():void
		{
			_isDestroyed = true;

			if (_view)
				_view.destroy();
			if (_scene)
				_scene.destroy();
			if (_face)
				_face.destroy();
			if (_pointFace)
				_pointFace.destroy();

			_view = null;
			_scene = null;
			_face = null;
			_faces = null;
			_pointFace = null;
			_triangles = null;
			_view_graphics = null;
			_view_graphics_drawGraphicsData = null;
			_culler = null;
			_renderables = null;
		}
	}
}

internal class SortFaceData
{
	public var i:int;
	public var z:Number;

	public function SortFaceData(index:int, depth:Number)
	{
		i = index;
		z = depth;
	}
}