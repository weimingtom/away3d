package away3d.loaders;

import away3d.haxeutils.DictionaryUtils;
import away3d.core.math.Number2D;
import away3d.core.utils.ValueObject;
import away3d.materials.IMaterial;
import away3d.loaders.data.ContainerData;
import away3d.containers.ObjectContainer3D;
import away3d.loaders.data.AnimationData;
import away3d.animators.skin.Bone;
import flash.events.EventDispatcher;
import away3d.loaders.data.MaterialData;
import away3d.loaders.utils.MaterialLibrary;
import away3d.materials.ITriangleMaterial;
import flash.utils.Dictionary;
import away3d.loaders.utils.ChannelLibrary;
import away3d.materials.ShadingColorMaterial;
import away3d.loaders.data.FaceData;
import away3d.animators.skin.Channel;
import away3d.materials.WireframeMaterial;
import away3d.animators.SkinAnimation;
import away3d.core.base.Face;
import away3d.loaders.data.MeshMaterialData;
import away3d.loaders.utils.GeometryLibrary;
import away3d.loaders.data.ObjectData;
import away3d.loaders.data.GeometryData;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import away3d.loaders.data.MeshData;
import away3d.animators.IMeshAnimation;
import away3d.core.utils.Cast;
import away3d.loaders.data.ChannelData;
import away3d.loaders.utils.AnimationLibrary;
import away3d.materials.ColorMaterial;
import away3d.animators.skin.SkinController;
import away3d.animators.skin.SkinVertex;
import away3d.core.utils.Init;
import away3d.core.utils.Debug;
import away3d.loaders.data.BoneData;
import away3d.core.math.Number3D;
import away3d.materials.WireColorMaterial;
import away3d.core.base.UV;
import away3d.core.math.Matrix3D;
import away3d.core.base.Vertex;
import away3d.materials.BitmapMaterial;
import away3d.core.base.Geometry;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * File loader for the Collada file format with animation.
 */
class Collada extends AbstractParser  {
	
	/** @private */
	public var ini:Init;
	private var collada:Xml;
	private var material:ITriangleMaterial;
	private var centerMeshes:Bool;
	private var scaling:Float;
	private var shading:Bool;
	private var texturePath:String;
	private var autoLoadTextures:Bool;
	private var materialLibrary:MaterialLibrary;
	private var animationLibrary:AnimationLibrary;
	private var geometryLibrary:GeometryLibrary;
	private var channelLibrary:ChannelLibrary;
	private var symbolLibrary:Dictionary;
	private var yUp:Bool;
	private var toRADIANS:Float;
	private var _skinController:SkinController;
	private var _meshData:MeshData;
	private var _geometryData:GeometryData;
	private var _materialData:MaterialData;
	private var _animationData:AnimationData;
	private var _meshMaterialData:MeshMaterialData;
	private var numChildren:Int;
	private var _maxX:Float;
	private var _minX:Float;
	private var _maxY:Float;
	private var _minY:Float;
	private var _maxZ:Float;
	private var _minZ:Float;
	private var _faceListIndex:Int;
	private var _faceData:FaceData;
	private var _faceMaterial:ITriangleMaterial;
	private var _face:Face;
	private var _vertex:Vertex;
	private var _moveVector:Number3D;
	private var rotationMatrix:Matrix3D;
	private var scalingMatrix:Matrix3D;
	private var translationMatrix:Matrix3D;
	private var VALUE_X:String;
	private var VALUE_Y:String;
	private var VALUE_Z:String;
	private var VALUE_U:String;
	private var VALUE_V:String;
	private var _geometryArray:Array<Dynamic>;
	private var _geometryArrayLength:Int;
	private var _channelArray:Array<Dynamic>;
	private var _channelArrayLength:Int;
	/**
	 * Collada Animation
	 */
	private var _defaultAnimationClip:AnimationData;
	private var _haveAnimation:Bool;
	private var _haveClips:Bool;
	private var _containers:Dictionary;
	/**
	 * Container data object used for storing the parsed collada data structure.
	 */
	public var containerData:ContainerData;
	

	private function buildContainers(containerData:ContainerData, parent:ObjectContainer3D):Void {
		
		for (__i in 0...containerData.children.length) {
			var _objectData:ObjectData = containerData.children[__i];

			if (_objectData != null) {
				if (Std.is(_objectData, MeshData)) {
					buildMesh(cast(_objectData, MeshData), parent);
				} else if (Std.is(_objectData, BoneData)) {
					var _boneData:BoneData = cast(_objectData, BoneData);
					var bone:Bone = new Bone({name:_boneData.name});
					_boneData.container = cast(bone, ObjectContainer3D);
					_containers[untyped bone.name] = bone;
					//ColladaMaya 3.05B
					bone.id = _boneData.id;
					bone.transform = _boneData.transform;
					bone.joint.transform = _boneData.jointTransform;
					buildContainers(_boneData, bone.joint);
					parent.addChild(bone);
				} else if (Std.is(_objectData, ContainerData)) {
					var _containerData:ContainerData = cast(_objectData, ContainerData);
					var objectContainer:ObjectContainer3D = _containerData.container = new ObjectContainer3D({name:_containerData.name});
					_containers[untyped objectContainer.name] = objectContainer;
					objectContainer.transform = _objectData.transform;
					buildContainers(_containerData, objectContainer);
					if (centerMeshes && objectContainer.children.length) {
						objectContainer.movePivot(_moveVector.x = (objectContainer.maxX + objectContainer.minX) / 2, _moveVector.y = (objectContainer.maxY + objectContainer.minY) / 2, _moveVector.z = (objectContainer.maxZ + objectContainer.minZ) / 2);
						_moveVector.transform(_moveVector, _objectData.transform);
						objectContainer.moveTo(_moveVector.x, _moveVector.y, _moveVector.z);
					}
					parent.addChild(objectContainer);
				}
			}
		}

	}

