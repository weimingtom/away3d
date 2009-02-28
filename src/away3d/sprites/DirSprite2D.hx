package away3d.sprites;

import flash.display.BitmapData;
import flash.utils.Dictionary;
import away3d.core.utils.ValueObject;
import away3d.core.base.Object3D;
import away3d.core.utils.Init;
import away3d.core.utils.Debug;
import away3d.core.project.ProjectorType;
import away3d.core.base.Vertex;


/**
 * Spherical billboard (always facing the camera) sprite object that uses an array of bitmapData objects defined with viewing direction vectors.
 * Draws 2d directional image dependent on viewing angle inline with z-sorted triangles in a scene.
 */
class DirSprite2D extends Object3D  {
	public var vertices(getVertices, null) : Array<Dynamic>;
	public var bitmaps(getBitmaps, null) : Dictionary;
	
	private var _vertices:Array<Dynamic>;
	private var _bitmaps:Dictionary;
	/**
	 * Defines the overall scaling of the sprite object
	 */
	public var scaling:Float;
	/**
	 * Defines the overall 2d rotation of the sprite object
	 */
	public var rotation:Float;
	/**
	 * Defines whether the texture bitmap is smoothed (bilinearly filtered) when drawn to screen
	 */
	public var smooth:Bool;
	/**
	 * An optional offset value added to the z depth used to sort the sprite
	 */
	public var deltaZ:Float;
	

	public function getVertices():Array<Dynamic> {
		
		return _vertices;
	}

	public function getBitmaps():Dictionary {
		
		return _bitmaps;
	}

	/**
	 * Creates a new <code>DirSprite2D</code> object.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		this._vertices = [];
		this._bitmaps = new Dictionary(true);
		
		OPPOSITE_OR[X | X] = N;
		OPPOSITE_OR[XY | X] = Y;
		OPPOSITE_OR[XZ | X] = Z;
		OPPOSITE_OR[XYZ | X] = YZ;
		OPPOSITE_OR[Y | Y] = N;
		OPPOSITE_OR[XY | Y] = X;
		OPPOSITE_OR[XYZ | Y] = XZ;
		OPPOSITE_OR[YZ | Y] = Z;
		OPPOSITE_OR[Z | Z] = N;
		OPPOSITE_OR[XZ | Z] = X;
		OPPOSITE_OR[XYZ | Z] = XY;
		OPPOSITE_OR[YZ | Z] = Y;
		SCALINGS[1] = [1, 1, 1];
		SCALINGS[2] = [-1, 1, 1];
		SCALINGS[4] = [-1, 1, -1];
		SCALINGS[8] = [1, 1, -1];
		SCALINGS[16] = [1, -1, 1];
		SCALINGS[32] = [-1, -1, 1];
		SCALINGS[64] = [-1, -1, -1];
		SCALINGS[128] = [1, -1, -1];
		
		super(init);
		scaling = ini.getNumber("scaling", 1, {min:0});
		rotation = ini.getNumber("rotation", 0);
		smooth = ini.getBoolean("smooth", false);
		deltaZ = ini.getNumber("deltaZ", 0);
		var btmps:Array<Dynamic> = ini.getArray("bitmaps");
		for (__i in 0...btmps.length) {
			var btmp:Init = btmps[__i];

			if (btmp != null) {
				btmp = Init.parse(btmp);
				var x:Float = btmp.getNumber("x", 0);
				var y:Float = btmp.getNumber("y", 0);
				var z:Float = btmp.getNumber("z", 0);
				var b:BitmapData = btmp.getBitmap("bitmap");
				add(x, y, z, b);
			}
		}

		projectorType = ProjectorType.DIR_SPRITE;
	}

	/**
	 * Adds a new bitmap definition to the array of directional textures.
	 * 
	 * @param		x			The x coordinate of the directional texture.
	 * @param		y			The y coordinate of the directional texture.
	 * @param		z			The z coordinate of the directional texture.
	 * @param		bitmap		The bitmapData object to be used as the directional texture.
	 */
	public function add(x:Float, y:Float, z:Float, bitmap:BitmapData):Void {
		
		if ((bitmap != null)) {
			for (__i in 0..._vertices.length) {
				var v:Vertex = _vertices[__i];

				if (v != null) {
					if ((v.x == x) && (v.y == y) && (v.z == z)) {
						Debug.warning("Same base point for two bitmaps: " + v);
						return;
					}
				}
			}

		}
		var vertex:Vertex = new Vertex(x, y, z);
		_vertices.push(vertex);
		_bitmaps[untyped vertex] = bitmap;
	}

}

