package away3d.animators;

import away3d.animators.data.AnimationKeyFrameData;
import away3d.core.base.Face;
import away3d.core.base.Vertex;
import away3d.core.base.UV;
import away3d.core.base.Geometry;
import flash.events.EventDispatcher;
import away3d.core.base.Element;
import away3d.core.base.Object3D;
import away3d.core.base.VertexPosition;
import away3d.core.base.Mesh;
import away3d.core.base.Frame;


class Animator extends Mesh  {
	public var framelist(getFramelist, null) : Array<String>;
	
	private var varr:Array<Vertex>;
	private var uvarr:Array<UV>;
	private var fnarr:Array<String>;
	

	private function getVertIndex(face:Face):Array<Int> {
		
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
	public function generate(baseObject:Mesh, aFrames:Array<AnimationKeyFrameData>, doloop:Bool):Void {
		
		var i:Int;
		var j:Int;
		var k:Int;
		// export requirement
		var aVti:Array<Int>;
		if (doloop) {
			var fr:AnimationKeyFrameData = new AnimationKeyFrameData(aFrames[0].vertices, aFrames[0].prefix);
			var pref:String = "";
			i = 0;
			while (i < fr.prefix.length) {
				if (Std.parseInt(fr.prefix.substr(i, 1)) == null) {
					pref += fr.prefix.substr(i, 1);
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
		varr = untyped varr.concat(baseObject.geometry.vertices);
		i = 0;
		while (i < baseObject.faces.length) {
			face = baseObject.faces[i];
			uvarr.push(face.uv0);
			uvarr.push(face.uv1);
			uvarr.push(face.uv2);
			addFace(face);
			aVti = getVertIndex(face);
			
			// update loop variables
			i++;
		}

		geometry.frames = new IntHash<Frame>();
		geometry.framenames = new Hash<Int>();
		fnarr = [];
		var oFrames:Hash<Array<Vertex>> = new Hash<Array<Vertex>>();
		var arr:Array<Vertex>;
		i = 0;
		while (i < aFrames.length) {
			oFrames.set(aFrames[i].prefix, new Array<Vertex>());
			
			fnarr.push(aFrames[i].prefix);
			arr = aFrames[i].vertices;
			j = 0;
			while (j < arr.length) {
				oFrames.get(aFrames[i].prefix).push(arr[j]);
				oFrames.get(aFrames[i].prefix).push(arr[j]);
				oFrames.get(aFrames[i].prefix).push(arr[j]);
				
				
				// update loop variables
				j++;
			}

			
			// update loop variables
			i++;
		}

		var frame:Frame;
		i = 0;
		while (i < fnarr.length) {
			//trace("[ " + fnarr[i] + " ]");
			frame = new Frame();
			geometry.framenames.set(fnarr[i], i);
			geometry.frames.set(i, frame);
			k = 0;
			j = 0;
			while (j < oFrames.get(fnarr[i]).length) {
				var vp:VertexPosition = new VertexPosition(varr[k]);
				k++;
				vp.x = oFrames.get(fnarr[i])[j].x;
				vp.y = oFrames.get(fnarr[i])[j + 1].y;
				vp.z = oFrames.get(fnarr[i])[j + 2].z;
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

	public function getFramelist():Array<String> {
		
		return fnarr;
	}

	/**
	 * Add new frames to the object at runtime
	 * 
	 * @paramaFrames				A multidimentional array with vertices references  [{vertices:object3d1.vertices, prefix:"frame1"}, {vertices:object3d2.vertices, prefix:"frame2"}]
	 * 
	 */
	public function addFrames(aFrames:Array<AnimationKeyFrameData>):Void {
		
		var i:Int;
		var j:Int;
		var k:Int;
		var oFrames:Hash<Array<Vertex>> = new Hash<Array<Vertex>>();
		var arr:Array<Vertex>;
		i = 0;
		while (i < aFrames.length) {
			oFrames.set(aFrames[i].prefix, new Array<Vertex>());
			
			fnarr.push(aFrames[i].prefix);
			arr = aFrames[i].vertices;
			j = 0;
			while (j < arr.length) {
				oFrames.get(aFrames[i].prefix).push(arr[j]);
				oFrames.get(aFrames[i].prefix).push(arr[j]);
				oFrames.get(aFrames[i].prefix).push(arr[j]);
				
				// update loop variables
				j++;
			}

			
			// update loop variables
			i++;
		}

		var frame:Frame;
		i = 0;
		while (i < fnarr.length) {
			trace("[ " + fnarr[i] + " ]");
			frame = new Frame();
			geometry.framenames.set(fnarr[i], i);
			geometry.frames.set(i, frame);
			k = 0;
			j = 0;
			while (j < Reflect.field(oFrames, fnarr[i]).length) {
				var vp:VertexPosition = new VertexPosition(varr[k]);
				k++;
				vp.x = oFrames.get(fnarr[i])[j].x;
				vp.y = oFrames.get(fnarr[i])[j + 1].y;
				vp.z = oFrames.get(fnarr[i])[j + 2].z;
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
	public function new(baseObject:Mesh, aFrames:Array<AnimationKeyFrameData>, ?init:Dynamic=null, ?doloop:Bool=false) {
		this.varr = new Array<Vertex>();
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
		
		var tmpnames:Array<String> = new Array<String>();
		var i:Int = 0;
		var y:Int = 0;
		for (framename in geometry.framenames.keys()) {
			tmpnames.push(framename);
		}

		var fr:Frame;
		i = 0;
		while (i < tmpnames.length) {
			fr = geometry.frames.get(geometry.framenames.get(tmpnames[i]));
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

