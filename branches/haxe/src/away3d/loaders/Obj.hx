package away3d.loaders;

import away3d.haxeutils.Error;
import away3d.containers.ObjectContainer3D;
import away3d.materials.BitmapFileMaterial;
import away3d.core.utils.ValueObject;
import flash.events.ProgressEvent;
import flash.events.Event;
import away3d.core.base.Face;
import flash.events.SecurityErrorEvent;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import away3d.core.utils.Cast;
import away3d.core.utils.Init;
import flash.net.URLLoader;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import flash.net.URLRequest;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * File loader for the OBJ file format.<br/>
 * <br/>
 * note: Multiple objects support and autoload mtls are supported since Away v 2.1.<br/>
 * Class tested with the following 3D apps:<br/>
 * - Strata CX mac 5.5<br/>
 * - Biturn ver 0.87b4 PC<br/>
 * - LightWave 3D OBJ Export v2.1 PC<br/>
 * - Max2Obj Version 4.0 PC<br/>
 * - AC3D 6.2.025 mac<br/>
 * - Carrara (file provided)<br/>
 * - Hexagon (file provided)<br/>
 * - geometry supported tags: f,v,vt, g<br/>
 * - geometry unsupported tags:vn,ka, kd r g b, kd, ks r g b,ks,ke r g b,ke,d alpha,d,tr alpha,tr,ns s,ns,illum n,illum,map_Ka,map_Bump<br/>
 * - mtl unsupported tags: kd,ka,ks,ns,tr<br/> 
 * <br/>
 * export from apps as polygon group or mesh as .obj file.<br/>
 * added support for 3dmax negative vertexes references
 */
class Obj extends AbstractParser  {
	
	private var ini:Init;
	public var mesh:Mesh;
	private var mtlPath:String;
	private var aMeshes:Array<Dynamic>;
	private var aSources:Array<Dynamic>;
	private var aMats:Array<Dynamic>;
	private var vertices:Array<Dynamic>;
	private var uvs:Array<Dynamic>;
	private var scaling:Float;
	

