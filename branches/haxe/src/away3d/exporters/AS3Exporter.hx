package away3d.exporters;

import away3d.containers.ObjectContainer3D;
import away3d.core.base.Element;
import away3d.core.base.Face;
import away3d.core.base.Frame;
import away3d.core.base.Geometry;
import away3d.core.base.Mesh;
import away3d.core.base.Object3D;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.math.Number3D;
import away3d.loaders.data.MaterialData;
import away3d.materials.WireframeMaterial;
import away3d.primitives.Torus;
import away3d.primitives.Cylinder;
import flash.events.EventDispatcher;
import away3d.primitives.Sphere;
import away3d.primitives.WireSphere;
import away3d.primitives.Skybox;
import flash.utils.Dictionary;
import away3d.primitives.Plane;
import away3d.primitives.LineSegment;
import away3d.primitives.WireCircle;
import away3d.primitives.WireCone;
import away3d.primitives.Skybox6;
import away3d.primitives.WirePlane;
import away3d.primitives.Cube;
import flash.system.System;
import away3d.primitives.WireCube;
import away3d.primitives.GeodesicSphere;
import away3d.primitives.GridPlane;
import away3d.primitives.WireTorus;
import away3d.primitives.Cone;
import away3d.primitives.WireCylinder;
import away3d.primitives.RegularPolygon;


// use namespace arcane;

class AS3Exporter  {
	
	private var useMesh:Bool;
	private var isAnim:Bool;
	private var asString:String;
	private var containerString:String;
	private var materialString:String;
	private var geoString:String;
	private var meshString:String;
	private var gcount:Int;
	private var mcount:Int;
	private var objcount:Int;
	private var geocount:Int;
	private var geonums:Dictionary;
	private var facenums:Dictionary;
	private var indV:Int;
	private var indVt:Int;
	private var indF:Int;
	private var geos:Array<Dynamic>;
	private var p1:EReg;
	private var aTypes:Array<Dynamic>;
	

