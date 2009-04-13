package away3d.loaders;

import away3d.core.math.Number3D;
import away3d.core.utils.ValueObject;
import flash.utils.ByteArray;
import away3d.materials.IMaterial;
import away3d.containers.ObjectContainer3D;
import flash.events.EventDispatcher;
import away3d.loaders.data.MaterialData;
import away3d.loaders.utils.MaterialLibrary;
import away3d.materials.ITriangleMaterial;
import away3d.haxeutils.HashMap;
import away3d.materials.ShadingColorMaterial;
import away3d.loaders.data.FaceData;
import away3d.materials.WireframeMaterial;
import away3d.core.base.Face;
import away3d.loaders.utils.GeometryLibrary;
import away3d.loaders.data.MeshMaterialData;
import away3d.loaders.data.ObjectData;
import away3d.loaders.data.GeometryData;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import away3d.loaders.data.MeshData;
import away3d.core.utils.Cast;
import away3d.loaders.utils.AnimationLibrary;
import away3d.core.utils.Init;
import away3d.core.utils.Debug;
import flash.utils.Endian;
import away3d.materials.WireColorMaterial;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.materials.BitmapMaterial;
import away3d.core.base.Geometry;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * File loader for the 3DS file format.
 */
class Max3DS extends AbstractParser  {
	
	/** @private */
	public var ini:Init;
	/** An array of bytes from the 3ds files. */
	private var _data:ByteArray;
	private var _verticesDictionary:IntHash<Vertex>;
	private var _materialData:MaterialData;
	private var _faceMaterial:ITriangleMaterial;
	private var _meshData:MeshData;
	private var _geometryData:GeometryData;
	private var _faceData:FaceData;
	private var averageX:Float;
	private var averageY:Float;
	private var averageZ:Float;
	private var numVertices:Int;
	private var _meshMaterialData:MeshMaterialData;
	private var _faceListIndex:Int;
	private var _face:Face;
	private var _vertex:Vertex;
	private var _moveVector:Number3D;
	private var _totalChunks:Int;
	private var _parsedChunks:Int;
	//>----- Color Types --------------------------------------------------------
	private static inline var AMBIENT:String = "ambient";
	private static inline var DIFFUSE:String = "diffuse";
	private static inline var SPECULAR:String = "specular";
	//>----- Main Chunks --------------------------------------------------------
	private static inline var PRIMARY:Int = 0x4D4D;
	// Start of our actual objects
	private static inline var EDIT3DS:Int = 0x3D3D;
	// Start of the keyframe information
	private static inline var KEYF3DS:Int = 0xB000;
	//>----- General Chunks -----------------------------------------------------
	private static inline var VERSION:Int = 0x0002;
	private static inline var MESH_VERSION:Int = 0x3D3E;
	private static inline var KFVERSION:Int = 0x0005;
	private static inline var COLOR_F:Int = 0x0010;
	private static inline var COLOR_RGB:Int = 0x0011;
	private static inline var LIN_COLOR_24:Int = 0x0012;
	private static inline var LIN_COLOR_F:Int = 0x0013;
	private static inline var INT_PERCENTAGE:Int = 0x0030;
	private static inline var FLOAT_PERC:Int = 0x0031;
	private static inline var MASTER_SCALE:Int = 0x0100;
	private static inline var IMAGE_FILE:Int = 0x1100;
	private static inline var AMBIENT_LIGHT:Int = 0X2100;
	//>----- Object Chunks -----------------------------------------------------
	private static inline var MESH:Int = 0x4000;
	private static inline var MESH_OBJECT:Int = 0x4100;
	private static inline var MESH_VERTICES:Int = 0x4110;
	private static inline var VERTEX_FLAGS:Int = 0x4111;
	private static inline var MESH_FACES:Int = 0x4120;
	private static inline var MESH_MATER:Int = 0x4130;
	private static inline var MESH_TEX_VERT:Int = 0x4140;
	private static inline var MESH_XFMATRIX:Int = 0x4160;
	private static inline var MESH_COLOR_IND:Int = 0x4165;
	private static inline var MESH_TEX_INFO:Int = 0x4170;
	private static inline var HEIRARCHY:Int = 0x4F00;
	//>----- Material Chunks ---------------------------------------------------
	private static inline var MATERIAL:Int = 0xAFFF;
	private static inline var MAT_NAME:Int = 0xA000;
	private static inline var MAT_AMBIENT:Int = 0xA010;
	private static inline var MAT_DIFFUSE:Int = 0xA020;
	private static inline var MAT_SPECULAR:Int = 0xA030;
	private static inline var MAT_SHININESS:Int = 0xA040;
	private static inline var MAT_FALLOFF:Int = 0xA052;
	private static inline var MAT_EMISSIVE:Int = 0xA080;
	private static inline var MAT_SHADER:Int = 0xA100;
	private static inline var MAT_TEXMAP:Int = 0xA200;
	private static inline var MAT_TEXFLNM:Int = 0xA300;
	private static inline var OBJ_LIGHT:Int = 0x4600;
	private static inline var OBJ_CAMERA:Int = 0x4700;
	//>----- KeyFrames Chunks --------------------------------------------------
	private static inline var ANIM_HEADER:Int = 0xB00A;
	private static inline var ANIM_OBJ:Int = 0xB002;
	private static inline var ANIM_NAME:Int = 0xB010;
	private static inline var ANIM_POS:Int = 0xB020;
	private static inline var ANIM_ROT:Int = 0xB021;
	private static inline var ANIM_SCALE:Int = 0xB022;
	private var texturePath:String;
	private var autoLoadTextures:Bool;
	/**
	 * Reference container for all materials used in the 3ds object.
	 */
	public var materialLibrary:MaterialLibrary;
	public var animationLibrary:AnimationLibrary;
	public var geometryLibrary:GeometryLibrary;
	/**
	 * Array of mesh data objects used for storing the parsed 3ds data structure.
	 */
	public var meshDataList:Array<Dynamic>;
	/**
	 * In the 3ds file only the file names of texture files are given.
	 * If the textures are stored in a specific path, that path can be
	 * specified through the constructor.
	 */
	private var centerMeshes:Bool;
	private var material:ITriangleMaterial;
	private var _maxX:Float;
	private var _minX:Float;
	private var _maxY:Float;
	private var _minY:Float;
	private var _maxZ:Float;
	private var _minZ:Float;
	

