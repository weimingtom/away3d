package away3d.loaders
{
	import __AS3__.vec.Vector;
	
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.UV;
	import away3d.core.base.Vertex;
	import away3d.core.geom.Plane3D;
	import away3d.core.graphs.BSPNode;
	import away3d.core.graphs.BSPTree;
	import away3d.loaders.data.MaterialData;
	import away3d.loaders.utils.MaterialLibrary;
	import away3d.materials.BitmapMaterial;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	use namespace arcane;
	
	public class Bsp extends AbstractParser
	{
		private static const BSP_VERSION : int = 29;
		
		private var _header : QBSPHeader;
		
		private var _numPlanes : int;
		private var _numModels : int;
		private var _numVertices : int;
		private var _numLeaves : int;
		private var _numNodes : int;
		private var _numTexInfos : int;
		private var _numClipNodes : int;
		private var _numFaces : int;
		private var _numMarkSurfaces : int;
		private var _numSurfaceEdges : int;
		private var _numEdges : int;
		
		private var _textureDataSize : int;
		private var _visDataSize : int;
		private var _lightDataSize : int;
		private var _entDataSize : int;
		
		private var _numTextures : int;
		private var _textureData : Vector.<int>;
		private var _visData : Array;	// bytes
		private var _lightData : Array;	// bytes
		private var _entData : Array;	// bytes
		
		private var _models : Vector.<QBSPModel>;
		private var _vertices : Vector.<Vertex>;
		private var _planes : Vector.<Plane3D>;
		private var _leaves : Vector.<QBSPLeaf>;
		private var _nodes : Vector.<QBSPNode>;
		private var _texInfo : Vector.<QBSPTexInfo>;
		private var _clipNodes : Vector.<QBSPClipNode>;
		private var _faces : Vector.<QBSPFace>;
		private var _markSurfaces : Vector.<int>;
		private var _surfEdges : Vector.<int>;
		private var _edges : Vector.<QBSPEdge>;
		
		private var _textureDataDetails : Vector.<QBSPMipTex>;
		
		private var _bitmapDatas : Vector.<BitmapData>;	// textures
		
		private var _bspTree : BSPTree;
		
		private var _materials : Vector.<BitmapMaterial>;
		
		private var _faceIdLookUp : Dictionary;
		
		private var _currentModel : QBSPModel;
		
		public function Bsp(init:Object=null)
		{
			super(init);
		}
		
		/**
		 * Creates a 3d mesh object from the raw binary data of a bsp file.
		 * 
		 * @param	data				The binary data of a loaded file.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * 
		 * @return						A 3d mesh object representation of the md2 file.
		 */
        public static function parse(data:*, init:Object = null):BSPTree
        {
        	return Loader3D.parseGeometry(data, Bsp, init).handle as BSPTree;
        }
    	
    	/**
    	 * Loads and parses an md2 file into a 3d mesh object.
    	 * 
    	 * @param	url					The url location of the file to load.
    	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
    	 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.
    	 */
        public static function load(url:String, init:Object = null):Loader3D
        {
            return Loader3D.loadGeometry(url, Bsp, init);
        }
        
        override arcane function prepareData(data:*):void
        {
        	var ba : ByteArray = ByteArray(data);
        	ba.endian = Endian.LITTLE_ENDIAN;
        	ba.position = 0;
        	readData(ba);
        	parseData();
        }
        
        private function readData(data : ByteArray) : void
        {
        	readHeader(data);
        	readModels(data);
        	readVertices(data);
        	readPlanes(data);
        	readLeaves(data);
			readNodes(data);
			readTexInfo(data);
			//readClipNodes(data);	// don't need this
			readFaces(data);
			readMarkSurfaces(data);
			readSurfacesEdges(data);
			readEdges(data);
			readTextureData(data);
			readVisData(data);
			//readLightingData(data);	// don't need this (yet)
			//readEntityData(data);		// dont need this (yet)
        }
        
        private function parseData() : void
        {
        	var materialLibrary : MaterialLibrary = parseMaterials();
        	_faceIdLookUp = new Dictionary(true);
        	parseFaces();
        	parseModels(materialLibrary);
        }
        
        private function parseMaterials() : MaterialLibrary
        {
        	var material : BitmapMaterial;
        	var materialData : MaterialData;
        	var library : MaterialLibrary;
        	
        	library = new MaterialLibrary();
			_materials = new Vector.<BitmapMaterial>(_numTextures);
			
			for (var i : int = 0; i < _numTextures; i++) {
				materialData = library.addMaterial(_textureDataDetails[i].name);
				materialData.material = _materials[i] = new BitmapMaterial(_bitmapDatas[i]);
				_materials[i].repeat = true;
			}
			
			return library;
        }
        
        // convert all faces to triangles
        private function parseFaces() : void
        {
        	var face : QBSPFace;
			var texinfo : QBSPTexInfo;
			var currentFaceVertices : Vector.<Vertex>;
			
			for (var i : int = 0; i < _numFaces; i++) {
				face = _faces[i];
				texinfo = _texInfo[face.texinfo];
				
				currentFaceVertices = new Vector.<Vertex>();
				for (var j : int = 0; j < face.numedges; j++) {
					var edge : QBSPEdge = getEdge(face.firstedge+j);
					var v1 : Vertex, v2 : Vertex;
					var index1 : int = edge.v0, index2 : int = edge.v1;
			
					currentFaceVertices.push(_vertices[index2]);
				}
				triangulateFace(texinfo, face, currentFaceVertices);
			}
        }
        
        private function getEdge(index : int) : QBSPEdge
		{
			var id : int = _surfEdges[index];
			var edge : QBSPEdge;
			if (id > 0) return _edges[id];
			
			edge = new QBSPEdge();
			edge.v0 = _edges[-id].v1;
			edge.v1 = _edges[-id].v0;
			return edge;
		}
        
		private function triangulateFace(texinfo : QBSPTexInfo, face : QBSPFace, currentFaceVertices : Vector.<Vertex>) : void
		{
			var v1 : Vertex, v2 : Vertex, v3 : Vertex;
			var uv1 : UV, uv2 : UV, uv3 : UV;
			var triangle : Face;
			var material : BitmapMaterial = _materials[texinfo.miptex];
			var len : int = currentFaceVertices.length-1;
			
			v1 = currentFaceVertices[0];
			uv1 = parseUV(v1, texinfo, material);
			
			_faceIdLookUp[face] = new Vector.<Face>();
			
			for (var i : int = 1; i < len; i++) {
				v2 = currentFaceVertices[i];
				v3 = currentFaceVertices[i+1];
				uv2 = parseUV(v2, texinfo, material);
				uv3 = parseUV(v3, texinfo, material);
				triangle = new Face(v3, v2, v1, material, uv3, uv2, uv1);
				
				_faceIdLookUp[face].push(triangle);
			}
		}
        
        private function parseModels(materialLibrary : MaterialLibrary) : void
        {
			var current : BSPTree;
			
			for (var i : int = 0; i < 1; ++i) {
			//for (var i : int = 0; i < _numModels; i++) {
				_currentModel = _models[i];
				current = parseBSP(_currentModel);
				current.materialLibrary = materialLibrary;
				current.init();
				
				// temp
				/*if (i == 0)*/ container = _bspTree = current;
			}
        }
        
		private function parseUV(vertex : Vertex, texinfo : QBSPTexInfo, material : BitmapMaterial) : UV
		{
			var uv : UV = new UV();
			uv.u = (vertex.x*texinfo.vectorS0+vertex.y*texinfo.vectorS2+vertex.z*texinfo.vectorS1+texinfo.offsetS)/material.width;
			uv.v = 1-(vertex.x*texinfo.vectorT0+vertex.y*texinfo.vectorT2+vertex.z*texinfo.vectorT1+texinfo.offsetT)/material.height;
			return uv;
		}
        
        private function parseBSP(model : QBSPModel) : BSPTree
        {
        	var bspTree : BSPTree = new BSPTree();
        	var firstNode : int = model.headnode0;
        	
        	bspTree.x = model.origin0;
        	bspTree.y = model.origin2;
        	bspTree.z = model.origin1;
        	
        	bspTree._leaves = new Vector.<BSPNode>(model.numLeafs+1);	// include 0-leaf
        	
			parseBSPNode(bspTree, _nodes[firstNode], bspTree._rootNode);
        	
        	return bspTree;
        }
        
        private function parseBSPNode(tree : BSPTree, sourceNode : QBSPNode, currentNode : BSPNode) : void
		{
			var front : int = sourceNode.children0;
			var back : int = sourceNode.children1;
			var isFrontChildNode : Boolean = front > 0;
			var isBackChildNode : Boolean = back > 0;
			var frontNode : BSPNode = new BSPNode(currentNode);
			var backNode : BSPNode = new BSPNode(currentNode);
			var plane : Plane3D = _planes[sourceNode.planeNum];
			
			currentNode._partitionPlane = plane;
			currentNode.positiveNode = frontNode;
			currentNode.negativeNode = backNode;
			
			if (isFrontChildNode)
				parseBSPNode(tree, _nodes[front], frontNode);
			else {
				front = -(front+1);
				//front = ~front;
				parseBSPLeaf(tree, _leaves[front], frontNode, front);
			}
			
			if (isBackChildNode)
				parseBSPNode(tree, _nodes[back], backNode);
			else {
				back = -(back+1);
				//back = ~back;
				parseBSPLeaf(tree, _leaves[back], backNode, back);
			}
			frontNode.id = front;
			backNode.id = back;
		}
		
		private function parseBSPLeaf(tree : BSPTree, sourceNode : QBSPLeaf, currentNode : BSPNode, index : int) : void
		{
			var triangles : Vector.<Face>;
			var face : QBSPFace;
			var len : int = sourceNode.firstMarkSurface + sourceNode.numMarkSurface;
			var faceId : int;
			currentNode._isLeaf = true;
			
			if (index > 0) {
				tree._leaves[index] = currentNode;
			
				for (var i : int = sourceNode.firstMarkSurface; i < len; i++) {
					faceId = _markSurfaces[i];
					face = _faces[faceId];
					
					triangles = _faceIdLookUp[face] as Vector.<Face>;
					if (triangles) currentNode.addFaces(triangles);
					else {
							//throw(new Error("Triangles = null!"));
							//currentNode.add([]);
					}
				}
				parseVisList(sourceNode, currentNode);
			}
		}
		
		private function parseVisList(sourceNode : QBSPLeaf, currentNode : BSPNode) : void
		{
			var v : int = sourceNode.visofs;
			
			for (var l : int = 1; l < _numLeaves; ++v) {
				if (_visData[v] == 0)
					l += 8*_visData[++v];
				else {
					for (var bit : int = 1; bit < 0xff && l < _numLeaves; bit <<= 1, ++l) {
						if (_visData[v] & bit)
							currentNode.addVisibleLeaf(l);
					}
				}
			}
			/* if (currentNode._visList)
				trace (currentNode._visList.length); */
		}
        
        private function readHeader(data : ByteArray) : void
        {
        	_header = new QBSPHeader();
        	_header.version = data.readInt();
        	
        	if (_header.version != BSP_VERSION) {
        		throw new Error("Wrong BSP Version!");
        	}
        	
			_header.entities.offset = data.readInt();
			_header.entities.size = data.readInt();
			_header.planes.offset = data.readInt();
			_header.planes.size = data.readInt();
			_header.textures.offset = data.readInt();
			_header.textures.size = data.readInt();
			_header.vertices.offset = data.readInt();
			_header.vertices.size = data.readInt();
			_header.visibility.offset = data.readInt();
			_header.visibility.size = data.readInt();
			_header.nodes.offset = data.readInt();
			_header.nodes.size = data.readInt();
			_header.texinfo.offset = data.readInt();
			_header.texinfo.size = data.readInt();
			_header.faces.offset = data.readInt();
			_header.faces.size = data.readInt();
			_header.lightmaps.offset = data.readInt();
			_header.lightmaps.size = data.readInt();
			_header.clipnodes.offset = data.readInt();
			_header.clipnodes.size = data.readInt();
			_header.leaves.offset = data.readInt();
			_header.leaves.size = data.readInt();
			_header.markSurfaces.offset = data.readInt();
			_header.markSurfaces.size = data.readInt();
			_header.edges.offset = data.readInt();
			_header.edges.size = data.readInt();
			_header.surfaceEdges.offset = data.readInt();
			_header.surfaceEdges.size = data.readInt();
			_header.models.offset = data.readInt();
			_header.models.size = data.readInt();
			
			_numModels = _header.models.size/QBSPModel.SIZE_OF;
			_numVertices = _header.vertices.size/QBSPVertex.SIZE_OF;
			_numPlanes = _header.planes.size/QBSPPlane.SIZE_OF;
			_numLeaves = _header.leaves.size/QBSPLeaf.SIZE_OF;
			_numNodes = _header.nodes.size/QBSPNode.SIZE_OF;
			_numTexInfos = _header.texinfo.size/QBSPTexInfo.SIZE_OF;
			_numClipNodes = _header.clipnodes.size/QBSPClipNode.SIZE_OF;
			_numFaces = _header.faces.size/QBSPFace.SIZE_OF;
			_numEdges = _header.edges.size/QBSPEdge.SIZE_OF;
			_numMarkSurfaces = _header.markSurfaces.size;	// = short
			_numSurfaceEdges = _header.surfaceEdges.size/4;
			
			_textureDataSize = _header.textures.size;
			_visDataSize = _header.visibility.size;
			_lightDataSize = _header.lightmaps.size;
			_entDataSize = _header.entities.size;
        }
        
        private function readModels(data : ByteArray) : void
		{
			var current : QBSPModel;
			
			_models = new Vector.<QBSPModel>(_numModels);
			data.position = _header.models.offset;
			
			for (var i : uint = 0; i < _numModels; i++) {
				current = new QBSPModel();
				/* current.mins[0] = data.readFloat();
				current.mins[1] = data.readFloat();
				current.mins[2] = data.readFloat();
				current.maxs[0] = data.readFloat();
				current.maxs[1] = data.readFloat();
				current.maxs[2] = data.readFloat(); */
				
				data.position += 24;
				current.origin0 = data.readFloat();
				current.origin1 = data.readFloat();
				current.origin2 = data.readFloat();
				current.headnode0 = data.readInt();
				current.headnode1 = data.readInt();
				current.headnode2 = data.readInt();
				current.headnode3 = data.readInt();
				current.numLeafs = data.readInt();
				current.firstface = data.readInt();
				current.numfaces = data.readInt();
				_models[i] = current;
			}
		}
		
		private function readVertices(data : ByteArray) : void
		{
			var current : Vertex;
			
			_vertices = new Vector.<Vertex>(_numVertices);
			data.position = _header.vertices.offset;
			
			for (var i : uint = 0; i < _numVertices; i++) {
				current = new Vertex();
				current.x = data.readFloat();
				current.z = data.readFloat();
				current.y = data.readFloat();
				_vertices[i] = current;
			}
		}
		
		private function readPlanes(data : ByteArray) : void
		{
			var current : Plane3D;
			var x : Number, y : Number, z : Number, d : Number;
			
			_planes = new Vector.<Plane3D>(_numPlanes);
			data.position = _header.planes.offset;
			
			for (var i : uint = 0; i < _numPlanes; i++) {
				x = data.readFloat();
				z = data.readFloat();
				y = data.readFloat();
				d = data.readFloat();
				data.position += 4;
				
				_planes[i] = new Plane3D(x, y, z, -d);
			}
		}
		
		private function readLeaves(data : ByteArray) : void
		{
			var current : QBSPLeaf;
			
			_leaves = new Vector.<QBSPLeaf>(_numLeaves);
			data.position = _header.leaves.offset;
			
			for (var i : uint = 0; i < _numLeaves; i++) {
				current = new QBSPLeaf();
				current.contents = data.readInt();
				current.visofs = data.readInt();
				
				// skip bounding box, use native
				/* data.readShort();
				data.readShort();
				data.readShort();
				data.readShort();
				data.readShort();
				data.readShort(); */
				data.position += 12;
				
				current.firstMarkSurface = data.readUnsignedShort();
				current.numMarkSurface = data.readUnsignedShort();
				
				// skip sound-related properties
				/* data.readByte();
				data.readByte();
				data.readByte();
				data.readByte(); */
				data.position += 4;
				_leaves[i] = current;
			}
		}
		
		private function readNodes(data : ByteArray) : void
		{
			var current : QBSPNode;
			
			_nodes = new Vector.<QBSPNode>(_numNodes);
			data.position = _header.nodes.offset;
			
			for (var i : uint = 0; i < _numNodes; i++) {
				current = new QBSPNode();
				current.planeNum = data.readInt();
				current.children0 = data.readShort();
				current.children1 = data.readShort();
				
				// skip bounding box
				/* current.mins[0] = data.readShort();
				current.mins[1] = data.readShort();
				current.mins[2] = data.readShort();
				current.maxs[0] = data.readShort();
				current.maxs[1] = data.readShort();
				current.maxs[2] = data.readShort(); */
				
				// only used for collision detection, ignore
				//current.firstface = data.readUnsignedShort();
				//current.numfaces = data.readUnsignedShort();
				
				data.position += 16;
				
				_nodes[i] = current;
			}
		}
		
		private function readTexInfo(data : ByteArray) : void
		{
			var current : QBSPTexInfo;
			
			_texInfo = new Vector.<QBSPTexInfo>(_numTexInfos);
			data.position = _header.texinfo.offset;
			
			for (var i : uint = 0; i < _numTexInfos; i++) {
				current = new QBSPTexInfo();
				
				current.vectorS0 = data.readFloat();
				current.vectorS1 = data.readFloat();
				current.vectorS2 = data.readFloat();
				current.offsetS = data.readFloat();
				current.vectorT0 = data.readFloat();
				current.vectorT1 = data.readFloat();
				current.vectorT2 = data.readFloat();
				current.offsetT = data.readFloat();
				
				current.miptex = data.readInt();
				current.flags = data.readInt();

				_texInfo[i] = current;
			}
		}
		
		// not used
		/* private function readClipNodes(data : ByteArray) : void
		{
			var current : QBSPClipNode;
			
			_clipNodes = new Vector.<QBSPClipNode>(_numClipNodes);
			data.position = _header.clipnodes.offset;
			
			for (var i : uint = 0; i < _numClipNodes; i++) {
				current = new QBSPClipNode();
				
				current.clipNum = data.readInt();
				current.children0 = data.readShort();
				current.children1 = data.readShort();
				
				_clipNodes[i] = current;
			}
		} */
		
		private function readFaces(data : ByteArray) : void
		{
			var current : QBSPFace;
			
			_faces = new Vector.<QBSPFace>(_numFaces);
			data.position = _header.faces.offset;
			
			for (var i : uint = 0; i < _numFaces; i++) {
				current = new QBSPFace();
				
				current.planeNum = data.readShort();
				current.side = data.readShort();
				current.firstedge = data.readInt();
				current.numedges = data.readShort();
				current.texinfo = data.readShort();
				current.styles[0] = data.readUnsignedByte();
				current.styles[1] = data.readUnsignedByte();
				current.styles[2] = data.readUnsignedByte();
				current.styles[3] = data.readUnsignedByte();
				current.lightOfs = data.readInt();
				
				_faces[i] = current;
			}
		}
		
		private function readSurfacesEdges(data : ByteArray) : void
		{
			_surfEdges = new Vector.<int>(_numSurfaceEdges);
			data.position = _header.surfaceEdges.offset;
			
			for (var i : uint = 0; i < _numSurfaceEdges; i++) {
				_surfEdges[i] = data.readInt();
			}
		}
		
		private function readMarkSurfaces(data : ByteArray) : void
		{
			_markSurfaces = new Vector.<int>(_numMarkSurfaces);
			data.position = _header.markSurfaces.offset;
			
			for (var i : uint = 0; i < _numMarkSurfaces; i++) {
				_markSurfaces[i] = data.readUnsignedShort();
			}
		}
		
		private function readEdges(data : ByteArray) : void
		{
			var current : QBSPEdge;
			
			_edges = new Vector.<QBSPEdge>(_numEdges);
			data.position = _header.edges.offset;
			
			for (var i : uint = 0; i < _numEdges; i++) {
				current = new QBSPEdge();
				current.v0 = data.readUnsignedShort();
				current.v1 = data.readUnsignedShort();
				_edges[i] = current;
			}
		}
		
		private function readTextureData(data : ByteArray) : void
		{
			data.position = _header.textures.offset;
			_numTextures = data.readInt();
			_textureData = new Vector.<int>(_numTextures);
			_textureDataDetails = new Vector.<QBSPMipTex>(_numTextures);
			_bitmapDatas = new Vector.<BitmapData>(_numTextures);
			
			for (var i : uint = 0; i < _numTextures; i++) {
				_textureData[i] = data.readInt();
			}
			
			for (i = 0; i < _numTextures; i++) {
				readTextureDetail(data, _textureData[i], i);
			}
		}
		
		private function readTextureDetail(data : ByteArray, offset : int, index : int) : void
		{
			var texDetail : QBSPMipTex = new QBSPMipTex();
			data.position = _header.textures.offset+offset;
			
			texDetail.name = data.readUTFBytes(16);
			texDetail.width = data.readUnsignedInt();
			texDetail.height = data.readUnsignedInt();
			texDetail.offsets0 = data.readUnsignedInt();
			texDetail.offsets1 = data.readUnsignedInt();
			texDetail.offsets2 = data.readUnsignedInt();
			texDetail.offsets3 = data.readUnsignedInt();
			_textureDataDetails[index] = texDetail;
			loadImage(data, texDetail, _header.textures.offset+offset, index);
		}
		
		private function loadImage(data : ByteArray, texDetail : QBSPMipTex, offset : int, index : int) : void
		{
			var bmp : BitmapData = new BitmapData(texDetail.width, texDetail.height, false);
			var rect : Rectangle = bmp.rect;
			var colour : int;
			var len : int = texDetail.width*texDetail.height;
			var vector : Vector.<uint> = new Vector.<uint>(len);
			
			data.position = texDetail.offsets0+offset;
			
			for (var i : int = 0; i < len; ++i) {
				vector[i] = QuakePalette.PALETTE[data.readUnsignedByte()];
			}
			bmp.setVector(rect, vector);
			_bitmapDatas[index] = bmp;
		}
		
		private function readVisData(data : ByteArray) : void
		{
			_visData = new Array(_visDataSize);
			data.position = _header.visibility.offset;
			
			for (var i : uint = 0; i < _visDataSize; i++) {
				_visData[i] = data.readUnsignedByte();
			}
		}
		
		private function readLightingData(data : ByteArray) : void
		{
			_lightData = new Array(_lightDataSize);
			data.position = _header.lightmaps.offset;
			
			for (var i : uint = 0; i < _lightDataSize; i++) {
				_lightData[i] = data.readByte();
			}
		}
		
		private function readEntityData(data : ByteArray) : void
		{
			_entData = new Array(_entDataSize);
			data.position = _header.entities.offset;
			
			for (var i : uint = 0; i < _entDataSize; i++) {
				_entData[i] = data.readByte();
			}
		}
	}
}


