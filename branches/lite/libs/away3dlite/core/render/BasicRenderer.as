package away3dlite.core.render
{
	import away3dlite.arcane;
	import away3dlite.containers.*;
	import away3dlite.core.base.*;
	import away3dlite.materials.*;
	
	import flash.display.*;
	
	use namespace arcane;
	
	/**
	 * Standard renderer for a view.
	 * 
	 * @see away3dlite.containers.View3D
	 */
	public class BasicRenderer extends Renderer
	{
		private var _mesh:Mesh;
		private var _screenVertices:Vector.<Number>;
		private var _uvtData:Vector.<Number>;
		private var _material:Material;
		private var _i:int;
		private var _j:int;
		private var _k:int;
		
		private var _material_graphicsData:Vector.<IGraphicsData>;

		private function collectFaces(object:Object3D):void
		{
			if (!object.visible ||object._frustumCulling || object._perspCulling)
			{
				if (cullObjects)
					numCulled++;
				return;
			}

			_mouseEnabledArray.push(_mouseEnabled);
			_mouseEnabled = object._mouseEnabled = (_mouseEnabled && object.mouseEnabled);

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

					if (child.canvas)
					{
						var _child_canvas:Sprite = child.canvas;
						if (_child_canvas != object.canvas)
							_child_canvas.parent.setChildIndex(_child_canvas, children.indexOf(child));
						_child_canvas.graphics.clear();
					}

					if (child.layer)
						child.layer.graphics.clear();

					collectFaces(child);
				}
			}
			
			if (object is Mesh)
			{
				var mesh:Mesh = object as Mesh;
				_clipping.collectFaces(mesh, _faces);

				if (_view.mouseEnabled && _mouseEnabled)
					collectScreenVertices(mesh);
				
				if(mesh._faces)
					_view._totalFaces += mesh._faces.length;
			}
			else if (object is Particles)
			{
				var _particles_lists:Array = _clipping.collectParticles((object as Particles).lists);

				if (_particles_lists.length > 0)
					_particles = _particles.concat(_particles_lists);
			}

			_mouseEnabled = _mouseEnabledArray.pop();

			++_view._totalObjects;
			++_view._renderedObjects;
		}
		
		/** @private */
		protected override function sortFaces():void
		{
			super.sortFaces();
			
			//reorder indices
			_material = null;
			_mesh = null;
			
			if (useFloatZSort) {
				i = 0;
				j = np1[i];
				while (j) {
					sortFacesCommon();
					i++;
					j = np1[i];
				}
			}
			else {
				i = -1;
				while (i++ < 255) {
            		j = q1[i];
					while (j) {
						sortFacesCommon();
						j = np1[j];
					}
				}
			}
		}
		
		/** @private */
		private function sortFacesCommon():void
		{
            _face = _faces[j-1];
			
			if (_material != _face.material) 
			{
				if (_material) 
				{
					_material_graphicsData[_material.trianglesIndex] = _triangles;
					draw(_mesh);
				}
				
				//clear vectors by overwriting with a new instance (length = 0 leaves garbage)
				_ind = _triangles.indices = new Vector.<int>();
				_vert = _triangles.vertices = new Vector.<Number>();
				_uvt = _triangles.uvtData = new Vector.<Number>();
				_i = -1;
				_j = -1;
				_k = -1;
				
				_mesh = _face.mesh;
				_material = _face.material;
				_material_graphicsData = _material.graphicsData;
				_screenVertices = _mesh._screenVertices;
				_uvtData = _mesh._uvtData;
				_faceStore = new Vector.<int>(_mesh._vertices.length/3, true);
			} else if (_mesh != _face.mesh) {
				_mesh = _face.mesh;
				_screenVertices = _mesh._screenVertices;
				_uvtData = _mesh._uvtData;
				_faceStore = new Vector.<int>(_mesh._vertices.length/3, true);
			}
			
			if (_faceStore[_face.i0]) {
				_ind[++_i] = _faceStore[_face.i0] - 1;
			} else {
				_vert[++_j] = _screenVertices[_face.x0];
				_faceStore[_face.i0] = (_ind[++_i] = _j*.5) + 1;
				_vert[++_j] = _screenVertices[_face.y0];
				
				_uvt[++_k] = _uvtData[_face.u0];
				_uvt[++_k] = _uvtData[_face.v0];
				_uvt[++_k] = _uvtData[_face.t0];
			}
			
			if (_faceStore[_face.i1]) {
				_ind[++_i] = _faceStore[_face.i1] - 1;
			} else {
				_vert[++_j] = _screenVertices[_face.x1];
				_faceStore[_face.i1] = (_ind[++_i] = _j*.5) + 1;
				_vert[++_j] = _screenVertices[_face.y1];
				
				_uvt[++_k] = _uvtData[_face.u1];
				_uvt[++_k] = _uvtData[_face.v1];
				_uvt[++_k] = _uvtData[_face.t1];
			}
			
			if (_faceStore[_face.i2]) {
				_ind[++_i] = _faceStore[_face.i2] - 1;
			} else {
				_vert[++_j] = _screenVertices[_face.x2];
				_faceStore[_face.i2] = (_ind[++_i] = _j*.5) + 1;
				_vert[++_j] = _screenVertices[_face.y2];
				
				_uvt[++_k] = _uvtData[_face.u2];
				_uvt[++_k] = _uvtData[_face.v2];
				_uvt[++_k] = _uvtData[_face.t2];
			}
			
			if (_face.i3) {
				_ind[++_i] = _faceStore[_face.i0] - 1;
				_ind[++_i] = _faceStore[_face.i2] - 1;
				
				if (_faceStore[_face.i3]) {
					_ind[++_i] = _faceStore[_face.i3] - 1;
				} else {
					_vert[++_j] = _screenVertices[_face.x3];
					_faceStore[_face.i3] = (_ind[++_i] = _j*.5) + 1;
					_vert[++_j] = _screenVertices[_face.y3];
					
					_uvt[++_k] = _uvtData[_face.u3];
					_uvt[++_k] = _uvtData[_face.v3];
					_uvt[++_k] = _uvtData[_face.t3];
				}
			}
		}
		
		/**
		 * Creates a new <code>BasicRenderer</code> object.
		 */
		public function BasicRenderer()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		public override function getFaceUnderPoint(x:Number, y:Number):Face
		{
			if (!_faces.length)
				return null;
			
			collectPointVertices(x, y);
			
			_screenZ = 0;
			
			collectPointFace(x, y);
			
			return _pointFace;
		}

		/**
		 * @inheritDoc
		 */
		public override function render():void
		{
			super.render();

			_faces = new Vector.<Face>();

			collectFaces(_scene);

			// sort merged particles
			_particles.sortOn("screenZ", 18);

			_faces.fixed = true;

			_view._renderedFaces = _faces.length;

			if (_faces.length)
			{
				_sort.fixed = false;
				_sort.length = _faces.length;
				_sort.fixed = true;

				sortFaces();
			}

			if (_mesh && _material)
			{
				_material_graphicsData = _material.graphicsData;
				_material_graphicsData[_material.trianglesIndex] = _triangles;
				draw(_mesh);
				_mesh = null;
			}

			// draw remain particles
			drawParticles();
		}
		
		private function draw(_mesh:Mesh):void
		{
			drawParticles(_mesh.screenZ);
			
			if(_mesh.visible && !_mesh._frustumCulling && !_mesh._perspCulling)
			{
				if(_mesh.layer)
				{
					_mesh.layer.graphics.drawGraphicsData(_material_graphicsData);
				}
				else if(_mesh.canvas)
				{
					_mesh.canvas.graphics.drawGraphicsData(_material_graphicsData);
				}
				else
				{
					_view_graphics_drawGraphicsData(_material_graphicsData);
				}
			}
		} 
	}
}