	/**
	 * Read id and length of 3ds chunk
	 * 
	 * @param chunk 
	 * 
	 */
	private function readChunk(chunk:Chunk3ds):Void {
		
		chunk.id = _data.readUnsignedShort();
		chunk.length = _data.readUnsignedInt();
		chunk.bytesRead = 6;
	}

	/**
	 * Skips past a chunk. If we don't understand the meaning of a chunk id,
	 * we just skip past it.
	 * 
	 * @param chunk
	 * 
	 */
	private function skipChunk(chunk:Chunk3ds):Void {
		
		_data.position += chunk.length - chunk.bytesRead;
		chunk.bytesRead = chunk.length;
	}

	/**
	 * Read the base 3DS object.
	 * 
	 * @param chunk
	 * 
	 */
	private function parse3DS(chunk:Chunk3ds):Void {
		
		while (chunk.bytesRead < chunk.length) {
			var subChunk:Chunk3ds = Type.createInstance(Chunk3ds, []);
			readChunk(subChunk);
			switch (subChunk.id) {
				case EDIT3DS :
					parseEdit3DS(subChunk);
				case KEYF3DS :
					skipChunk(subChunk);
				default :
					skipChunk(subChunk);
				

			}
			chunk.bytesRead += subChunk.length;
		}

	}

