package away3d.loaders
{
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.materials.*;
	import away3d.core.base.*;
	import away3d.core.base.*
	import away3d.core.base.*
	import away3d.core.utils.Cast;
	import away3d.core.utils.Init;
	import away3d.loaders.data.*;
	import away3d.loaders.utils.*;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/* 3DS file parser */
	public class Max3DS
	{
		use namespace arcane;
		
		public var container:ObjectContainer3D;
		public var materialLibrary:MaterialLibrary = new MaterialLibrary();
		public var meshDataList:Array = [];
		
		/**
		* An array of bytes from the 3ds files.
		*/
		private var _data:ByteArray;
		
		/**
		* In the 3ds file only the file names of texture files are given.
		* If the textures are stored in a specific path, that path can be
		* specified through the constructor.
		*/
		protected var centerMeshes:Boolean;
		protected var material:ITriangleMaterial;
		
		public function Max3DS(data:ByteArray, init:Object = null)
		{
			_data = data;
			_data.endian = Endian.LITTLE_ENDIAN;
			
			init = Init.parse(init);
			materialLibrary.texturePath = init.getString("texturePath", "");
			materialLibrary.autoLoadTextures = init.getBoolean("autoLoadTextures", true);
			material = init.getMaterial("material");
			centerMeshes = init.getBoolean("centerMeshes", true);
			
			var materials:Object = init.getObject("materials") || {};
			
			for (var name:String in materials) {
                _materialData = materialLibrary.addMaterial(name);
                _materialData.material = Cast.material(materials[name]);
                
                //determine material type
                if (_materialData.material is BitmapMaterial)
                	_materialData.materialType = MaterialData.TEXTURE_MATERIAL;
                else if (_materialData.material is ShadingColorMaterial)
                	_materialData.materialType = MaterialData.SHADING_MATERIAL;
                else if (_materialData.material is WireframeMaterial)
                	_materialData.materialType = MaterialData.WIREFRAME_MATERIAL;
   			}
            
			container = new ObjectContainer3D(init);
			
			//first chunk is always the primary, so we simply read it and parse it
			var chunk:Chunk3ds = new Chunk3ds();
			readChunk(chunk);
			parse3DS(chunk);
			
			//build materials
			buildMaterials();
			
			//build the meshes
			buildMeshes();
		}

        public static function load(url:String, init:Object = null):Object3DLoader
        {
            return Object3DLoader.loadGeometry(url, parse, true, init);
        }
		
		public static function loadTextures(data:*, init:Object = null):Object3DLoader
		{
			var parser:Max3DS = new Max3DS(Cast.bytearray(data), init);
			return Object3DLoader.loadTextures(parser.container, parser.materialLibrary, init);
		}
		
        public static function parse(data:*, init:Object = null, loader:Object3DLoader = null):Object3D
        {
        	var parser:Max3DS = new Max3DS(Cast.bytearray(data), init);
        	if (loader)
        		loader.materialLibrary = parser.materialLibrary;
            return parser.container;
        }
		
		/**
		 * Read id and length of 3ds chunk
		 * 
		 * @param chunk 
		 * 
		 */		
		private function readChunk(chunk:Chunk3ds):void
		{
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
		private function skipChunk(chunk:Chunk3ds):void
		{
			_data.position += chunk.length - chunk.bytesRead;
			chunk.bytesRead = chunk.length;
		}
		
		/**
		 * Read the base 3DS object.
		 * 
		 * @param chunk
		 * 
		 */		
		private function parse3DS(chunk:Chunk3ds):void
		{
			while (chunk.bytesRead < chunk.length)
			{
				var subChunk:Chunk3ds = new Chunk3ds();
				readChunk(subChunk);
				switch (subChunk.id)
				{
					case EDIT3DS:
						parseEdit3DS(subChunk);
						break;
					case KEYF3DS:
						skipChunk(subChunk);
						break;
					default:
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
		private function parseEdit3DS(chunk:Chunk3ds):void
		{
			while (chunk.bytesRead < chunk.length)
			{
				var subChunk:Chunk3ds = new Chunk3ds();
				readChunk(subChunk);
				switch (subChunk.id)
				{
					case MATERIAL:
						parseMaterial(subChunk);
						break;
					case MESH:
						_meshData = new MeshData();
						readMeshName(subChunk);
						parseMesh(subChunk);
						meshDataList.push(_meshData);
						break;
					default:
						skipChunk(subChunk);
				}
				
				chunk.bytesRead += subChunk.length;
			}
		}
		
		private var _materialData:MaterialData;
		
		private function parseMaterial(chunk:Chunk3ds):void
		{
			while (chunk.bytesRead < chunk.length)
			{
				var subChunk:Chunk3ds = new Chunk3ds();
				readChunk(subChunk);
				switch (subChunk.id)
				{
					case MAT_NAME:
						readMaterialName(subChunk);
						break;
					case MAT_AMBIENT:
						readColor(AMBIENT);
						break;
					case MAT_DIFFUSE:
						readColor(DIFFUSE);
						break;
					case MAT_SPECULAR:
						readColor(SPECULAR);
						break;
					case MAT_TEXMAP:
						parseMaterial(subChunk);
						break;
					case MAT_TEXFLNM:
						readTextureFileName(subChunk);
						break;
					default:
						skipChunk(subChunk);
				}
				chunk.bytesRead += subChunk.length;
			}
		}
		
		private function readMaterialName(chunk:Chunk3ds):void
		{
			_materialData = materialLibrary.addMaterial(readASCIIZString(_data));
			
			chunk.bytesRead = chunk.length;
		}
		
		private function readColor(type:String):void
		{
			_materialData.materialType = MaterialData.SHADING_MATERIAL;
			
			var color:int;
			var chunk:Chunk3ds = new Chunk3ds();
			readChunk(chunk);
			switch (chunk.id)
			{
				case COLOR_RGB:
					color = readColorRGB(chunk);
					break;
				case COLOR_F:
				// TODO: write implentation code
					trace("COLOR_F not implemented yet");
					skipChunk(chunk);
					break;
				default:
					skipChunk(chunk);
					trace("unknown ambient color format");
			}
			
			switch (type)
			{
				case AMBIENT:
					_materialData.ambientColor = color;
					break;
				case DIFFUSE:
					_materialData.diffuseColor = color;
					break;
				case SPECULAR:
					_materialData.specularColor = color;
					break;
			}
		}
		
		private function readColorRGB(chunk:Chunk3ds):int
		{
			var color:int = 0;
			
			for (var i:int = 0; i < 3; i++)
			{
				var c:int = _data.readUnsignedByte();
				color += c*Math.pow(0x100, 2-i);
				chunk.bytesRead++;
			}
			
			return color;
		}
		
		private function readTextureFileName(chunk:Chunk3ds):void
		{
			_materialData.textureFileName = readASCIIZString(_data);
			_materialData.materialType = MaterialData.TEXTURE_MATERIAL;
			
			chunk.bytesRead = chunk.length;
		}
		
		private var _meshData:MeshData;
		
		private function parseMesh(chunk:Chunk3ds):void
		{
			while (chunk.bytesRead < chunk.length)
			{
				var subChunk:Chunk3ds = new Chunk3ds();
				readChunk(subChunk);
				switch (subChunk.id)
				{
					case MESH_OBJECT:
						parseMesh(subChunk);
						break;
					case MESH_VERTICES:
						readMeshVertices(subChunk);
						break;
					case MESH_FACES:
						readMeshFaces(subChunk);
						parseMesh(subChunk);
						break;
					case MESH_MATER:
						readMeshMaterial(subChunk);
						break;
					case MESH_TEX_VERT:
						readMeshTexVert(subChunk);
						break;
					default:
						skipChunk(subChunk);
				}
				chunk.bytesRead += subChunk.length;
			}
		}
		
		private function readMeshName(chunk:Chunk3ds):void
		{
			_meshData.name = readASCIIZString(_data);
			chunk.bytesRead += _meshData.name.length + 1;
		}
		
		private function readMeshVertices(chunk:Chunk3ds):void
		{
			var numVerts:int = _data.readUnsignedShort();
			chunk.bytesRead += 2;
			
			for (var i:int = 0; i < numVerts; i++)
			{
				_meshData.vertices.push(new Vertex(_data.readFloat(), _data.readFloat(), _data.readFloat()));
				chunk.bytesRead += 12;
			}
		}
		
		private var _faceData:FaceData;
		
		private function readMeshFaces(chunk:Chunk3ds):void
		{
			var numFaces:int = _data.readUnsignedShort();
			chunk.bytesRead += 2;
			for (var i:int = 0; i < numFaces; i++)
			{
				_faceData = new FaceData();
				
				_faceData.v2 = _data.readUnsignedShort();
				_faceData.v1 = _data.readUnsignedShort();
				_faceData.v0 = _data.readUnsignedShort();
				_faceData.visible = (_data.readUnsignedShort() as Boolean);
				chunk.bytesRead += 8;
				
				_meshData.faces.push(_faceData);
			}
		}
			
		/**
		 * Read the Mesh Material chunk
		 * 
		 * @param chunk
		 * 
		 */
		private function readMeshMaterial(chunk:Chunk3ds):void
		{
			var meshMaterial:MeshMaterialData = new MeshMaterialData();
			meshMaterial.name = readASCIIZString(_data);
			chunk.bytesRead += meshMaterial.name.length +1;
			
			var numFaces:int = _data.readUnsignedShort();
			chunk.bytesRead += 2;
			for (var i:int = 0; i < numFaces; i++)
			{
				meshMaterial.faceList.push(_data.readUnsignedShort());
				chunk.bytesRead += 2;
			}
			
			_meshData.materials.push(meshMaterial);
		}
		
		private function readMeshTexVert(chunk:Chunk3ds):void
		{
			var numUVs:int = _data.readUnsignedShort();
			chunk.bytesRead += 2;
			
			for (var i:int = 0; i < numUVs; i++)
			{
				_meshData.uvs.push(new UV(_data.readFloat(), _data.readFloat()));
				chunk.bytesRead += 8;
			}
		}
		
		/**
		 * Reads a null-terminated ascii string out of a byte array.
		 * 
		 * @param data The byte array to read from.
		 * @return The string read, without the null-terminating character.
		 * 
		 */		
		private function readASCIIZString(data:ByteArray):String
		{
			var readLength:int = 0; // length of string to read
			var l:int = data.length - data.position;
			var tempByteArray:ByteArray = new ByteArray();
			
			for (var i:int = 0; i < l; i++)
			{
				var c:int = data.readByte();
				
				if (c == 0)
				{
					break;
				}
				tempByteArray.writeByte(c);
			}
			
			var asciiz:String = "";
			tempByteArray.position = 0;
			for (i = 0; i < tempByteArray.length; i++)
			{
				asciiz += String.fromCharCode(tempByteArray.readByte());
			}
			return asciiz;
		}
		private var averageX:Number;
		private var averageY:Number;
		private var averageZ:Number;
		private var numVertices:int;
		
		private var _meshMaterialData:MeshMaterialData;
		private var _faceListIndex:int;
		
		private var _face:Face;
		private var _vertex:Vertex;
				
		private function buildMeshes():void
		{
			
			for each (_meshData in meshDataList)
			{
				
				//set materialdata for each face
				for each (_meshMaterialData in _meshData.materials) {
					for each (_faceListIndex in _meshMaterialData.faceList) {
						_faceData = _meshData.faces[_faceListIndex] as FaceData;
						_faceData.materialData = materialLibrary[_meshMaterialData.name];
					}
				}
				
				//create Mesh object
				var mesh:Mesh = new Mesh();
				
				
				var face:Face;
				var matData:MaterialData;
				
				for each(_faceData in _meshData.faces) {
					_face = new Face(_meshData.vertices[_faceData.v0],
												_meshData.vertices[_faceData.v1],
												_meshData.vertices[_faceData.v2],
												_faceData.materialData.material,
												_meshData.uvs[_faceData.v0],
												_meshData.uvs[_faceData.v1],
												_meshData.uvs[_faceData.v2]);
					mesh.addFace(_face);
					_faceData.materialData.faces.push(_face);
				}
				
				if (centerMeshes) {
					//determine center and offset all vertices (useful for subsequent max/min/radius calculations)
					averageX = averageY = averageZ = 0;
					numVertices = _meshData.vertices.length;
					for each (_vertex in _meshData.vertices) {
						averageX += _vertex._x;
						averageY += _vertex._y;
						averageZ += _vertex._z;
					}
					
					mesh.movePivot(averageX/numVertices, averageY/numVertices, averageZ/numVertices);
				}
				
				container.addChild(mesh);
				mesh.type = ".3ds";
			}
		}
		
		private function buildMaterials():void
		{
			for each (_materialData in materialLibrary)
			{
				//overridden by the material property in constructor
				if (material)
					_materialData.material = material;
				
				//overridden by materials passed in contructor
				if (_materialData.material)
					continue;
				
				switch (_materialData.materialType)
				{
					case MaterialData.TEXTURE_MATERIAL:
						materialLibrary.loadRequired = true;
						break;
					case MaterialData.SHADING_MATERIAL:
						_materialData.material = new ShadingColorMaterial({ambient:_materialData.ambientColor, diffuse:_materialData.diffuseColor, specular:_materialData.specularColor});
						break;
					case MaterialData.WIREFRAME_MATERIAL:
						_materialData.material = new WireColorMaterial();
						break;
				}
			}
		}
		
		//>----- Color Types --------------------------------------------------------
		
		public const AMBIENT:String = "ambient";
		public const DIFFUSE:String = "diffuse";
		public const SPECULAR:String = "specular";
		
		//>----- Main Chunks --------------------------------------------------------
		
		public const PRIMARY:int = 0x4D4D;
		public const EDIT3DS:int = 0x3D3D;  // Start of our actual objects
		public const KEYF3DS:int = 0xB000;  // Start of the keyframe information
		
		//>----- General Chunks -----------------------------------------------------
		
		public const VERSION:int = 0x0002;
		public const MESH_VERSION:int = 0x3D3E;
		public const KFVERSION:int = 0x0005;
		public const COLOR_F:int = 0x0010;
		public const COLOR_RGB:int = 0x0011;
		public const LIN_COLOR_24:int = 0x0012;
		public const LIN_COLOR_F:int = 0x0013;
		public const INT_PERCENTAGE:int = 0x0030;
		public const FLOAT_PERC:int = 0x0031;
		public const MASTER_SCALE:int = 0x0100;
		public const IMAGE_FILE:int = 0x1100;
		public const AMBIENT_LIGHT:int = 0X2100;
		
		//>----- Object Chunks -----------------------------------------------------
		
		public const MESH:int = 0x4000;
		public const MESH_OBJECT:int = 0x4100;
		public const MESH_VERTICES:int = 0x4110;
		public const VERTEX_FLAGS:int = 0x4111;
		public const MESH_FACES:int = 0x4120;
		public const MESH_MATER:int = 0x4130;
		public const MESH_TEX_VERT:int = 0x4140;
		public const MESH_XFMATRIX:int = 0x4160;
		public const MESH_COLOR_IND:int = 0x4165;
		public const MESH_TEX_INFO:int = 0x4170;
		public const HEIRARCHY:int = 0x4F00;
		
		//>----- Material Chunks ---------------------------------------------------
		
		public const MATERIAL:int = 0xAFFF;
		public const MAT_NAME:int = 0xA000;
		public const MAT_AMBIENT:int = 0xA010;
		public const MAT_DIFFUSE:int = 0xA020;
		public const MAT_SPECULAR:int = 0xA030;
		public const MAT_SHININESS:int = 0xA040;
		public const MAT_FALLOFF:int = 0xA052;
		public const MAT_EMISSIVE:int = 0xA080;
		public const MAT_SHADER:int = 0xA100;
		public const MAT_TEXMAP:int = 0xA200;
		public const MAT_TEXFLNM:int = 0xA300;
		public const OBJ_LIGHT:int = 0x4600;
		public const OBJ_CAMERA:int = 0x4700;
		
		//>----- KeyFrames Chunks --------------------------------------------------
		
		public const ANIM_HEADER:int = 0xB00A;
		public const ANIM_OBJ:int = 0xB002;
		public const ANIM_NAME:int = 0xB010;
		public const ANIM_POS:int = 0xB020;
		public const ANIM_ROT:int = 0xB021;
		public const ANIM_SCALE:int = 0xB022;
	}
}

class Chunk3ds
{	
	public var id:int;
	public var length:int;
	public var bytesRead:int;	 
}