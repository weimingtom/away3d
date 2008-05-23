package away3d.loaders
{
    import away3d.containers.*;
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;
    import away3d.loaders.data.*;
    import away3d.loaders.utils.*;
    import away3d.materials.*;

    /**
    * File loader for the Collada file format.
    */
    public class Collada
    {
    	use namespace arcane;

    	private var ini:Init;
        private var collada:XML;
        private var material:ITriangleMaterial;
        private var centerMeshes:Boolean;
        private var scaling:Number;
        private var yUp:Boolean;
        private var toRADIANS:Number = Math.PI / 180;
    	private var _meshData:MeshData;
        private var _materialData:MaterialData;
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
        
        private function buildContainer(containerData:ContainerData, parent:ObjectContainer3D):void
		{
			for each (var _objectData:ObjectData in containerData.children) {
				if (_objectData is ContainerData) {
					var _containerData:ContainerData = _objectData as ContainerData;
					var objectContainer:ObjectContainer3D = new ObjectContainer3D({name:_objectData.name});
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
						
						objectContainer.movePivot(averageX/numChildren, averageY/numChildren, averageZ/numChildren);
					}
					parent.addChild(objectContainer);
				} else if (_objectData is MeshData) {
					buildMesh(_objectData as MeshData, parent);
				}
			}
		}
    	
        private function buildMesh(_meshData:MeshData, parent:ObjectContainer3D):void
		{
			
			//set materialdata for each face
			for each (_meshMaterialData in _meshData.materials) {
				for each (_faceListIndex in _meshMaterialData.faceList) {
					_faceData = _meshData.faces[_faceListIndex] as FaceData;
					_faceData.materialData = materialLibrary[_meshMaterialData.name];
				}
			}
			
			var mesh:Mesh = new Mesh({name:_meshData.name});
			mesh.transform = _meshData.transform;
			
			for each(_faceData in _meshData.faces) {
				if (!_faceData.materialData)
					continue;
				_face = new Face(_meshData.vertices[_faceData.v0],
											_meshData.vertices[_faceData.v1],
											_meshData.vertices[_faceData.v2],
											_faceData.materialData.material,
											_meshData.uvs[_faceData.uv0],
											_meshData.uvs[_faceData.uv1],
											_meshData.uvs[_faceData.uv2]);
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
						//_materialData.material = new BitmapMaterial(_materialData.textureBitmap);
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
		
        private function getArray(spaced:String):Array
        {
        	spaced = spaced.split("\r\n").join(" ");
            var strings:Array = spaced.split(" ");
            var numbers:Array = new Array();
    
            var totalStrings:Number = strings.length;
    
            for (var i:Number = 0; i < totalStrings; i++)
            	if (strings[i] != "")
                	numbers.push(Number(strings[i]));
    
            return numbers;
        }
		
        private function rotateMatrix(vector:Array):Matrix3D
        {
            if (yUp)
                rotationMatrix.rotationMatrix(vector[0], vector[1], vector[2], -vector[3] * toRADIANS);
            else
                rotationMatrix.rotationMatrix(vector[0], vector[2], vector[1], -vector[3] * toRADIANS);
            
            return rotationMatrix;
        }
        
        private function translateMatrix(vector:Array):Matrix3D
        {
            if (yUp)
                translationMatrix.translationMatrix(-vector[0] * scaling, vector[1] * scaling, vector[2] * scaling);
            else
                translationMatrix.translationMatrix( vector[0] * scaling, vector[2] * scaling, vector[1] * scaling);
            
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
        * Reference container for all materials used in the collada scene.
        */
    	public var materialLibrary:MaterialLibrary = new MaterialLibrary();
    	
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
            
			materialLibrary.texturePath = ini.getString("texturePath", "");
			materialLibrary.autoLoadTextures = ini.getBoolean("autoLoadTextures", true);
            scaling = ini.getNumber("scaling", 1)*100;
            material = ini.getMaterial("material");
            centerMeshes = ini.getBoolean("centerMeshes", false);
            
            var materials:Object = ini.getObject("materials") || {};

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
			
			//build the containers
            container = new ObjectContainer3D(ini);
			buildContainer(containerData, container);
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
        	if (loader) {
        		loader.materialLibrary = parser.materialLibrary;
        		loader.containerData = parser.containerData;
        	}
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
			return Object3DLoader.loadTextures(parser.container, parser.materialLibrary, init);
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
            return Object3DLoader.loadGeometry(url, parse, false, init);
        }
                
        private function parseCollada():void
        {
        	default xml namespace = collada.namespace();
			
            // Get up axis
            yUp = (collada.asset.up_axis == "Y_UP");
    		
    		if (yUp) {
    			VALUE_X = "X";
    			VALUE_Y = "Y";
    			VALUE_Z = "Z";
        	} else {
                VALUE_X = "X";
                VALUE_Y = "Z";
                VALUE_Z = "Y";
        	}
                    
            // Parse first scene
            var sceneId:String = getId(collada.scene.instance_visual_scene.@url);
    		
            var scene:XML = collada.library_visual_scenes.visual_scene.(@id == sceneId)[0];
    		
            parseScene(scene);
        }
        
        private function parseScene(scene:XML):void
        {
        	trace(scene.node);
        	containerData = new ContainerData();
            for each (var node:XML in scene.node)
                parseNode(node, containerData);
        }
    	
        private function parseNode(node:XML, parent:ContainerData):void
        {
	    	var _transform:Matrix3D;
	    	var _objectData:ObjectData;
	    	
            if (String(node.instance_geometry) == "")
                _objectData = new ContainerData();
            else                                                
                _objectData = new MeshData();

            _objectData.name = node.@name;
            _transform = _objectData.transform;
    
            for each (var child:XML in node.children())
            {
    
                switch (child.name().localName)
                {
                    case "translate":
                        _transform.multiply(_transform, translateMatrix(getArray(child)));
                        break;
    					
                    case "rotate":
                        _transform.multiply(_transform, rotateMatrix(getArray(child)));
                        break;
    					
                    case "scale":
                        _transform.multiply(_transform, scaleMatrix(getArray(child)));
                        break;
    					
                    // Baked transform matrix
                    case "matrix":
                    	var m:Matrix3D = new Matrix3D();
                    	m.array2matrix(getArray(child));
                        _transform.multiply(_transform, m);
                        break;
    					
                    case "node":
                    	parent.children.push(_objectData);
                        if (_objectData is ContainerData && String(child).indexOf("ForegroundColor") == -1)
                            parseNode(child, _objectData as ContainerData);
                        break;
                        
    				case "instance_node":
    					parent.children.push(_objectData);
    					parseNode(collada.library_nodes.node.(@id == getId(child.@url))[0], _objectData as ContainerData);
    					break;
    					
                    case "instance_geometry":
                    	parent.children.push(_objectData);
                    	
                    	if(String(child).indexOf("lines") == -1) {
							
	                        //if (String(child) != "") {
								//add materials to materialLibrary
	                            for each (var instance_material:XML in child..instance_material)
	                            	setMaterial(instance_material.@symbol, getId(instance_material.@target));
	                            
	                            var geo:XML = collada.library_geometries.geometry.(@id == getId(child.@url))[0];
	                            parseGeometry(geo, _objectData as MeshData);
	                        //}
	                    }
                        break;
                }
            }
        }
        
        private function setMaterial(name:String, target:String):void
        {
           	_materialData = materialLibrary.addMaterial(name);
            if(name == "FrontColorNoCulling") {
            	_materialData.materialType = MaterialData.SHADING_MATERIAL;
            } else {
            	_materialData.materialType = MaterialData.TEXTURE_MATERIAL;
                _materialData.textureFileName = getTextureFileName(target);
            }
        }
        
        private function parseGeometry(geometry:XML, _meshData:MeshData):void
        {	
            // Semantics
            _meshData.name = geometry.@id;
    		
            // Triangles
            for each (var triangles:XML in geometry.mesh.triangles)
            {
                // Input
                var field:Array = new Array();
                
                for each(var input:XML in triangles.input)
                {
                	var semantic:String = input.@semantic;
                	switch(semantic)
                	{
                		case "VERTEX":
                			deserialize(input, geometry, Vertex, _meshData.vertices);
                			break;
                		case "TEXCOORD":
                			deserialize(input, geometry, UV, _meshData.uvs);
                			break;
                		default:
                	}
                    field.push(input.@semantic);
                }
    			
                var data     :Array  = triangles.p.split(' ');
                var len      :Number = triangles.@count;
                var material :String = triangles.@material;
                
                _meshMaterialData = new MeshMaterialData();
    			_meshMaterialData.name = material;
				_meshData.materials.push(_meshMaterialData);
				
				if (!materialLibrary[material])
					setMaterial(material, material);
				
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
                    _meshMaterialData.faceList.push(_meshData.faces.length);
                    _meshData.faces.push(_faceData);
                }
            }
        }
		
		// Retrieves the filename of a material
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
                var params:Array = new Array();
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
	                    		case VALUE_Z:
	                    			vertex._z = float*scaling;
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