	/**
	 * Read the Edit chunk
	 * 
	 * @param chunk
	 * 
	 */
	private function parseEdit3DS(chunk:Chunk3ds):Void {
		
		while (chunk.bytesRead < chunk.length) {
			var subChunk:Chunk3ds = Type.createInstance(Chunk3ds, []);
			readChunk(subChunk);
			switch (subChunk.id) {
				case MATERIAL :
					parseMaterial(subChunk);
				case MESH :
					_meshData = new MeshData();
					readMeshName(subChunk);
					_meshData.geometry = geometryLibrary.addGeometry(_meshData.name);
					_geometryData = _meshData.geometry;
					_verticesDictionary = new IntHash<Vertex>();
					parseMesh(subChunk);
					meshDataList.push(_meshData);
					if (centerMeshes) {
						_geometryData.maxX = -Math.POSITIVE_INFINITY;
						_geometryData.minX = Math.POSITIVE_INFINITY;
						_geometryData.maxY = -Math.POSITIVE_INFINITY;
						_geometryData.minY = Math.POSITIVE_INFINITY;
						_geometryData.maxZ = -Math.POSITIVE_INFINITY;
						_geometryData.minZ = Math.POSITIVE_INFINITY;
						for (_vertex in _verticesDictionary.iterator()) {

							if (_vertex != null) {
								if (_geometryData.maxX < _vertex._x) {
									_geometryData.maxX = _vertex._x;
								}
								if (_geometryData.minX > _vertex._x) {
									_geometryData.minX = _vertex._x;
								}
								if (_geometryData.maxY < _vertex._y) {
									_geometryData.maxY = _vertex._y;
								}
								if (_geometryData.minY > _vertex._y) {
									_geometryData.minY = _vertex._y;
								}
								if (_geometryData.maxZ < _vertex._z) {
									_geometryData.maxZ = _vertex._z;
								}
								if (_geometryData.minZ > _vertex._z) {
									_geometryData.minZ = _vertex._z;
								}
							}
						}

					}
				default :
					skipChunk(subChunk);
				

			}
			chunk.bytesRead += subChunk.length;
		}

	}

	private function parseMaterial(chunk:Chunk3ds):Void {
		
		while (chunk.bytesRead < chunk.length) {
			var subChunk:Chunk3ds = Type.createInstance(Chunk3ds, []);
			readChunk(subChunk);
			switch (subChunk.id) {
				case MAT_NAME :
					readMaterialName(subChunk);
				case MAT_AMBIENT :
					readColor(AMBIENT);
				case MAT_DIFFUSE :
					readColor(DIFFUSE);
				case MAT_SPECULAR :
					readColor(SPECULAR);
				case MAT_TEXMAP :
					parseMaterial(subChunk);
				case MAT_TEXFLNM :
					readTextureFileName(subChunk);
				default :
					skipChunk(subChunk);
				

			}
			chunk.bytesRead += subChunk.length;
		}

	}

	private function readMaterialName(chunk:Chunk3ds):Void {
		
		_materialData = materialLibrary.addMaterial(readASCIIZString(_data));
		Debug.trace(" + Build Material : " + _materialData.name);
		chunk.bytesRead = chunk.length;
	}

	private function readColor(type:String):Void {
		
		_materialData.materialType = MaterialData.SHADING_MATERIAL;
		var color:Int;
		var chunk:Chunk3ds = Type.createInstance(Chunk3ds, []);
		readChunk(chunk);
		switch (chunk.id) {
			case COLOR_RGB :
				color = readColorRGB(chunk);
			case COLOR_F :
				// TODO: write implentation code
				trace("COLOR_F not implemented yet");
				skipChunk(chunk);
			default :
				skipChunk(chunk);
				trace("unknown ambient color format");
			

		}
		switch (type) {
			case AMBIENT :
				_materialData.ambientColor = color;
			case DIFFUSE :
				_materialData.diffuseColor = color;
			case SPECULAR :
				_materialData.specularColor = color;
			

		}
	}

