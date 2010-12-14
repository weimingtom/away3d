package away3dlite.core.base
{
	import away3dlite.arcane;
	import away3dlite.cameras.*;
	import away3dlite.containers.*;
	import away3dlite.materials.*;
	import away3dlite.materials.shaders.*;
	
	import flash.display.*;
	import flash.geom.*;

	use namespace arcane;

	/**
	 * Basic geometry object
	 */
	public class Mesh extends Object3D
	{
		/** @private */
		arcane var _materialsDirty:Boolean;
		/** @private */
		arcane var _materialsCacheList:Vector.<Material> = new Vector.<Material>();
		/** @private */
		arcane var _vertexId:int;
		/** @private */
		arcane var _screenVertices:Vector.<Number>;
		/** @private */
		arcane var _uvtData:Vector.<Number>;
		/** @private */
		arcane var _indices:Vector.<int>;
		/** @private */
		arcane var _indicesTotal:int;
		/** @private */
		arcane var _culling:String;
		/** @private */
		arcane var _faces:Vector.<Face> = new Vector.<Face>();
		/** @private */
		arcane var _faceLengths:Vector.<int> = new Vector.<int>();
		/** @private */
		arcane var _sort:Vector.<int> = new Vector.<int>();
		/** @private */
		arcane var _vertices:Vector.<Number> = new Vector.<Number>();
		/** @private */
		arcane var _faceMaterials:Vector.<Material> = new Vector.<Material>();
		
		public var useBoundingBox:Boolean;
		public var onBoundingBoxUpdate:Function;
		public var minBounding:Vector3D = new Vector3D();
		public var maxBounding:Vector3D = new Vector3D();
		
		/** @private */
		arcane override function updateScene(val:Scene3D):void
		{
			if (scene == val)
				return;

			if (_scene)
				buildMaterials(true);

			_scene = val;

			if (_scene)
				buildMaterials();
			
			// update default BoundingBox
			if(_vertices)
				updateBoundingBox(minBounding, maxBounding);
		}

		/** @private */
		arcane override function project(camera:Camera3D, parentSceneMatrix3D:Matrix3D = null):void
		{
			super.project(camera, parentSceneMatrix3D);

			if (_materialsDirty)
				_scene.isDirty = true;

			// project the normals
			if (material is IShader)
				_uvtData = IShader(material).getUVData(transform.matrix3D.clone());

			if (_vertices && !_perspCulling)
			{
				//DO NOT CHANGE vertices getter!!!!!!!
				Utils3D.projectVectors(_viewMatrix3D, vertices, _screenVertices, _uvtData);

				// projected position for frustum culling
				projectedPosition = Utils3D.projectVector(transform.matrix3D, transform.matrix3D.position);
				projectedPosition = Utils3D.projectVector(_viewMatrix3D, projectedPosition);

				if (_materialsDirty)
					buildMaterials();

				var i:int = _materialsCacheList.length;
				var mat:Material;
				while (i--)
				{
					if ((mat = _materialsCacheList[int(i)]))
					{
						//update rendering faces in the scene
						_scene._materialsNextList[int(i)] = mat;

						//update material for this object
						mat.updateMaterial(this, camera);
					}
				}
				
				if (useBoundingBox)
					updateBoundingBox(minBounding, maxBounding);
			}
		}

		/** @private */
		arcane function buildFaces():void
		{
			_faces.fixed = _sort.fixed = false;
			_indicesTotal = _faces.length = _sort.length = 0;

			var i:int = _faces.length = _sort.length = _faceLengths.length;
			var index:int = _indices.length;
			var faceLength:int;

			while (i--)
			{
				faceLength = _faceLengths[int(i)];

				if (faceLength == 3)
					_indicesTotal += 3;
				else if (faceLength == 4)
					_indicesTotal += 6;
				_faces[int(i)] = new Face(this, i, index -= faceLength, faceLength);
			}

			// speed up
			_vertices.fixed = _uvtData.fixed = _indices.fixed = _faceLengths.fixed = _faces.fixed = _sort.fixed = true;
			
			_screenVertices.length = 0;

			// calculate normals for the shaders
			if (_material is IShader)
				IShader(_material).calculateNormals(_vertices, _indices, _uvtData, _vertexNormals);

			updateSortType();

			_materialsDirty = true;
		}

		protected var _vertexNormals:Vector.<Number>;

		private var _material:Material;
		private var _bothsides:Boolean;
		private var _sortType:String;

		private function removeMaterial(mat:Material):void
		{
			if (mat._id.length == 0)
				return;

			var i:uint = mat._id[_scene._id];

			_materialsCacheList[mat._id[_scene._id]] = null;

			if (_materialsCacheList.length == i + 1)
				_materialsCacheList.length--;
		}

		private function addMaterial(mat:Material):void
		{
			var i:uint = mat._id[_scene._id];

			if (_materialsCacheList.length <= i)
				_materialsCacheList.length = i + 1;

			_materialsCacheList[int(i)] = mat;
		}

		private function buildMaterials(clear:Boolean = false):void
		{
			_materialsDirty = false;

			if (_scene && !_isDestroyed)
			{
				var oldMaterial:Material;
				var newMaterial:Material;

				// update face materials
				_faceMaterials.fixed = false;
				_faceMaterials.length = _faceLengths.length;
				_faceMaterials.fixed = true;

				var i:int = _faces ? _faces.length : 0;
				while (i--)
				{
					oldMaterial = _faces[int(i)]._material;

					if (!clear)
						newMaterial = _faceMaterials[int(i)] || _material;

					//reset face materials
					if (oldMaterial != newMaterial)
					{
						//remove old material from lists
						if (oldMaterial)
						{
							_scene.removeSceneMaterial(oldMaterial);
							removeMaterial(oldMaterial);
						}

						//add new material to lists
						if (newMaterial)
						{
							_scene.addSceneMaterial(newMaterial);
							addMaterial(newMaterial);
						}

						//set face material
						_faces[int(i)].material = newMaterial;
					}
				}
			}
		}

		public function updateBoundingBox(minBounding:Vector3D, maxBounding:Vector3D):void
		{
			var minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number;
			
			// reset
			if(minBounding.length == 0 && minBounding.length == 0)
			{
				minX = minZ = minY = Infinity;
				maxX = maxY = maxZ = -Infinity;
			}else{
				// value from parent
				minX = minBounding.x;
				minY = minBounding.y;
				minZ = minBounding.z;
				
				maxX = maxBounding.x;
				maxY = maxBounding.y;
				maxZ = maxBounding.z;
			}
			
			var i:int;
			var _length:int = _vertices.length;
			var j:Number;
			
			// find OBB bounding box
			for (i = 0; i < _length; i++)
			{
				j = _vertices[int(i++)];
				minX = (j < minX) ? j : minX;
				maxX = (j > maxX) ? j : maxX;
				
				j = _vertices[int(i++)];
				minY = (j < minY) ? j : minY;
				maxY = (j > maxY) ? j : maxY;
				
				j = _vertices[int(i)];
				minZ = (j < minZ) ? j : minZ;
				maxZ = (j > maxZ) ? j : maxZ;
			}
			
			minBounding.x = minX;
			minBounding.y = minY;
			minBounding.z = minZ;
			
			maxBounding.x = maxX;
			maxBounding.y = maxY;
			maxBounding.z = maxZ;
			
			// callback if exist
			if(onBoundingBoxUpdate is Function)
				onBoundingBoxUpdate(minBounding, maxBounding);
		}
		
		public function updateBoundingSphere():void
		{
			var d:Number;
			var _length:int = _vertices.length;
			
			for (var i:int = 0; i < _length; i += 3)
			{
				d = _vertices[int(i)] * _vertices[int(i)] + _vertices[int(i + 1)] * _vertices[int(i + 1)] + _vertices[int(i + 2)] * _vertices[int(i + 2)];
				maxRadius = (d > maxRadius) ? d : maxRadius;
			}
		}
		
		private function updateSortType():void
		{
			var face:Face;
			switch (_sortType)
			{
				case SortType.CENTER:
					for each (face in _faces)
					{
						face.calculateScreenZInt = face.calculateAverageZInt;
						face.calculateScreenZ = face.calculateAverageZ;
					}
					break;
				case SortType.FRONT:
					for each (face in _faces)
					{
						face.calculateScreenZInt = face.calculateNearestZInt;
						face.calculateScreenZ = face.calculateNearestZ;
					}
					break;
				case SortType.BACK:
					for each (face in _faces)
					{
						face.calculateScreenZInt = face.calculateFurthestZInt;
						face.calculateScreenZ = face.calculateFurthestZ;
					}
					break;
				default:
			}
		}

		/**
		 * Determines if the faces in the mesh are sorted. Used in the <code>FastRenderer</code> class.
		 *
		 * @see away3dlite.core.render.FastRenderer
		 */
		public var sortFaces:Boolean = true;

		/**
		 * Returns the screen vertices in the mesh.
		 */
		public function get screenVertices():Vector.<Number>
		{
			return _screenVertices;
		}

		/**
		 * Returns the 3d vertices used in the mesh.
		 */
		public function get vertices():Vector.<Number>
		{
			return _vertices;
		}

		/**
		 * Returns the faces used in the mesh.
		 */
		public function get faces():Vector.<Face>
		{
			return _faces;
		}


		/**
		 * Determines the global material used on the faces in the mesh.
		 */
		public function get material():Material
		{
			return _material;
		}

		public function set material(val:Material):void
		{
			val = val || new WireColorMaterial();

			if (_material == val)
				return;

			// remove old referer
			if (_material && _material.meshes && _material.meshes.indexOf(this) > -1)
			{
				_material.meshes.fixed = false;
				_material.meshes.splice(_material.meshes.indexOf(this), 1);
				_material.meshes.fixed = true;
			}

			_material = val;

			// reset all face material
			if (_faceMaterials.length > 0)
			{
				var i:int = _faces ? _faces.length : 0;
				while (i--)
					_faceMaterials[int(i)] = _faces[int(i)].mesh._materialsDirty ? _faceMaterials[int(i)] : _material;
			}

			// keep referer to every mesh
			if (!_material.meshes)
				_material.meshes = new Vector.<Mesh>();

			_material.meshes.fixed = false;
			_material.meshes.push(this);
			_material.meshes.fixed = true;

			_materialsDirty = true;

			// calculate normals for the shaders
			if (_material is IShader)
				IShader(_material).calculateNormals(_vertices, _indices, _uvtData, _vertexNormals);
		}

		/**
		 * Determines whether the faces in teh mesh are visible on both sides (true) or just the front side (false).
		 * The front side of a face is determined by the side that has it's vertices arranged in a counter-clockwise order.
		 */
		public function get bothsides():Boolean
		{
			return _bothsides;
		}

		public function set bothsides(val:Boolean):void
		{
			_bothsides = val;

			if (_bothsides)
			{
				_culling = TriangleCulling.NONE;
			}
			else
			{
				_culling = TriangleCulling.POSITIVE;
			}
		}

		/**
		 * Determines by which mechanism vertices are sorted. Uses the values given by the <code>SortType</code> class. Options are CENTER, FRONT and BACK. Defaults to CENTER.
		 *
		 * @see away3dlite.core.base.SortType
		 */
		public function get sortType():String
		{
			return _sortType;
		}

		public function set sortType(val:String):void
		{
			if (_sortType == val)
				return;

			_sortType = val;

			updateSortType();
		}

		/**
		 * Creates a new <code>Mesh</code> object.
		 *
		 * @param material		Determines the global material used on the faces in the mesh.
		 */
		public function Mesh(material:Material = null)
		{
			super();

			// private use
			_screenVertices = new Vector.<Number>();
			_uvtData = new Vector.<Number>();
			_indices = new Vector.<int>();

			//setup default values
			this.material = material;
			this.bothsides = false;
			this.sortType = SortType.CENTER;
		}

		public function addFace(vs:Vector.<Vector3D>, uvs:Vector.<Point>):void
		{
			var q:int = Math.min(vs.length, uvs.length);
			for (var i:int = 0; i < q; i++)
			{
				pushV3D(vs[int(i)], uvs[int(i)]);
			}
			_faceLengths.push(q);
		}

		public function pushV3D(v:Vector3D, uv:Point):void
		{
			_vertices.push(v.x, v.y, v.z);
			_uvtData.push(uv.x, uv.y, 1);
			_indices.push(this._indicesTotal++);
		}

		/**
		 * Duplicates the mesh properties to another <code>Mesh</code> object.
		 *
		 * @param	object	[optional]	The new object instance into which all properties are copied. The default is <code>Mesh</code>.
		 * @return						The new object instance with duplicated properties applied.
		 */
		public override function clone(object:Object3D = null):Object3D
		{
			var mesh:Mesh = (object as Mesh) || new Mesh();
			super.clone(mesh);
			mesh.type = type;
			mesh.material = material;
			mesh.sortType = sortType;
			mesh.bothsides = bothsides;
			mesh._vertices = vertices;
			mesh._uvtData = _uvtData.concat();
			mesh._faceMaterials = _faceMaterials;
			mesh._indices = _indices.concat();
			mesh._faceLengths = _faceLengths;
			mesh.buildFaces();
			mesh.buildMaterials();

			return mesh;
		}
		
		override public function destroy():void
		{
			if (_isDestroyed)
				return;

			// main material
			removeMaterial(_material);
			_scene.removeSceneMaterial(_material);
			_material.destroy();
			_material = null;

			// cache material
			for each (var _cacheMaterial:Material in _materialsCacheList)
			{
				if (_cacheMaterial)
				{
					removeMaterial(_cacheMaterial);
					_cacheMaterial.destroy();
				}
			}
			_cacheMaterial = null;
			_materialsCacheList = null;

			// face
			for each (var face:Face in _faces)
			{
				if (face.material)
					face.material = null;
			}
			face = null;
			_faces = null;

			_faceLengths = null;
			_sort = null;

			// face material
			for each (var _faceMaterial:Material in _faceMaterials)
			{
				if (_faceMaterial)
					_faceMaterial.destroy();
			}
			_faceMaterial = null;
			_faceMaterials = null;

			// 3D elements
			_vertices = null;
			_uvtData = null;
			_indices = null;
			_screenVertices = null;

			super.destroy();
		}
	}
}