	private function write(object3d:Object3D, ?containerid:Int=-1):Void {
		
		var mat:String = "null";
		var nameinsert:String = (object3d.name == null) ? "" : "name:\"" + object3d.name + "\", ";
		var bothsidesinsert:String = ((cast(object3d, Mesh)).bothsides) ? "bothsides:true, " : "";
		var type:String = "";
		var i:Int = 0;
		while (i < aTypes.length) {
			if (Std.is(object3d, aTypes)) {
				type = ("" + aTypes[i]);
				type = substr(7, type.length - 1 - 7);
				if (i > 9) {
					var linemat:WireframeMaterial = (cast((cast(object3d, Mesh)).material, WireframeMaterial));
					var wirematinsert:String = " material: new WireframeMaterial(0x" + linemat.color.toString(16).toUpperCase() + ", {width:" + linemat.width + "*_scale})";
				}
				break;
			}
			
			// update loop variables
			++i;
		}

		var xpos:String = (object3d.x == 0) ? "0" : object3d.x + "*_scale";
		var ypos:String = (object3d.y == 0) ? "0" : object3d.y + "*_scale";
		var zpos:String = (object3d.z == 0) ? "0" : object3d.z + "*_scale";
		if (type != "") {
			var objname:String = "" + type.toLowerCase() + objcount;
			var constructinsert:String = "\n\t\t\tvar " + objname + ":" + type + " = new " + type + "(";
			switch (type) {
				case "Sphere" :
					meshString += constructinsert + "{" + nameinsert + bothsidesinsert + "material:" + mat + ", segmentsH:" + (cast(object3d, aTypes)[i]).segmentsH + ", segmentsW:" + (cast(object3d, aTypes)[i]).segmentsW + ", radius:" + (cast(object3d, aTypes)[i]).radius + "*_scale, yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "Plane" :
					meshString += constructinsert + "{" + nameinsert + bothsidesinsert + "material:" + mat + ", segmentsH:" + (cast(object3d, aTypes)[i]).segmentsH + ", segmentsW:" + (cast(object3d, aTypes)[i]).segmentsW + ", width:" + (cast(object3d, aTypes)[i]).width + "*_scale, height:" + (cast(object3d, aTypes)[i]).height + "*_scale, yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "Cone" :
					meshString += constructinsert + "{" + nameinsert + bothsidesinsert + "material:" + mat + ", segmentsH:" + (cast(object3d, aTypes)[i]).segmentsH + ", segmentsW:" + (cast(object3d, aTypes)[i]).segmentsW + ", radius:" + (cast(object3d, aTypes)[i]).radius + "*_scale, height:" + (cast(object3d, aTypes)[i]).height + ", openEnded:" + (cast(object3d, aTypes)[i]).openEnded + ", yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "Cube" :
					meshString += constructinsert + "{" + nameinsert + bothsidesinsert + "material:" + mat + ", height:" + (cast(object3d, aTypes)[i]).height + "*_scale, depth:" + (cast(object3d, aTypes)[i]).depth + "*_scale, width:" + (cast(object3d, aTypes)[i]).width + "*_scale, yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "Cylinder" :
					meshString += constructinsert + "{" + nameinsert + bothsidesinsert + "material:" + mat + ", segmentsH:" + (cast(object3d, aTypes)[i]).segmentsH + ", segmentsW:" + (cast(object3d, aTypes)[i]).segmentsW + ", radius:" + (cast(object3d, aTypes)[i]).radius + "*_scale, height:" + (cast(object3d, aTypes)[i]).height + "*_scale, openEnded:" + (cast(object3d, aTypes)[i]).openEnded + ", yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "RegularPolygon" :
					meshString += constructinsert + "{" + nameinsert + bothsidesinsert + "material:" + mat + ", radius:" + (cast(object3d, aTypes)[i]).radius + "*_scale, sides:" + (cast(object3d, aTypes)[i]).sides + ", yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "Torus" :
					meshString += constructinsert + "{" + nameinsert + bothsidesinsert + "material:" + mat + ", segmentsR:" + (cast(object3d, aTypes)[i]).segmentsR + ", segmentsT:" + (cast(object3d, aTypes)[i]).segmentsT + ", radius:" + (cast(object3d, aTypes)[i]).radius + "*_scale, tube:" + (cast(object3d, aTypes)[i]).tube + "*_scale, yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "LineSegment" :
					var v0:Vertex = (cast(object3d, aTypes)[i]).start;
					var v1:Vertex = (cast(object3d, aTypes)[i]).end;
					meshString += constructinsert + "{" + nameinsert + wirematinsert + "});\n\t\t\t" + objname + ".start = new Vertex(" + v0.x + "*_scale," + v0.y + "*_scale," + v0.z + "*_scale);\n\t\t\t" + objname + ".end = new Vertex(" + v1.x + "*_scale," + v1.y + "*_scale," + v1.z + "*_scale);";
				case "WireTorus" :
					meshString += constructinsert + "{" + nameinsert + wirematinsert + ", radius:" + (cast(object3d, aTypes)[i]).radius + "*_scale, tube:" + (cast(object3d, aTypes)[i]).tube + ", segmentsR:" + (cast(object3d, aTypes)[i]).segmentsR + ", segmentsT:" + (cast(object3d, aTypes)[i]).segmentsT + ", yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "WireCircle" :
					meshString += constructinsert + "{" + nameinsert + wirematinsert + ", radius:" + (cast(object3d, aTypes)[i]).radius + "*_scale, sides:" + (cast(object3d, aTypes)[i]).sides + ", yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "WireCone" :
					meshString += constructinsert + "{" + nameinsert + wirematinsert + ", radius:" + (cast(object3d, aTypes)[i]).radius + "*_scale, height:" + (cast(object3d, aTypes)[i]).height + "*_scale, segmentsW:" + (cast(object3d, aTypes)[i]).segmentsW + ", segmentsH:" + (cast(object3d, aTypes)[i]).segmentsH + ", yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "WireCube" :
					meshString += constructinsert + "{" + nameinsert + wirematinsert + ", width:" + (cast(object3d, aTypes)[i]).width + "*_scale, height:" + (cast(object3d, aTypes)[i]).height + "*_scale, depth:" + (cast(object3d, aTypes)[i]).depth + "*_scale});";
				case "WireCylinder" :
					meshString += constructinsert + "{" + nameinsert + wirematinsert + ", radius:" + (cast(object3d, aTypes)[i]).radius + "*_scale, height:" + (cast(object3d, aTypes)[i]).height + "*_scale, segmentsW:" + (cast(object3d, aTypes)[i]).segmentsW + ", segmentsH:" + (cast(object3d, aTypes)[i]).segmentsH + ", yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "WirePlane" :
					meshString += constructinsert + "{" + nameinsert + wirematinsert + ", width:" + (cast(object3d, aTypes)[i]).width + "*_scale, height:" + (cast(object3d, aTypes)[i]).height + "*_scale, segmentsW:" + (cast(object3d, aTypes)[i]).segmentsW + ", segmentsH:" + (cast(object3d, aTypes)[i]).segmentsH + ", yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "WireSphere" :
					meshString += constructinsert + "{" + nameinsert + wirematinsert + ", radius:" + (cast(object3d, aTypes)[i]).radius + "*_scale, segmentsW:" + (cast(object3d, aTypes)[i]).segmentsW + ", segmentsH:" + (cast(object3d, aTypes)[i]).segmentsH + ", yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "GeodesicSphere" :
					meshString += constructinsert + "{" + nameinsert + bothsidesinsert + "material:" + mat + ", radius:" + (cast(object3d, aTypes)[i]).radius + "*_scale, fractures:" + (cast(object3d, aTypes)[i]).fractures + "});";
				case "GridPlane" :
					meshString += constructinsert + "{" + nameinsert + wirematinsert + ", width:" + (cast(object3d, aTypes)[i]).width + "*_scale, height:" + (cast(object3d, aTypes)[i]).height + ", segmentsW:" + (cast(object3d, aTypes)[i]).segmentsW + ", segmentsH:" + (cast(object3d, aTypes)[i]).segmentsH + ", yUp:" + (cast(object3d, aTypes)[i]).yUp + "});";
				case "Skybox" :
					meshString += constructinsert + "null,null,null,null,null,null);";
				case "Skybox6" :
					meshString += constructinsert + "null);";
				

			}
			if ((cast(object3d, aTypes)[i]).rotationX != 0) {
				meshString += "\n\t\t\t" + objname + ".rotationX=" + (cast(object3d, aTypes)[i]).rotationX + ";";
			}
			if ((cast(object3d, aTypes)[i]).rotationY != 0) {
				meshString += "\n\t\t\t" + objname + ".rotationY=" + (cast(object3d, aTypes)[i]).rotationY + ";";
			}
			if ((cast(object3d, aTypes)[i]).rotationZ != 0) {
				meshString += "\n\t\t\t" + objname + ".rotationZ=" + (cast(object3d, aTypes)[i]).rotationZ + ";";
			}
			if ((cast(object3d, Mesh)).pushfront) {
				meshString += "\n\t\t\t(" + objname + " as Mesh).pushfront = true;";
			}
			if ((cast(object3d, Mesh)).pushback) {
				meshString += "\n\t\t\t(" + objname + " as Mesh).pushback = true;";
			}
			if ((cast(object3d, Mesh)).ownCanvas) {
				meshString += "\n\t\t\t(" + objname + " as Mesh).ownCanvas = true;";
			}
			meshString += "\n\t\t\t" + objname + ".position= new Number3D(" + xpos + "," + ypos + "," + zpos + ");";
			meshString += "\n\t\t\toList.push(" + objname + ");";
			if (containerid != -1) {
				meshString += "\n\t\t\taC[" + containerid + "].addChild(" + objname + ");\n";
			} else {
				meshString += "\n\t\t\taddChild(" + objname + ");\n";
			}
		} else {
			useMesh = true;
			var aV:Array<Dynamic> = [];
			var aVt:Array<Dynamic> = [];
			var aF:Array<Dynamic> = [];
			var MaV:Array<Dynamic> = [];
			var MaVt:Array<Dynamic> = [];
			meshString += "\t\t\tvar m" + objcount + ":Matrix3D = new Matrix3D();\n";
			meshString += "\t\t\tm" + objcount + ".sxx = " + object3d.transform.sxx + ";\n";
			meshString += "\t\t\tm" + objcount + ".sxy = " + object3d.transform.sxy + ";\n";
			meshString += "\t\t\tm" + objcount + ".sxz = " + object3d.transform.sxz + ";\n";
			meshString += "\t\t\tm" + objcount + ".tx = " + object3d.transform.tx + ";\n";
			meshString += "\t\t\tm" + objcount + ".syx = " + object3d.transform.syx + ";\n";
			meshString += "\t\t\tm" + objcount + ".syy = " + object3d.transform.syy + ";\n";
			meshString += "\t\t\tm" + objcount + ".syz = " + object3d.transform.syz + ";\n";
			meshString += "\t\t\tm" + objcount + ".ty = " + object3d.transform.ty + ";\n";
			meshString += "\t\t\tm" + objcount + ".szx = " + object3d.transform.szx + ";\n";
			meshString += "\t\t\tm" + objcount + ".szy = " + object3d.transform.szy + ";\n";
			meshString += "\t\t\tm" + objcount + ".szz = " + object3d.transform.szz + ";\n";
			meshString += "\t\t\tm" + objcount + ".tz = " + object3d.transform.tz + ";\n";
			meshString += "\n\t\t\tobjs.obj" + objcount + " = {" + nameinsert + " transform:m" + objcount + ", pivotPoint:new Number3D(" + object3d.pivotPoint.x + "," + object3d.pivotPoint.y + "," + object3d.pivotPoint.z + "), container:" + containerid + ", bothsides:" + (cast(object3d, Mesh)).bothsides + ", material:" + mat + ", ownCanvas:" + (cast(object3d, Mesh)).ownCanvas + ", pushfront:" + (cast(object3d, Mesh)).pushfront + ", pushback:" + (cast(object3d, Mesh)).pushback + "};";
			var aFaces:Array<Dynamic> = (cast(object3d, Mesh)).faces;
			var geometry:Geometry = (cast(object3d, Mesh)).geometry;
			var va:Int;
			var vb:Int;
			var vc:Int;
			var vta:Int;
			var vtb:Int;
			var vtc:Int;
			var nPos:Number3D = object3d.scenePosition;
			var tmp:Number3D = new Number3D();
			var j:Int;
			var aRef:Array<Dynamic> = [vc, vb, va];
			var animated:Bool = (cast(object3d, Mesh)).geometry.frames != null;
			var face:Face;
			var geoIndex:Int;
			if ((geoIndex = checkGeometry(geometry)) != -1) {
				meshString += "\n\t\t\tobjs.obj" + objcount + ".geo=geos[" + geoIndex + "];\n";
			} else {
				geoIndex = geos.length;
				geos.push(geometry);
				i = 0;
				while (i < aFaces.length) {
					face = aFaces[i];
					geonums[cast face] = geoIndex;
					facenums[cast face] = i;
					j = 0;
					while (j < 3) {
						tmp.x = Reflect.field(face, "v" + j).x;
						tmp.y = Reflect.field(face, "v" + j).y;
						tmp.z = Reflect.field(face, "v" + j).z;
						aRef[j] = checkDoubles(MaV, (tmp.x.toFixed(4) + "/" + tmp.y.toFixed(4) + "/" + tmp.z.toFixed(4)));
						
						// update loop variables
						++j;
					}

					vta = checkDoubles(MaVt, face.uv0.u + "/" + face.uv0.v);
					vtb = checkDoubles(MaVt, face.uv1.u + "/" + face.uv1.v);
					vtc = checkDoubles(MaVt, face.uv2.u + "/" + face.uv2.v);
					aF.push(aRef[0].toString(16) + "," + aRef[1].toString(16) + "," + aRef[2].toString(16) + "," + vta.toString(16) + "," + vtb.toString(16) + "," + vtc.toString(16));
					
					// update loop variables
					++i;
				}

				geoString += "\t\t\tvar geo" + geoIndex + ":Object = {};\n";
				geoString += "\t\t\tgeo" + geoIndex + ".aVstr=\"" + encode(MaV.toString()) + "\";\n";
				geoString += "\t\t\tgeo" + geoIndex + ".aUstr=\"" + encode(MaVt.toString()) + "\";\n";
				geoString += "\t\t\tgeo" + geoIndex + ".aV= read(geo" + geoIndex + ".aVstr).split(\",\");\n";
				geoString += "\t\t\tgeo" + geoIndex + ".aU= read(geo" + geoIndex + ".aUstr).split(\",\");\n";
				geoString += "\t\t\tgeo" + geoIndex + ".f=\"" + aF.toString() + "\";\n";
				geoString += "\t\t\tgeos.push(geo" + geoIndex + ");\n";
				meshString += "\n\t\t\tobjs.obj" + objcount + ".geo=geos[" + geoIndex + "];\n";
				//meshString +="\n\t\t\tobjs.obj"+objcount+".f=\""+aF.toString()+"\";\n";
				if (animated) {
					readVertexAnimation((cast(object3d, Mesh)), "objs.obj" + objcount);
				}
			}
		}
		objcount++;
	}