	private function readColorRGB(chunk:Chunk3ds):Int {
		
		var color:Int = 0;
		var i:Int = 0;
		while (i < 3) {
			var c:Int = _data.readUnsignedByte();
			color += c * Math.pow(0x100, 2 - i);
			chunk.bytesRead++;
			
			// update loop variables
			++i;
		}

		return color;
	}

	private function readTextureFileName(chunk:Chunk3ds):Void {
		
		_materialData.textureFileName = readASCIIZString(_data);
		_materialData.materialType = MaterialData.TEXTURE_MATERIAL;
		chunk.bytesRead = chunk.length;
	}

	private function parseMesh(chunk:Chunk3ds):Void {
		
		while (chunk.bytesRead < chunk.length) {
			var subChunk:Chunk3ds = Type.createInstance(Chunk3ds, []);
			readChunk(subChunk);
			switch (subChunk.id) {
				case MESH_OBJECT :
					parseMesh(subChunk);
				case MESH_VERTICES :
					readMeshVertices(subChunk);
				case MESH_FACES :
					readMeshFaces(subChunk);
					parseMesh(subChunk);
				case MESH_MATER :
					readMeshMaterial(subChunk);
				case MESH_TEX_VERT :
					readMeshTexVert(subChunk);
				default :
					skipChunk(subChunk);
				

			}
			chunk.bytesRead += subChunk.length;
		}

	}

	private function readMeshName(chunk:Chunk3ds):Void {
		
		_meshData.name = readASCIIZString(_data);
		chunk.bytesRead += _meshData.name.length + 1;
		Debug.trace(" + Build Mesh : " + _meshData.name);
	}

	private function readMeshVertices(chunk:Chunk3ds):Void {
		
		var numVerts:Int = _data.readUnsignedShort();
		chunk.bytesRead += 2;
		var i:Int = 0;
		while (i < numVerts) {
			_meshData.geometry.vertices.push(new Vertex(-_data.readFloat(), _data.readFloat(), _data.readFloat()));
			chunk.bytesRead += 12;
			
			// update loop variables
			++i;
		}

	}

	private function readMeshFaces(chunk:Chunk3ds):Void {
		
		var numFaces:Int = _data.readUnsignedShort();
		chunk.bytesRead += 2;
		var i:Int = 0;
		while (i < numFaces) {
			_faceData = new FaceData();
			_faceData.v0 = _data.readUnsignedShort();
			_faceData.v1 = _data.readUnsignedShort();
			_faceData.v2 = _data.readUnsignedShort();
			_verticesDictionary.put(_faceData.v0, _geometryData.vertices[_faceData.v0]);
			_verticesDictionary.put(_faceData.v1, _geometryData.vertices[_faceData.v1]);
			_verticesDictionary.put(_faceData.v2, _geometryData.vertices[_faceData.v2]);
			_faceData.visible = ((cast(_data.readUnsignedShort(), Bool)) != null);
			chunk.bytesRead += 8;
			_geometryData.faces.push(_faceData);
			
			// update loop variables
			++i;
		}

	}

	/**
	 * Read the Mesh Material chunk
	 * 
	 * @param chunk
	 * 
	 */
	private function readMeshMaterial(chunk:Chunk3ds):Void {
		
		var meshMaterial:MeshMaterialData = new MeshMaterialData();
		meshMaterial.symbol = readASCIIZString(_data);
		chunk.bytesRead += meshMaterial.symbol.length + 1;
		var numFaces:Int = _data.readUnsignedShort();
		chunk.bytesRead += 2;
		var i:Int = 0;
		while (i < numFaces) {
			meshMaterial.faceList.push(_data.readUnsignedShort());
			chunk.bytesRead += 2;
			
			// update loop variables
			++i;
		}

		_meshData.geometry.materials.push(meshMaterial);
	}

	private function readMeshTexVert(chunk:Chunk3ds):Void {
		
		var numUVs:Int = _data.readUnsignedShort();
		chunk.bytesRead += 2;
		var i:Int = 0;
		while (i < numUVs) {
			_meshData.geometry.uvs.push(new UV(_data.readFloat(), _data.readFloat()));
			chunk.bytesRead += 8;
			
			// update loop variables
			++i;
		}

	}

