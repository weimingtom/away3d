package away3dlite.core.render
{
	import away3dlite.arcane;
	import away3dlite.containers.*;
	import away3dlite.core.base.*;
	import away3dlite.materials.Material;
	
	import flash.display.*;

	use namespace arcane;

	/**
	 * @author robbateman
	 */
	public class FastRenderer extends Renderer
	{
		private var _i:int;
		private var _x:Number;
		private var _y:Number;

		private function collectFaces(object:Object3D):void
		{
			++_view._totalObjects;
			
			if (!object.visible || (cullObjects && object._frustumCulling))
				return;
			
			if (object is ObjectContainer3D)
			{
				var children:Array = (object as ObjectContainer3D).children;
				var child:Object3D;

				if (sortObjects)
					children.sortOn("screenZ", 18);

				for each (child in children)
				{
					if (cullObjects)
						_culler.cull(child);

					if (child._canvas)
					{
						var _child_canvas:Sprite = child._canvas;
						_child_canvas.parent.setChildIndex(_child_canvas, children.indexOf(child));
						_child_canvas.graphics.clear();
					}

					if (child._layer)
						child._layer.graphics.clear();

					collectFaces(child);
				}
			}

			if (object is IRenderableList)
			{
				var renderableItems:Array = _clipping.collectParticles((object as Particles).children);

				if (renderableItems.length > 0)
					_renderables = _renderables.concat(renderableItems);
			}
			
			++_view._renderedObjects;
		}

		private function drawFaces(object:Object3D):void
		{
			if (!object.visible || (cullObjects && object._frustumCulling))
				return;

			if (object is ObjectContainer3D)
			{
				var children:Array = (object as ObjectContainer3D).children;
				var child:Object3D;

				for each (child in children)
					drawFaces(child);
			}

			if (object is Mesh)
			{
				var _mesh:Mesh = object as Mesh;
				_faces = _mesh._faces;

				if(!_faces)
					return;

				var _mesh_material:Material = _mesh.material;
				var _mesh_material_graphicsData:Vector.<IGraphicsData> = _mesh_material.graphicsData;

				_mesh_material_graphicsData[_mesh_material.trianglesIndex] = _triangles;

				_ind.fixed = false;
				_sort = _mesh._sort;
				_triangles.culling = _mesh._culling;
				_uvt = _triangles.uvtData = _mesh._uvtData;
				_vert = _triangles.vertices = _mesh._screenVertices;
				_ind.length = _mesh._indicesTotal;
				_ind.fixed = true;

				if (_view.mouseEnabled && _mesh.mouseEnabled)
					collectScreenVertices(_mesh);

				if (_mesh.sortFaces)
				{
					sortFaces();
				}
				else
				{
					var j:int = _faces.length;
					_i = -1;
					while (j--)
					{
						_face = _faces[int(j)];
						_ind[int(++_i)] = _face.i0;
						_ind[int(++_i)] = _face.i1;
						_ind[int(++_i)] = _face.i2;

						if (_face.length == 4)
						{
							_ind[int(++_i)] = _face.i0;
							_ind[int(++_i)] = _face.i2;
							_ind[int(++_i)] = _face.i3;
						}
					}
				}

				drawParticles(object.screenZ);

				if (object._layer)
				{
					object._layer.graphics.drawGraphicsData(_mesh_material_graphicsData);
				}
				else if (object._canvas)
				{
					object._canvas.graphics.drawGraphicsData(_mesh_material_graphicsData);
				}
				else
				{
					_view_graphics_drawGraphicsData(_mesh_material_graphicsData);
				}

				var _faces_length:int = _faces.length;
				_view._totalFaces += _faces_length;
				_view._renderedFaces += _faces_length;
			}
		}

		private function collectPointFaces(object:Object3D):void
		{
			if (object is ObjectContainer3D)
			{
				var children:Array = (object as ObjectContainer3D).children;
				var child:Object3D;

				for each (child in children)
					collectPointFaces(child);

			}
			else if (object is Mesh)
			{
				var mesh:Mesh = object as Mesh;

				_faces = mesh._faces;
				_sort = mesh._sort;

				collectPointFace(_x, _y);
			}
		}

		/** @private */
		protected override function sortFaces(i:int = 0, j:int = 0):void
		{
			super.sortFaces(i, j);

			if (!useFloatZSort)
			{
				i = -1;
				_i = -1;
				while (i++ < 255)
				{
					j = q1[int(i)];
					while (j)
					{
						sortFacesCommon(j);
						j = np1[j];
					}
				}
			}
			else
			{
				i = 0;
				_i = -1;
				j = np1[int(i)];
				while (j)
				{
					sortFacesCommon(j);
					i++;
					j = np1[int(i)];
				}
			}
		}

		/** @private */
		private function sortFacesCommon(j:int):void
		{
			_face = _faces[int(j - 1)];
			_ind[int(++_i)] = _face.i0;
			_ind[int(++_i)] = _face.i1;
			_ind[int(++_i)] = _face.i2;

			if (_face.length == 4)
			{
				_ind[int(++_i)] = _face.i0;
				_ind[int(++_i)] = _face.i2;
				_ind[int(++_i)] = _face.i3;
			}
		}

		/**
		 * @inheritDoc
		 */
		public override function getFaceUnderPoint(x:Number, y:Number):Face
		{
			_x = x;
			_y = y;

			collectPointVertices(x, y);

			_screenZ = 0;

			collectPointFaces(_scene);

			return _pointFace;
		}

		/**
		 * Creates a new <code>FastRenderer</code> object.
		 */
		public function FastRenderer()
		{

		}

		/**
		 * @inheritDoc
		 */
		public override function render():void
		{
			super.render();

			collectFaces(_scene);

			// sort merged particles
			_renderables.sortOn("screenZ", 18);

			drawFaces(_scene);

			// draw front
			drawParticles();
		}
	}
}