	private function encode(str:String):String {
		
		var start:Int = 0;
		var chunk:String;
		var end:Int = 0;
		var encstr:String = "";
		var charcount:Int = str.length;
		var i:Int = 0;
		while (i < charcount) {
			if (str.charCodeAt(i) >= 48 && str.charCodeAt(i) <= 57 && str.charCodeAt(i) != 48) {
				start = i;
				chunk = "";
				while (str.charCodeAt(i) >= 48 && str.charCodeAt(i) <= 57 && i <= charcount) {
					i++;
				}

				chunk = (substr(start, i - start)).toString(16);
				encstr += chunk;
				i--;
			} else {
				encstr += substr(i, i + 1 - i);
			}
			
			// update loop variables
			++i;
		}

		return encstr.replace(p1, "/0/");
	}

	private function readVertexAnimation(obj:Mesh, id:String):Void {
		
		isAnim = true;
		meshString += "\n\t\t\tobjs.obj" + objcount + ".meshanimated=true;\n";
		var tmpnames:Array<Dynamic> = [];
		var i:Int = 0;
		var j:Int = 0;
		var fr:Frame;
		var avp:Array<Dynamic>;
		var afn:Array<Dynamic> = [];
		//reset names in logical sequence
		var framename:String;
		for (framename in obj.geometry.framenames) {
			tmpnames.push(framename);
			
		}

		tmpnames.sort();
		var myPattern:EReg = new EReg();
		i = 0;
		while (i < tmpnames.length) {
			avp = [];
			fr = obj.geometry.frames[obj.geometry.framenames[tmpnames[i]]];
			if (tmpnames[i].indexOf(" ") != -1) {
				tmpnames[i] = tmpnames[i].replace(myPattern, "");
			}
			afn.push("\"" + tmpnames[i] + "\"");
			meshString += "\n\t\t\t" + id + ".fr" + tmpnames[i] + "=[";
			j = 0;
			while (j < fr.vertexpositions.length) {
				avp.push(fr.vertexpositions[j].x.toFixed(1));
				avp.push(fr.vertexpositions[j].y.toFixed(1));
				avp.push(fr.vertexpositions[j].z.toFixed(1));
				
				// update loop variables
				++j;
			}

			meshString += avp.toString() + "];\n";
			
			// update loop variables
			++i;
		}

		//restore right sequence voor non sync md2 files
		fr = obj.geometry.frames[obj.geometry.framenames[tmpnames[0]]];
		var verticesorder:Array<Dynamic> = fr.getIndexes(obj.vertices);
		var indexes:Array<Dynamic> = [];
		var face:Face;
		var ox:Float;
		var oy:Float;
		var oz:Float;
		var ind:Int = 0;
		var k:Int;
		var tmpval:Float = -1234567890;
		i = 0;
		while (i < obj.faces.length) {
			face = obj.faces[i];
			j = 2;
			while (j > -1) {
				ox = Reflect.field(face, "v" + j).x;
				oy = Reflect.field(face, "v" + j).y;
				oz = Reflect.field(face, "v" + j).z;
				ind = 0;
				Reflect.setField(face, "v" + j, tmpval);
				Reflect.setField(face, "v" + j, tmpval);
				Reflect.setField(face, "v" + j, tmpval);
				k = 0;
				while (k < obj.vertices.length) {
					if (obj.vertices[k].x == tmpval && obj.vertices[k].y == tmpval && obj.vertices[k].z == tmpval) {
						ind = k;
						break;
					}
					
					// update loop variables
					++k;
				}

				Reflect.setField(face, "v" + j, ox);
				Reflect.setField(face, "v" + j, oy);
				Reflect.setField(face, "v" + j, oz);
				indexes.push(ind);
				
				// update loop variables
				--j;
			}

			
			// update loop variables
			++i;
		}

		meshString += "\n\t\t\t" + id + ".indexes=[" + indexes.toString() + "];\n";
		meshString += "\n\t\t\t" + id + ".fnarr = [" + afn.toString() + "];\n";
	}