	/**
	 * Reads a null-terminated ascii string out of a byte array.
	 * 
	 * @param data The byte array to read from.
	 * @return The string read, without the null-terminating character.
	 * 
	 */
	private function readASCIIZString(data:ByteArray):String {
		//var readLength:int = 0; // length of string to read
		
		var l:Int = data.length - data.position;
		var tempByteArray:ByteArray = new ByteArray();
		var i:Int = 0;
		while (i < l) {
			var c:Int = data.readByte();
			if (c == 0) {
				break;
			}
			tempByteArray.writeByte(c);
			
			// update loop variables
			++i;
		}

		var asciiz:String = "";
		tempByteArray.position = 0;
		i = 0;
		while (i < tempByteArray.length) {
			asciiz += String.fromCharCode(tempByteArray.readByte());
			
			// update loop variables
			++i;
		}

		return asciiz;
	}

	private function buildMeshes():Void {
		
		for (__i in 0...meshDataList.length) {
			_meshData = meshDataList[__i];

			if (_meshData != null) {
				var mesh:Mesh = new Mesh({name:_meshData.name});
				_geometryData = _meshData.geometry;
				var geometry:Geometry = _geometryData.geometry;
				if (geometry == null) {
					geometry = _geometryData.geometry = new Geometry();
					mesh.geometry = geometry;
					//set materialdata for each face
					for (__i in 0..._geometryData.materials.length) {
						_meshMaterialData = _geometryData.materials[__i];

						if (_meshMaterialData != null) {
							for (__i in 0..._meshMaterialData.faceList.length) {
								_faceListIndex = _meshMaterialData.faceList[__i];

								if (_faceListIndex != null) {
									_faceData = cast(_geometryData.faces[_faceListIndex], FaceData);
									_faceData.materialData = materialLibrary.get(_meshMaterialData.symbol);
								}
							}

						}
					}

					for (__i in 0..._geometryData.faces.length) {
						_faceData = _geometryData.faces[__i];

						if (_faceData != null) {
							if ((_faceData.materialData != null)) {
								_faceMaterial = cast(_faceData.materialData.material, ITriangleMaterial);
							} else {
								_faceMaterial = null;
							}
							_face = new Face(_geometryData.vertices[_faceData.v0], _geometryData.vertices[_faceData.v1], _geometryData.vertices[_faceData.v2], _faceMaterial, _geometryData.uvs[_faceData.v0], _geometryData.uvs[_faceData.v1], _geometryData.uvs[_faceData.v2]);
							geometry.addFace(_face);
							if ((_faceData.materialData != null)) {
								_faceData.materialData.elements.push(_face);
							}
						}
					}

				} else {
					mesh.geometry = geometry;
				}
				//center vertex points in mesh for better bounding radius calulations
				if (centerMeshes) {
					mesh.movePivot(_moveVector.x = (_geometryData.maxX + _geometryData.minX) / 2, _moveVector.y = (_geometryData.maxY + _geometryData.minY) / 2, _moveVector.z = (_geometryData.maxZ + _geometryData.minZ) / 2);
					_moveVector.transform(_moveVector, _meshData.transform);
					mesh.moveTo(_moveVector.x, _moveVector.y, _moveVector.z);
				}
				mesh.type = ".3ds";
				(cast(container, ObjectContainer3D)).addChild(mesh);
			}
		}

	}

	private function buildMaterials():Void {
		
		for (_materialData in materialLibrary.iterator()) {
			if (_materialData != null) {
				if ((material != null)) {
					_materialData.material = material;
				}
				//overridden by materials passed in contructor
				if ((_materialData.material != null)) {
					continue;
				}
				switch (_materialData.materialType) {
					case MaterialData.TEXTURE_MATERIAL :
						materialLibrary.loadRequired = true;
					case MaterialData.SHADING_MATERIAL :
						_materialData.material = new ShadingColorMaterial({ambient:_materialData.ambientColor, diffuse:_materialData.diffuseColor, specular:_materialData.specularColor});
					case MaterialData.WIREFRAME_MATERIAL :
						_materialData.material = new WireColorMaterial();
					

				}
			}
		}

	}

