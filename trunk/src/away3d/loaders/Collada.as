package away3d.loaders
{
    import away3d.containers.*;
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;
    import away3d.materials.*;
    import away3d.loaders.data.ContainerData;
    import away3d.loaders.data.FaceData;
    import away3d.loaders.data.MaterialData;
    import away3d.loaders.data.MeshData;
    import away3d.loaders.data.MeshMaterialData;
    import away3d.loaders.data.ObjectData;
    
    import flash.utils.*;

    /** Collada scene loader */
    public class Collada
    {
    	use namespace arcane;
    	
        public var container:ObjectContainer3D;
    	public var materialLibrary:MaterialLibrary = new MaterialLibrary();
        public var containerData:ContainerData;
        
        protected var collada:XML;
        protected var material:ITriangleMaterial;
        protected var centerMeshes:Boolean;
        protected var scaling:Number;
        protected var yUp:Boolean;
    
        public function Collada(xml:XML, init:Object = null)
        {
            collada = xml;
            init = Init.parse(init);
			materialLibrary.texturePath = init.getString("texturePath", "");
			materialLibrary.autoLoadTextures = init.getBoolean("autoLoadTextures", true);
            scaling = init.getNumber("scaling", 1)*100;
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
    		
			//parse the collada file
            parseCollada();
            
            //build materials
			buildMaterials();
			
			//build the containers
            container = new ObjectContainer3D(init);
			buildContainer(containerData, container);
        }

        public static function parse(data:*, init:Object = null, object:Object = null):ObjectContainer3D
        {
            var parser:Collada = new Collada(Cast.xml(data), init);
        	if (object) {
        		object.materialLibrary = parser.materialLibrary;
        		object.containerData = parser.containerData;
        	}
            return parser.container;
        }
		
		public static function loadTextures(data:*, init:Object = null):Object3DLoader
		{
			var parser:Collada = new Collada(Cast.xml(data), init);
			return Object3DLoader.loadTextures(parser.container, parser.materialLibrary, init);
		}
		
        public static function load(url:String, init:Object = null):Object3DLoader
        {
            return Object3DLoader.loadGeometry(url, parse, false, init);
        }
    
        protected function parseCollada():void
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
    	
        protected function parseScene(scene:XML):void
        {
        	containerData = new ContainerData();
            for each (var node:XML in scene.node)
                parseNode(node, containerData);
        }
    	
    	protected var _meshData:MeshData;
        protected var _materialData:MaterialData;
        
        protected function parseNode(node:XML, parent:ContainerData):void
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
                        _transform.multiply(_transform, m)
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
        
        protected function setMaterial(name:String, target:String):void
        {
           	_materialData = materialLibrary.addMaterial(name);
            if(name == "FrontColorNoCulling") {
            	_materialData.materialType = MaterialData.SHADING_MATERIAL;
            } else {
            	_materialData.materialType = MaterialData.TEXTURE_MATERIAL;
                _materialData.textureFileName = getTextureFileName(target);
            }
        }
        
        protected var _meshMaterialData:MeshMaterialData;
        
        protected function parseGeometry(geometry:XML, _meshData:MeshData):void
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
        
        protected var numChildren:int;
        
        protected function buildContainer(containerData:ContainerData, parent:ObjectContainer3D):void
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
        
    	protected var averageX:Number;
		protected var averageY:Number;
		protected var averageZ:Number;
		protected var numVertices:int;
		
    	protected var _faceListIndex:int;
    	protected var _faceData:FaceData;
    	
    	protected var _face:Face;
    	protected var _vertex:Vertex;
    	
        protected function buildMesh(_meshData:MeshData, parent:ObjectContainer3D):void
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
			
			var face:Face;
			var matData:MaterialData;
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
        
        protected function buildMaterials():void
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
		
        protected function getArray(spaced:String):Array
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
		
		// Retrieves the filename of a material
		protected function getTextureFileName( name:String ):String
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
		
    	internal var rotationMatrix:Matrix3D = new Matrix3D();
    	
        protected function rotateMatrix(vector:Array):Matrix3D
        {
            if (yUp)
                rotationMatrix.rotationMatrix(vector[0], vector[1], vector[2], -vector[3] * toRADIANS);
            else
                rotationMatrix.rotationMatrix(vector[0], vector[2], vector[1], -vector[3] * toRADIANS);
            
            return rotationMatrix;
        }
    
    	internal var translationMatrix:Matrix3D = new Matrix3D();
    	
        protected function translateMatrix(vector:Array):Matrix3D
        {
            if (yUp)
                translationMatrix.translationMatrix(-vector[0] * scaling, vector[1] * scaling, vector[2] * scaling);
            else
                translationMatrix.translationMatrix( vector[0] * scaling, vector[2] * scaling, vector[1] * scaling);
            
            return translationMatrix;
        }
    
    	internal var scalingMatrix:Matrix3D = new Matrix3D();
    	
        protected function scaleMatrix(vector:Array):Matrix3D
        {
            if (yUp)
                scalingMatrix.scaleMatrix(vector[0], vector[1], vector[2]);
            else
                scalingMatrix.scaleMatrix(vector[0], vector[2], vector[1]);
            
            return scalingMatrix;
        }
    
        protected function deserialize(input:XML, geo:XML, Element:Class, output:Array):Array
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
    
    
        protected function getId(url:String):String
        {
            return url.split("#")[1];
        }

        protected static var toDEGREES:Number = 180 / Math.PI;
        protected static var toRADIANS:Number = Math.PI / 180;
        
        protected var VALUE_X:String;
        protected var VALUE_Y:String;
        protected var VALUE_Z:String;
        
        protected var VALUE_U:String = "S";
        protected var VALUE_V:String = "T";
    }
}
