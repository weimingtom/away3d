package away3d.materials;

import flash.events.EventDispatcher;
import away3d.core.utils.Cast;
import away3d.core.utils.Init;
import away3d.core.render.AbstractRenderSession;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;


/**
 * Color material with flat shading.
 */
class ShadingColorMaterial extends CenterLightingMaterial  {
	public var visible(getVisible, null) : Bool;
	
	private var fr:Int;
	private var fg:Int;
	private var fb:Int;
	private var sfr:Int;
	private var sfg:Int;
	private var sfb:Int;
	/**
	 * Defines a color value for ambient light.
	 */
	public var ambient:Int;
	/**
	 * Defines a color value for diffuse light.
	 */
	public var diffuse:Int;
	/**
	 * Defines a color value for specular light.
	 */
	public var specular:Int;
	/**
	 * Defines an alpha value for the texture.
	 */
	public var alpha:Float;
	/**
	 * Defines whether the resulting shaded color of the surface should be cached.
	 */
	public var cache:Bool;
	

	/**
	 * Creates a new <code>ShadingColorMaterial</code> object.
	 * 
	 * @param	color				A string, hex value or colorname representing the color of the material.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?color:Dynamic=null, ?init:Dynamic=null) {
		
		
		if (color == null) {
			color = "random";
		}
		color = Cast.trycolor(color);
		super(init);
		ambient = ini.getColor("ambient", color);
		diffuse = ini.getColor("diffuse", color);
		specular = ini.getColor("specular", color);
		alpha = ini.getNumber("alpha", 1);
		cache = ini.getBoolean("cache", false);
	}

	/**
	 * @inheritDoc
	 */
	private override function renderTri(tri:DrawTriangle, session:AbstractRenderSession, kar:Float, kag:Float, kab:Float, kdr:Float, kdg:Float, kdb:Float, ksr:Float, ksg:Float, ksb:Float):Void {
		
		fr = Std.int(((ambient & 0xFF0000) * kar + (diffuse & 0xFF0000) * kdr + (specular & 0xFF0000) * ksr) >> 16);
		fg = Std.int(((ambient & 0x00FF00) * kag + (diffuse & 0x00FF00) * kdg + (specular & 0x00FF00) * ksg) >> 8);
		fb = Std.int(((ambient & 0x0000FF) * kab + (diffuse & 0x0000FF) * kdb + (specular & 0x0000FF) * ksb));
		if (fr > 0xFF) {
			fr = 0xFF;
		}
		if (fg > 0xFF) {
			fg = 0xFF;
		}
		if (fb > 0xFF) {
			fb = 0xFF;
		}
		session.renderTriangleColor(fr << 16 | fg << 8 | fb, alpha, tri.v0, tri.v1, tri.v2);
		if (cache) {
			if (tri.faceVO != null) {
				sfr = Std.int(((ambient & 0xFF0000) * kar + (diffuse & 0xFF0000) * kdr) >> 16);
				sfg = Std.int(((ambient & 0x00FF00) * kag + (diffuse & 0x00FF00) * kdg) >> 8);
				sfb = Std.int(((ambient & 0x0000FF) * kab + (diffuse & 0x0000FF) * kdb));
				if (sfr > 0xFF) {
					sfr = 0xFF;
				}
				if (sfg > 0xFF) {
					sfg = 0xFF;
				}
				if (sfb > 0xFF) {
					sfb = 0xFF;
				}
				tri.faceVO.material = new ColorMaterial();
			}
		}
	}

	/**
	 * Indicates whether the material is visible
	 */
	public override function getVisible():Bool {
		
		return true;
	}

}

