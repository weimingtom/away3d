package away3d.exporters;

import away3d.core.base.UV;
import away3d.core.base.Mesh;
import away3d.core.base.Geometry;
import away3d.core.base.Object3D;
import away3d.containers.ObjectContainer3D;
import away3d.core.base.Face;
import away3d.core.math.Number3D;
import away3d.animators.utils.PathUtils;
import flash.events.EventDispatcher;
import flash.system.System;


// use namespace arcane;

/**
 * Class ObjExporter generates a string in the WaveFront obj format representing the object3D(s). Paste to a texteditor and save as filename.obj.
 * 
 */
class ObjExporter  {
	
	private var objString:String;
	private var gcount:Int;
	private var indV:Int;
	private var indVn:Int;
	private var indVt:Int;
	private var indF:Int;
	private var _scaling:Float;
	private var _righthanded:Bool;
	private var nRotation:Number3D;
	

	private function write(object3d:Object3D):Void {
		
		var aV:Array<Dynamic> = [];
		var aVn:Array<Dynamic> = [];
		var aVt:Array<Dynamic> = [];
		var aF:Array<Dynamic> = [];
		objString += "\n";
		var aFaces:Array<Dynamic> = (cast(object3d, Mesh)).faces;
		var face:Face;
		var n0:Number3D;
		var n1:Number3D;
		var n2:Number3D;
		var geometry:Geometry = (cast(object3d, Mesh)).geometry;
		var va:Int;
		var vb:Int;
		var vc:Int;
		var vta:Int;
		var vtb:Int;
		var vtc:Int;
		var na:Int;
		var nb:Int;
		var nc:Int;
		nRotation.x = object3d.rotationX;
		nRotation.y = object3d.rotationY;
		nRotation.z = object3d.rotationZ;
		var nPos:Number3D = object3d.scenePosition;
		var tmp:Number3D = new Number3D();
		var j:Int;
		var aRef:Array<Dynamic> = [vc, vb, va];
		var i:Int = 0;
		while (i < aFaces.length) {
			face = aFaces[i];
			j = 2;
			while (j > -1) {
				tmp.x = (Reflect.field(face, "v" + j).x + nPos.x) * _scaling;
				tmp.y = (Reflect.field(face, "v" + j).y + nPos.y) * _scaling;
				tmp.z = (Reflect.field(face, "v" + j).z + nPos.z) * _scaling;
				tmp = PathUtils.rotatePoint(tmp, nRotation);
				if (_righthanded) {
					tmp.x *= -1;
					tmp.z *= -1;
				}
				aRef[j] = checkDoubles(aV, ("v " + tmp.x.toFixed(10) + " " + tmp.y.toFixed(10) + " " + tmp.z.toFixed(10) + "\n"));
				
				// update loop variables
				--j;
			}

			vta = checkDoubles(aVt, ("vt " + (_righthanded ? 1 - face.uv2.u : face.uv2.u) + " " + (_righthanded ? face.uv2.v : 1 - face.uv2.v) + "\n"));
			vtb = checkDoubles(aVt, ("vt " + (_righthanded ? 1 - face.uv1.u : face.uv1.u) + " " + (_righthanded ? face.uv1.v : 1 - face.uv1.v) + "\n"));
			vtc = checkDoubles(aVt, ("vt " + (_righthanded ? 1 - face.uv0.u : face.uv0.u) + " " + (_righthanded ? face.uv0.v : 1 - face.uv0.v) + "\n"));
			n0 = geometry.getVertexNormal(face.v0);
			n1 = geometry.getVertexNormal(face.v1);
			n2 = geometry.getVertexNormal(face.v2);
			na = checkDoubles(aVn, ("vn " + n2.x.toFixed(15) + " " + n2.y.toFixed(15) + " " + n2.z.toFixed(15) + "\n"));
			nb = checkDoubles(aVn, ("vn " + n1.x.toFixed(15) + " " + n1.y.toFixed(15) + " " + n1.z.toFixed(15) + "\n"));
			nc = checkDoubles(aVn, ("vn " + n0.x.toFixed(15) + " " + n0.y.toFixed(15) + " " + n0.z.toFixed(15) + "\n"));
			aF.push("f " + (aRef[2] + indV) + "/" + (vta + indVt) + "/" + (na + indVn) + " " + (aRef[1] + indV) + "/" + (vtb + indVt) + "/" + (nb + indVn) + " " + (aRef[0] + indV) + "/" + (vtc + indVt) + "/" + (nc + indVn) + "\n");
			
			// update loop variables
			++i;
		}

		indV += aV.length;
		indVn += aVn.length;
		indVt += aVt.length;
		indF += aF.length;
		objString += "# Number of vertices: " + aV.length + "\n";
		i = 0;
		while (i < aV.length) {
			objString += aV[i];
			
			// update loop variables
			++i;
		}

		objString += "\n# Number of Normals: " + aVn.length + "\n";
		i = 0;
		while (i < aVn.length) {
			objString += aVn[i];
			
			// update loop variables
			++i;
		}

		objString += "\n# Number of Texture Vertices: " + aVt.length + "\n";
		i = 0;
		while (i < aVt.length) {
			objString += aVt[i];
			
			// update loop variables
			++i;
		}

		objString += "\n# Number of Polygons: " + aF.length + "\n";
		i = 0;
		while (i < aF.length) {
			objString += aF[i];
			
			// update loop variables
			++i;
		}

	}

	private function checkDoubles(arr:Array<Dynamic>, string:String):Int {
		
		var i:Int = 0;
		while (i < arr.length) {
			if (arr[i] == string) {
				return i + 1;
			}
			
			// update loop variables
			++i;
		}

		arr.push(string);
		return arr.length;
	}

	private function parse(object3d:Object3D):Void {
		
		if (Std.is(object3d, ObjectContainer3D)) {
			var obj:ObjectContainer3D = (cast(object3d, ObjectContainer3D));
			objString += "g g" + gcount + "\n";
			gcount++;
			var i:Int = 0;
			while (i < obj.children.length) {
				if (Std.is(obj.children[i], ObjectContainer3D)) {
					parse(obj.children[i]);
				} else {
					write(obj.children[i]);
				}
				
				// update loop variables
				i++;
			}

		} else {
			write(object3d);
		}
	}

	function new(object3d:Object3D, ?righthanded:Bool=true, ?scaling:Float=0.001) {
		this.gcount = 0;
		this.indV = 0;
		this.indVn = 0;
		this.indVt = 0;
		this.indF = 0;
		this.nRotation = new Number3D();
		
		
		objString = "# Obj file generated by Away3D: http://www.away3d.com\n# exporter version 1.0 \n";
		_righthanded = righthanded;
		_scaling = scaling;
		parse(object3d);
		objString += "\n#\n# Total number of vertices: " + indV;
		objString += "\n# Total number of Normals: " + indVn;
		objString += "\n# Total number of Texture Vertices: " + indVt;
		objString += "\n# Total number of Polygons: " + indF + "\n";
		objString += "\n# End of File";
		System.setClipboard(objString);
		trace("ObjExporter done: open an external texteditor and paste!!");
	}

}