	private function parseObj(data:String):Void {
		
		var lines:Array<Dynamic> = data.split('\n');
		var trunk:Array<Dynamic>;
		var isNew:Bool = true;
		var group:ObjectContainer3D;
		vertices = [new Vertex()];
		uvs = [new UV()];
		var isNeg:Bool;
		var myPattern:EReg = new RegExp("-", "g");
		var face0:Array<Dynamic>;
		var face1:Array<Dynamic>;
		var face2:Array<Dynamic>;
		var face3:Array<Dynamic>;
		for (__i in 0...lines.length) {
			var line:String = lines[__i];

			if (line != null) {
				trunk = line.replace("  ", " ").replace("  ", " ").replace("  ", " ").split(" ");
				switch (trunk[0]) {
					case "g" :
						group = new ObjectContainer3D();
						group.name = trunk[1];
						if (container == null) {
							if (aMeshes.length == 1) {
								container = new ObjectContainer3D(aMeshes[0].mesh);
							} else {
								container = new ObjectContainer3D();
							}
						}
						(cast(container, ObjectContainer3D)).addChild(group);
						isNew = true;
					case "usemtl" :
						aMeshes[aMeshes.length - 1].materialid = trunk[1];
					case "v" :
						if (isNew) {
							generateNewMesh();
							isNew = false;
							if (group != null) {
								group.addChild(mesh);
							}
						}
						vertices.push(new Vertex(-Std.parseFloat(trunk[1]) * scaling, Std.parseFloat(trunk[2]) * scaling, -Std.parseFloat(trunk[3]) * scaling));
					case "vt" :
						uvs.push(new UV(Std.parseFloat(trunk[1]), Std.parseFloat(trunk[2])));
					case "f" :
						isNew = true;
						if (trunk[1].indexOf("-") == -1) {
							face0 = trysplit(trunk[1], "/");
							face1 = trysplit(trunk[2], "/");
							face2 = trysplit(trunk[3], "/");
							if (trunk[4] != null) {
								face3 = trysplit(trunk[4], "/");
							} else {
								face3 = null;
							}
							isNeg = false;
						} else {
							face0 = trysplit(trunk[1].replace(myPattern, ""), "/");
							face1 = trysplit(trunk[2].replace(myPattern, ""), "/");
							face2 = trysplit(trunk[3].replace(myPattern, ""), "/");
							if (trunk[4] != null) {
								face3 = trysplit(trunk[4].replace(myPattern, ""), "/");
							} else {
								face3 = null;
							}
							isNeg = true;
						}
						try {
							if (face3 != null && face3.length > 0 && !Math.isNaN(Std.parseInt(face3[0]))) {
								if (isNeg) {
									mesh.addFace(new Face(vertices[vertices.length - Std.parseInt(face1[0])], vertices[vertices.length - Std.parseInt(face0[0])], vertices[vertices.length - Std.parseInt(face3[0])], null, checkUV(1, uvs[uvs.length - Std.parseInt(face1[1])]), checkUV(2, uvs[uvs.length - Std.parseInt(face0[1])]), checkUV(3, uvs[uvs.length - Std.parseInt(face3[1])])));
									mesh.addFace(new Face(vertices[vertices.length - Std.parseInt(face2[0])], vertices[vertices.length - Std.parseInt(face1[0])], vertices[vertices.length - Std.parseInt(face3[0])], null, checkUV(1, uvs[uvs.length - Std.parseInt(face2[1])]), checkUV(2, uvs[uvs.length - Std.parseInt(face1[1])]), checkUV(3, uvs[uvs.length - Std.parseInt(face3[1])])));
								} else {
									mesh.addFace(new Face(vertices[Std.parseInt(face1[0])], vertices[Std.parseInt(face0[0])], vertices[Std.parseInt(face3[0])], null, checkUV(1, uvs[Std.parseInt(face1[1])]), checkUV(2, uvs[Std.parseInt(face0[1])]), checkUV(3, uvs[Std.parseInt(face3[1])])));
									mesh.addFace(new Face(vertices[Std.parseInt(face2[0])], vertices[Std.parseInt(face1[0])], vertices[Std.parseInt(face3[0])], null, checkUV(1, uvs[Std.parseInt(face2[1])]), checkUV(2, uvs[Std.parseInt(face1[1])]), checkUV(3, uvs[Std.parseInt(face3[1])])));
								}
							} else {
								if (isNeg) {
									mesh.addFace(new Face(vertices[vertices.length - Std.parseInt(face2[0])], vertices[vertices.length - Std.parseInt(face1[0])], vertices[vertices.length - Std.parseInt(face0[0])], null, checkUV(1, uvs[uvs.length - Std.parseInt(face2[1])]), checkUV(2, uvs[uvs.length - Std.parseInt(face1[1])]), checkUV(3, uvs[uvs.length - Std.parseInt(face0[1])])));
								} else {
									mesh.addFace(new Face(vertices[Std.parseInt(face2[0])], vertices[Std.parseInt(face1[0])], vertices[Std.parseInt(face0[0])], null, checkUV(1, uvs[Std.parseInt(face2[1])]), checkUV(2, uvs[Std.parseInt(face1[1])]), checkUV(3, uvs[Std.parseInt(face0[1])])));
								}
							}
						} catch (e:Error) {
							trace("Error while parsing obj file: unvalid face f " + face0 + "," + face1 + "," + face2 + "," + face3);
						}

					

				}
			}
		}

		vertices = null;
		uvs = null;
		if (container == null) {
			container = mesh;
		}
	}

	private function checkUV(id:Int, ?uv:UV=null):UV {
		
		if (uv == null) {
			switch (id) {
				case 1 :
					return new UV(0, 1);
				case 2 :
					return new UV(.5, 0);
				case 3 :
					return new UV(1, 1);
				

			}
		}
		return uv;
	}

	private static function trysplit(source:String, by:String):Array<Dynamic> {
		
		if (source == null) {
			return null;
		}
		if (source.indexOf(by) == -1) {
			return [source];
		}
		return source.split(by);
	}

	private function checkMtl(data:String):Void {
		
		var index:Int = data.indexOf("mtllib");
		if (index != -1) {
			aSources = [];
			loadMtl(parseUrl(index, data));
		}
	}

	private function errorMtl(event:Event):Void {
		
		trace("Obj MTL LOAD ERROR: unable to load .mtl file at " + mtlPath);
	}

	private function mtlProgress(event:Event):Void {
		//NOT BUILDED IN YET
		//trace( (event.target.bytesLoaded / event.target.bytesTotal) *100);
		
	}