	private function checkUnicV(arr:Array<Dynamic>, v:Vertex, mesh:Mesh):Int {
		
		var i:Int = 0;
		while (i < arr.length) {
			if (v == arr[i].vertex) {
				return arr[i].index;
			}
			
			// update loop variables
			++i;
		}

		var id:Int;
		i = 0;
		while (i < mesh.vertices.length) {
			if (v == mesh.vertices[i]) {
				id = i;
				break;
			}
			
			// update loop variables
			++i;
		}

		arr.push({vertex:v, index:id});
		return id;
	}

	//to be replaced by the checkdouble code
	private function checkUnicUV(arr:Array<Dynamic>, uv:UV, mesh:Mesh):Int {
		
		var i:Int = 0;
		while (i < arr.length) {
			if (uv == arr[i]) {
				return i;
			}
			
			// update loop variables
			++i;
		}

		arr.push(uv);
		return Std.int(arr.length - 1);
	}

	private function checkDoubles(arr:Array<Dynamic>, string:String):Int {
		
		var i:Int = 0;
		while (i < arr.length) {
			if (arr[i] == string) {
				return i;
			}
			
			// update loop variables
			++i;
		}

		arr.push(string);
		return arr.length - 1;
	}

	private function checkGeometry(geometry:Geometry):Int {
		
		var i:String;
		for (i in geos) {
			if (Reflect.field(geos, i) == geometry) {
				return (i);
			}
			
		}

		return -1;
	}

