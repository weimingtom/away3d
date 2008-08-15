package away3d.loaders
{
	import away3d.animators.*;
	import away3d.animators.skin.*;
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.loaders.data.*;
	import away3d.loaders.utils.*;
	import away3d.materials.*;
	
	import flash.utils.Dictionary;
	
    /**
    * File loader for the Collada file format with animation.
    */
    public class Collada
    {
    	use namespace arcane;
		/** @private */
    	arcane var ini:Init;
    	
        private var collada:XML;
        private var material:ITriangleMaterial;
        private var centerMeshes:Boolean;
        private var scaling:Number;
        private var texturePath:String;
        private var autoLoadTextures:Boolean;
        private var materialLibrary:MaterialLibrary;
        private var animationLibrary:AnimationLibrary;
        private var geometryLibrary:GeometryLibrary;
        private var yUp:Boolean;
        private var toRADIANS:Number = Math.PI / 180;
    	private var _meshData:MeshData;
    	private var _geometryData:GeometryData;
        private var _materialData:MaterialData;
        private var _animationData:AnimationData;
		private var _meshMaterialData:MeshMaterialData;
		private var numChildren:int;
		private var averageX:Number;
		private var averageY:Number;
		private var averageZ:Number;
		private var numVertices:int;
    	private var _faceListIndex:int;
    	private var _faceData:FaceData;
    	private var _face:Face;
    	private var _vertex:Vertex;
		private var rotationMatrix:Matrix3D = new Matrix3D();
    	private var scalingMatrix:Matrix3D = new Matrix3D();
    	private var translationMatrix:Matrix3D = new Matrix3D();
        private var VALUE_X:String;
        private var VALUE_Y:String;
        private var VALUE_Z:String;
        private var VALUE_U:String = "S";
        private var VALUE_V:String = "T";

		/**
		 * Collada Animation
		 */
		private var _defaultAnimationClip:AnimationData;
		private var _haveAnimation:Boolean = false;
		private var _haveClips:Boolean = false;
		private var _bones:Dictionary = new Dictionary(true);
		
		private function buildRootBones(containerData:ContainerData, parent:ObjectContainer3D):void
		{
			for each (var _objectData:ObjectData in containerData.children) {
				if (_objectData is BoneData) {
					var _boneData:BoneData = _objectData as BoneData;
					var bone:Bone = new Bone({name:_boneData.name});
					
					buildBones(_boneData, bone);
					
					parent.addChild(bone);
				}
			}
		}
		
		private function buildBones(boneData:BoneData, parent:Bone):void
		{
			_bones[parent.name] = parent;
			
			//ColladaMaya 3.05B
			parent.id = boneData.id;
			
			parent.transform = boneData.transform;
			
			parent.joint.transform = boneData.jointTransform;
			
			Debug.trace(" + Joint : " + parent.joint + " -> " + parent);
			
			for each (var _boneData:BoneData in boneData.children) {
				var bone:Bone = new Bone({name:_boneData.name});
				
				buildBones(_boneData, bone);
				
				parent.joint.addChild(bone);
			}
		}
		
		private function buildContainer(containerData:ContainerData, parent:ObjectContainer3D):void
		{
			for each (var _objectData:ObjectData in containerData.children) {
				if (!(_objectData is BoneData) && _objectData as ContainerData) {
					var _containerData:ContainerData = _objectData as ContainerData;
					var objectContainer:ObjectContainer3D = new ObjectContainer3D({name:_containerData.name});
					
					objectContainer.transform = _objectData.transform;
					
					buildContainer(_containerData, objectContainer);
					
					if (centerMeshes) {
						//determine center and offset all children (useful for subsequent max/min/radius calculations)
						averageX = averageY = averageZ = 0;
						numChildren = _containerData.children.length;
						for each (var _child:Object3D in objectContainer.children) {
							averageX += _child.x;
							averageY += _child.y;
							averageZ += _child.z;
						}
						if(numChildren){
							objectContainer.movePivot(averageX/numChildren, averageY/numChildren, averageZ / numChildren);
						}
					}
					
					parent.addChild(objectContainer);
					
				} else if (_objectData is MeshData) {
					buildMesh(_objectData as MeshData, parent);
				}
			}
		}
		
		private function buildMesh(_meshData:MeshData, parent:ObjectContainer3D):void
		{
			Debug.trace(" + Build Mesh : "+_meshData.name)
			
			var mesh:Mesh = new Mesh({name:_meshData.name});
			mesh.transform = _meshData.transform;
			mesh.bothsides = _meshData.geometry.bothsides;
			
			_geometryData = _meshData.geometry;
			var geometry:Geometry = _geometryData.geometry;
			
			if (!geometry) {
				geometry = _geometryData.geometry = new Geometry();
				
				
				//set materialdata for each face
				for each (_meshMaterialData in _geometryData.materials) {
					for each (_faceListIndex in _meshMaterialData.faceList) {
						_faceData = _geometryData.faces[_faceListIndex] as FaceData;
						_faceData.materialData = materialLibrary[_meshMaterialData.name];
					}
				}
				
				
				if (_geometryData.skinVertices.length) {
					var bone:Bone;
					var i:int;
					var joints:Array;
					var skinController:SkinController;
					var rootBone:Bone;
					
					geometry.skinVertices = _geometryData.skinVertices;
					geometry.skinControllers = _geometryData.skinControllers;
					//mesh.bone = container.getChildByName(_meshData.bone) as Bone;
					
					for each (skinController in geometry.skinControllers) {
						bone = container.getBoneByName(skinController.name);
		                if (bone) {
		                    skinController.joint = bone.joint;
		                    
		                    if (!(bone.parent.parent is Bone))
		                    	rootBone = bone;
		                } else
		                	Debug.warning("no joint found for " + skinController.name);
		                
		                skinController.inverseTransform = rootBone.parent.inverseSceneTransform;
			  		}
				}
				
				//create faces form face and mesh data
				var face:Face;
				var matData:MaterialData;
				for each(_faceData in _geometryData.faces) {
					if (!_faceData.materialData)
						continue;
					_face = new Face(_geometryData.vertices[_faceData.v0],
												_geometryData.vertices[_faceData.v1],
												_geometryData.vertices[_faceData.v2],
												_faceData.materialData.material,
												_geometryData.uvs[_faceData.uv0],
												_geometryData.uvs[_faceData.uv1],
												_geometryData.uvs[_faceData.uv2]);
					geometry.addFace(_face);
					_faceData.materialData.faces.push(_face);
				}
			}
			
			mesh.geometry = geometry;
			
			if (centerMeshes) {
				//center vertex points in mesh for better bounding radius calulations
				averageX = averageY = averageZ = 0;
				numVertices = _geometryData.vertices.length;
				for each (_vertex in _geometryData.vertices) {
					averageX += _vertex._x;
					averageY += _vertex._y;
					averageZ += _vertex._z;
				}
				
				averageX /= numVertices;
				averageY /= numVertices;
				averageZ /= numVertices;
				
				mesh.movePivot(averageX, averageY, averageZ);
				mesh.moveTo(averageX, averageY, averageZ);
			}
			
			mesh.type = ".Collada";
			parent.addChild(mesh);
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
					case MaterialData.COLOR_MATERIAL:
						_materialData.material = new ColorMaterial(_materialData.diffuseColor);
						break;
					case MaterialData.WIREFRAME_MATERIAL:
						_materialData.material = new WireColorMaterial();
						break;
				}
			}
		}
		
		private function buildAnimations():void
		{
			for each (_animationData in animationLibrary)
			{
				switch (_animationData.animationType)
				{
					case AnimationData.SKIN_ANIMATION:
						var animation:SkinAnimation = new SkinAnimation();
						animation.length = _animationData.length;
						
						for each (var channel:Channel in _animationData.channels) {
							channel.target = _bones[channel.name] as Bone;
							animation.appendChannel(channel);
						}
						
						_animationData.animation = animation;
						break;
					case AnimationData.VERTEX_ANIMATION:
						break;
				}
			}
		}
		
        private function getArray(spaced:String):Array
        {
        	spaced = spaced.split("\r\n").join(" ");
            var strings:Array = spaced.split(" ");
            var numbers:Array = [];
			
            var totalStrings:Number = strings.length;
			
            for (var i:Number = 0; i < totalStrings; i++)
            	if (strings[i] != "")
                	numbers.push(Number(strings[i]));

            return numbers;
        }
		
        private function rotateMatrix(vector:Array):Matrix3D
        {
            if (yUp) {
                	rotationMatrix.rotationMatrix(vector[0], -vector[1], -vector[2], vector[3]*toRADIANS);
            } else {
                	rotationMatrix.rotationMatrix(vector[0], vector[2], vector[1], vector[3]*toRADIANS);
            }
            
            return rotationMatrix;
        }

        private function translateMatrix(vector:Array):Matrix3D
        {
            if (yUp)
                translationMatrix.translationMatrix(-vector[0]*scaling, vector[1]*scaling, vector[2]*scaling);
            else
                translationMatrix.translationMatrix(vector[0]*scaling, vector[2]*scaling, vector[1]*scaling);
			
            return translationMatrix;
        }
		
        private function scaleMatrix(vector:Array):Matrix3D
        {
            if (yUp)
                scalingMatrix.scaleMatrix(vector[0], vector[1], vector[2]);
            else
                scalingMatrix.scaleMatrix(vector[0], vector[2], vector[1]);
			
            return scalingMatrix;
        }

        private function getId(url:String):String
        {
            return url.split("#")[1];
        }
		
        /**
        * 3d container object used for storing the parsed collada scene.
        */
        public var container:ObjectContainer3D;
    	
    	/**
    	 * Container data object used for storing the parsed collada data structure.
    	 */
        public var containerData:ContainerData;
		
		/**
		 * Creates a new <code>Collada</code> object. Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods.
		 *
		 * @param	xml				The xml data of a loaded file.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 *
		 * @see away3d.loaders.Collada#parse()
		 * @see away3d.loaders.Collada#load()
		 */
		
        public function Collada(xml:XML, init:Object = null)
        {
            collada = xml;
            
            ini = Init.parse(init);
			
			texturePath = ini.getString("texturePath", "");
			autoLoadTextures = ini.getBoolean("autoLoadTextures", true);
            scaling = ini.getNumber("scaling", 1)*100;
            material = ini.getMaterial("material");
            centerMeshes = ini.getBoolean("centerMeshes", false);

            var materials:Object = ini.getObject("materials") || {};
			
			//create the container
            container = new ObjectContainer3D(ini);
			container.name = "collada";
			
			materialLibrary = container.materialLibrary = new MaterialLibrary();
			animationLibrary = container.animationLibrary = new AnimationLibrary();
			geometryLibrary = container.geometryLibrary = new GeometryLibrary();
			materialLibrary.autoLoadTextures = autoLoadTextures;
			materialLibrary.texturePath = texturePath;
			
			//organise the materials
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
			
			//parse the collada file
            parseCollada();
            
            //build materials
			buildMaterials();
			
			//build the bones
			buildRootBones(containerData, container);
			
			//build the containers
			buildContainer(containerData, container);
			
			//build animations
			buildAnimations();
        }
		
        /**
		 * Creates a 3d container object from the raw xml data of a collada file.
		 *
		 * @param	data				The xml data of a loaded file.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * @param	loader	[optional]	Not intended for direct use.
		 *
		 * @return						A 3d container object representation of the collada file.
		 */
        public static function parse(data:*, init:Object = null, loader:Object = null):ObjectContainer3D
        {
			var parser:Collada = new Collada(Cast.xml(data), init);
            return parser.container;
        }
		
    	/**
    	 * Loads and parses the textures for a collada file into a 3d container object.
    	 *
    	 * @param	data				The xml data of a loaded file.
    	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
    	 * @return						A 3d loader object that can be used as a placeholder in a scene while the textures are loading.
    	 */
		public static function loadTextures(data:*, init:Object = null):Object3DLoader
		{
			var parser:Collada = new Collada(Cast.xml(data), init);
			return Object3DLoader.loadTextures(parser.container, parser.ini);
		}
		
    	/**
    	 * Loads and parses a collada file into a 3d container object.
    	 *
    	 * @param	url					The url location of the file to load.
    	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
    	 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.
    	 */
        public static function load(url:String, init:Object = null):Object3DLoader
        {
			//texturePath as model folder
			if (url)
			{
				var _pathArray		:Array = url.split("/");
				var _imageName		:String = _pathArray.pop();
				var _texturePath	:String = (_pathArray.length>0)?_pathArray.join("/")+"/":_pathArray.join("/");
				if (init){
					init.texturePath = (init.texturePath)?init.texturePath:_texturePath;
				}else {
					init = { texturePath:_texturePath };
				}
			}
			return Object3DLoader.loadGeometry(url, parse, false, init);
        }

        private function parseCollada():void
        {
			default xml namespace = collada.namespace();
			Debug.trace(" ! ------------- Begin Parse Collada -------------");

            // Get up axis
            yUp = (collada.asset.up_axis == "Y_UP")||(String(collada.asset.up_axis) == "");

    		if (yUp) {
    			VALUE_X = "X";
    			VALUE_Y = "Y";
    			VALUE_Z = "Z";
        	} else {
                VALUE_X = "X";
                VALUE_Y = "Z";
                VALUE_Z = "Y";
        	}
			
            parseScene();
			
			parseAnimationClips();
        }
		
		/**
		 * Converts the scene heirarchy to an Away3d data structure
		 */
        private function parseScene():void
        {
        	var scene:XML = collada.library_visual_scenes.visual_scene.(@id == getId(collada.scene.instance_visual_scene.@url))[0];
        	
        	if (scene == null) {
        		Debug.trace(" ! ------------- No scene to parse -------------");
        		return;
        	}
        	
			Debug.trace(" ! ------------- Begin Parse Scene -------------");
			
			containerData = new ContainerData();
			
            for each (var node:XML in scene.node)
				parseNode(node, containerData);
			
			Debug.trace(" ! ------------- End Parse Scene -------------");
		}
		
		/**
		 * Converts a single scene node to a BoneData ContainerData or MeshData object.
		 * 
		 * @see away3d.loaders.data.BoneData
		 * @see away3d.loaders.data.ContainerData
		 * @see away3d.loaders.data.MeshData
		 */
        private function parseNode(node:XML, parent:ContainerData):void
        {
			var _transform:Matrix3D;
	    	var _objectData:ObjectData;
	    	
			if (String(node.instance_controller) == "" && String(node.instance_geometry) == "")
			{
				if (String(node.@type) == "JOINT")
					_objectData = new BoneData();
				else
					_objectData = new ContainerData();
				
				parent.children.push(_objectData);
			}else{
				_objectData = new MeshData();
			}
			
			
			//ColladaMaya 3.05B
			if (String(node.@type) == "JOINT")
				_objectData.id = node.@sid;
			else
				_objectData.id = node.@id;
			
			//ColladaMaya 3.02
            _objectData.name = node.@id;
            _transform = _objectData.transform;
			
			Debug.trace(" + Parse Node : " + _objectData.id + " : " + _objectData.name);

           	var geo:XML;
           	var ctrlr:XML;
           	var sid:String;
			var instance_material:XML;
			var arrayChild:Array
			var boneData:BoneData = (_objectData as BoneData);
			
            for each (var child:XML in node.children())
            {
                arrayChild = getArray(child);
				switch (child.name().localName)
                {
					case "translate":
                        _transform.multiply(_transform, translateMatrix(arrayChild));
                        
                        break;

                    case "rotate":
                    	sid = child.@sid;
                        if (_objectData is BoneData && (sid == "rotateX" || sid == "rotateY" || sid == "rotateZ"))
							boneData.jointTransform.multiply(boneData.jointTransform, rotateMatrix(arrayChild));
                        else
	                        _transform.multiply(_transform, rotateMatrix(arrayChild));
	                    
                        break;
						
                    case "scale":
                        if (_objectData is BoneData)
							boneData.jointTransform.multiply(boneData.jointTransform, scaleMatrix(arrayChild));
                        else
	                        _transform.multiply(_transform, scaleMatrix(arrayChild));
						
                        break;
						
                    // Baked transform matrix
                    case "matrix":
                    	var m:Matrix3D = new Matrix3D();
                    	//var inv:Matrix3D = new Matrix3D();
                    	//inv.inverse(parent.transform);
                    	m.array2matrix(arrayChild, yUp, scaling);
                    	//m.multiply(m, inv);
                        _transform.multiply(_transform, m);
						break;
						
                    case "node":
						//parent.children.push(_objectData);
                        //if (String(child).indexOf("ForegroundColor") == -1)
                            parseNode(child, _objectData as ContainerData);
                        
                        break;

    				case "instance_node":
						//parent.children.push(_objectData);
    					parseNode(collada.library_nodes.node.(@id == getId(child.@url))[0], _objectData as ContainerData);
    					
    					break;

                    case "instance_geometry":
						parent.children.push(_objectData);
                    	if(String(child).indexOf("lines") == -1) {
							
							//add materials to materialLibrary
	                        for each (instance_material in child..instance_material)
	                        	parseMaterial(instance_material.@symbol, getId(instance_material.@target));
							
	                        geo = collada.library_geometries.geometry.(@id == getId(child.@url))[0];
	                        parseGeometry(geo, _objectData as MeshData);
	                    }
	                    
                        break;
					
                    case "instance_controller":
						parent.children.push(_objectData);
						
						//add materials to materialLibrary
						for each (instance_material in child..instance_material)
							parseMaterial(instance_material.@symbol, getId(instance_material.@target));
						
						ctrlr = collada.library_controllers.controller.(@id == getId(child.@url))[0];
						parseController(ctrlr, _objectData as MeshData);
						
						break;
                }
            }
        }
		
		/**
		 * Converts a material definition to a MaterialData object
		 * 
		 * @see away3d.loaders.data.MaterialData
		 */
        private function parseMaterial(name:String, target:String):void
        {
           	_materialData = materialLibrary.addMaterial(name);
            if(name == "FrontColorNoCulling") {
            	_materialData.materialType = MaterialData.SHADING_MATERIAL;
            } else {
                _materialData.textureFileName = getTextureFileName(target);
                
                if (_materialData.textureFileName) {
            		_materialData.materialType = MaterialData.TEXTURE_MATERIAL;
                } else {
                	_materialData.materialType = MaterialData.COLOR_MATERIAL;
                	_materialData.diffuseColor = getTextureColor(target);
                }
            }
        }
		
		/**
		 * Populates a MeshData object from geometry data.
		 * 
		 * @see away3d.loaders.data.MeshData
		 */
        private function parseGeometry(geometry:XML, _meshData:MeshData):void
        {
        	var geoId:String = geometry.@id;
        	var geometryData:GeometryData = geometryLibrary.getGeometry(geoId);
        	
        	if (geometryData) {
        		_meshData.geometry = geometryData;
        		return;
        	}
        	
        	geometryData = geometryLibrary.addGeometry(geoId);
        	_meshData.geometry = geometryData;
        	
			Debug.trace(" + Parse Geometry : "+ geoId);
            // Semantics
            //_meshData.name = geometry.@id;
			
            // Triangles
            for each (var triangles:XML in geometry.mesh.triangles)
            {
                // Input
                var field:Array = [];

                for each(var input:XML in triangles.input)
                {
                	var semantic:String = input.@semantic;
                	switch(semantic)
                	{
                		case "VERTEX":
                			deserialize(input, geometry, Vertex, geometryData.vertices);
                			break;
                		case "TEXCOORD":
                			deserialize(input, geometry, UV, geometryData.uvs);
                			break;
                		default:
                	}
                    field.push(input.@semantic);
                }

                var data     :Array  = triangles.p.split(' ');
                var len      :Number = triangles.@count;
                var material :String = triangles.@material;
				Debug.trace(" + Parse MeshMaterialData");
                _meshMaterialData = new MeshMaterialData();
    			_meshMaterialData.name = material;
				geometryData.materials.push(_meshMaterialData);
				
				//if (!materialLibrary[material])
				//	parseMaterial(material, material);
					
                for (var j:Number = 0; j < len; j++)
                {
                    var _faceData:FaceData = new FaceData();

                    for (var v:Number = 0; v < 3; v++)
                    {
                        for each (var fld:String in field)
                        {
                        	switch(fld)
                        	{
                        		case "VERTEX":
                        			_faceData["v" + v] = data.shift();
                        			break;
                        		case "TEXCOORD":
                        			_faceData["uv" + v] = data.shift();
                        			break;
                        		default:
                        			data.shift();
                        	}
                        }
                    }
                    _meshMaterialData.faceList.push(geometryData.faces.length);
                    geometryData.faces.push(_faceData);
                }
            }
			// Double Side
			if (String(geometry.extra.technique.double_sided) != "")
            	geometryData.bothsides = (geometry.extra.technique.double_sided[0].toString() == "1");
            else
            	geometryData.bothsides = false;
        }
		
		private function parseController(ctrlr:XML, instance:MeshData) : void
        {
			Debug.trace(" + Parse Controller : " + instance);
			
            var skin:XML = ctrlr.skin[0];
            var geoId:String = getId(skin.@source);
			
			var geometry:XML = collada.library_geometries.geometry.(@id == geoId)[0];
			
			Debug.trace(" ! geoId : " + geoId);
			if (!geometry)
				return;
			
			var geometryData:GeometryData = geometryLibrary.getGeometry(geoId);
        	
        	if (geometryData) {
        		instance.geometry = geometryData;
        		return;
        	}
        	
			parseGeometry(geometry, instance);
			
			var jointId:String = getId(skin.joints.input.(@semantic == "JOINT")[0].@source);
            var tmp:String = skin.source.(@id == jointId).Name_array.toString();
			//Blender?
			if (!tmp) tmp = skin.source.(@id == jointId).IDREF_array.toString();
            tmp = tmp.replace(/\n/g, " ");
            var nameArray:Array = tmp.split(" ");
            tmp = skin.bind_shape_matrix[0].toString();
			
            var bind_shape_array:Array = tmp.split(" ");
			var bind_shape:Matrix3D = new Matrix3D();
			bind_shape.array2matrix(bind_shape_array, yUp, scaling);
			
			var bindMatrixId:String = getId(skin.joints.input.(@semantic == "INV_BIND_MATRIX").@source);

            tmp = skin.source.(@id == bindMatrixId)[0].float_array.toString();
            tmp = tmp.replace(/\n/g, " ");
            var float_array:Array = tmp.split(" ");
            var v:Array;
            var matrix:Matrix3D;
            var name:String;
            var joints:Array = new Array();
			var skinController:SkinController;
            var i:int = 0;
            
            while (i < float_array.length)
            {
            	name = nameArray[i / 16];
				matrix = new Matrix3D();
				matrix.array2matrix(float_array.slice(i, i+16), yUp, scaling);
				matrix.multiply(matrix, bind_shape);
				
                instance.geometry.skinControllers.push(skinController = new SkinController());
                skinController.name = name;
                skinController.bindMatrix = matrix;
                
                i = i + 16;
            }
			
			Debug.trace(" + SkinWeight");

            tmp = skin.vertex_weights[0].@count;
            var num_weights:int = int(skin.vertex_weights[0].@count);

			var weightsId:String = getId(skin.vertex_weights.input.(@semantic == "WEIGHT")[0].@source);
			
            tmp = skin.source.(@id == weightsId).float_array.toString();
            var weights:Array = tmp.split(" ");
			
            tmp = skin.vertex_weights.vcount.toString();
            var vcount:Array = tmp.split(" ");
			
            tmp = skin.vertex_weights.v.toString();
            v = tmp.split(" ");
			
			var skinVertex	:SkinVertex;
            var c			:int;
            var j			:int;
            var count		:int = 0;
			
            i=0;
            while (i < instance.geometry.vertices.length)
            {
                c = int(vcount[i]);
                skinVertex = new SkinVertex(instance.geometry.vertices[i]);
                instance.geometry.skinVertices.push(skinVertex);
                j=0;
                while (j < c)
                {
                    skinVertex.controllers.push(instance.geometry.skinControllers[int(v[count])]);
                    count++;
                    skinVertex.weights.push(Number(weights[int(v[count])]));
                    count++;
                    j++;
                }
                i++;
            }
        }
		
		/**
		 * Detects and parses all animation clips
		 */ 
		private function parseAnimationClips() : void
        {        
			//create default animation clip
			_defaultAnimationClip = animationLibrary.addAnimation("default");
			
        	//Check for animations
			var anims:XML = collada.library_animations[0];
			
			if (!anims) {
        		Debug.trace(" ! ------------- No animations to parse -------------");
        		return;
			}
        	
			//Check to see if animation clips exist
			var clips:XML = collada.library_animation_clips[0];
			
			Debug.trace(" ! Animation Clips Exist : " + _haveClips);
			
            Debug.trace(" ! ------------- Begin Parse Animation -------------");
            
            //loop through all animation nodes
			for each (var node:XML in anims.animation)
				parseAnimationNode(node);
			
			if (clips) {
				//loop through all animation clips
				for each (var clip:XML in clips.animation_clip)
					parseAnimationClip(clip);
			}
			
			Debug.trace(" ! ------------- End Parse Animation -------------");
        }
        
        private function parseAnimationClip(clip:XML) : void
        {
			var animationClip:AnimationData = animationLibrary.addAnimation(clip.@id);
			
			for each (var channel:XML in clip.instance_animation)
				animationClip.channels[getId(channel.@url)] = _defaultAnimationClip.channels[getId(channel.@url)];
        }
		
		private function parseAnimationNode(node:XML) : void
        {
			var id:String = node.channel.@target;
			var name:String = id.split("/")[0];
            var type:String = id.split("/")[1];
			var sampler:XML = node.sampler[0];
			
            if (!type) {
            	Debug.trace(" ! No animation type detected");
            	return;
            }
            
            type = type.split(".")[0];
			
            if (type == "image" || node.@id.split(".")[1] == "frameExtension")
            {
                //TODO : Material Animation
				Debug.trace(" ! Material animation not yet implemented");
				return;
            }
			
            var channel:Channel = new Channel(name);
			var i:int;
			var j:int;
			
			_defaultAnimationClip.channels[String(node.@id)] = channel;
			
			Debug.trace(" ! channelType : " + type);
			
            for each (var input:XML in sampler.input)
            {
				var src:XML = node.source.(@id == getId(input.@source))[0]
                var count:int = int(src.float_array.@count);
                var list:Array = String(src.float_array).split(" ");
                var len:int = int(src.technique_common.accessor.@count);
                var stride:int = int(src.technique_common.accessor.@stride);
                var semantic:String = input.@semantic;
				
				var p:String
				var f:Number;
				var sign:int = (type.charAt(type.length - 1) == "X")? -1 : 1;
                switch(semantic) {
                    case "INPUT":
                        for each (p in list) {
                            f = Number(p);
                            
                            if (_defaultAnimationClip.length < f)
                                _defaultAnimationClip.length = f;
                            
                            channel.times.push(f);
                        }
                        break;
                    case "OUTPUT":
                        i=0
                        while (i < len) {
                            channel.param[i] = new Array();
                            
                            if (stride == 16) {
		                    	var m:Matrix3D = new Matrix3D();
		                    	m.array2matrix(list.slice(i*stride, i*stride + 16), yUp, scaling)
		                    	channel.param[i].push(m);
                            } else {
	                            j = 0;
	                            while (j < stride) {
	                            	channel.param[i].push(Number(list[i*stride + j]));
	                            	j++;
	                            }
                            }
                            i++;
                        }
                        break;
                    case "INTERPOLATION":
                        for each (p in list)
                        {
							channel.interpolations.push(p);
                        }
                        break;
                    case "IN_TANGENT":
                        i=0;
                        while (i < len)
                        {
                        	channel.inTangent[i] = new Array();
                        	j = 0;
                            while (j < stride) {
                                channel.inTangent[i].push(new Number2D(Number(list[stride * i + j]), Number(list[stride * i + j + 1])));
                            	j++;
                            }
                            i++;
                        }
                        break;
                    case "OUT_TANGENT":
                        i=0;
                        while (i < len)
                        {
                        	channel.outTangent[i] = new Array();
                        	j = 0;
                            while (j < stride) {
                                channel.outTangent[i].push(new Number2D(Number(list[stride * i + j]), Number(list[stride * i + j + 1])));
                            	j++;
                            }
                            i++;
                        }
                        break;
                }
            }
            var param:Array;
            
            switch(type)
            {
                case "translateX":
                	channel.type = ["x"];
					if (yUp)
						for each (param in channel.param)
							param[0] *= -1*scaling;
                	break;
				case "translateY":
					if (yUp)
						channel.type = ["y"];
					else
						channel.type = ["z"];
					for each (param in channel.param)
						param[0] *= scaling;
     				break;
				case "translateZ":
					if (yUp)
						channel.type = ["z"];
					else
						channel.type = ["y"];
					for each (param in channel.param)
						param[0] *= scaling;
     				break;
				case "rotateX":
     				channel.type = ["jointRotationX"];
     				if (yUp)
						for each (param in channel.param)
							param[0] *= -1;
     				break;
				case "rotateY":
					if (yUp)
						channel.type = ["jointRotationY"];
					else
						channel.type = ["jointRotationZ"];
					if (yUp)
						for each (param in channel.param)
							param[0] *= -1;
     				break;
				case "rotateZ":
					if (yUp)
						channel.type = ["jointRotationZ"];
					else
						channel.type = ["jointRotationY"];
					if (yUp)
						for each (param in channel.param)
							param[0] *= -1;
            		break;
				case "scaleX":
					channel.type = ["jointScaleX"];
					if (yUp)
						for each (param in channel.param)
							param[0] *= -1;
            		break;
				case "scaleY":
					if (yUp)
						channel.type = ["jointScaleY"];
					else
						channel.type = ["jointScaleZ"];
     				break;
				case "scaleZ":
					if (yUp)
						channel.type = ["jointScaleZ"];
					else
						channel.type = ["jointScaleY"];
     				break;
				case "translate":
					if (yUp) {
						channel.type = ["x", "y", "z"];
						for each (param in channel.param)
							param[0] *= -1;
     				} else {
     					channel.type = ["x", "z", "y"];
     				}
     				for each (param in channel.param) {
						param[0] *= scaling;
						param[1] *= scaling;
						param[2] *= scaling;
     				}
					break;
				case "scale":
					if (yUp)
						channel.type = ["jointScaleX", "jointScaleY", "jointScaleZ"];
					else
						channel.type = ["jointScaleX", "jointScaleZ", "jointScaleY"];
     				break;
				case "rotate":
					if (yUp) {
						channel.type = ["jointRotationX", "jointRotationY", "jointRotationZ"];
						for each (param in channel.param) {
							param[0] *= -1;
							param[1] *= -1;
							param[2] *= -1;
						}
     				} else {
						channel.type = ["jointRotationX", "jointRotationZ", "jointRotationY"];
     				}
					break;
				case "transform":
					channel.type = ["transform"];
					break;
            }
        }
		
		/**
		 * Retrieves the filename of a material
		 */
		private function getTextureFileName( name:String ):String
		{
			var filename :String = null;
			var material:XML = collada.library_materials.material.(@id == name)[0];
	
			if( material )
			{
				var effectId:String = getId( material.instance_effect.@url );
				var effect:XML = collada.library_effects.effect.(@id == effectId)[0];
	
				if (effect..texture.length() == 0) return null;
	
				var textureId:String = effect..texture[0].@texture;
	
				var sampler:XML =  effect..newparam.(@sid == textureId)[0];
	
				// Blender
				var imageId:String = textureId;
	
				// Not Blender
				if( sampler )
				{
					var sourceId:String = sampler..source[0];
					var source:XML =  effect..newparam.(@sid == sourceId)[0];
	
					imageId = source..init_from[0];
				}
	
				var image:XML = collada.library_images.image.(@id == imageId)[0];
	
				filename = image.init_from;
	
				if (filename.substr(0, 2) == "./")
				{
					filename = filename.substr( 2 );
				}
			}
			return filename;
		}
		
		/**
		 * Retrieves the color of a material
		 */
		private function getTextureColor( name:String ):uint
		{
			var color:uint;
			var material:XML = collada.library_materials.material.(@id == name)[0];
			if( material )
			{
				var effectId:String = getId( material.instance_effect.@url );
				var effect:XML = collada.library_effects.effect.(@id == effectId)[0];
	
				if (effect..diffuse.length() == 0) return color;
	
				var diffuse:XML =  effect..diffuse[0];
				
				var colorArray:Array = diffuse.color.split(" ");
				var colorString:String = (colorArray[0]*255).toString(16) + (colorArray[1]*255).toString(16) + (colorArray[2]*255).toString(16);
				color = parseInt(colorString, 16);
			}
			return color;
		}
				
		/**
		 * Converts a data string to an array of objects. Handles vertex and uv objects
		 */
        private function deserialize(input:XML, geo:XML, Element:Class, output:Array):Array
        {
            var id:String = input.@source.split("#")[1];

            // Source?
            var acc:XMLList = geo..source.(@id == id).technique_common.accessor;

            if (acc != new XMLList())
            {
                // Build source floats array
                var floId:String  = acc.@source.split("#")[1];
                var floXML:XMLList = collada..float_array.(@id == floId);
                var floStr:String  = floXML.toString();
                var floats:Array   = getArray(floStr);
    			var float:Number;
                // Build params array
                var params:Array = [];
				var param:String;
				
                for each (var par:XML in acc.param)
                    params.push(par.@name);

                // Build output array
                var count:int = acc.@count;
                var stride:int = acc.@stride;
    			var len:int = floats.length;
    			var i:int = 0;
                while (i < len)
                {
    				var element:ValueObject = new Element();
	            	if (element is Vertex) {
	            		var vertex:Vertex = element as Vertex;
	                    for each (param in params) {
	                    	float = floats[i];
	                    	switch (param) {
	                    		case VALUE_X:
	                    			if (yUp)
	                    				vertex._x = -float*scaling;
	                    			else
	                    				vertex._x = float*scaling;
	                    			break;
	                    		case VALUE_Y:
	                    				vertex._y = float*scaling;
	                    			break;
	                    			break;
	                    		case VALUE_Z:
	                    				vertex._z = float*scaling;
	                    			break;
	                    			break;
	                    		default:
	                    	}
	                    	i++;
	                    }
		            } else if (element is UV) {
		            	var uv:UV = element as UV;
	                    for each (param in params) {
	                    	float = floats[i];
	                    	switch (param) {
	                    		case VALUE_U:
	                    			uv._u = float;
	                    			break;
	                    		case VALUE_V:
	                    			uv._v = float;
	                    			break;
	                    		default:
	                    	}
	                    	i++;
	                    }
		            }
	                output.push(element);
	            }
            }
            else
            {
                // Store indexes if no source
                var recursive :XMLList = geo..vertices.(@id == id)["input"];

                output = deserialize(recursive[0], geo, Element, output);
            }

            return output;
        }
    }
}