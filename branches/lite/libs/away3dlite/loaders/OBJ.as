package away3dlite.loaders
{
	import away3dlite.arcane;
	import away3dlite.containers.ObjectContainer3D;
	import away3dlite.core.base.Face;
	import away3dlite.core.base.Mesh;
	import away3dlite.core.base.Object3D;
	import away3dlite.materials.BitmapFileMaterial;
	import away3dlite.materials.Material;

	import flash.events.*;
	import flash.geom.Vector3D;
	import flash.net.*;
	import flash.utils.ByteArray;

	use namespace arcane;

	/**
	 * File loader for the OBJ file format.<br/>
	 * <br/>
	 * note: Multiple objects support and autoload mtls are supported since Away v 2.1.<br/>
	 * Class tested with the following 3D apps:<br/>
	 * - Strata CX mac 5.5<br/>
	 * - Biturn ver 0.87b4 PC<br/>
	 * - LightWave 3D OBJ Export v2.1 PC<br/>
	 * - Max2OBJ Version 4.0 PC<br/>
	 * - AC3D 6.2.025 mac<br/>
	 * - Carrara (file provided)<br/>
	 * - Hexagon (file provided)<br/>
	 * - LD3T (file provided)<br/>
	 * - geometry supported tags: f,v,vt, g<br/>
	 * - geometry unsupported tags:vn,ka, kd r g b, kd, ks r g b,ks,ke r g b,ke,d alpha,d,tr alpha,tr,ns s,ns,illum n,illum,map_Ka,map_Bump<br/>
	 * - mtl unsupported tags: kd,ka,ks,ns,tr<br/>
	 * <br/>
	 * export from apps as polygon group or mesh as .obj file.<br/>
	 * added support for 3dmax negative vertexes references
	 */
	public class OBJ extends Mesh
	{
		private var verticeDatas:Vector.<Vector3D>;
		private var uvs:Array = [];
		private var scaling:Number = 1;

		private var faceDatas:Vector.<Face>;
		private var container:Object3D;

		private var n:int = -1;

		private function parse(data:String):void
		{
			obj = String(data);

			var lines:Array = obj.split('\n');
			if (lines.length == 1)
				lines = obj.split(String.fromCharCode(13));
			var trunk:Array;
			var isNew:Boolean = true;
			var group:ObjectContainer3D;

			//vertices = [new Vertex()];
			faceDatas = new Vector.<Face>();
			verticeDatas = new Vector.<Vector3D>();
			verticeDatas[0] = new Vector3D();
			uvs = [new UV()];

			var isNeg:Boolean;
			var myPattern:RegExp = new RegExp("-", "g");
			var face0:Array;
			var face1:Array;
			var face2:Array;
			var face3:Array;

			for each (var line:String in lines)
			{
				trunk = line.replace("  ", " ").replace("  ", " ").replace("  ", " ").split(" ");

				switch (trunk[0])
				{
					case "g":
						group = new ObjectContainer3D();
						group.name = trunk[1];

						if (container == null)
						{
							if (aMeshes.length == 1)
							{
								container = new ObjectContainer3D(aMeshes[0].mesh);
							}
							else
							{
								container = new ObjectContainer3D();
							}
						}

						(container as ObjectContainer3D).addChild(group);
						isNew = true;

						break;

					case "usemtl":
						if (useMaterial)
							aMeshes[aMeshes.length - 1].materialid = trunk[1];

						break;

					case "v":
						if (isNew)
						{
							generateNewMesh();
							isNew = false;
							if (group != null)
							{
								group.addChild(mesh);
							}
						}

						verticeDatas.push(new Vector3D(-parseFloat(trunk[1]) * scaling, parseFloat(trunk[2]) * scaling, -parseFloat(trunk[3]) * scaling));

						break;

					case "vt":
						uvs.push(new UV(parseFloat(trunk[1]), 1 - parseFloat(trunk[2])));
						break;

					case "f":
						isNew = true;

						if (trunk[1].indexOf("-") == -1)
						{

							face0 = trysplit(trunk[1], "/");
							face1 = trysplit(trunk[2], "/");
							face2 = trysplit(trunk[3], "/");

							if (trunk[4] != null)
							{
								face3 = trysplit(trunk[4], "/");
							}
							else
							{
								face3 = null;
							}

							isNeg = false;

						}
						else
						{

							face0 = trysplit(trunk[1].replace(myPattern, ""), "/");
							face1 = trysplit(trunk[2].replace(myPattern, ""), "/");
							face2 = trysplit(trunk[3].replace(myPattern, ""), "/");

							if (trunk[4] != null)
							{
								face3 = trysplit(trunk[4].replace(myPattern, ""), "/");
							}
							else
							{
								face3 = null;
							}

							isNeg = true;
						}


						try
						{

							if (face3 != null && face3.length > 0 && !isNaN(parseInt(face3[0])))
							{
								if (isNeg)
								{
									_addFace(verticeDatas[verticeDatas.length - parseInt(face1[0])], verticeDatas[verticeDatas.length - parseInt(face0[0])], verticeDatas[verticeDatas.length - parseInt(face3[0])], checkUV(1, uvs[uvs.length - parseInt(face1[1])]), checkUV(2, uvs[uvs.length - parseInt(face0[1])]), checkUV(3, uvs[uvs.length - parseInt(face3[1])]));

									_addFace(verticeDatas[verticeDatas.length - parseInt(face2[0])], verticeDatas[verticeDatas.length - parseInt(face1[0])], verticeDatas[verticeDatas.length - parseInt(face3[0])], checkUV(1, uvs[uvs.length - parseInt(face2[1])]), checkUV(2, uvs[uvs.length - parseInt(face1[1])]), checkUV(3, uvs[uvs.length - parseInt(face3[1])]));
								}
								else
								{
									_addFace(verticeDatas[parseInt(face1[0])], verticeDatas[parseInt(face0[0])], verticeDatas[parseInt(face3[0])], checkUV(1, uvs[parseInt(face1[1])]), checkUV(2, uvs[parseInt(face0[1])]), checkUV(3, uvs[parseInt(face3[1])]));

									_addFace(verticeDatas[parseInt(face2[0])], verticeDatas[parseInt(face1[0])], verticeDatas[parseInt(face3[0])], checkUV(1, uvs[parseInt(face2[1])]), checkUV(2, uvs[parseInt(face1[1])]), checkUV(3, uvs[parseInt(face3[1])]));
								}

							}
							else
							{

								if (isNeg)
								{
									_addFace(verticeDatas[verticeDatas.length - parseInt(face2[0])], verticeDatas[verticeDatas.length - parseInt(face1[0])], verticeDatas[verticeDatas.length - parseInt(face0[0])], checkUV(1, uvs[uvs.length - parseInt(face2[1])]), checkUV(2, uvs[uvs.length - parseInt(face1[1])]), checkUV(3, uvs[uvs.length - parseInt(face0[1])]));
								}
								else
								{
									_addFace(verticeDatas[parseInt(face2[0])], verticeDatas[parseInt(face1[0])], verticeDatas[parseInt(face0[0])], checkUV(1, uvs[parseInt(face2[1])]), checkUV(2, uvs[parseInt(face1[1])]), checkUV(3, uvs[parseInt(face0[1])]));
								}
							}
						}
						catch (e:Error)
						{
							trace("Error while parsing obj file: unvalid face f " + face0 + "," + face1 + "," + face2 + "," + face3);
						}

						break;

				}
			}

			if (container == null)
				container = mesh;

			//check materials
			if (useMaterial)
			{
				var index:int = obj.indexOf("mtllib");
				if (index != -1)
				{
					aSources = [];
					loadMtl(parseUrl(index, obj));
				}
			}

			verticeDatas = null;
			uvs = null;
			this.material = material;

			buildFaces();
		}

		/*
		   arcane override function buildFaces():void
		   {
		   _faceMaterials.fixed = false;
		   _faces.length = _sort.length = 0;
		   var i:int = _faces.length = _faceMaterials.length = _indices.length/3;

		   while (i--)
		   {
		   var _face:Face = _faces[int(i)] = new Face(this, i);
		   maxRadius = (maxRadius>_face.length)?maxRadius:_face.length;
		   }

		   // speed up
		   _vertices.fixed = true;
		   _uvtData.fixed = true;
		   _indices.fixed = true;
		   _faceMaterials.fixed = true;

		   // calculate normals for the shaders
		   if (_material is IShader)
		   IShader(_material).calculateNormals(_vertices, _indices, _uvtData, _vertexNormals);

		   if (_scene)
		   _scene._dirtyFaces = true;

		   updateSortType();
		   }
		 */

		private var obj:String;
		public var mesh:Mesh;
		private var mtlPath:String;
		private var aMeshes:Array = [];
		private var aSources:Array;
		private var aMats:Array;
		//private var vertices:Array = [];
		//private var uvs:Array = [];
		//private var scaling:Number;
		private var useMaterial:Boolean;

		private function _addFace(v0:Vector3D, v1:Vector3D, v2:Vector3D, uv0:Vector3D, uv1:Vector3D, uv2:Vector3D):void
		{
			_vertices.push(v0.x, v0.y, v0.z, v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
			_uvtData.push(uv0.x, uv0.y, 1, uv1.x, uv1.y, 1, uv2.x, uv2.y, 1);

			n += 3;

			_indices.push(n, n - 1, n - 2);

			_faceLengths.push(3);
		}

		private function checkUV(id:int, uv:UV = null):Vector3D
		{
			if (uv == null)
			{
				switch (id)
				{
					case 1:
						return new Vector3D(0, 1);
						break;
					case 2:
						return new Vector3D(.5, 0);
						break;
					case 3:
						return new Vector3D(1, 1);
						break;
				}

			}

			return new Vector3D(uv.u, uv.v);
		}

		private static function trysplit(source:String, by:String):Array
		{
			if (source == null)
				return null;
			if (source.indexOf(by) == -1)
				return [source];

			return source.split(by);
		}

		private function errorMtl(event:Event):void
		{
			trace("OBJ MTL LOAD ERROR: unable to load .mtl file at " + mtlPath);
		}

		private function mtlProgress(event:Event):void
		{
			//NOT BUILDED IN YET
			//trace( (event.target.bytesLoaded / event.target.bytesTotal) *100);
		}

		private function loadMtl(url:String):void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseMtl);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorMtl);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorMtl);
			loader.addEventListener(ProgressEvent.PROGRESS, mtlProgress);
			loader.load(new URLRequest(mtlPath + url));
		}

		private function parseUrl(index:Number, data:String):String
		{
			return data.substring(index + 7, data.indexOf(".mtl") + 4);
		}

		private function parseMtl(event:Event):void
		{
			var lines:Array = String(event.target["data"]).split('\n');
			if (lines.length == 1)
				lines = String(event.target["data"]).split(String.fromCharCode(13));
			var trunk:Array;
			var i:int;
			var j:int;
			var mat:BitmapFileMaterial;
			aMats = [];

			for each (var line:String in lines)
			{
				trunk = line.split(" ");
				switch (trunk[0])
				{
					case "newmtl":
						aSources.push({material: null, materialid: trunk[1]});
						break;
					case "map_Kd":
						mat = checkDoubleMaterials(parseMapKdString(trunk, mtlPath));
						aSources[aSources.length - 1].material = mat;
						break;
				}
			}

			var aMeshes_length:int = aMeshes.length;
			var aSources_length:int = aSources.length;
			
			for (j = 0; j < aMeshes_length; ++j)
			{
				for (i = 0; i < aSources_length; ++i)
				{
					if (aMeshes[int(j)].materialid == aSources[int(i)].materialid)
					{
						mat = aSources[int(i)].material;
						aMeshes[int(j)].mesh.material = mat;
					}
				}
			}

			aSources = null;
			aMats = null;
		}

		private static function parseMapKdString(trunk:Array, defaultMtlPath:String):String
		{
			var url:String = "";
			var i:int;
			var breakflag:Boolean;

			var trunk_length:int = trunk.length;
			for (i = 1; i < trunk_length; )
			{
				switch (trunk[int(i)])
				{
					case "-blendu":
					case "-blendv":
					case "-cc":
					case "-clamp":
					case "-texres":
						i += 2; //Skip ahead 1 attribute
						break;
					case "-mm":
						i += 3; //Skip ahead 2 attributes
						break;
					case "-o":
					case "-s":
					case "-t":
						i += 4; //Skip ahead 3 attributes
						continue;
					default:
						breakflag = true;
						break;
				}

				if (breakflag)
					break;
			}

			//Reconstruct URL/filename
			for (i; i < trunk_length; i++)
			{
				url += trunk[int(i)];
				url += " ";
			}

			//Remove the extraneous space and/or newline from the right side
			url = url.replace(/\s+$/, "");

			//If the final url has a ":" in it assume that it is an absolute path,
			//else include the default mtl path that it was found in.
			if (url.match(":"))
				return url;
			else
				return defaultMtlPath + url;
		}

		private function checkDoubleMaterials(url:String):BitmapFileMaterial
		{
			var mat:BitmapFileMaterial;
			var aMats_length:int = aMats.length;
			for (var i:int = 0; i < aMats_length; ++i)
			{
				if (aMats[int(i)].url == url)
				{
					mat = aMats[int(i)].material;
					aMats.push({url: url, material: mat});
					return mat;
				}
			}

			mat = new BitmapFileMaterial(url.replace(String.fromCharCode(13), ""));
			aMats.push({url: url, material: mat});
			return mat;
		}

		private function generateNewMesh():void
		{
		/*
		   mesh = new Mesh();
		   mesh.name = "obj_"+aMeshes.length;
		   mesh.type = ".OBJ";

		   if(aMeshes.length == 1 && container == null)
		   container = new ObjectContainer3D(aMeshes[0].mesh);

		   aMeshes.push({materialid:"", mesh:mesh});

		   if(aMeshes.length > 1 || container != null)
		   (container as ObjectContainer3D).addChild(mesh);
		 */
		}

		/**
		 * Creates a new <code>OBJ</code> object.
		 *
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * note: Property "useMaterial" true by default added for A 2.4/3.4 and higher.
		 * @see away3d.loaders.OBJ#parse()
		 * @see away3d.loaders.OBJ#load()
		 */
		public function OBJ(data:* = null, material:Material = null, scale:int = 1)
		{
			super();

			this.material = material;

			if (data)
			{
				if (data is ByteArray)
				{
					parse(data);
				}
				else
				{
					load(data);
				}
			}

			scaling = scale;

			//mtlPath = ini.getString("mtlPath", "");
			//scaling = ini.getNumber("scaling", 1);
			//useMaterial = ini.getBoolean("useMaterial", true);

			//binary = false;
		}

		/**
		 * Creates a 3d mesh object from the raw ascii data of a obj file.
		 *
		 * @param	data				The ascii data of a loaded file.
		 * @param	init				[optional]	An initialisation object for specifying default instance properties.
		 *
		 * @return						A 3d mesh object representation of the obj file.
		 *
		   public static function parse(data:*, init:OBJect = null):Object3D
		   {
		   return Loader3D.parseGeometry(data, OBJ, init).handle;
		   }
		 */
		/**
		 * Loads and parses a obj file into a 3d mesh object.
		 *
		 * @param	url					The url location of the file to load.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 *
		 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.
		 *
		   public static function load(url:String, init:OBJect = null):Loader3D
		   {
		   //mtlPath as model folder
		   if (url)
		   {
		   var _pathArray:Array = url.split("/");
		   _pathArray.pop();
		   var _mtlPath:String = (_pathArray.length>0)?_pathArray.join("/")+"/":_pathArray.join("/");
		   if (init){
		   init["mtlPath"] = (init["mtlPath"])?init["mtlPath"]:_mtlPath;
		   }else {
		   init = { mtlPath:_mtlPath };
		   }
		   }
		   return Loader3D.loadGeometry(url, OBJ, init);
		   }
		 */

		public function load(uri:String, mtlPath:String = null):Object
		{
			return LoaderUtil.load(uri, onLoad);
		}

		private function onLoad(event:Event):void
		{
			if (event.type == Event.COMPLETE)
				parse(String(event.target.data));
		}
	}
}

