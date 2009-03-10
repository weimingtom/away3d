package away3d.animators;

import flash.utils.Dictionary;
import away3d.core.base.Face;
import away3d.core.base.Geometry;
import flash.events.EventDispatcher;
import away3d.core.base.Element;
import away3d.core.base.Object3D;
import away3d.core.base.VertexPosition;
import away3d.core.base.Mesh;
import away3d.core.base.Frame;
import away3d.core.base.Vertex;


class Animator extends Mesh  {
	public var framelist(getFramelist, null) : Array<Dynamic>;
	
	private var varr:Array<Dynamic>;
	private var uvarr:Array<Dynamic>;
	private var fnarr:Array<String>;
	

	private function getVertIndex(face:Face):Array<Dynamic> {
		
		var a:Int = 0;
		var b:Int = 0;
		var c:Int = 0;
		var i:Int = 0;
		while (i < varr.length) {
			a = (varr[i] == face.v0) ? i : a;
			b = (varr[i] == face.v1) ? i : b;
			c = (varr[i] == face.v2) ? i : c;
			if (a != 0 && b != 0 && c != 0) {
				break;
			}
			
			// update loop variables
			i++;
		}

		return [a, b, c];
	}

	//Array aFrames properties: vertices:Array[vertex.x,y and z positions], prefix:String
	public function generate(baseObject:Mesh, aFrames:Array<Dynamic>, doloop:Bool):Void {
		
		var i:Int;
		var j:Int;
		var k:Int;
		// export requirement
		indexes = new Array<Dynamic>();
		var aVti:Array<Dynamic>;
		if (doloop) {
			var fr:Dynamic = {};
			fr.vertices = aFrames[0].vertices;
			fr.prefix = aFrames[0].prefix;
			var pref:String = "";
			i = 0;
			while (i < fr.prefix.length) {
				if (Math.isNaN(fr.prefix.substr(i, i + 1 - i))) {
					pref += fr.prefix.substr(i, i + 1 - i);
				} else {
					break;
				}
				
				// update loop variables
				i++;
			}

			fr.prefix = pref + (aFrames.length + 1);
			aFrames.push(fr);
		}
		var face:Face;
		varr = varr.concat(baseObject.geometry.vertices);
		i = 0;
		while (i < baseObject.faces.length) {
			face = baseObject.faces[i];
			uvarr.push(face.uv0);
			uvarr.push(face.uv1);
			uvarr.push(face.uv2);
			addFace(face);
			aVti = getVertIndex(face);
			indexes.push([aVti[0], aVti[1], aVti[2], uvarr.length - 3, uvarr.length - 2, uvarr.length - 1]);
			
			// update loop variables
			i++;
		}

		geometry.frames = new Dictionary();
		geometry.framenames = new Hash<Int>();
		fnarr = [];
		var oFrames:Dynamic = {};
		var arr:Array<Dynamic>;
		i = 0;
		while (i < aFrames.length) {
			Reflect.setField(oFrames, aFrames[i].prefix, new Array());
			fnarr.push(aFrames[i].prefix);
			arr = aFrames[i].vertices;
			j = 0;
			while (j < arr.length) {
				Reflect.field(oFrames, aFrames[i].prefix).push(arr[j], arr[j], arr[j]);
				
				// update loop variables
				j++;
			}

			
			// update loop variables
			i++;
		}

		var frame:Frame;
		var vertex:Vertex;
		i = 0;
		while (i < fnarr.length) {
			//trace("[ " + fnarr[i] + " ]");
			frame = new Frame();
			geometry.framenames.set(fnarr[i], i);
			geometry.frames[untyped i] = frame;
			k = 0;
			j = 0;
			while (j < Reflect.field(oFrames, fnarr[i]).length) {
				var vp:VertexPosition = new VertexPosition(varr[k]);
				k++;
			
				vertex = Reflect.field(oFrames, fnarr[i])[j];
				vp.x = vertex.x;
				vertex = Reflect.field(oFrames, fnarr[i])[j + 1];
				vp.y = vertex.y;
				vertex = Reflect.field(oFrames, fnarr[i])[j + 2];
				vp.z = vertex.z;
				
				frame.vertexpositions.push(vp);
				
				// update loop variables
				j += 3;
			}

			if (i == 0) {
				frame.adjust();
			}
			
			// update loop variables
			i++;
		}

	}