/**
 * value objects for parsing
 */

class DEntry
{
	public var offset : int;
	public var size : int;
	
	public function toString():String
	{
		return "[DEntry(offset="+offset+" , size="+size+")]";
	}
}

// The BSP file header
class QBSPHeader
{	
	public var version : int;						// Model version, must be 0x17 (23).
	public var entities : DEntry = new DEntry();	// List of Entities.
	public var planes : DEntry = new DEntry(); 		// Map Planes.
                         							// numplanes = size/sizeof(plane_t)
	public var textures : DEntry = new DEntry();	// Wall Textures.
	public var vertices : DEntry = new DEntry();	// Map Vertices.
													// numvertices = size/sizeof(vertex_t)
	public var visibility : DEntry = new DEntry();	// Leaves Visibility lists.
	public var nodes : DEntry = new DEntry();		// BSP Nodes.
                           							// numnodes = size/sizeof(node_t)	
	public var texinfo : DEntry = new DEntry();		// Texture Info for faces.
                           							// numtexinfo = size/sizeof(texinfo_t)
	public var faces : DEntry = new DEntry();		// Faces of each surface.
													// numfaces = size/sizeof(face_t)
	public var lightmaps : DEntry = new DEntry();	// Wall Light Maps.
	public var clipnodes : DEntry = new DEntry();	// clip nodes, for Models.
													// numclips = size/sizeof(clipnode_t)
	public var leaves : DEntry = new DEntry();		// BSP Leaves.
													// numlaves = size/sizeof(leaf_t)
	public var markSurfaces : DEntry = new DEntry();// List of Faces.
	public var edges : DEntry = new DEntry();		// Edges of faces.
													// numedges = Size/sizeof(edge_t)
	public var surfaceEdges : DEntry = new DEntry();// List of Edges.
	public var models : DEntry = new DEntry();		// List of Models.
													// nummodels = Size/sizeof(model_t)
	
