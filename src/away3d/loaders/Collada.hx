package away3d.loaders;

	import away3d.animators.*;
	import away3d.animators.skin.*;
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.loaders.data.*;
	import away3d.loaders.utils.*;
	import away3d.materials.*;
	
	import flash.utils.*;
	
	use namespace arcane;
	
    /**
    * File loader for the Collada file format with animation.
    */
    class Collada extends AbstractParser {
		/** @private */
    	
		/** @private */
    	arcane var ini:Init;
    	
        var collada:XML;
        var material:ITriangleMaterial;
        var centerMeshes:Bool;
        var scaling:Float;
        var shading:Bool;
        var texturePath:String;
        var autoLoadTextures:Bool;
        var materialLibrary:MaterialLibrary;
        var animationLibrary:AnimationLibrary;
        var geometryLibrary:GeometryLibrary;
        var channelLibrary:ChannelLibrary;
        var symbolLibrary:Dictionary;
        var yUp:Bool;
        var toRADIANS:Int ;
        var _skinController:SkinController;
    	var _meshData:MeshData;
    	var _geometryData:GeometryData;
        var _materialData:MaterialData;
        var _animationData:AnimationData;
		var _meshMaterialData:MeshMaterialData;
		var numChildren:Int;
		var _maxX:Float;
		var _minX:Float;
		var _maxY:Float;
		var _minY:Float;
		var _maxZ:Float;
		var _minZ:Float;
    	var _faceListIndex:Int;
    	var _faceData:FaceData;
    	var _face:Face;
    	var _vertex:Vertex;
    	var _moveVector:Number3D ;
		var rotationMatrix:Matrix3D ;
    	var scalingMatrix:Matrix3D ;
    	var translationMatrix:Matrix3D ;
        var VALUE_X:String;
        var VALUE_Y:String;
        var VALUE_Z:String;
        var VALUE_U:String ;
        var VALUE_V:String ;
		var _geometryArray:Array<Dynamic>;
		var _geometryArrayLength:Int;
		var _channelArray:Array<Dynamic>;
		var _channelArrayLength:Int;
		
		/**
		 * Collada Animation
		 */
		var _defaultAnimationClip:AnimationData;
		var _haveAnimation:Bool ;
		var _haveClips:Bool ;
		var _containers:Dictionary ;
		
		function buildContainers(containerData:ContainerData, parent:ObjectContainer3D):Void
		{
			for (_objectData in containerData.children) {
				if (Std.is( _objectData, MeshData)) {
					buildMesh(cast( _objectData, MeshData), parent);
				} else if (Std.is( _objectData, BoneData)) {
					var _boneData:BoneData = cast( _objectData, BoneData);
					var bone:Bone = new Bone({name:_boneData.name});
					_boneData.container = cast( bone, ObjectContainer3D);
					
					_containers[bone.name] = bone;
					
					//ColladaMaya 3.05B
					bone.id = _boneData.id;
					
					bone.transform = _boneData.transform;
					
					bone.joint.transform = _boneData.jointTransform;
					
					buildContainers(_boneData, bone.joint);
					
					parent.addChild(bone);
					
				} else if (Std.is( _objectData, ContainerData)) {
					var _containerData:ContainerData = cast( _objectData, ContainerData);
					var objectContainer:ObjectContainer3D = _containerData.container = new ObjectContainer3D({name:_containerData.name});
					
					_containers[objectContainer.name] = objectContainer;
					
					objectContainer.transform = _objectData.transform;
					
					buildContainers(_containerData, objectContainer);
					
					if (centerMeshes && objectContainer.children.length) {
						//center children in container for better bounding radius calulations
						objectContainer.movePivot(_moveVector.x = (objectContainer.maxX + objectContainer.minX)/2, _moveVector.y = (objectContainer.maxY + objectContainer.minY)/2, _moveVector.z = (objectContainer.maxZ + objectContainer.minZ)/2);
						_moveVector.transform(_moveVector, _objectData.transform);
						objectContainer.moveTo(_moveVector.x, _moveVector.y, _moveVector.z);
					}
					
					parent.addChild(objectContainer);
					
				}
			}
		}
		
		function buildMesh(_meshData:MeshData, parent:ObjectContainer3D):Void
		{
			Debug.trace(" + Build Mesh : "+_meshData.name)
			
			var mesh:Mesh = new Mesh({name:_meshData.name});
			mesh.transform = _meshData.transform;
			mesh.bothsides = _meshData.geometry.bothsides;
			
			_geometryData = _meshData.geometry;
			var geometry:Geometry = _geometryData.geometry;
			
			if (!geometry) {
				geometry = _geometryData.geometry = new Geometry();
				
				mesh.geometry = geometry;
				
				//set materialdata for each face
				for (_meshMaterialData in _geometryData.materials) {
					for (_faceListIndex in _meshMaterialData.faceList) {
						_faceData = cast( _geometryData.faces[_faceListIndex], FaceData);
						_faceData.materialData = symbolLibrary[_meshMaterialData.symbol];
					}
				}
				
				
				if (_geometryData.skinVertices.length) {
					var i:Int;
					var joints:Array<Dynamic>;
					var rootBone:Bone = (cast( container, ObjectContainer3D)).getBoneByName(_meshData.skeleton);
					
					geometry.skinVertices = _geometryData.skinVertices;
					geometry.skinControllers = _geometryData.skinControllers;
					//mesh.bone = container.getChildByName(_meshData.bone) as Bone;
					
		   			geometry.rootBone = rootBone;
		   			
		   			for each (_skinController in geometry.skinControllers)
		                _skinController.inverseTransform = parent.inverseSceneTransform;
				}
				
				//create faces from face and mesh data
				var face:Face;
				var matData:MaterialData;
				
				for (_faceData in _geometryData.faces) {
					if (!_faceData.materialData)
						continue;
					_face = new Face(_geometryData.vertices[_faceData.v0],
												_geometryData.vertices[_faceData.v1],
												_geometryData.vertices[_faceData.v2],
												cast( _faceData.materialData.material, ITriangleMaterial),
												_geometryData.uvs[_faceData.uv0],
												_geometryData.uvs[_faceData.uv1],
												_geometryData.uvs[_faceData.uv2]);
					geometry.addFace(_face);
					_faceData.materialData.elements.push(_face);
				}
			} else {
				mesh.geometry = geometry;
			}
			
			if (centerMeshes) {
				trace(_geometryData.maxX);
				trace(_geometryData.minX);
				mesh.movePivot(_moveVector.x = (_geometryData.maxX + _geometryData.minX)/2, _moveVector.y = (_geometryData.maxY + _geometryData.minY)/2, _moveVector.z = (_geometryData.maxZ + _geometryData.minZ)/2);
				_moveVector.transform(_moveVector, _meshData.transform);
				mesh.moveTo(_moveVector.x, _moveVector.y, _moveVector.z);
			}
			
			mesh.type = ".Collada";
			parent.addChild(mesh);
		}
		
        function buildMaterials():Void
		{
			for (_materialData in materialLibrary)
			{
				Debug.trace(" + Build Material : "+_materialData.name)
				
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
						_materialData.material = new ShadingColorMaterial(null, {ambient:_materialData.ambientColor, diffuse:_materialData.diffuseColor, specular:_materialData.specularColor, shininess:_materialData.shininess});
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
		
		function buildAnimations():Void
		{
			var bone:Bone;
			
			for (_geometryData in geometryLibrary) {
				for (_skinController in _geometryData.geometry.skinControllers) {
					bone = (cast( container, ObjectContainer3D)).getBoneByName(_skinController.name);
	                if (bone)
	                    _skinController.joint = bone.joint;
	                else
	                	Debug.warning("no joint found for " + _skinController.name);
	   			}
	  		}
		   			
			for (_animationData in animationLibrary)
			{
				switch (_animationData.animationType)
				{
					case AnimationData.SKIN_ANIMATION:
						var animation:SkinAnimation = new SkinAnimation();
						
						var param:Array<Dynamic>;
			            var rX:String;
			            var rY:String;
			            var rZ:String;
			            var sX:String;
			            var sY:String;
			            var sZ:String;
						
						for (channelData in _animationData.channels) {
							var channel:Channel = channelData.channel;
							channel.target = _containers[channel.name];
							animation.appendChannel(channel);
							
							var times:Array<Dynamic> = channel.times;
							
							if (_animationData.start > times[0])
								_animationData.start = times[0];
							
							if (_animationData.end < times[times.length-1])
								_animationData.end = times[times.length - 1];
							
				            if (Std.is( channel.target, Bone)) {
				            	rX = "jointRotationX";
				            	rY = "jointRotationY";
				            	rZ = "jointRotationZ";
				            	sX = "jointScaleX";
				            	sY = "jointScaleY";
				            	sZ = "jointScaleZ";
				            } else {
				            	rX = "rotationX";
				            	rY = "rotationY";
				            	rZ = "rotationZ";
				            	sX = "scaleX";
				            	sY = "scaleY";
				            	sZ = "scaleZ";
				            }
				            
				            switch(channelData.type)
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
				     			case "jointOrientX":
				     				channel.type = ["rotationX"];
				     				if (yUp)
										for each (param in channel.param)
											param[0] *= -1;
				     				break;
								case "rotateX":
								case "RotX":
				     				channel.type = [rX];
				     				if (yUp)
										for each (param in channel.param)
											param[0] *= -1;
				     				break;
				     			case "jointOrientY":
				     				channel.type = ["rotationY"];
				     				//if (yUp)
										for each (param in channel.param)
											param[0] *= -1;
				     				break;
								case "rotateY":
								case "RotY":
									if (yUp)
										channel.type = [rY];
									else
										channel.type = [rZ];
									//if (yUp)
										for each (param in channel.param)
											param[0] *= -1;
				     				break;
				     			case "jointOrientZ":
				     				channel.type = ["rotationZ"];
				     				//if (yUp)
										for each (param in channel.param)
											param[0] *= -1;
				     				break;
								case "rotateZ":
								case "RotZ":
									if (yUp)
										channel.type = [rZ];
									else
										channel.type = [rY];
									//if (yUp)
										for each (param in channel.param)
											param[0] *= -1;
				            		break;
								case "scaleX":
									channel.type = [sX];
									//if (yUp)
									//	for each (param in channel.param)
									//		param[0] *= -1;
				            		break;
								case "scaleY":
									if (yUp)
										channel.type = [sY];
									else
										channel.type = [sZ];
				     				break;
								case "scaleZ":
									if (yUp)
										channel.type = [sZ];
									else
										channel.type = [sY];
				     				break;
								case "translate":
								case "translation":
									if (yUp) {
										channel.type = ["x", "y", "z"];
										for each (param in channel.param)
											param[0] *= -1;
				     				} else {
				     					channel.type = ["x", "z", "y"];
				     				}
				     				for (param in channel.param) {
										param[0] *= scaling;
										param[1] *= scaling;
										param[2] *= scaling;
				     				}
									break;
								case "scale":
									if (yUp)
										channel.type = [sX, sY, sZ];
									else
										channel.type = [sX, sZ, sY];
				     				break;
								case "rotate":
									if (yUp) {
										channel.type = [rX, rY, rZ];
										for (param in channel.param) {
											param[0] *= -1;
											param[1] *= -1;
											param[2] *= -1;
										}
				     				} else {
										channel.type = [rX, rZ, rY];
										for (param in channel.param) {
											param[1] *= -1;
											param[2] *= -1;
										}
				     				}
									break;
								case "transform":
									channel.type = ["transform"];
									break;
				            }
						}
						
						animation.start = _animationData.start;
						animation.length = _animationData.end - _animationData.start;
						
						_animationData.animation = animation;
						break;
					case AnimationData.VERTEX_ANIMATION:
						break;
				}
			}
		}
		
        function getArray(spaced:String):Array<Dynamic>
        {
        	spaced = spaced.split("\r\n").join(" ");
            var strings:Array<Dynamic> = spaced.split(" ");
            var numbers:Array<Dynamic> = [];
			
            var totalStrings:Int = strings.length;
			
            for (var i:Int = 0; i < totalStrings; i++)
            	if (strings[i] != "")
                	numbers.push(Number(strings[i]));

            return numbers;
        }
		
        function rotateMatrix(vector:Array<Dynamic>):Matrix3D
        {
            if (yUp) {
                	rotationMatrix.rotationMatrix(vector[0], -vector[1], -vector[2], vector[3]*toRADIANS);
            } else {
                	rotationMatrix.rotationMatrix(vector[0], vector[2], vector[1], -vector[3]*toRADIANS);
            }
            
            return rotationMatrix;
        }

        function translateMatrix(vector:Array<Dynamic>):Matrix3D
        {
            if (yUp)
                translationMatrix.translationMatrix(-vector[0]*scaling, vector[1]*scaling, vector[2]*scaling);
            else
                translationMatrix.translationMatrix(vector[0]*scaling, vector[2]*scaling, vector[1]*scaling);
			
            return translationMatrix;
        }
		
        function scaleMatrix(vector:Array<Dynamic>):Matrix3D
        {
            if (yUp)
                scalingMatrix.scaleMatrix(vector[0], vector[1], vector[2]);
            else
                scalingMatrix.scaleMatrix(vector[0], vector[2], vector[1]);
			
            return scalingMatrix;
        }

        function getId(url:String):String
        {
            return url.split("#")[1];
        }
    	
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
		
        public function new(data:Dynamic, ?init:Dynamic = null)
        {
         	
         	toRADIANS = Math.PI / 180;
         	_moveVector = new Number3D();
         	rotationMatrix = new Matrix3D();
         	scalingMatrix = new Matrix3D();
         	translationMatrix = new Matrix3D();
         	VALUE_U = "S";
         	VALUE_V = "T";
         	_haveAnimation = false;
         	_haveClips = false;
         	_containers = new Dictionary(true);
         	collada = Cast.xml(data);
            
            ini = Init.parse(init);
			
			texturePath = ini.getString("texturePath", "");
			autoLoadTextures = ini.getBoolean("autoLoadTextures", true);
            scaling = ini.getNumber("scaling", 1)*100;
            shading = ini.getBoolean("shading", false);
            material = ini.getMaterial("material");
            centerMeshes = ini.getBoolean("centerMeshes", false);

            var materials:Dynamic = ini.getObject("materials") || {};
			
			//create the container
            container = new ObjectContainer3D(ini);
			container.name = "collada";
			
			materialLibrary = container.materialLibrary = new MaterialLibrary();
			animationLibrary = container.animationLibrary = new AnimationLibrary();
			geometryLibrary = container.geometryLibrary = new GeometryLibrary();
			channelLibrary = new ChannelLibrary();
			symbolLibrary = new Dictionary(true);
			materialLibrary.autoLoadTextures = autoLoadTextures;
			materialLibrary.texturePath = texturePath;
			
			//organise the materials
            for (var name:String in materials) {
                _materialData = materialLibrary.addMaterial(name);
                _materialData.material = Cast.material(materials[name]);

                //determine material type
                if (Std.is( _materialData.material, BitmapMaterial))
                	_materialData.materialType = MaterialData.TEXTURE_MATERIAL;
                else if (Std.is( _materialData.material, ShadingColorMaterial))
                	_materialData.materialType = MaterialData.SHADING_MATERIAL;
                else if (Std.is( _materialData.material, WireframeMaterial))
                	_materialData.materialType = MaterialData.WIREFRAME_MATERIAL;
   			}
   			
			//parse the collada file
            parseCollada();
        }
		
        /**
		 * Creates a 3d container object from the raw xml data of a collada file.
		 *
		 * @param	data				The xml data of a loaded file.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * @param	loader	[optional]	Not intended for direct use.
		 *
		 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is parsing.
		 */
        public static function parse(data:Dynamic, ?init:Dynamic = null):ObjectContainer3D
        {
            return cast( Object3DLoader.parseGeometry(data, Collada, init).handle, ObjectContainer3D);
        }
		
    	/**
    	 * Loads and parses a collada file into a 3d container object.
    	 *
    	 * @param	url					The url location of the file to load.
    	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
    	 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.
    	 */
        public static function load(url:String, ?init:Dynamic = null):Object3DLoader
        {
			//texturePath as model folder
			if (url)
			{
				var _pathArray:Array<Dynamic> = url.split("/");
				var _imageName:String = _pathArray.pop();
				var _texturePath:String = (_pathArray.length>0)?_pathArray.join("/")+"/":_pathArray.join("/");
				
				if (init)
					init.texturePath = init.texturePath || _texturePath;
				else
					init = {texturePath:_texturePath};
			}
			return Object3DLoader.loadGeometry(url, Collada, false, init);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function parseNext():Void
        {
        	if (_parsedChunks < _geometryArrayLength)
        		parseGeometry(_geometryArray[_parsedChunks]);
        	else
        		parseChannel(_channelArray[-_geometryArrayLength + _parsedChunks]);
        	
        	_parsedChunks++;
        	
        	if (_parsedChunks == _totalChunks) {
	        	//build materials
				buildMaterials();
				
				//build the containers
				buildContainers(containerData, cast( container, ObjectContainer3D));
				
				//build the meshes
				//buildMeshes(containerData, container as ObjectContainer3D);
				
				//build animations
				buildAnimations();
				
	        	notifySuccess();
        	} else {
				notifyProgress();
	        }
        }

        function parseCollada():Void
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
        function parseScene():Void
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
			_geometryArray = geometryLibrary.getGeometryArray();
			_geometryArrayLength = _geometryArray.length;
			_totalChunks += _geometryArrayLength;
		}
		
		/**
		 * Converts a single scene node to a BoneData ContainerData or MeshData object.
		 * 
		 * @see away3d.loaders.data.BoneData
		 * @see away3d.loaders.data.ContainerData
		 * @see away3d.loaders.data.MeshData
		 */
        function parseNode(node:XML, parent:ContainerData):Void
        {	
			var _transform:Matrix3D;
	    	var _objectData:ObjectData;
	    	var _name:String = node.name().localName;
	    	
        	if (String(node.instance_light.@url) != "" || String(node.instance_camera.@url) != "")
        		return;
	    	
	    	
			if (String(node.instance_controller) == "" && String(node.instance_geometry) == "")
			{
				
				if (String(node.@type) == "JOINT")
					_objectData = new BoneData();
				else {
					if (String(node.instance_node.@url) == "" && (String(node.node) == "" || Std.is( parent, BoneData)))
						return;
					_objectData = new ContainerData();
				}
			}else{
				_objectData = new MeshData();
			}
			
			parent.children.push(_objectData);
			
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
			var arrayChild:Array<Dynamic>
			var boneData:BoneData = (cast( _objectData, BoneData));
			
            for (child in node.children())
            {
                arrayChild = getArray(child);
				switch (child.name().localName)
                {
					case "translate":
                        _transform.multiply(_transform, translateMatrix(arrayChild));
                        
                        break;

                    case "rotate":
                    	sid = child.@sid;
                        if (Std.is( _objectData, BoneData) && (sid == "rotateX" || sid == "rotateY" || sid == "rotateZ" || sid == "rotX" || sid == "rotY" || sid == "rotZ"))
							boneData.jointTransform.multiply(boneData.jointTransform, rotateMatrix(arrayChild));
                        else
	                        _transform.multiply(_transform, rotateMatrix(arrayChild));
	                    
                        break;
						
                    case "scale":
                        if (Std.is( _objectData, BoneData))
							boneData.jointTransform.multiply(boneData.jointTransform, scaleMatrix(arrayChild));
                        else
	                        _transform.multiply(_transform, scaleMatrix(arrayChild));
						
                        break;
						
                    // Baked transform matrix
                    case "matrix":
                    	var m:Matrix3D = new Matrix3D();
                    	m.array2matrix(arrayChild, yUp, scaling);
                        _transform.multiply(_transform, m);
						break;
						
                    case "node":
                    	//3dsMax 11 - Feeling ColladaMax v3.05B
                    	//<node><node/></node>
                    	if(Std.is( _objectData, MeshData))
                    	{
							parseNode(child, cast( parent, ContainerData));
                    	}else{
                    		parseNode(child, cast( _objectData, ContainerData));
                    	}
                        
                        break;

    				case "instance_node":
    					parseNode(collada.library_nodes.node.(@id == getId(child.@url))[0], cast( _objectData, ContainerData));
    					
    					break;

                    case "instance_geometry":
                    	if(String(child).indexOf("lines") == -1) {
							
							//add materials to materialLibrary
	                        for each (instance_material in child..instance_material)
	                        	parseMaterial(instance_material.@symbol, getId(instance_material.@target));
							
							geo = collada.library_geometries.geometry.(@id == getId(child.@url))[0];
							
	                        (cast( _objectData, MeshData)).geometry = geometryLibrary.addGeometry(geo.@id, geo);
	                    }
	                    
                        break;
					
                    case "instance_controller":
						
						//add materials to materialLibrary
						for each (instance_material in child..instance_material)
							parseMaterial(instance_material.@symbol, getId(instance_material.@target));
						
						ctrlr = collada.library_controllers.controller.(@id == getId(child.@url))[0];
						geo = collada.library_geometries.geometry.(@id == getId(ctrlr.skin[0].@source))[0];
						
	                    (cast( _objectData, MeshData)).geometry = geometryLibrary.addGeometry(geo.@id, geo, ctrlr);
						
						(cast( _objectData, MeshData)).skeleton = getId(child.skeleton);
						break;
                }
            }
        }
		
		/**
		 * Converts a material definition to a MaterialData object
		 * 
		 * @see away3d.loaders.data.MaterialData
		 */
        function parseMaterial(symbol:String, name:String):Void
        {
           	_materialData = materialLibrary.addMaterial(name);
        	symbolLibrary[symbol] = _materialData;
            if(symbol == "FrontColorNoCulling") {
            	_materialData.materialType = MaterialData.SHADING_MATERIAL;
            } else {
                _materialData.textureFileName = getTextureFileName(name);
                
                if (_materialData.textureFileName) {
            		_materialData.materialType = MaterialData.TEXTURE_MATERIAL;
                } else {
                	if (shading)
                		_materialData.materialType = MaterialData.SHADING_MATERIAL;
                	else
	                	_materialData.materialType = MaterialData.COLOR_MATERIAL;
                	
                	parseColorMaterial(name, _materialData);
                }
            }
        }
		
		/**
		 * Parses geometry data.
		 * 
		 * @see away3d.loaders.data.GeometryData
		 */
		function parseGeometry(geometryData:GeometryData):Void
		{
			Debug.trace(" + Parse Geometry : "+ geometryData.name);
			var verticesDictionary:Dictionary = new Dictionary(true);
			
            // Triangles
            for (triangles in geometryData.geoXML.mesh.triangles)
            {
                // Input
                var field:Array<Dynamic> = [];
				
                for (input in triangles.input)
                {
                	var semantic:String = input.@semantic;
                	switch(semantic)
                	{
                		case "VERTEX":
                			deserialize(input, geometryData.geoXML, Vertex, geometryData.vertices);
                			break;
                		case "TEXCOORD":
                			deserialize(input, geometryData.geoXML, UV, geometryData.uvs);
                			break;
                		default:
                	}
                    field.push(input.@semantic);
                }

                var data:Array<Dynamic>  = triangles.p.split(' ');
                var len      :Number = triangles.@count;
                var symbol :String = triangles.@material
                
				Debug.trace(" + Parse MeshMaterialData");
                _meshMaterialData = new MeshMaterialData();
    			_meshMaterialData.symbol = symbol;
				geometryData.materials.push(_meshMaterialData);
				
				//if (!materialLibrary[material])
				//	parseMaterial(material, material);
					
                for (j in 0...len)
                {
                    var _faceData:FaceData = new FaceData();

                    for (vn in 0...3)
                    {
                        for (fld in field)
                        {
                        	switch(fld)
                        	{
                        		case "VERTEX":
                        			_faceData["v" + vn] = data.shift();
                        			break;
                        		case "TEXCOORD":
                        			_faceData["uv" + vn] = data.shift();
                        			break;
                        		default:
                        			data.shift();
                        	}
                        }
                    }
                    //trace(_faceData.v0);
                    verticesDictionary[_faceData.v0] = geometryData.vertices[_faceData.v0];
                    verticesDictionary[_faceData.v1] = geometryData.vertices[_faceData.v1];
                    verticesDictionary[_faceData.v2] = geometryData.vertices[_faceData.v2];
                    
                    _meshMaterialData.faceList.push(geometryData.faces.length);
                    geometryData.faces.push(_faceData);
                }
            }
            
			//center vertex points in mesh for better bounding radius calulations
        	if (centerMeshes) {
				geometryData.maxX = -Infinity;
				geometryData.minX = Infinity;
				geometryData.maxY = -Infinity;
				geometryData.minY = Infinity;
				geometryData.maxZ = -Infinity;
				geometryData.minZ = Infinity;
                for (_vertex in verticesDictionary) {
					if (geometryData.maxX < _vertex._x)
						geometryData.maxX = _vertex._x;
					if (geometryData.minX > _vertex._x)
						geometryData.minX = _vertex._x;
					if (geometryData.maxY < _vertex._y)
						geometryData.maxY = _vertex._y;
					if (geometryData.minY > _vertex._y)
						geometryData.minY = _vertex._y;
					if (geometryData.maxZ < _vertex._z)
						geometryData.maxZ = _vertex._z;
					if (geometryData.minZ > _vertex._z)
						geometryData.minZ = _vertex._z;
                }
			}
			
			// Double Side
			if (String(geometryData.geoXML.extra.technique.double_sided) != "")
            	geometryData.bothsides = (geometryData.geoXML.extra.technique.double_sided[0].toString() == "1");
            else
            	geometryData.bothsides = false;
			
			//parse controller
			if (!geometryData.ctrlXML)
				return;
			
			var skin:XML = geometryData.ctrlXML.skin[0];
			
			var jointId:String = getId(skin.joints.input.(@semantic == "JOINT")[0].@source);
            var tmp:String = skin.source.(@id == jointId).Name_array.toString();
			//Blender?
			if (!tmp) tmp = skin.source.(@id == jointId).IDREF_array.toString();
            tmp = tmp.replace(~/\n/g, " ");
            var nameArray:Array<Dynamic> = tmp.split(" ");
            
			var bind_shape:Matrix3D = new Matrix3D();
			bind_shape.array2matrix(getArray(skin.bind_shape_matrix[0].toString()), yUp, scaling);
			
			var bindMatrixId:String = getId(skin.joints.input.(@semantic == "INV_BIND_MATRIX").@source);
            var float_array:Array<Dynamic> = getArray(skin.source.(@id == bindMatrixId)[0].float_array.toString());
            
            var v:Array<Dynamic>;
            var matrix:Matrix3D;
            var name:String;
            var joints:Array<Dynamic> = new Array();
			var skinController:SkinController;
            var i:Int = 0;
            
            while (i < float_array.length)
            {
            	name = nameArray[i / 16];
				matrix = new Matrix3D();
				matrix.array2matrix(float_array.slice(i, i+16), yUp, scaling);
				matrix.multiply(matrix, bind_shape);
				
                geometryData.skinControllers.push(skinController = new SkinController());
                skinController.name = name;
                skinController.bindMatrix = matrix;
                
                i = i + 16;
            }
			
			Debug.trace(" + SkinWeight");

            tmp = skin.vertex_weights[0].@count;
            var num_weights:Int = int(skin.vertex_weights[0].@count);

			var weightsId:String = getId(skin.vertex_weights.input.(@semantic == "WEIGHT")[0].@source);
			
            tmp = skin.source.(@id == weightsId).float_array.toString();
            var weights:Array<Dynamic> = tmp.split(" ");
			
            tmp = skin.vertex_weights.vcount.toString();
            var vcount:Array<Dynamic> = tmp.split(" ");
			
            tmp = skin.vertex_weights.v.toString();
            v = tmp.split(" ");
			
			var skinVertex:SkinVertex;
            var c:Int;
            var count:Int = 0;
			
            i=0;
            while (i < geometryData.vertices.length)
            {
                c = int(vcount[i]);
                skinVertex = new SkinVertex(geometryData.vertices[i]);
                geometryData.skinVertices.push(skinVertex);
                j=0;
                while (j < c)
                {
                    skinVertex.controllers.push(geometryData.skinControllers[int(v[count])]);
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
		function parseAnimationClips() : Void
        {
			
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
            
            //loop through all animation channels
			for each (var channel:XML in anims.animation)
				channelLibrary.addChannel(channel.@id, channel);
			
			if (clips) {
				//loop through all animation clips
				for each (var clip:XML in clips.animation_clip)
					parseAnimationClip(clip);
			}
			
			//create default animation clip
			_defaultAnimationClip = animationLibrary.addAnimation("default");
			
			for each (var channelData:ChannelData in channelLibrary)
				_defaultAnimationClip.channels[channelData.name] = channelData;
			
			Debug.trace(" ! ------------- End Parse Animation -------------");
			_channelArray = channelLibrary.getChannelArray();
			_channelArrayLength = _channelArray.length;
			_totalChunks += _channelArrayLength;
        }
        
        function parseAnimationClip(clip:XML) : Void
        {
			var animationClip:AnimationData = animationLibrary.addAnimation(clip.@id);
			
			for each (var channel:XML in clip.instance_animation)
				animationClip.channels[getId(channel.@url)] = channelLibrary[getId(channel.@url)];
        }
		
		function parseChannel(channelData:ChannelData) : Void
        {
        	var node:XML = channelData.xml;
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
			
            var channel:Channel = channelData.channel = new Channel(name);
			var i:Int;
			var j:Int;
			
			_defaultAnimationClip.channels[channelData.name] = channelData;
			
			Debug.trace(" ! channelType : " + type);
			
            for (input in sampler.input)
            {
				var src:XML = node.source.(@id == getId(input.@source))[0]
                var count:Int = int(src.float_array.@count);
                var list:Array<Dynamic> = String(src.float_array).split(" ");
                var len:Int = int(src.technique_common.accessor.@count);
                var stride:Int = int(src.technique_common.accessor.@stride);
                var semantic:String = input.@semantic;
				
				var p:String
				var sign:Int = (type.charAt(type.length - 1) == "X")? -1 : 1;
                switch(semantic) {
                    case "INPUT":
                        for each (p in list)
                            channel.times.push(Number(p));
                        
                        if (_defaultAnimationClip.start > channel.times[0])
                            _defaultAnimationClip.start = channel.times[0];
                        
                        if (_defaultAnimationClip.end < channel.times[channel.times.length-1])
                            _defaultAnimationClip.end = channel.times[channel.times.length-1];
                        
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
                        for (p in list)
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
            
			channelData.type = type;
        }
		
		/**
		 * Retrieves the filename of a material
		 */
		function getTextureFileName( name:String ):String
		{
			var filename:String = null;
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
		function parseColorMaterial(name:String, materialData:MaterialData):Void
		{
			
			var material:XML = collada.library_materials.material.(@id == name)[0];
			
			if (material) {
				var effectId:String = getId( material.instance_effect.@url );
				var effect:XML = collada.library_effects.effect.(@id == effectId)[0];
				
				materialData.ambientColor = getColorValue(effect..ambient[0]);
				materialData.diffuseColor = getColorValue(effect..diffuse[0]);
				materialData.specularColor = getColorValue(effect..specular[0]);
				materialData.shininess = Number(effect..shininess.float[0]);
			}
		}
		
		function getColorValue(color:XML):UInt
		{
			if (!color || color.length() == 0)
				return 0xFFFFFF;
			
			var colorArray:Array<Dynamic> = color.color.split(" ");
			var colorString:String = (colorArray[0]*255).toString(16) + (colorArray[1]*255).toString(16) + (colorArray[2]*255).toString(16);
			return parseInt(colorString, 16);
		}
		
		/**
		 * Converts a data string to an array of objects. Handles vertex and uv objects
		 */
        function deserialize(input:XML, geo:XML, VObject:Class, output:Array<Dynamic>):Array<Dynamic>
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
                var floats:Array<Dynamic>   = getArray(floStr);
    			var float:Float;
                // Build params array
                var params:Array<Dynamic> = [];
				var param:String;
				
                for each (var par:XML in acc.param)
                    params.push(par.@name);

                // Build output array
                var count:int = acc.@count;
                var stride:int = acc.@stride;
    			var len:Int = floats.length;
    			var i:Int = 0;
                while (i < len)
                {
    				var element:ValueObject = new VObject();
	            	if (Std.is( element, Vertex)) {
	            		var vertex:Vertex = cast( element, Vertex);
	                    for (param in params) {
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
		            } else if (Std.is( element, UV)) {
		            	var uv:UV = cast( element, UV);
	                    for (param in params) {
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
                var recursive:XMLList = geo..vertices.(@id == id)["input"];

                output = deserialize(recursive[0], geo, VObject, output);
            }

            return output;
        }
    }