internal class UV
{
	public var u:Number;
	public var v:Number;

	public function UV(u:Number = 0, v:Number = 0)
	{
		this.u = u;
		this.v = v;
	}
}

import flash.display.Loader;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;

internal class LoaderUtil
{
	public static function load(uri:String, onLoad:Function = null, dataFormat:String = "binary"):Object
	{
		if (uri.lastIndexOf(".jpg") == uri.length - 4 || uri.lastIndexOf(".png") == uri.length - 4)
		{
			dataFormat = "bitmap";
		}

		if (dataFormat == "binary")
		{
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = dataFormat;

			urlLoader.addEventListener(ProgressEvent.PROGRESS, onLoad, false, 0, true);
			urlLoader.addEventListener(Event.COMPLETE, onLoad, false, 0, true);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoad, false, 0, true);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onLoad, false, 0, true);
			urlLoader.addEventListener(Event.OPEN, onLoad, false, 0, true);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoad, false, 0, true);

			urlLoader.addEventListener(Event.COMPLETE, function():void
				{
					urlLoader.removeEventListener(ProgressEvent.PROGRESS, onLoad);
					urlLoader.removeEventListener(Event.COMPLETE, onLoad);
					urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onLoad);
					urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onLoad);
					urlLoader.removeEventListener(Event.OPEN, onLoad);
					urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoad);
					try
					{
						urlLoader.close();
					}
					catch (e:Error)
					{
					}
					;
				}, false, 0, true);

			try
			{
				urlLoader.load(new URLRequest(uri));
			}
			catch (e:Error)
			{
				trace(" ! Error in loading file (" + uri + "): \n" + e.message + "\n" + e.getStackTrace());
			}
			return urlLoader;
		}
		else
		{
			var loader:Loader = new Loader();

			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoad, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoad, false, 0, true);
			loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onLoad, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.OPEN, onLoad, false, 0, true);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoad, false, 0, true);

			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function():void
				{
					loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoad, false, 0, true);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad, false, 0, true);
					loader.contentLoaderInfo.addEventListener(Event.INIT, onLoad, false, 0, true);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoad, false, 100, true);
					loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoad, false, 0, true);
					loader.contentLoaderInfo.addEventListener(Event.OPEN, onLoad, false, 0, true);
					loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onLoad, false, 0, true);
					try
					{
						loader.close();
					}
					catch (e:Error)
					{
					}
					;
				}, false, 0, true);

			try
			{
				loader.load(new URLRequest(uri));
			}
			catch (e:Error)
			{
				trace(" ! Error in loading file (" + uri + "): \n" + e.message + "\n" + e.getStackTrace());
			}
			return loader;
		}
	}
}