	public function toString() : String
	{
		return 	"version: 0x"+ version.toString(16) +
				"\nentities: "+ entities +
				"\nplanes : "+ planes +
				"\nmiptex : "+ textures +
				"\nvertices : "+ vertices +
				"\nvisilist : "+ visibility +
				"\nnodes : "+ nodes +
				"\ntexinfo : "+ texinfo +
				"\nfaces : "+ faces +
				"\nlightmaps : "+ lightmaps +
				"\nclipnodes : "+ clipnodes +
				"\nleaves : "+ leaves +
				"\nlface : "+ markSurfaces +
				"\nedges : "+ edges +
				"\nledges : "+ surfaceEdges +
				"\nmodels : "+ models;
	}
}

class QBSPClipNode
{
	
	public static const SIZE_OF : int = 8;
	
	public var clipNum : int;
	public var children0 : int;	// originally short[]
	public var children1 : int;
	
}

class QBSPEdge
{
	public static const SIZE_OF : int = 4;
	
	public var v0 : uint;	// originally: unsigned short[]
	public var v1 : uint;
}

class QBSPFace
{
	public static const SIZE_OF : int = 20;
	
	public var planeNum : int;	// originally: short
	// Side is zero if this plane faces in the same direction as the face (i.e. "out" of the face) or non-zero otherwise.
	public var side : int;		// originally: short,
	public var firstedge : int;	// we must support > 64k edges
	public var numedges : int;	// originally: short
	public var texinfo : int;	// originally: short
	