	private function loadMtl(url:String):Void {
		
		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, parseMtl);
		loader.addEventListener(IOErrorEvent.IO_ERROR, errorMtl);
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorMtl);
		loader.addEventListener(ProgressEvent.PROGRESS, mtlProgress);
		loader.load(new URLRequest(mtlPath + url));
	}

	private function parseUrl(index:Float, data:String):String {
		
		return data.substr(index + 7, data.indexOf(".mtl") + 4 - index + 7);
	}

	private function parseMtl(event:Event):Void {
		
		var loader:URLLoader = URLLoader(event.target);
		var lines:Array<Dynamic> = event.target.data.split('\n');
		var trunk:Array<Dynamic>;
		var i:Int;
		var j:Int;
		var _face:Face;
		var mat:BitmapFileMaterial;
		aMats = [];
		for (__i in 0...lines.length) {
			var line:String = lines[__i];

			if (line != null) {
				trunk = line.split(" ");
				switch (trunk[0]) {
					case "newmtl" :
						aSources.push({material:null, materialid:trunk[1]});
					case "map_Kd" :
						mat = checkDoubleMaterials(mtlPath + trunk[1]);
						aSources[aSources.length - 1].material = mat;
					

					//aSources[aSources.length-1].material = new BitmapFileMaterial(baseUrl+trunk[1]);
				}
			}
		}

		j = 0;
		while (j < aMeshes.length) {
			i = 0;
			while (i < aSources.length) {
				if (aMeshes[j].materialid == aSources[i].materialid) {
					mat = aSources[i].material;
					for (__i in 0...aMeshes[j].mesh.faces.length) {
						_face = aMeshes[j].mesh.faces[__i];

						if (_face != null) {
							_face.material = mat;
						}
					}

				}
				
				// update loop variables
				++i;
			}

			
			// update loop variables
			++j;
		}

		aSources = null;
		aMats = null;
	}

	private function checkDoubleMaterials(url:String):BitmapFileMaterial {
		
		var mat:BitmapFileMaterial;
		var i:Int = 0;
		while (i < aMats.length) {
			if (aMats[i].url == url) {
				mat = aMats[i].material;
				aMats.push({url:url, material:mat});
				return mat;
			}
			
			// update loop variables
			++i;
		}

		mat = new BitmapFileMaterial(url.replace(String.fromCharCode(13), ""));
		aMats.push({url:url, material:mat});
		return mat;
	}

	private function generateNewMesh():Void {
		
		mesh = new Mesh(ini);
		mesh.name = "obj_" + aMeshes.length;
		mesh.type = "Obj";
		mesh.url = "External";
		if (aMeshes.length == 1 && container == null) {
			container = new ObjectContainer3D(aMeshes[0].mesh);
		}
		aMeshes.push({materialid:"", mesh:mesh});
		if (aMeshes.length > 1 || container != null) {
			(cast(container, ObjectContainer3D)).addChild(mesh);
		}
	}

	/**
	 * Creates a new <code>Obj</code> object. Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods.
	 * 
	 * @param	data				The binary data of a loaded file.
	 * @param	urlbase				The url of the .obj file, required to compose the url mtl adres and be able access the bitmap sources relative to mtl location.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 * 
	 * @see away3d.loaders.Obj#parse()
	 * @see away3d.loaders.Obj#load()
	 */
	public function new(data:Dynamic, ?init:Dynamic=null) {
		// autogenerated
		super();
		this.aMeshes = [];
		this.vertices = [];
		this.uvs = [];
		
		
		var dataString:String = Cast.string(data);
		ini = Init.parse(init);
		mtlPath = ini.getString("mtlPath", "");
		scaling = ini.getNumber("scaling", 1) * 10;
		parseObj(dataString);
		checkMtl(dataString);
	}

	/**
	 * Creates a 3d mesh object from the raw ascii data of a obj file.
	 * 
	 * @param	data				The ascii data of a loaded file.
	 * @param	init				[optional]	An initialisation object for specifying default instance properties.
	 * 
	 * @return						A 3d mesh object representation of the obj file.
	 */
	public static function parse(data:Dynamic, ?init:Dynamic=null):Object3D {
		
		return Object3DLoader.parseGeometry(data, Obj, init).handle;
	}

	/**
	 * Loads and parses a obj file into a 3d mesh object.
	 * 
	 * @param	url					The url location of the file to load.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.
	 */
	public static function load(url:String, ?init:Dynamic=null):Object3DLoader {
		//mtlPath as model folder
		
		if ((url != null)) {
			var _pathArray:Array<Dynamic> = url.split("/");
			var _imageName:String = _pathArray.pop();
			var _mtlPath:String = (_pathArray.length > 0) ? _pathArray.join("/") + "/" : _pathArray.join("/");
			if ((init != null)) {
				init.mtlPath = (init.mtlPath) ? init.mtlPath : _mtlPath;
			} else {
				init = {mtlPath:_mtlPath};
			}
		}
		return Object3DLoader.loadGeometry(url, Obj, false, init);
	}

}