	public function getFramelist():Array<Dynamic> {
		
		return fnarr;
	}

	/**
	 * Add new frames to the object at runtime
	 * 
	 * @paramaFrames				A multidimentional array with vertices references  [{vertices:object3d1.vertices, prefix:"frame1"}, {vertices:object3d2.vertices, prefix:"frame2"}]
	 * 
	 */
	public function addFrames(aFrames:Array<Dynamic>):Void {
		
		var i:Int;
		var j:Int;
		var k:Int;
		var oFrames:Dynamic = {};
		var arr:Array<Dynamic>;
		i = 0;
		while (i < aFrames.length) {
			Reflect.setField(oFrames, aFrames[i].prefix, new Array());
			fnarr.push(aFrames[i].prefix);
			arr = aFrames[i].vertices;
			j = 0;
			while (j < arr.length) {
				Reflect.field(oFrames, aFrames[i].prefix).push(arr[j], arr[j], arr[j]);
				
				// update loop variables
				j++;
			}

			
			// update loop variables
			i++;
		}

		var frame:Frame;
		var vertex:Vertex;
		i = 0;
		while (i < fnarr.length) {
			//trace("[ " + fnarr[i] + " ]");
			frame = new Frame();
			geometry.framenames.set(fnarr[i], i);
			geometry.frames[untyped i] = frame;
			k = 0;
			j = 0;
			while (j < Reflect.field(oFrames, fnarr[i]).length) {
				var vp:VertexPosition = new VertexPosition(varr[k]);
				k++;

		
				vertex = Reflect.field(oFrames, fnarr[i])[j];
				vp.x = vertex.x;
				vertex = Reflect.field(oFrames, fnarr[i])[j + 1];
				vp.y = vertex.y;
				vertex = Reflect.field(oFrames, fnarr[i])[j + 2];
				vp.z = vertex.z;

				frame.vertexpositions.push(vp);
				
				// update loop variables
				j += 3;
			}

			if (i == 0) {
				frame.adjust();
			}
			
			// update loop variables
			i++;
		}

	}

	/**
	 * Creates a new <code>Animator</code> object.
	 * 
	 * @param	baseObject			The Mesh to be used as reference
	 * @paramaFrames				A multidimentional array with vertices references  [{vertices:object3d1.vertices, prefix:"frame1"}, {vertices:object3d2.vertices, prefix:"frame2"}]
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 * @param	doloop	[optional]	If the geometry needs to be shown in a loop
	 * 
	 */
	public function new(baseObject:Mesh, aFrames:Array<Dynamic>, ?init:Dynamic=null, ?doloop:Bool=false) {
		this.varr = [];
		this.uvarr = [];
		this.fnarr = [];
		
		
		super(init);
		generate(baseObject, aFrames, doloop);
		type = "Animator";
		url = "Mesh";
	}

	/**
	 * Scales the vertex positions contained within all animation frames
	 * 
	 * @param	scale	The scaling value
	 */
	public function scaleAnimation(scale:Float):Void {
		
		var tmpnames:Array<Dynamic> = new Array<Dynamic>();
		var i:Int = 0;
		var y:Int = 0;
		var framename:String;
		for (framename in geometry.framenames.keys()) {
			tmpnames.push(framename);
		}

		var fr:Frame;
		i = 0;
		while (i < tmpnames.length) {
			fr = geometry.frames[untyped geometry.framenames.get(tmpnames[i])];
			y = 0;
			while (y < fr.vertexpositions.length) {
				fr.vertexpositions[y].x *= scale;
				fr.vertexpositions[y].y *= scale;
				fr.vertexpositions[y].z *= scale;
				
				// update loop variables
				y++;
			}

			
			// update loop variables
			i++;
		}

	}

}