	// lighting info
	public var styles : Array = new Array(4);	// originally byte[]
	public var lightOfs : int;		// start of [numstyles*surfsize] samples
}

class QBSPLeaf
{
	public static const SIZE_OF : int = 28;
	
	public static const AMBIENT_WATER : int = 0;
	public static const AMBIENT_SKY : int = 1;
	public static const AMBIENT_SLIME : int = 2;
	public static const AMBIENT_LAVA : int = 3;
	
	public var contents : int;
	public var visofs : int;				// -1 = no visibility info
	public var firstMarkSurface : int;	// originally: unsigned short
	public var numMarkSurface : int;	// originally: unsigned short
	
}

/*class QBSPTexLump
{
	public static const SIZEOF : int = 20;
	
	public var numMipTex : int;
	//public var dataOffset : Array = new Array(4);
}*/

class QBSPMipTex
{
	public static const SIZEOF : int = 40;
	
	public var name : String;	// originally: char name[16]
	public var width : uint;
	public var height : uint;
	public var offsets0 : uint;	// 4 mip maps stored (uints)
	public var offsets1 : uint;
	public var offsets2 : uint;
	public var offsets3 : uint;
}

class QBSPModel
{
	public static const SIZE_OF : int = 64;
	
	public var origin0 : Number;	// floats
	public var origin1 : Number;
	public var origin2 : Number;
	public var headnode0 : Number;	// ints
	public var headnode1 : Number;
	public var headnode2 : Number;
	public var headnode3 : Number;
	public var numLeafs : int;	// not including the solid leaf 0
	public var firstface : int;
	public var numfaces : int;
}