	private function parse(object3d:Object3D, ?containerid:Int=-1):Void {
		
		if (Std.is(object3d, ObjectContainer3D)) {
			var obj:ObjectContainer3D = (cast(object3d, ObjectContainer3D));
			var id:Int = gcount;
			if (containerid != -1) {
				containerString += "\n\t\t\tvar cont" + id + ":ObjectContainer3D = new ObjectContainer3D();\n";
				containerString += "\t\t\taC.push(cont" + id + ");\n";
				if (containerid == 0) {
					containerString += "\t\t\taddChild(cont" + id + ");\n";
				} else {
					containerString += "\t\t\tcont" + containerid + ".addChild(cont" + id + ");\n";
				}
				containerString += "\t\t\tvar m" + id + ":Matrix3D = new Matrix3D();\n";
				containerString += "\t\t\tm" + id + ".sxx = " + obj.transform.sxx + ";\n";
				containerString += "\t\t\tm" + id + ".sxy = " + obj.transform.sxy + ";\n";
				containerString += "\t\t\tm" + id + ".sxz = " + obj.transform.sxz + ";\n";
				containerString += "\t\t\tm" + id + ".tx = " + obj.transform.tx + ";\n";
				containerString += "\t\t\tm" + id + ".syx = " + obj.transform.syx + ";\n";
				containerString += "\t\t\tm" + id + ".syy = " + obj.transform.syy + ";\n";
				containerString += "\t\t\tm" + id + ".syz = " + obj.transform.syz + ";\n";
				containerString += "\t\t\tm" + id + ".ty = " + obj.transform.ty + ";\n";
				containerString += "\t\t\tm" + id + ".szx = " + obj.transform.szx + ";\n";
				containerString += "\t\t\tm" + id + ".szy = " + obj.transform.szy + ";\n";
				containerString += "\t\t\tm" + id + ".szz = " + obj.transform.szz + ";\n";
				containerString += "\t\t\tm" + id + ".tz = " + obj.transform.tz + ";\n";
				containerString += "\t\t\tcont" + id + ".transform = m" + id + ";\n";
				/*
				 if(obj.x != 0) containerString +="\t\t\tcont"+id+".x = "+obj.x+"*_scale;\n";
				 if(obj.y != 0) containerString +="\t\t\tcont"+id+".y = "+obj.y+"*_scale;\n";
				 if(obj.z != 0) containerString +="\t\t\tcont"+id+".z = "+obj.z+"*_scale;\n";
				 if(obj.rotationX != 0) containerString +="\t\t\tcont"+id+".rotationX = "+obj.rotationX+";\n";
				 if(obj.rotationY != 0) containerString +="\t\t\tcont"+id+".rotationY = "+obj.rotationY+";\n";
				 if(obj.rotationZ != 0) containerString +="\t\t\tcont"+id+".rotationZ = "+obj.rotationZ+";\n";
				 if(obj.scaleX != 1) containerString +="\t\t\tcont"+id+".scaleX = "+obj.scaleX+";\n";
				 if(obj.scaleY != 1) containerString +="\t\t\tcont"+id+".scaleY = "+obj.scaleY+";\n";
				 if(obj.scaleZ != 1) containerString +="\t\t\tcont"+id+".scaleZ = "+obj.scaleZ+";\n";
				 */
				if (obj.name != null) {
					containerString += "\t\t\tcont" + id + ".name = \"" + obj.name + "\";\n";
				}
				if (obj.pivotPoint.toString() != "x:0 y:0 z:0") {
					containerString += "\t\t\tcont" + id + ".movePivot(" + obj.pivotPoint.x + "," + obj.pivotPoint.y + "," + obj.pivotPoint.z + ");\n";
				}
			} else {
				containerString += "\t\t\taC.push(this);\n";
				containerString += "\t\t\tvar m" + id + ":Matrix3D = new Matrix3D();\n";
				containerString += "\t\t\tm" + id + ".sxx = " + obj.transform.sxx + ";\n";
				containerString += "\t\t\tm" + id + ".sxy = " + obj.transform.sxy + ";\n";
				containerString += "\t\t\tm" + id + ".sxz = " + obj.transform.sxz + ";\n";
				containerString += "\t\t\tm" + id + ".tx = " + obj.transform.tx + ";\n";
				containerString += "\t\t\tm" + id + ".syx = " + obj.transform.syx + ";\n";
				containerString += "\t\t\tm" + id + ".syy = " + obj.transform.syy + ";\n";
				containerString += "\t\t\tm" + id + ".syz = " + obj.transform.syz + ";\n";
				containerString += "\t\t\tm" + id + ".ty = " + obj.transform.ty + ";\n";
				containerString += "\t\t\tm" + id + ".szx = " + obj.transform.szx + ";\n";
				containerString += "\t\t\tm" + id + ".szy = " + obj.transform.szy + ";\n";
				containerString += "\t\t\tm" + id + ".szz = " + obj.transform.szz + ";\n";
				containerString += "\t\t\tm" + id + ".tz = " + obj.transform.tz + ";\n";
				containerString += "\t\t\ttransform = m" + id + ";\n";
				/*
				 if(obj.x != 0) containerString +="\t\t\tcont"+id+".x = "+obj.x+"*_scale;\n";
				 if(obj.y != 0) containerString +="\t\t\tcont"+id+".y = "+obj.y+"*_scale;\n";
				 if(obj.z != 0) containerString +="\t\t\tcont"+id+".z = "+obj.z+"*_scale;\n";
				 if(obj.rotationX != 0) containerString +="\t\t\tcont"+id+".rotationX = "+obj.rotationX+";\n";
				 if(obj.rotationY != 0) containerString +="\t\t\tcont"+id+".rotationY = "+obj.rotationY+";\n";
				 if(obj.rotationZ != 0) containerString +="\t\t\tcont"+id+".rotationZ = "+obj.rotationZ+";\n";
				 if(obj.scaleX != 1) containerString +="\t\t\tcont"+id+".scaleX = "+obj.scaleX+";\n";
				 if(obj.scaleY != 1) containerString +="\t\t\tcont"+id+".scaleY = "+obj.scaleY+";\n";
				 if(obj.scaleZ != 1) containerString +="\t\t\tcont"+id+".scaleZ = "+obj.scaleZ+";\n";
				 */
				if (obj.name != null) {
					containerString += "\t\t\tname = \"" + obj.name + "\";\n";
				}
				if (obj.pivotPoint.toString() != "x:0 y:0 z:0") {
					containerString += "\t\t\tmovePivot(" + obj.pivotPoint.x + "," + obj.pivotPoint.y + "," + obj.pivotPoint.z + ");\n";
				}
			}
			gcount++;
			var i:Int = 0;
			while (i < obj.children.length) {
				if (Std.is(obj.children[i], ObjectContainer3D)) {
					parse(obj.children[i], id);
				} else {
					write(obj.children[i], id);
				}
				
				// update loop variables
				i++;
			}

			if (containerid != -1) {
			} else {
				if (obj.materialLibrary != null) {
					materialString += "\t\t\tmaterialLibrary = new MaterialLibrary();\n";
					var __keys:Iterator<Dynamic> = untyped (__keys__(obj.materialLibrary)).iterator();
					for (__key in __keys) {
						var materialData:MaterialData = obj.materialLibrary[cast __key];

						materialString += "\t\t\tvar mData_" + mcount + ":MaterialData = materialLibrary.addMaterial(\"" + materialData.name + "\");\n";
						materialString += "\t\t\tmData_" + mcount + ".materialType = \"" + materialData.materialType + "\";\n";
						materialString += "\t\t\tmData_" + mcount + ".ambientColor = " + materialData.ambientColor + ";\n";
						materialString += "\t\t\tmData_" + mcount + ".diffuseColor = " + materialData.diffuseColor + ";\n";
						materialString += "\t\t\tmData_" + mcount + ".shininess = " + materialData.shininess + ";\n";
						materialString += "\t\t\tmData_" + mcount + ".specularColor = " + materialData.specularColor + ";\n";
						materialString += "\t\t\tmData_" + mcount + ".textureFileName = \"" + materialData.textureFileName + "\";\n";
						materialString += "\t\t\tvar mElements_" + mcount + ":Array = mData_" + mcount + ".elements;\n";
						for (__i in 0...materialData.elements.length) {
							var element:Element = materialData.elements[__i];

							if (geonums[cast element] != null && facenums[cast element] != null) {
								materialString += "\t\t\tmElements_" + mcount + ".push(geos[" + geonums[cast element] + "].geometry.faces[" + facenums[cast element] + "]);\n";
							}
						}

						materialString += "\t\t\t\n";
						mcount++;
					}

				}
			}
		} else {
			write(object3d, -1);
		}
	}

