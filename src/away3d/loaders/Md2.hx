package away3d.loaders;

import away3d.haxeutils.Error;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import away3d.core.base.Frame;
import away3d.core.base.Face;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import away3d.core.utils.Cast;
import away3d.core.utils.Init;
import flash.utils.Endian;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.base.VertexPosition;


// use namespace arcane;

/**
 * File loader for the Md2 file format.
 * 
 * @author Philippe Ajoux (philippe.ajoux@gmail.com)
 */
class Md2 extends AbstractParser  {
	
	private var ini:Init;
	private var ident:Int;
	private var version:Int;
	private var skinwidth:Int;
	private var skinheight:Int;
	private var framesize:Int;
	private var num_skins:Int;
	private var num_vertices:Int;
	private var num_st:Int;
	private var num_tris:Int;
	private var num_glcmds:Int;
	private var num_frames:Int;
	private var offset_skins:Int;
	private var offset_st:Int;
	private var offset_tris:Int;
	private var offset_frames:Int;
	private var offset_glcmds:Int;
	private var offset_end:Int;
	private var mesh:Mesh;
	private var scaling:Float;
	

	private function parseMd2(data:ByteArray):Void {
		
		data.endian = Endian.LITTLE_ENDIAN;
		var vertices:Array<Dynamic> = [];
		var faces:Array<Dynamic> = [];
		var uvs:Array<Dynamic> = [];
		ident = data.readInt();
		version = data.readInt();
		// Make sure it is valid MD2 file
		if (ident != 844121161 || version != 8) {
			throw new Error("Error loading MD2 file: Not a valid MD2 file/bad version");
		}
		skinwidth = data.readInt();
		skinheight = data.readInt();
		framesize = data.readInt();
		num_skins = data.readInt();
		num_vertices = data.readInt();
		num_st = data.readInt();
		num_tris = data.readInt();
		num_glcmds = data.readInt();
		num_frames = data.readInt();
		offset_skins = data.readInt();
		offset_st = data.readInt();
		offset_tris = data.readInt();
		offset_frames = data.readInt();
		offset_glcmds = data.readInt();
		offset_end = data.readInt();
		var i:Int;
		// Vertice setup
		//      Be sure to allocate memory for the vertices to the object
		//      These vertices will be updated each frame with the proper coordinates
		i = 0;
		while (i < num_vertices) {
			vertices.push(new Vertex());
			
			// update loop variables
			i++;
		}

		// UV coordinates
		data.position = offset_st;
		i = 0;
		while (i < num_st) {
			uvs.push(new UV(data.readShort() / skinwidth, 1 - (data.readShort() / skinheight)));
			
			// update loop variables
			i++;
		}

		// Faces
		data.position = offset_tris;
		// export requirement
		mesh.indexes = new Array();
		i = 0;
		while (i < num_tris) {
			var a:Int = data.readUnsignedShort();
			var b:Int = data.readUnsignedShort();
			var c:Int = data.readUnsignedShort();
			var ta:Int = data.readUnsignedShort();
			var tb:Int = data.readUnsignedShort();
			var tc:Int = data.readUnsignedShort();
			mesh.indexes.push([a, b, c, ta, tb, tc]);
			mesh.addFace(new Face(vertices[a], vertices[b], vertices[c], null, uvs[ta], uvs[tb], uvs[tc]));
			
			// update loop variables
			i++;
		}

		// Frame animation data
		//      This part is a little funky.
		data.position = offset_frames;
		readFrames(data, vertices, num_frames);
		mesh.type = ".Md2";
	}

	private function readFrames(data:ByteArray, vertices:Array<Dynamic>, num_frames:Int):Void {
		
		mesh.geometry.frames = new Dictionary();
		mesh.geometry.framenames = new Dictionary();
		var i:Int = 0;
		while (i < num_frames) {
			var frame:Frame = new Frame();
			var sx:Float = data.readFloat();
			var sy:Float = data.readFloat();
			var sz:Float = data.readFloat();
			var tx:Float = data.readFloat();
			var ty:Float = data.readFloat();
			var tz:Float = data.readFloat();
			var name:String = "";
			var j:Int = 0;
			while (j < 16) {
				var char:Int = data.readUnsignedByte();
				if (char != 0) {
					name += String.fromCharCode(char);
				}
				
				// update loop variables
				j++;
			}

			trace("[ " + name + " ]");
			Reflect.setField(mesh.geometry.framenames, name, i);
			mesh.geometry.frames[i] = frame;
			var h:Int = 0;
			while (h < vertices.length) {
				var vp:VertexPosition = new VertexPosition(vertices[h]);
				vp.x = -((sx * data.readUnsignedByte()) + tx) * scaling;
				vp.z = ((sy * data.readUnsignedByte()) + ty) * scaling;
				vp.y = ((sz * data.readUnsignedByte()) + tz) * scaling;
				// "vertex normal index"
				data.readUnsignedByte();
				frame.vertexpositions.push(vp);
				
				// update loop variables
				h++;
			}

			if (i == 0) {
				frame.adjust();
			}
			
			// update loop variables
			i++;
		}

	}

	/**
	 * Creates a new <code>Md2</code> object. Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods.
	 * 
	 * @param	data				The binary data of a loaded file.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 * 
	 * @see away3d.loaders.Md2#parse()
	 * @see away3d.loaders.Md2#load()
	 */
	public function new(data:Dynamic, ?init:Dynamic=null) {
		// autogenerated
		super();
		
		
		ini = Init.parse(init);
		scaling = ini.getNumber("scaling", 1) * 100;
		mesh = cast((container = new Mesh(ini)), Mesh);
		parseMd2(Cast.bytearray(data));
	}

	/**
	 * Creates a 3d mesh object from the raw xml data of an md2 file.
	 * 
	 * @param	data				The binary data of a loaded file.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 * 
	 * @return						A 3d mesh object representation of the md2 file.
	 */
	public static function parse(data:Dynamic, ?init:Dynamic=null):Mesh {
		
		return cast(Object3DLoader.parseGeometry(data, Md2, init).handle, Mesh);
	}

	/**
	 * Loads and parses an md2 file into a 3d mesh object.
	 * 
	 * @param	url					The url location of the file to load.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.
	 */
	public static function load(url:String, ?init:Dynamic=null):Object3DLoader {
		
		return Object3DLoader.loadGeometry(url, Md2, true, init);
	}

}