	private function buildMesh(_meshData:MeshData, parent:ObjectContainer3D):Void {
		
		Debug.trace(" + Build Mesh : " + _meshData.name);
		var mesh:Mesh = new Mesh({name:_meshData.name});
		mesh.transform = _meshData.transform;
		mesh.bothsides = _meshData.geometry.bothsides;
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
							_faceData.materialData = symbolLibrary[untyped _meshMaterialData.symbol];
						}
					}

				}
			}

			if ((_geometryData.skinVertices.length > 0)) {
				var i:Int;
				var joints:Array<Dynamic>;
				var rootBone:Bone = (cast(container, ObjectContainer3D)).getBoneByName(_meshData.skeleton);
				geometry.skinVertices = _geometryData.skinVertices;
				geometry.skinControllers = _geometryData.skinControllers;
				//mesh.bone = container.getChildByName(_meshData.bone) as Bone;
				geometry.rootBone = rootBone;
				for (__i in 0...geometry.skinControllers.length) {
					_skinController = geometry.skinControllers[__i];

					if (_skinController != null) {
						_skinController.inverseTransform = parent.inverseSceneTransform;
					}
				}

			}
			var face:Face;
			var matData:MaterialData;
			for (__i in 0..._geometryData.faces.length) {
				_faceData = _geometryData.faces[__i];

				if (_faceData != null) {
					if ((_faceData.materialData != null)) {
						_faceMaterial = cast(_faceData.materialData.material, ITriangleMaterial);
					} else {
						_faceMaterial = null;
					}
					_face = new Face(_geometryData.vertices[_faceData.v0], _geometryData.vertices[_faceData.v1], _geometryData.vertices[_faceData.v2], _faceMaterial, _geometryData.uvs[_faceData.uv0], _geometryData.uvs[_faceData.uv1], _geometryData.uvs[_faceData.uv2]);
					geometry.addFace(_face);
					if ((_faceData.materialData != null)) {
						_faceData.materialData.elements.push(_face);
					}
				}
			}

		} else {
			mesh.geometry = geometry;
		}
		if (centerMeshes) {
			mesh.movePivot(_moveVector.x = (_geometryData.maxX + _geometryData.minX) / 2, _moveVector.y = (_geometryData.maxY + _geometryData.minY) / 2, _moveVector.z = (_geometryData.maxZ + _geometryData.minZ) / 2);
			_moveVector.transform(_moveVector, _meshData.transform);
			mesh.moveTo(_moveVector.x, _moveVector.y, _moveVector.z);
		}
		mesh.type = ".Collada";
		parent.addChild(mesh);
	}

	private function buildMaterials():Void {
		
		var __keys:Iterator<Dynamic> = untyped (__keys__(materialLibrary)).iterator();
		for (__key in __keys) {
			_materialData = materialLibrary[untyped __key];

			if (_materialData != null) {
				Debug.trace(" + Build Material : " + _materialData.name);
				//overridden by the material property in constructor
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
						_materialData.material = new ShadingColorMaterial(null, {ambient:_materialData.ambientColor, diffuse:_materialData.diffuseColor, specular:_materialData.specularColor, shininess:_materialData.shininess});
					case MaterialData.COLOR_MATERIAL :
						_materialData.material = new ColorMaterial(_materialData.diffuseColor);
					case MaterialData.WIREFRAME_MATERIAL :
						_materialData.material = new WireColorMaterial();
					

				}
			}
		}

	}

	private function buildAnimations():Void {
		
		var bone:Bone;
		var __keys:Iterator<Dynamic> = untyped (__keys__(geometryLibrary)).iterator();
		for (__key in __keys) {
			_geometryData = geometryLibrary[untyped __key];

			if (_geometryData != null) {
				for (__i in 0..._geometryData.geometry.skinControllers.length) {
					_skinController = _geometryData.geometry.skinControllers[__i];

					if (_skinController != null) {
						bone = (cast(container, ObjectContainer3D)).getBoneByName(_skinController.name);
						if ((bone != null)) {
							_skinController.joint = bone.joint;
						} else {
							Debug.warning("no joint found for " + _skinController.name);
						}
					}
				}

			}
		}

		var __keys:Iterator<Dynamic> = untyped (__keys__(animationLibrary)).iterator();
		for (__key in __keys) {
			_animationData = animationLibrary[untyped __key];

			if (_animationData != null) {
				switch (_animationData.animationType) {
					case AnimationData.SKIN_ANIMATION :
						var animation:SkinAnimation = new SkinAnimation();
						var param:Array<Dynamic>;
						var rX:String;
						var rY:String;
						var rZ:String;
						var sX:String;
						var sY:String;
						var sZ:String;
						var __keys:Iterator<Dynamic> = untyped (__keys__(_animationData.channels)).iterator();
						for (__key in __keys) {
							var channelData:ChannelData = _animationData.channels[untyped __key];

							if (channelData != null) {
								var channel:Channel = channelData.channel;
								channel.target = _containers[untyped channel.name];
								animation.appendChannel(channel);
								var times:Array<Dynamic> = channel.times;
								if (_animationData.start > times[0]) {
									_animationData.start = times[0];
								}
								if (_animationData.end < times[times.length - 1]) {
									_animationData.end = times[times.length - 1];
								}
								if (Std.is(channel.target, Bone)) {
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
								switch (channelData.type) {
									case "translateX" :
										channel.type = ["x"];
										if (yUp) {
											for (__i in 0...channel.param.length) {
												param = channel.param[__i];

												if (param != null) {
													param[0] *= -1 * scaling;
												}
											}

										}
									case "translateY" :
										if (yUp) {
											channel.type = ["y"];
										} else {
											channel.type = ["z"];
										}
										for (__i in 0...channel.param.length) {
											param = channel.param[__i];

											if (param != null) {
												param[0] *= scaling;
											}
										}

									case "translateZ" :
										if (yUp) {
											channel.type = ["z"];
										} else {
											channel.type = ["y"];
										}
										for (__i in 0...channel.param.length) {
											param = channel.param[__i];

											if (param != null) {
												param[0] *= scaling;
											}
										}

									case "jointOrientX" :
										channel.type = ["rotationX"];
										if (yUp) {
											for (__i in 0...channel.param.length) {
												param = channel.param[__i];

												if (param != null) {
													param[0] *= -1;
												}
											}

										}
									case "rotateX" :
									case "RotX" :
										channel.type = [rX];
										if (yUp) {
											for (__i in 0...channel.param.length) {
												param = channel.param[__i];

												if (param != null) {
													param[0] *= -1;
												}
											}

										}
									case "jointOrientY" :
										channel.type = ["rotationY"];
										//if (yUp)
										for (__i in 0...channel.param.length) {
											param = channel.param[__i];

											if (param != null) {
												param[0] *= -1;
											}
										}

									case "rotateY" :
									case "RotY" :
										if (yUp) {
											channel.type = [rY];
										} else {
											channel.type = [rZ];
										}
										//if (yUp)
										for (__i in 0...channel.param.length) {
											param = channel.param[__i];

											if (param != null) {
												param[0] *= -1;
											}
										}

									case "jointOrientZ" :
										channel.type = ["rotationZ"];
										//if (yUp)
										for (__i in 0...channel.param.length) {
											param = channel.param[__i];

											if (param != null) {
												param[0] *= -1;
											}
										}

									case "rotateZ" :
									case "RotZ" :
										if (yUp) {
											channel.type = [rZ];
										} else {
											channel.type = [rY];
										}
										//if (yUp)
										for (__i in 0...channel.param.length) {
											param = channel.param[__i];

											if (param != null) {
												param[0] *= -1;
											}
										}

									case "scaleX" :
										channel.type = [sX];
									case "scaleY" :
										if (yUp) {
											channel.type = [sY];
										} else {
											channel.type = [sZ];
										}
									case "scaleZ" :
										if (yUp) {
											channel.type = [sZ];
										} else {
											channel.type = [sY];
										}
									case "translate" :
									case "translation" :
										if (yUp) {
											channel.type = ["x", "y", "z"];
											for (__i in 0...channel.param.length) {
												param = channel.param[__i];

												if (param != null) {
													param[0] *= -1;
												}
											}

										} else {
											channel.type = ["x", "z", "y"];
										}
										for (__i in 0...channel.param.length) {
											param = channel.param[__i];

											if (param != null) {
												param[0] *= scaling;
												param[1] *= scaling;
												param[2] *= scaling;
											}
										}

									case "scale" :
										if (yUp) {
											channel.type = [sX, sY, sZ];
										} else {
											channel.type = [sX, sZ, sY];
										}
									case "rotate" :
										if (yUp) {
											channel.type = [rX, rY, rZ];
											for (__i in 0...channel.param.length) {
												param = channel.param[__i];

												if (param != null) {
													param[0] *= -1;
													param[1] *= -1;
													param[2] *= -1;
												}
											}

										} else {
											channel.type = [rX, rZ, rY];
											for (__i in 0...channel.param.length) {
												param = channel.param[__i];

												if (param != null) {
													param[1] *= -1;
													param[2] *= -1;
												}
											}

										}
									case "transform" :
										channel.type = ["transform"];
									

								}
							}
						}

						animation.start = _animationData.start;
						animation.length = _animationData.end - _animationData.start;
						_animationData.animation = animation;
					case AnimationData.VERTEX_ANIMATION :
					

				}
			}
		}

	}

	private function getArray(spaced:String):Array<Dynamic> {
		
		spaced = spaced.split("\r\n").join(" ");
		var strings:Array<Dynamic> = spaced.split(" ");
		var numbers:Array<Dynamic> = [];
		var totalStrings:Float = strings.length;
		var i:Float = 0;
		while (i < totalStrings) {
			if (strings[i] != "") {
				numbers.push((strings[i]));
			}
			
			// update loop variables
			i++;
		}

		return numbers;
	}

	private function rotateMatrix(vector:Array<Dynamic>):Matrix3D {
		
		if (yUp) {
			rotationMatrix.rotationMatrix(vector[0], -vector[1], -vector[2], vector[3] * toRADIANS);
		} else {
			rotationMatrix.rotationMatrix(vector[0], vector[2], vector[1], -vector[3] * toRADIANS);
		}
		return rotationMatrix;
	}

	private function translateMatrix(vector:Array<Dynamic>):Matrix3D {
		
		if (yUp) {
			translationMatrix.translationMatrix(-vector[0] * scaling, vector[1] * scaling, vector[2] * scaling);
		} else {
			translationMatrix.translationMatrix(vector[0] * scaling, vector[2] * scaling, vector[1] * scaling);
		}
		return translationMatrix;
	}

	private function scaleMatrix(vector:Array<Dynamic>):Matrix3D {
		
		if (yUp) {
			scalingMatrix.scaleMatrix(vector[0], vector[1], vector[2]);
		} else {
			scalingMatrix.scaleMatrix(vector[0], vector[2], vector[1]);
		}
		return scalingMatrix;
	}

	private function getId(url:String):String {
		
		return url.split("#")[1];
	}

	/**
	 * Creates a new <code>Collada</code> object. Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods.
	 *
	 * @param	xml				The xml data of a loaded file.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 *
	 * @see away3d.loaders.Collada#parse()
	 * @see away3d.loaders.Collada#load()
	 */
	public function new(data:Dynamic, ?init:Dynamic=null) {
		// autogenerated
		super();
		this.toRADIANS = Math.PI / 180;
		this._moveVector = new Number3D();
		this.rotationMatrix = new Matrix3D();
		this.scalingMatrix = new Matrix3D();
		this.translationMatrix = new Matrix3D();
		this.VALUE_U = "S";
		this.VALUE_V = "T";
		this._haveAnimation = false;
		this._haveClips = false;
		this._containers = new Dictionary(true);
		
		
		collada = Cast.xml(data);
		ini = Init.parse(init);
		texturePath = ini.getString("texturePath", "");
		autoLoadTextures = ini.getBoolean("autoLoadTextures", true);
		scaling = ini.getNumber("scaling", 1) * 100;
		shading = ini.getBoolean("shading", false);
		material = cast(ini.getMaterial("material"), ITriangleMaterial);
		centerMeshes = ini.getBoolean("centerMeshes", false);
		var materials:Dynamic = ini.getObject("materials");
		if (materials == null)  {
			materials = {};
		};
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
	public static function parse(data:Dynamic, ?init:Dynamic=null):ObjectContainer3D {
		
		return cast(Object3DLoader.parseGeometry(data, Collada, init).handle, ObjectContainer3D);
	}

	/**
	 * Loads and parses a collada file into a 3d container object.
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
				init.texturePath = (init.texturePath != null) ? init.texturePath : _texturePath;
			} else {
				init = {texturePath:_texturePath};
			}
		}
		return Object3DLoader.loadGeometry(url, Collada, false, init);
	}

	/**
	 * @inheritDoc
	 */
	public override function parseNext():Void {
		
		if (_parsedChunks < _geometryArrayLength) {
			parseGeometry(_geometryArray[_parsedChunks]);
		} else {
			parseChannel(_channelArray[-_geometryArrayLength + _parsedChunks]);
		}
		_parsedChunks++;
		if (_parsedChunks == _totalChunks) {
			buildMaterials();
			//build the containers
			buildContainers(containerData, cast(container, ObjectContainer3D));
			//build the meshes
			//buildMeshes(containerData, container as ObjectContainer3D);
			//build animations
			buildAnimations();
			notifySuccess();
		} else {
			notifyProgress();
		}
	}

	private function parseCollada():Void {
		
		// default xml namespace = collada.namespace();
		Debug.trace(" ! ------------- Begin Parse Collada -------------");
		// Get up axis
		yUp = (collada.asset.up_axis == "Y_UP") || (Std.string(collada.asset.up_axis) == "");
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
	private function parseScene():Void {
		
		var scene:Xml = collada.library_visual_scenes.visual_scene.(@id == getId(collada.scene.instance_visual_scene.@url))[0];
		if (scene == null) {
			Debug.trace(" ! ------------- No scene to parse -------------");
			return;
		}
		Debug.trace(" ! ------------- Begin Parse Scene -------------");
		containerData = new ContainerData();
		for (__i in 0...scene.node.length) {
			var node:Xml = scene.node[__i];

			if (node != null) {
				parseNode(node, containerData);
			}
		}

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
	private function parseNode(node:Xml, parent:ContainerData):Void {
		
		var _transform:Matrix3D;
		var _objectData:ObjectData;
		var _name:String = node.name().localName;
		if (Std.string(node.instance_light.@url) != "" || Std.string(node.instance_camera.@url) != "") {
			return;
		}
		if (Std.string(node.instance_controller) == "" && Std.string(node.instance_geometry) == "") {
			if (Std.string(node.@type) == "JOINT") {
				_objectData = new BoneData();
			} else {
				if (Std.string(node.instance_node.@url) == "" && (Std.string(node.node) == "" || Std.is(parent, BoneData))) {
					return;
				}
				_objectData = new ContainerData();
			}
		} else {
			_objectData = new MeshData();
		}
		parent.children.push(_objectData);
		//ColladaMaya 3.05B
		if (Std.string(node.@type) == "JOINT") {
			_objectData.id = node.@sid;
		} else {
			_objectData.id = node.@id;
		}
		//ColladaMaya 3.02
		_objectData.name = node.@id;
		_transform = _objectData.transform;
		Debug.trace(" + Parse Node : " + _objectData.id + " : " + _objectData.name);
		var geo:Xml;
		var ctrlr:Xml;
		var sid:String;
		var instance_material:Xml;
		var arrayChild:Array<Dynamic>;
		var boneData:BoneData = (cast(_objectData, BoneData));
		for (__i in 0...node.children().length) {
			var childNode:Xml = node.children()[__i];

			if (childNode != null) {
				arrayChild = getArray(childNode);
				switch (childNode.name().localName) {
					case "translate" :
						_transform.multiply(_transform, translateMatrix(arrayChild));
					case "rotate" :
						sid = childNode.@sid;
						if (Std.is(_objectData, BoneData) && (sid == "rotateX" || sid == "rotateY" || sid == "rotateZ" || sid == "rotX" || sid == "rotY" || sid == "rotZ")) {
							boneData.jointTransform.multiply(boneData.jointTransform, rotateMatrix(arrayChild));
						} else {
							_transform.multiply(_transform, rotateMatrix(arrayChild));
						}
					case "scale" :
						if (Std.is(_objectData, BoneData)) {
							boneData.jointTransform.multiply(boneData.jointTransform, scaleMatrix(arrayChild));
						} else {
							_transform.multiply(_transform, scaleMatrix(arrayChild));
						}
					case "matrix" :
						var m:Matrix3D = new Matrix3D();
						m.array2matrix(arrayChild, yUp, scaling);
						_transform.multiply(_transform, m);
					case "node" :
						//3dsMax 11 - Feeling ColladaMax v3.05B
						//<node><node/></node>
						if (Std.is(_objectData, MeshData)) {
							parseNode(childNode, cast(parent, ContainerData));
						} else {
							parseNode(childNode, cast(_objectData, ContainerData));
						}
					case "instance_node" :
						parseNode(collada.library_nodes.node.(@id == getId(childNode.@url))[0], cast(_objectData, ContainerData));
					case "instance_geometry" :
						if (Std.string(childNode).indexOf("lines") == -1) {
							for (__i in 0...childNode .. instance_material.length) {
								instance_material = childNode .. instance_material[__i];

								if (instance_material != null) {
									parseMaterial(instance_material.@symbol, getId(instance_material.@target));
								}
							}

							geo = collada.library_geometries.geometry.(@id == getId(childNode.@url))[0];
							(cast(_objectData, MeshData)).geometry = geometryLibrary.addGeometry(geo.@id, geo);
						}
					case "instance_controller" :
						//add materials to materialLibrary
						for (__i in 0...childNode .. instance_material.length) {
							instance_material = childNode .. instance_material[__i];

							if (instance_material != null) {
								parseMaterial(instance_material.@symbol, getId(instance_material.@target));
							}
						}

						ctrlr = collada.library_controllers.controller.(@id == getId(childNode.@url))[0];
						geo = collada.library_geometries.geometry.(@id == getId(ctrlr.skin[0].@source))[0];
						(cast(_objectData, MeshData)).geometry = geometryLibrary.addGeometry(geo.@id, geo, ctrlr);
						(cast(_objectData, MeshData)).skeleton = getId(childNode.skeleton);
					

				}
			}
		}

	}

	/**
	 * Converts a material definition to a MaterialData object
	 * 
	 * @see away3d.loaders.data.MaterialData
	 */
	private function parseMaterial(symbol:String, name:String):Void {
		
		_materialData = materialLibrary.addMaterial(name);
		symbolLibrary[untyped symbol] = _materialData;
		if (symbol == "FrontColorNoCulling") {
			_materialData.materialType = MaterialData.SHADING_MATERIAL;
		} else {
			_materialData.textureFileName = getTextureFileName(name);
			if ((_materialData.textureFileName != null)) {
				_materialData.materialType = MaterialData.TEXTURE_MATERIAL;
			} else {
				if (shading) {
					_materialData.materialType = MaterialData.SHADING_MATERIAL;
				} else {
					_materialData.materialType = MaterialData.COLOR_MATERIAL;
				}
				parseColorMaterial(name, _materialData);
			}
		}
	}

	/**
	 * Parses geometry data.
	 * 
	 * @see away3d.loaders.data.GeometryData
	 */
	private function parseGeometry(geometryData:GeometryData):Void {
		
		Debug.trace(" + Parse Geometry : " + geometryData.name);
		var verticesDictionary:Dictionary = new Dictionary(true);
		// Triangles
		for (__i in 0...geometryData.geoXML.mesh.triangles.length) {
			var triangles:Xml = geometryData.geoXML.mesh.triangles[__i];

			if (triangles != null) {
				var field:Array<Dynamic> = [];
				for (__i in 0...triangles.input.length) {
					var input:Xml = triangles.input[__i];

					if (input != null) {
						var semantic:String = input.@semantic;
						switch (semantic) {
							case "VERTEX" :
								deserialize(input, geometryData.geoXML, Vertex, geometryData.vertices);
							case "TEXCOORD" :
								deserialize(input, geometryData.geoXML, UV, geometryData.uvs);
							default :
							

						}
						field.push(input.@semantic);
					}
				}

				var data:Array<Dynamic> = triangles.p.split(' ');
				var len:Float = triangles.@count;
				var symbol:String = triangles.@material;
				Debug.trace(" + Parse MeshMaterialData");
				_meshMaterialData = new MeshMaterialData();
				_meshMaterialData.symbol = symbol;
				geometryData.materials.push(_meshMaterialData);
				//if (!materialLibrary[material])
				//	parseMaterial(material, material);
				var j:Float = 0;
				while (j < len) {
					var _faceData:FaceData = new FaceData();
					var vn:Float = 0;
					while (vn < 3) {
						for (__i in 0...field.length) {
							var fld:String = field[__i];

							if (fld != null) {
								switch (fld) {
									case "VERTEX" :
										Reflect.setField(_faceData, "v" + vn, data.shift());
									case "TEXCOORD" :
										Reflect.setField(_faceData, "uv" + vn, data.shift());
									default :
										data.shift();
									

								}
							}
						}

						
						// update loop variables
						vn++;
					}

					//trace(_faceData.v0);
					verticesDictionary[untyped _faceData.v0] = geometryData.vertices[_faceData.v0];
					verticesDictionary[untyped _faceData.v1] = geometryData.vertices[_faceData.v1];
					verticesDictionary[untyped _faceData.v2] = geometryData.vertices[_faceData.v2];
					_meshMaterialData.faceList.push(geometryData.faces.length);
					geometryData.faces.push(_faceData);
					
					// update loop variables
					j++;
				}

			}
		}

		//center vertex points in mesh for better bounding radius calulations
		if (centerMeshes) {
			geometryData.maxX = -Math.POSITIVE_INFINITY;
			geometryData.minX = Math.POSITIVE_INFINITY;
			geometryData.maxY = -Math.POSITIVE_INFINITY;
			geometryData.minY = Math.POSITIVE_INFINITY;
			geometryData.maxZ = -Math.POSITIVE_INFINITY;
			geometryData.minZ = Math.POSITIVE_INFINITY;
			var __keys:Iterator<Dynamic> = untyped (__keys__(verticesDictionary)).iterator();
			for (__key in __keys) {
				_vertex = verticesDictionary[untyped __key];

				if (_vertex != null) {
					if (geometryData.maxX < _vertex._x) {
						geometryData.maxX = _vertex._x;
					}
					if (geometryData.minX > _vertex._x) {
						geometryData.minX = _vertex._x;
					}
					if (geometryData.maxY < _vertex._y) {
						geometryData.maxY = _vertex._y;
					}
					if (geometryData.minY > _vertex._y) {
						geometryData.minY = _vertex._y;
					}
					if (geometryData.maxZ < _vertex._z) {
						geometryData.maxZ = _vertex._z;
					}
					if (geometryData.minZ > _vertex._z) {
						geometryData.minZ = _vertex._z;
					}
				}
			}

		}
		// Double Side
		if (Std.string(geometryData.geoXML.extra.technique.double_sided) != "") {
			geometryData.bothsides = (geometryData.geoXML.extra.technique.double_sided[0].toString() == "1");
		} else {
			geometryData.bothsides = false;
		}
		//parse controller
		if (!geometryData.ctrlXML) {
			return;
		}
		var skin:Xml = geometryData.ctrlXML.skin[0];
		var jointId:String = getId(skin.joints.input.(@semantic == "JOINT")[0].@source);
		var tmp:String = skin.source.(@id == jointId).Name_array.toString();
		//Blender?
		if (tmp == null) {
			tmp = skin.source.(@id == jointId).IDREF_array.toString();
		}
		tmp = tmp.replace(/\n/g, " ");
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
		while (i < float_array.length) {
			name = nameArray[i / 16];
			matrix = new Matrix3D();
			matrix.array2matrix(float_array.slice(i, i + 16), yUp, scaling);
			matrix.multiply(matrix, bind_shape);
			geometryData.skinControllers.push(skinController = new SkinController());
			skinController.name = name;
			skinController.bindMatrix = matrix;
			i = i + 16;
		}

		Debug.trace(" + SkinWeight");
		tmp = skin.vertex_weights[0].@count;
		var num_weights:Int = Std.int(skin.vertex_weights[0].@count);
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
		i = 0;
		while (i < geometryData.vertices.length) {
			c = Std.int(vcount[i]);
			skinVertex = new SkinVertex(geometryData.vertices[i]);
			geometryData.skinVertices.push(skinVertex);
			j = 0;
			while (j < c) {
				skinVertex.controllers.push(geometryData.skinControllers[Std.int(v[count])]);
				count++;
				skinVertex.weights.push((weights[Std.int(v[count])]));
				count++;
				j++;
			}

			i++;
		}

	}

	/**
	 * Detects and parses all animation clips
	 */
	private function parseAnimationClips():Void {
		//Check for animations
		
		var anims:Xml = collada.library_animations[0];
		if (!anims) {
			Debug.trace(" ! ------------- No animations to parse -------------");
			return;
		}
		//Check to see if animation clips exist
		var clips:Xml = collada.library_animation_clips[0];
		Debug.trace(" ! Animation Clips Exist : " + _haveClips);
		Debug.trace(" ! ------------- Begin Parse Animation -------------");
		//loop through all animation channels
		for (__i in 0...anims.animation.length) {
			var channel:Xml = anims.animation[__i];

			if (channel != null) {
				channelLibrary.addChannel(channel.@id, channel);
			}
		}

		if (clips) {
			for (__i in 0...clips.animation_clip.length) {
				var clip:Xml = clips.animation_clip[__i];

				if (clip != null) {
					parseAnimationClip(clip);
				}
			}

		}
		//create default animation clip
		_defaultAnimationClip = animationLibrary.addAnimation("default");
		var __keys:Iterator<Dynamic> = untyped (__keys__(channelLibrary)).iterator();
		for (__key in __keys) {
			var channelData:ChannelData = channelLibrary[untyped __key];

			if (channelData != null) {
				_defaultAnimationClip.channels[untyped channelData.name] = channelData;
			}
		}

		Debug.trace(" ! ------------- End Parse Animation -------------");
		_channelArray = channelLibrary.getChannelArray();
		_channelArrayLength = _channelArray.length;
		_totalChunks += _channelArrayLength;
	}

	private function parseAnimationClip(clip:Xml):Void {
		
		var animationClip:AnimationData = animationLibrary.addAnimation(clip.@id);
		for (__i in 0...clip.instance_animation.length) {
			var channel:Xml = clip.instance_animation[__i];

			if (channel != null) {
				animationClip.channels[untyped (DictionaryUtils.__castVar = getId(channel.@url))] = channelLibrary[untyped (DictionaryUtils.__castVar = getId(channel.@url))];
			}
		}

	}

	private function parseChannel(channelData:ChannelData):Void {
		
		var node:Xml = channelData.xml;
		var id:String = node.channel.@target;
		var name:String = id.split("/")[0];
		var type:String = id.split("/")[1];
		var sampler:Xml = node.sampler[0];
		if (type == null) {
			Debug.trace(" ! No animation type detected");
			return;
		}
		type = type.split(".")[0];
		if (type == "image" || node.@id.split(".")[1] == "frameExtension") {
			Debug.trace(" ! Material animation not yet implemented");
			return;
		}
		var channel:Channel = channelData.channel = new Channel(name);
		var i:Int;
		var j:Int;
		_defaultAnimationClip.channels[untyped channelData.name] = channelData;
		Debug.trace(" ! channelType : " + type);
		for (__i in 0...sampler.input.length) {
			var input:Xml = sampler.input[__i];

			if (input != null) {
				var src:Xml = node.source.(@id == getId(input.@source))[0];
				var count:Int = Std.int(src.float_array.@count);
				var list:Array<Dynamic> = Std.string(src.float_array).split(" ");
				var len:Int = Std.int(src.technique_common.accessor.@count);
				var stride:Int = Std.int(src.technique_common.accessor.@stride);
				var semantic:String = input.@semantic;
				var p:String;
				var sign:Int = (type.charAt(type.length - 1) == "X") ? -1 : 1;
				switch (semantic) {
					case "INPUT" :
						for (__i in 0...list.length) {
							p = list[__i];

							if (p != null) {
								channel.times.push((p));
							}
						}

						if (_defaultAnimationClip.start > channel.times[0]) {
							_defaultAnimationClip.start = channel.times[0];
						}
						if (_defaultAnimationClip.end < channel.times[channel.times.length - 1]) {
							_defaultAnimationClip.end = channel.times[channel.times.length - 1];
						}
					case "OUTPUT" :
						i = 0;
						while (i < len) {
							channel.param[i] = new Array();
							if (stride == 16) {
								var m:Matrix3D = new Matrix3D();
								m.array2matrix(list.slice(i * stride, i * stride + 16), yUp, scaling);
								channel.param[i].push(m);
							} else {
								j = 0;
								while (j < stride) {
									channel.param[i].push((list[i * stride + j]));
									j++;
								}

							}
							i++;
						}

					case "INTERPOLATION" :
						for (__i in 0...list.length) {
							p = list[__i];

							if (p != null) {
								channel.interpolations.push(p);
							}
						}

					case "IN_TANGENT" :
						i = 0;
						while (i < len) {
							channel.inTangent[i] = new Array();
							j = 0;
							while (j < stride) {
								channel.inTangent[i].push(new Number2D((list[stride * i + j]), (list[stride * i + j + 1])));
								j++;
							}

							i++;
						}

					case "OUT_TANGENT" :
						i = 0;
						while (i < len) {
							channel.outTangent[i] = new Array();
							j = 0;
							while (j < stride) {
								channel.outTangent[i].push(new Number2D((list[stride * i + j]), (list[stride * i + j + 1])));
								j++;
							}

							i++;
						}

					

				}
			}
		}

		channelData.type = type;
	}

	/**
	 * Retrieves the filename of a material
	 */
	private function getTextureFileName(name:String):String {
		
		var filename:String = null;
		var material:Xml = collada.library_materials.material.(@id == name)[0];
		if (material) {
			var effectId:String = getId(material.instance_effect.@url);
			var effect:Xml = collada.library_effects.effect.(@id == effectId)[0];
			if (effect .. texture.length() == 0) {
				return null;
			}
			var textureId:String = effect .. texture[0].@texture;
			var sampler:Xml = effect .. newparam.(@sid == textureId)[0];
			// Blender
			var imageId:String = textureId;
			// Not Blender
			if (sampler) {
				var sourceId:String = sampler .. source[0];
				var source:Xml = effect .. newparam.(@sid == sourceId)[0];
				imageId = source .. init_from[0];
			}
			var image:Xml = collada.library_images.image.(@id == imageId)[0];
			filename = image.init_from;
			if (filename.substr(0, 2) == "./") {
				filename = filename.substr(2);
			}
		}
		return filename;
	}

	/**
	 * Retrieves the color of a material
	 */
	private function parseColorMaterial(cname:String, materialData:MaterialData):Void {
		
		var material:Xml = collada.library_materials.material.(@id == cname)[0];
		if (material) {
			var effectId:String = getId(material.instance_effect.@url);
			var effect:Xml = collada.library_effects.effect.(@id == effectId)[0];
			materialData.ambientColor = getColorValue(effect .. ambient[0]);
			materialData.diffuseColor = getColorValue(effect .. diffuse[0]);
			materialData.specularColor = getColorValue(effect .. specular[0]);
			materialData.shininess = (effect .. shininess.float[0]);
		}
	}

	private function getColorValue(color:Xml):Int {
		
		if (!color || color.length() == 0) {
			return 0xFFFFFF;
		}
		var colorArray:Array<Dynamic> = color.color.split(" ");
		return Std.int(colorArray[0] * 255 << 16) | Std.int(colorArray[1] * 255 << 8) | Std.int(colorArray[2] * 255);
	}

	/**
	 * Converts a data string to an array of objects. Handles vertex and uv objects
	 */
	private function deserialize(input:Xml, geo:Xml, VObject:Class, output:Array<Dynamic>):Array<Dynamic> {
		
		var id:String = input.@source.split("#")[1];
		// Source?
		var acc:XMLList = geo .. source.(@id == id).technique_common.accessor;
		if (acc != new XMLList()) {
			var floId:String = acc.@source.split("#")[1];
			var floXML:XMLList = collada .. float_array.(@id == floId);
			var floStr:String = floXML.toString();
			var floats:Array<Dynamic> = getArray(floStr);
			var float:Float;
			// Build params array
			var params:Array<Dynamic> = [];
			var param:String;
			for (__i in 0...acc.param.length) {
				var par:Xml = acc.param[__i];

				if (par != null) {
					params.push(par.@name);
				}
			}

			// Build output array
			var count:Int = acc.@count;
			var stride:Int = acc.@stride;
			var len:Int = floats.length;
			var i:Int = 0;
			while (i < len) {
				var element:ValueObject = Type.createInstance(VObject, []);
				if (Std.is(element, Vertex)) {
					var vertex:Vertex = cast(element, Vertex);
					for (__i in 0...params.length) {
						param = params[__i];

						if (param != null) {
							float = floats[i];
							switch (param) {
								case VALUE_X :
									if (yUp) {
										vertex._x = -float * scaling;
									} else {
										vertex._x = float * scaling;
									}
								case VALUE_Y :
									vertex._y = float * scaling;
								case VALUE_Z :
									vertex._z = float * scaling;
								default :
								

							}
							i++;
						}
					}

				} else if (Std.is(element, UV)) {
					var uv:UV = cast(element, UV);
					for (__i in 0...params.length) {
						param = params[__i];

						if (param != null) {
							float = floats[i];
							switch (param) {
								case VALUE_U :
									uv._u = float;
								case VALUE_V :
									uv._v = float;
								default :
								

							}
							i++;
						}
					}

				}
				output.push(element);
			}

		} else {
			var recursive:XMLList = geo .. vertices.(@id == id)["input"];
			output = deserialize(Reflect.field(recursive, 0), geo, VObject, output);
		}
		return output;
	}

}