class QBSPNode
{
	public static const CONTENTS_EMPTY : int = -1;
	public static const CONTENTS_SOLID : int = -2;
	public static const CONTENTS_WATER : int = -3;
	public static const CONTENTS_SLIME : int = -4;
	public static const CONTENTS_LAVA : int = -5;
	public static const CONTENTS_SKY : int = -6;
	
	public static const SIZE_OF : int = 24;
	
	public var planeNum : int;
	public var children0 : int;	// originally: short[]
	public var children1 : int;
	public var firstface : uint;			// originally: unsigned short
	public var numfaces : uint;				// originally: unsigned short
}

class QBSPPlane
{
	// 0-2 are axial planes
	public static const PLANE_X : int = 0;
	public static const PLANE_Y : int = 1;
	public static const PLANE_Z : int = 2;

	// 3-5 are non-axial planes snapped to the nearest
	public static const PLANE_ANYX : int = 3;
	public static const PLANE_ANYY : int = 4;
	public static const PLANE_ANYZ : int = 5;
	
	public static const SIZE_OF : int = 20;
	
	public var type : int;
}

class QBSPTexInfo
{	
	public static const SIZE_OF : int = 40;
	
	public static const TEX_SPECIAL : int = 1;	// sky or slime, no lightmap or 256 subdivision
	