	/**
	 * Creates a new <code>Max3DS</code> object. Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods.
	 * 
	 * @param	data				The binary data of a loaded file.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 * 
	 * @see away3d.loaders.Max3DS#parse()
	 * @see away3d.loaders.Max3DS#load()
	 */
	public function new(data:Dynamic, ?init:Dynamic=null) {
		// autogenerated
		super();
		this._moveVector = new Number3D();
		this._totalChunks = 0;
		this._parsedChunks = 0;
		this.materialLibrary = new MaterialLibrary();
		this.meshDataList = [];
		
		
		_data = Cast.bytearray(data);
		_data.endian = Endian.LITTLE_ENDIAN;
		ini = Init.parse(init);
		texturePath = ini.getString("texturePath", "");
		autoLoadTextures = ini.getBoolean("autoLoadTextures", true);
		material = cast(ini.getMaterial("material"), ITriangleMaterial);
		centerMeshes = ini.getBoolean("centerMeshes", false);
		var materials:Dynamic = ini.getObject("materials");
		if (materials == null)  {
			materials = {};
		};
		var name:String;
		for (name in Reflect.fields(materials)) {
			_materialData = materialLibrary.addMaterial(name);
			_materialData.material = Cast.material(Reflect.field(materials, name));
			//determine material type
			if (Std.is(_materialData.material, BitmapMaterial)) {
				_materialData.materialType = MaterialData.TEXTURE_MATERIAL;
			} else if (Std.is(_materialData.material, ShadingColorMaterial)) {
				_materialData.materialType = MaterialData.SHADING_MATERIAL;
			} else if (Std.is(_materialData.material, WireframeMaterial)) {
				_materialData.materialType = MaterialData.WIREFRAME_MATERIAL;
			}
			
		}

		container = new ObjectContainer3D(ini);
		container.name = "max3ds";
		materialLibrary = container.materialLibrary = new MaterialLibrary();
		animationLibrary = container.animationLibrary = new AnimationLibrary();
		geometryLibrary = container.geometryLibrary = new GeometryLibrary();
		materialLibrary.autoLoadTextures = autoLoadTextures;
		materialLibrary.texturePath = texturePath;
		//first chunk is always the primary, so we simply read it and parse it
		var chunk:Chunk3ds = Type.createInstance(Chunk3ds, []);
		readChunk(chunk);
		parse3DS(chunk);
		//build materials
		buildMaterials();
		//build the meshes
		buildMeshes();
	}

	/**
	 * Loads and parses a 3ds file into a 3d container object.
	 * 
	 * @param	url					The url location of the file to load.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.
	 */
	public static function load(url:String, ?init:Dynamic=null):Object3DLoader {
		//texturePath as model folder
		
		if ((url != null)) {
			var _pathArray:Array<Dynamic> = url.split("/");
			var _imageName:String = _pathArray.pop();
			var _texturePath:String = (_pathArray.length > 0) ? _pathArray.join("/") + "/" : _pathArray.join("/");
			if ((init != null)) {
				init.texturePath = (init.texturePath) ? init.texturePath : _texturePath;
			} else {
				init = {texturePath:_texturePath};
			}
		}
		return Object3DLoader.loadGeometry(url, Max3DS, true, init);
	}

	/**
	 * Creates a 3d container object from the raw binary data of a 3ds file.
	 * 
	 * @param	data				The binary data of a loaded file.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 * 
	 * @return						A 3d container object representation of the 3ds file.
	 */
	public static function parse(data:Dynamic, ?init:Dynamic=null):ObjectContainer3D {
		
		return cast(Object3DLoader.parseGeometry(data, Max3DS, init).handle, ObjectContainer3D);
	}

}