	function new(object3d:Object3D, classname:String, ?packagename:String="") {
		this.containerString = "";
		this.materialString = "";
		this.geoString = "";
		this.meshString = "";
		this.gcount = 0;
		this.mcount = 0;
		this.objcount = 0;
		this.geocount = 0;
		this.geonums = new Dictionary();
		this.facenums = new Dictionary();
		this.indV = 0;
		this.indVt = 0;
		this.indF = 0;
		this.geos = [];
		this.p1 = new EReg();
		this.aTypes = [Plane, Sphere, Cube, Cone, Cylinder, RegularPolygon, Torus, GeodesicSphere, Skybox, Skybox6, LineSegment, GridPlane, WireTorus, WireCircle, WireCone, WireCube, WireCylinder, WirePlane, WireSphere];
		
		
		asString = "//AS3 exporter version 2.0, generated by Away3D: http://www.away3d.com\n";
		asString += "package " + packagename + "\n{\n\timport away3d.containers.ObjectContainer3D;\n\timport away3d.containers.Scene3D;\n\timport away3d.core.math.*;\n\timport away3d.materials.*;\n\timport away3d.core.base.*;\n\timport away3d.core.utils.Init;\n\timport away3d.loaders.utils.*;\n\timport away3d.loaders.data.*;\n\timport flash.utils.Dictionary;\n\timport away3d.primitives.*;\n\n";
		parse(object3d);
		if (gcount == 0) {
			asString += "\tpublic class " + classname + " extends Mesh\n\t{\n";
		} else {
			asString += "\tpublic class " + classname + " extends ObjectContainer3D\n\t{\n";
		}
		asString += "\t\tprivate var objs:Object = {};\n\t\tprivate var geos:Array = [];\n\t\tprivate var oList:Array =[];\n\t\tprivate var aC:Array;\n\t\tprivate var aV:Array;\n\t\tprivate var aU:Array;\n\t\tprivate var _scale:Number;\n\n";
		asString += "\t\tpublic function " + classname + "(init:Object = null)\n\t\t{\n\t\t\tvar ini:Init = Init.parse(init);\n\t\t\t_scale = ini.getNumber(\"scaling\", 1);\n\t\t\tsetSource();\n\t\t\taddContainers();\n\t\t\tbuildMeshes();\n\t\t\tbuildMaterials();\n\t\t\tcleanUp();\n\t\t}\n\n";
		asString += "\t\tprivate function buildMeshes():void\n\t\t{";
		asString += meshString;
		if (useMesh) {
			asString += "\n\t\t\tvar ref:Object;\n\t\t\tvar mesh:Mesh;\n\t\t\tvar j:int;\n\t\t\tvar av:Array;\n\t\t\tvar au:Array;\n\t\t\tvar v0:Vertex;\n\t\t\tvar v1:Vertex;\n\t\t\tvar v2:Vertex;\n\t\t\tvar u0:UV;\n\t\t\tvar u1:UV;\n\t\t\tvar u2:UV;\n\t\t\tvar aRef:Array ;\n\t\t\tfor(var i:int = 0;i<" + objcount + ";++i){\n";
			asString += "\t\t\t\tref = objs[\"obj\"+i];\n";
			asString += "\t\t\t\tif(ref != null){\n";
			asString += "\t\t\t\t\tmesh = new Mesh();\n\t\t\t\t\tmesh.type = \".as\";\n";
			if (isAnim) {
				asString += "\t\t\t\t\tif(ref.meshanimated) setMeshAnim(mesh, ref, oList.length);\n";
				asString += "\t\t\t\t\tif(ref.indexes != null) mesh.indexes = ref.indexes;\n";
			}
			asString += "\t\t\t\t\tmesh.bothsides = ref.bothsides;\n\t\t\t\t\tmesh.name = ref.name;\n";
			asString += "\t\t\t\t\tmesh.pushfront = ref.pushfront;\n\t\t\t\t\tmesh.pushback = ref.pushback;\n\t\t\t\t\tmesh.ownCanvas = ref.ownCanvas;\n";
			//asString += "\t\t\t\t\tif(ref.container == -1){\n\t\t\t\t\t\taddChild(mesh);\n\t\t\t\t\t} else {\n\t\t\t\t\t\taC[ref.container].addChild(mesh);\n\t\t\t\t\t}\n";
			asString += "\t\t\t\t\tif(ref.container != -1){\n\t\t\t\t\t\taC[ref.container].addChild(mesh);\n\t\t\t\t\t}\n";
			asString += "\n\t\t\t\t\toList.push(mesh);";
			asString += "\n\t\t\t\t\tmesh.transform = ref.transform;\n\t\t\t\t\tmesh.movePivot(ref.pivotPoint.x, ref.pivotPoint.y, ref.pivotPoint.z);\n";
			asString += "\t\t\t\t\tif (ref.geo.geometry != null) {\n";
			asString += "\t\t\t\t\t\tmesh.geometry = ref.geo.geometry;\n";
			asString += "\t\t\t\t\t\tcontinue;\n";
			asString += "\t\t\t\t\t}\n";
			asString += "\t\t\t\t\tref.geo.geometry = new Geometry();\n";
			asString += "\t\t\t\t\tmesh.geometry = ref.geo.geometry;\n";
			asString += "\t\t\t\t\taRef = ref.geo.f.split(\",\");\n";
			asString += "\t\t\t\t\tfor(j = 0;j<aRef.length;j+=6){\n";
			asString += "\t\t\t\t\t\ttry{\n";
			asString += "\t\t\t\t\t\t\tav = ref.geo.aV[parseInt(aRef[j], 16)].split(\"/\");\n";
			asString += "\t\t\t\t\t\t\tv0 = new Vertex(Number(parseFloat(av[0]))*_scale, Number(parseFloat(av[1]))*_scale, Number(parseFloat(av[2]))*_scale);\n";
			asString += "\t\t\t\t\t\t\tav = ref.geo.aV[parseInt(aRef[j+1],16)].split(\"/\");\n";
			asString += "\t\t\t\t\t\t\tv1 = new Vertex(Number(parseFloat(av[0]))*_scale, Number(parseFloat(av[1]))*_scale, Number(parseFloat(av[2]))*_scale);\n";
			asString += "\t\t\t\t\t\t\tav = ref.geo.aV[parseInt(aRef[j+2],16)].split(\"/\");\n";
			asString += "\t\t\t\t\t\t\tv2 = new Vertex(Number(parseFloat(av[0]))*_scale, Number(parseFloat(av[1]))*_scale, Number(parseFloat(av[2]))*_scale);\n";
			asString += "\t\t\t\t\t\t\tau = ref.geo.aU[parseInt(aRef[j+3],16)].split(\"/\");\n";
			asString += "\t\t\t\t\t\t\tu0 = new UV(parseFloat(au[0]), parseFloat(au[1]));\n";
			asString += "\t\t\t\t\t\t\tau = ref.geo.aU[parseInt(aRef[j+4],16)].split(\"/\");\n";
			asString += "\t\t\t\t\t\t\tu1 = new UV(parseFloat(au[0]), parseFloat(au[1]));\n";
			asString += "\t\t\t\t\t\t\tau = ref.geo.aU[parseInt(aRef[j+5],16)].split(\"/\");\n";
			asString += "\t\t\t\t\t\t\tu2 = new UV(parseFloat(au[0]), parseFloat(au[1]));\n";
			asString += "\t\t\t\t\t\t\tref.geo.geometry.addFace( new Face(v0, v1, v2, ref.material, u0, u1, u2) );\n";
			asString += "\t\t\t\t\t\t}catch(e:Error){\n";
			asString += "\t\t\t\t\t\t\ttrace(\"obj\"+i+\": [\"+aV[parseInt(aRef[j],16)].split(\"/\")+\"],[\"+aV[parseInt(aRef[j+1],16)].split(\"/\")+\"],[\"+aV[parseInt(aRef[j+2],16)].split(\"/\")+\"]\");\n";
			asString += "\t\t\t\t\t\t\ttrace(\"     uvs: [\"+aV[parseInt(aRef[j+3],16)].split(\"/\")+\"],[\"+aV[parseInt(aRef[j+4],16)].split(\"/\")+\"],[\"+aU[parseInt(aRef[j+5],16)].split(\"/\")+\"]\");\n";
			asString += "\t\t\t\t\t\t}\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t}\n";
			asString += "\t\t}";
			asString += "\n\n\t\tprivate function setSource():void\n\t\t{";
			asString += geoString;
			//asString += "\t\t\tvar aVstr:String=\""+encode( MaV.toString() )+"\";\n\t\t\tvar aUstr:String=\""+encode( MaVt.toString() )+"\";\n";
			//asString += "\t\t\taV= read(aVstr).split(\",\");\n\t\t\taU= read(aUstr).split(\",\");\n";
			asString += "\t\t}";
		} else {
			asString += "\t\t}";
			asString += "\n\n\t\tprivate function setSource():void\n\t\t{}\n";
		}
		asString += "\n\t\tprivate function buildMaterials():void\n\t\t{";
		asString += materialString;
		asString += "\n\t\t}";
		asString += "\n\t\tprivate function cleanUp():void\n\t\t{";
		asString += "\n\t\t\tfor(var i:int = 0;i<" + objcount + ";++i){\n\t\t\t\tobjs[\"obj\"+i] == null;\n\t\t\t}\n\t\t\taV = null;\n\t\t\taU = null;\n\t\t}";
		if (isAnim) {
			asString += "\n\n\t\tprivate function setMeshAnim(mesh:Mesh, obj:Object, id:int):void\n\t\t{\n";
			asString += "\n\t\t\ttrace(\"\\nAnimation frames prefixes for : this.meshes[\"+id+\"]\");";
			asString += "\n\t\t\tmesh.geometry.frames = new Dictionary();";
			asString += "\n\t\t\tmesh.geometry.framenames = new Dictionary();";
			asString += "\n\t\t\tvar y:int;\n";
			asString += "\t\t\tvar z:int;\n";
			asString += "\t\t\tvar frame:Frame;\n";
			asString += "\t\t\tvar vp:VertexPosition;\n";
			asString += "\t\t\tfor(var i:int = 0;i<obj.fnarr.length; ++i){\n";
			asString += "\t\t\t\ttrace(\"[ \"+obj.fnarr[i]+\" ]\");\n";
			asString += "\t\t\t\tframe = new Frame();\n";
			asString += "\t\t\t\tmesh.geometry.framenames[obj.fnarr[i]] = i;\n";
			asString += "\t\t\t\tmesh.geometry.frames[i] = frame;\n";
			asString += "\t\t\t\tz=0;\n";
			asString += "\t\t\t\tfor (y = 0; y < obj[\"fr\"+obj.fnarr[i]].length; y+=3){\n";
			asString += "\t\t\t\t\tvp = new VertexPosition(mesh.vertices[z]);\n";
			asString += "\t\t\t\t\tz++;\n";
			asString += "\t\t\t\t\tvp.x = obj[\"fr\"+obj.fnarr[i]][y]*_scale;\n";
			asString += "\t\t\t\t\tvp.y = obj[\"fr\"+obj.fnarr[i]][y+1]*_scale;\n";
			asString += "\t\t\t\t\tvp.z = obj[\"fr\"+obj.fnarr[i]][y+2]*_scale;\n";
			asString += "\t\t\t\t\tframe.vertexpositions.push(vp);\n";
			asString += "\t\t\t\t}\n";
			asString += "\t\t\t\tif (i == 0)\n";
			asString += "\t\t\t\t\tframe.adjust();\n";
			asString += "\t\t\t}\n";
			asString += "\t\t}";
		}
		if (containerString != "") {
			asString += "\n\n\t\tprivate function addContainers():void\n\t\t{\n";
			asString += "\t\t\taC = [];\n";
			asString += "\t\t\t" + containerString + "\n";
			asString += "\t\t}";
			asString += "\n\n\t\tpublic function get containers():Array\n\t\t{\n";
			asString += "\t\t\treturn aC;\n";
			asString += "\t\t}\n";
		} else {
			asString += "\n\n\t\tprivate function addContainers():void\n\t\t{}\n";
		}
		asString += "\n\n\t\tpublic function get meshes():Array\n\t\t{\n";
		asString += "\t\t\treturn oList;\n\t\t}\n";
		asString += "\n\n\t\tprivate function read(str:String):String\n\t\t{\n";
		asString += "\t\t\tvar start:int= 0;\n";
		asString += "\t\t\tvar chunk:String;\n";
		asString += "\t\t\tvar end:int= 0;\n";
		asString += "\t\t\tvar dec:String = \"\";\n";
		asString += "\t\t\tvar charcount:int = str.length;\n";
		asString += "\t\t\tfor(var i:int = 0;i<charcount;++i){\n";
		asString += "\t\t\t\tif (str.charCodeAt(i)>=44 && str.charCodeAt(i)<= 48 ){";
		asString += "\n\t\t\t\t\tdec+= str.substring(i, i+1);";
		asString += "\n\t\t\t\t}else{";
		asString += "\n\t\t\t\t\tstart = i;";
		asString += "\n\t\t\t\t\tchunk = \"\";";
		asString += "\n\t\t\t\t\twhile(str.charCodeAt(i)!=44 && str.charCodeAt(i)!= 45 && str.charCodeAt(i)!= 46 && str.charCodeAt(i)!= 47 && i<=charcount){";
		asString += "\n\t\t\t\t\t\ti++;";
		asString += "\n\t\t\t\t\t}";
		asString += "\n\t\t\t\t\tchunk = \"\"+parseInt(\"0x\"+str.substring(start, i), 16 );";
		asString += "\n\t\t\t\t\tdec+= chunk;";
		asString += "\n\t\t\t\t\ti--;";
		asString += "\n\t\t\t\t}\n";
		asString += "\t\t\t}\n";
		asString += "\t\t\treturn dec;";
		asString += "\n\t\t}\n";
		asString += "\n\t}\n}";
		System.setClipboard(asString);
		asString = "";
		trace("\n----------------------------------------------------------------------------\n AS3Exporter done: open a texteditor,\n\tpaste and save file in directory \"" + packagename + "\" as \"" + classname + ".as\".\n----------------------------------------------------------------------------\n");
	}

}