	public var vectorS0 : Number;	// originally float[]
	public var vectorS1 : Number;
	public var vectorS2 : Number;
	public var offsetS : Number;
	public var vectorT0 : Number;	// originally float[]
	public var vectorT1 : Number;
	public var vectorT2 : Number;
	public var offsetT : Number;
	public var miptex : int;
	public var flags : int;
}

class QBSPVertex
{
	public static const SIZE_OF : int = 12;
}

class QuakePalette
{
	public static const PALETTE : Array = [	0,
											0x0f0f0f,
											0x1f1f1f,
											0x2f2f2f,
											0x3f3f3f,
											0x4b4b4b,
											0x5b5b5b,
											0x6b6b6b,
											0x7b7b7b,
											0x8b8b8b,
											0x9b9b9b,
											0xababab,
											0xbbbbbb,
											0xcbcbcb,
											0xdbdbdb,
											0xebebeb,
											0xf0b07,
											0x170f0b,
											0x1f170b,
											0x271b0f,
											0x2f2313,
											0x372b17,
											0x3f2f17,
											0x4b371b,
											0x533b1b,
											0x5b431f,
											0x634b1f,
											0x6b531f,
											0x73571f,
											0x7b5f23,
											0x836723,
											0x8f6f23,
											0xb0b0f,
											0x13131b,
											0x1b1b27,
											0x272733,
											0x2f2f3f,
											0x37374b,
											0x3f3f57,
											0x474767,
											0x4f4f73,
											0x5b5b7f,
											0x63638b,
											0x6b6b97,
											0x7373a3,
											0x7b7baf,
											0x8383bb,
											0x8b8bcb,
											0x0,
											0x70700,
											0xb0b00,
											0x131300,
											0x1b1b00,
											0x232300,
											0x2b2b07,
											0x2f2f07,
											0x373707,
											0x3f3f07,
											0x474707,
											0x4b4b0b,
											0x53530b,
											0x5b5b0b,
											0x63630b,
											0x6b6b0f,
											0x70000,
											0xf0000,
											0x170000,
											0x1f0000,
											0x270000,
											0x2f0000,
											0x370000,
											0x3f0000,
											0x470000,
											0x4f0000,
											0x570000,
											0x5f0000,
											0x670000,
											0x6f0000,
											0x770000,
											0x7f0000,
											0x131300,
											0x1b1b00,
											0x232300,
											0x2f2b00,
											0x372f00,
											0x433700,
											0x4b3b07,
											0x574307,
											0x5f4707,
											0x6b4b0b,
											0x77530f,
											0x835713,
											0x8b5b13,
											0x975f1b,
											0xa3631f,
											0xaf6723,
											0x231307,
											0x2f170b,
											0x3b1f0f,
											0x4b2313,
											0x572b17,
											0x632f1f,
											0x733723,
											0x7f3b2b,
											0x8f4333,
											0x9f4f33,
											0xaf632f,
											0xbf772f,
											0xcf8f2b,
											0xdfab27,
											0xefcb1f,
											0xfff31b,
											0xb0700,
											0x1b1300,
											0x2b230f,
											0x372b13,
											0x47331b,
											0x533723,
											0x633f2b,
											0x6f4733,
											0x7f533f,
											0x8b5f47,
											0x9b6b53,
											0xa77b5f,
											0xb7876b,
											0xc3937b,
											0xd3a38b,
											0xe3b397,
											0xab8ba3,
											0x9f7f97,
											0x937387,
											0x8b677b,
											0x7f5b6f,
											0x775363,
											0x6b4b57,
											0x5f3f4b,
											0x573743,
											0x4b2f37,
											0x43272f,
											0x371f23,
											0x2b171b,
											0x231313,
											0x170b0b,
											0xf0707,
											0xbb739f,
											0xaf6b8f,
											0xa35f83,
											0x975777,
											0x8b4f6b,
											0x7f4b5f,
											0x734353,
											0x6b3b4b,
											0x5f333f,
											0x532b37,
											0x47232b,
											0x3b1f23,
											0x2f171b,
											0x231313,
											0x170b0b,
											0xf0707,
											0xdbc3bb,
											0xcbb3a7,
											0xbfa39b,
											0xaf978b,
											0xa3877b,
											0x977b6f,
											0x876f5f,
											0x7b6353,
											0x6b5747,
											0x5f4b3b,
											0x533f33,
											0x433327,
											0x372b1f,
											0x271f17,
											0x1b130f,
											0xf0b07,
											0x6f837b,
											0x677b6f,
											0x5f7367,
											0x576b5f,
											0x4f6357,
											0x475b4f,
											0x3f5347,
											0x374b3f,
											0x2f4337,
											0x2b3b2f,
											0x233327,
											0x1f2b1f,
											0x172317,
											0xf1b13,
											0xb130b,
											0x70b07,
											0xfff31b,
											0xefdf17,
											0xdbcb13,
											0xcbb70f,
											0xbba70f,
											0xab970b,
											0x9b8307,
											0x8b7307,
											0x7b6307,
											0x6b5300,
											0x5b4700,
											0x4b3700,
											0x3b2b00,
											0x2b1f00,
											0x1b0f00,
											0xb0700,
											0xff,
											0xb0bef,
											0x1313df,
											0x1b1bcf,
											0x2323bf,
											0x2b2baf,
											0x2f2f9f,
											0x2f2f8f,
											0x2f2f7f,
											0x2f2f6f,
											0x2f2f5f,
											0x2b2b4f,
											0x23233f,
											0x1b1b2f,
											0x13131f,
											0xb0b0f,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xffffff,
											0xc7c337,
											0xe7e357,
											0x7fbfff,
											0xabe7ff,
											0xd7ffff,
											0x670000,
											0x8b0000,
											0xb30000,
											0xd70000,
											0xff0000,
											0xfff393,
											0xfff7c7,
											0xffffff,
											0x9f5b53			
							];

}