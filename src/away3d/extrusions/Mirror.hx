package away3d.extrusions;

import away3d.core.math.Number3D;
import away3d.containers.ObjectContainer3D;
import away3d.materials.ITriangleMaterial;
import flash.events.EventDispatcher;
import away3d.core.base.Face;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


/**
 * Class Mirror an Object3D geometry and its uv's <Mirror></code>
 * 
 */
class Mirror  {
	
	private static var Axes:Array<Dynamic> = ["x-", "x+", "x", "y-", "y+", "y", "z-", "z+", "z"];
	

	private static function validate(axe:String):Bool {
		
		var i:Int = 0;
		while (i < Mirror.Axes.length) {
			if (axe == Mirror.Axes[i]) {
				return true;
			}
			
			// update loop variables
			i++;
		}

		return false;
	}

	private static function build(object3d:Object3D, axe:String, recenter:Bool, ?duplicate:Bool=true):Void {
		
		var obj:Mesh = (cast(object3d, Mesh));
		var aFaces:Array<Dynamic> = obj.faces;
		var face:Face;
		var i:Int;
		var uva:UV;
		var uvb:UV;
		var uvc:UV;
		var va:Vertex;
		var vb:Vertex;
		var vc:Vertex;
		var mat:ITriangleMaterial;
		var uv0:UV;
		var uv1:UV;
		var uv2:UV;
		var v0:Vertex;
		var v1:Vertex;
		var v2:Vertex;
		var posi:Number3D = object3d.position;
		var facecount:Int = aFaces.length;
		var offset:Float;
		var flip:Bool = true;
		switch (axe) {
			case "x" :
				offset = posi.x;
			case "x-" :
				offset = Math.abs(object3d.minX) + object3d.maxX;
			case "x+" :
				offset = Math.abs(object3d.minX) + object3d.maxX;
			case "y" :
				offset = posi.y;
			case "y-" :
				offset = Math.abs(object3d.minY) + object3d.maxY;
			case "y+" :
				offset = Math.abs(object3d.minY) + object3d.maxY;
			case "z" :
				offset = posi.z;
			case "z-" :
				flip = false;
				offset = Math.abs(object3d.minZ) + object3d.maxZ;
			case "z+" :
				flip = false;
				offset = Math.abs(object3d.minZ) + object3d.maxZ;
			

		}
		i = 0;
		while (i < facecount) {
			face = aFaces[i];
			mat = face.material;
			va = face.v0;
			vb = face.v1;
			vc = face.v2;
			if (!duplicate) {
				uva = face.uv0;
				uvb = face.uv1;
				uvc = face.uv2;
				uv0 = new UV();
				uv1 = new UV();
				uv2 = new UV();
				face.v0 = face.v1 = face.v2 = null;
				face.uv0 = face.uv1 = face.uv2 = null;
			}
			switch (axe) {
				case "x" :
					v0 = new Vertex();
					v1 = new Vertex();
					v2 = new Vertex();
				case "x-" :
					v0 = new Vertex();
					v1 = new Vertex();
					v2 = new Vertex();
				case "x+" :
					v0 = new Vertex();
					v1 = new Vertex();
					v2 = new Vertex();
				case "y" :
					v0 = new Vertex();
					v1 = new Vertex();
					v2 = new Vertex();
				case "y-" :
					v0 = new Vertex();
					v1 = new Vertex();
					v2 = new Vertex();
				case "y+" :
					v0 = new Vertex();
					v1 = new Vertex();
					v2 = new Vertex();
				case "z" :
					v0 = new Vertex();
					v1 = new Vertex();
					v2 = new Vertex();
				case "z-" :
					v0 = new Vertex();
					v1 = new Vertex();
					v2 = new Vertex();
				case "z+" :
					v0 = new Vertex();
					v1 = new Vertex();
					v2 = new Vertex();
				

			}
			if (flip) {
				if (duplicate) {
					obj.addFace(new Face());
				} else {
					face.v0 = v1;
					face.v1 = v0;
					face.v2 = v2;
					face.uv0 = uv1;
					face.uv1 = uv0;
					face.uv2 = uv2;
				}
			} else {
				if (duplicate) {
					obj.addFace(new Face());
				} else {
					face.v0 = v0;
					face.v1 = v1;
					face.v2 = v2;
					face.uv0 = uv0;
					face.uv1 = uv1;
					face.uv2 = uv2;
				}
			}
			
			// update loop variables
			i++;
		}

		if (recenter) {
			obj.applyPosition((obj.minX + obj.maxX) * .5, (obj.minY + obj.maxY) * .5, (obj.minZ + obj.maxZ) * .5);
		}
	}

	/**
	 * Mirrors an Object3D Mesh object geometry and uv's
	 * 
	 * @param	 object3d		The Object3D, ObjectContainer3D are parsed recurvely as well.
	 * @param	 axe		A string "x-", "x+", "x", "y-", "y+", "y", "z-", "z+", "z". "x", "y","z" mirrors on world position 0,0,0, the + mirrors geometry in positive direction, the - mirrors geometry in positive direction.
	 * @param	 recenter	[optional]	Recenter the Object3D pivot. This doesn't affect ObjectContainers3D's. Default is true.
	 * @param	 duplicate	[optional]	Duplicate model geometry along the axe or set to false mirror but do not duplicate. Default is true.
	 * 
	 */
	public static function apply(object3d:Object3D, axe:String, ?recenter:Bool=true, ?duplicate:Bool=true):Void {
		
		axe = axe.toLowerCase();
		if (Mirror.validate(axe)) {
			if (Std.is(object3d, ObjectContainer3D)) {
				var obj:ObjectContainer3D = (cast(object3d, ObjectContainer3D));
				var i:Int = 0;
				while (i < obj.children.length) {
					if (Std.is(obj.children[i], ObjectContainer3D)) {
						Mirror.apply(obj.children[i], axe, recenter, duplicate);
					} else {
						Mirror.build(obj.children[i], axe, recenter, duplicate);
					}
					
					// update loop variables
					i++;
				}

			} else {
				Mirror.build(object3d, axe, recenter, duplicate);
			}
		} else {
			trace("Mirror error: unvalid axe string:" + Mirror.Axes.toString());
		}
	}

	// autogenerated
	public function new () {
		
	}

	

}

