package away3d.sprites;

import flash.display.DisplayObject;
import away3d.core.draw.ScreenVertex;
import away3d.core.base.Object3D;
import away3d.core.utils.Init;
import away3d.core.project.ProjectorType;
import away3d.core.draw.DrawDisplayObject;
import away3d.core.base.Vertex;


/**
 * Spherical billboard (always facing the camera) sprite object that uses a movieclip as it's texture.
 * Draws individual display objects inline with z-sorted triangles in a scene.
 */
class MovieClipSprite extends Object3D  {
	
	private var _center:Vertex;
	private var _sc:ScreenVertex;
	private var _persp:Float;
	private var _ddo:DrawDisplayObject;
	/**
	 * Defines the displayobject to use for the sprite texture.
	 */
	public var movieclip:DisplayObject;
	/**
	 * Defines the overall scaling of the sprite object
	 */
	public var scaling:Float;
	/**
	 * An optional offset value added to the z depth used to sort the sprite
	 */
	public var deltaZ:Float;
	/**
	 * Defines whether the sprite should scale with distance from the camera. Defaults to false
	 */
	public var rescale:Bool;
	

	/**
	 * Creates a new <code>MovieClipSprite</code> object.
	 * 
	 * @param	movieclip			The displayobject to use as the sprite texture.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(movieclip:DisplayObject, ?init:Dynamic=null) {
		this._center = new Vertex();
		
		
		super(init);
		this.movieclip = movieclip;
		scaling = ini.getNumber("scaling", 1);
		deltaZ = ini.getNumber("deltaZ", 0);
		rescale = ini.getBoolean("rescale", false);
		projectorType = ProjectorType.MOVIE_CLIP_SPRITE;
	}

}

