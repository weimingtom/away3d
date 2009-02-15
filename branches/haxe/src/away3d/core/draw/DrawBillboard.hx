package away3d.core.draw;

import away3d.materials.IBillboardMaterial;
import away3d.materials.IUVMaterial;
import flash.geom.Matrix;
import flash.geom.Point;


// use namespace arcane;

/** Billboard primitive */
class DrawBillboard extends DrawPrimitive  {
	
	/** @private */
	public var topleft:ScreenVertex;
	/** @private */
	public var topright:ScreenVertex;
	/** @private */
	public var bottomleft:ScreenVertex;
	/** @private */
	public var bottomright:ScreenVertex;
	/** @private */
	public var left:ScreenVertex;
	/** @private */
	public var top:ScreenVertex;
	private var cos:Float;
	private var sin:Float;
	private var cosw:Float;
	private var cosh:Float;
	private var sinw:Float;
	private var sinh:Float;
	private var bounds:ScreenVertex;
	private var uvMaterial:IUVMaterial;
	private var pointMapping:Matrix;
	private var w:Float;
	private var h:Float;
	public var mapping:Matrix;
	/**
	 * The screenvertex used to position the billboard primitive in the view.
	 */
	public var screenvertex:ScreenVertex;
	/**
	 * A scaling value used to scale the billboard primitive relative to the dimensions of a uv material.
	 */
	public var scale:Float;
	/**
	 * The width of the billboard if a non-uv material is used.
	 */
	public var width:Float;
	/**
	 * The height of the billboard if a non-uv material is used.
	 */
	public var height:Float;
	/**
	 * A rotation value used to rotate the scaled bitmap primitive.
	 */
	public var rotation:Float;
	/**
	 * The material object used as the billboard primitive's texture.
	 */
	public var material:IBillboardMaterial;
	

	/**
	 * @inheritDoc
	 */
	public override function calc():Void {
		
		screenZ = screenvertex.z;
		minZ = screenZ;
		maxZ = screenZ;
		uvMaterial = cast(material, IUVMaterial);
		if ((uvMaterial != null)) {
			w = uvMaterial.width * scale;
			h = uvMaterial.height * scale;
		} else {
			w = width * scale;
			h = height * scale;
		}
		if (rotation != 0) {
			cos = Math.cos(rotation * Math.PI / 180);
			sin = Math.sin(rotation * Math.PI / 180);
			cosw = cos * w / 2;
			cosh = cos * h / 2;
			sinw = sin * w / 2;
			sinh = sin * h / 2;
			topleft.x = screenvertex.x - cosw - sinh;
			topleft.y = screenvertex.y + sinw - cosh;
			topright.x = screenvertex.x + cosw - sinh;
			topright.y = screenvertex.y - sinw - cosh;
			bottomleft.x = screenvertex.x - cosw + sinh;
			bottomleft.y = screenvertex.y + sinw + cosh;
			bottomright.x = screenvertex.x + cosw + sinh;
			bottomright.y = screenvertex.y - sinw + cosh;
			var boundsArray:Array<Dynamic> = new Array<Dynamic>();
			boundsArray.push(topleft);
			boundsArray.push(topright);
			boundsArray.push(bottomleft);
			boundsArray.push(bottomright);
			minX = 100000;
			minY = 100000;
			maxX = -100000;
			maxY = -100000;
			for (__i in 0...boundsArray.length) {
				bounds = boundsArray[__i];

				if (minX > bounds.x) {
					minX = bounds.x;
				}
				if (maxX < bounds.x) {
					maxX = bounds.x;
				}
				if (minY > bounds.y) {
					minY = bounds.y;
				}
				if (maxY < bounds.y) {
					maxY = bounds.y;
				}
			}

			mapping.a = scale * cos;
			mapping.b = -scale * sin;
			mapping.c = scale * sin;
			mapping.d = scale * cos;
			mapping.tx = topleft.x;
			mapping.ty = topleft.y;
		} else {
			bottomright.x = topright.x = (bottomleft.x = topleft.x = screenvertex.x - w / 2) + w;
			bottomright.y = bottomleft.y = (topright.y = topleft.y = screenvertex.y - h / 2) + h;
			minX = topleft.x;
			minY = topleft.y;
			maxX = bottomright.x;
			maxY = bottomright.y;
			mapping.a = mapping.d = scale;
			mapping.c = mapping.b = 0;
			mapping.tx = topleft.x;
			mapping.ty = topleft.y;
		}
	}

	/**
	 * @inheritDoc
	 */
	public override function clear():Void {
		
		screenvertex = null;
	}

	/**
	 * @inheritDoc
	 */
	public override function render():Void {
		
		material.renderBillboard(this);
	}

	/**
	 * @inheritDoc
	 */
	public override function contains(x:Float, y:Float):Bool {
		
		if (rotation != 0) {
			if (topleft.x * (y - topright.y) + topright.x * (topleft.y - y) + x * (topright.y - topleft.y) > 0.001) {
				return false;
			}
			if (topright.x * (y - bottomright.y) + bottomright.x * (topright.y - y) + x * (bottomright.y - topright.y) > 0.001) {
				return false;
			}
			if (bottomright.x * (y - bottomleft.y) + bottomleft.x * (bottomright.y - y) + x * (bottomleft.y - bottomright.y) > 0.001) {
				return false;
			}
			if (bottomleft.x * (y - topleft.y) + topleft.x * (bottomleft.y - y) + x * (topleft.y - bottomleft.y) > 0.001) {
				return false;
			}
		}
		uvMaterial = cast(material, IUVMaterial);
		if (uvMaterial == null || !uvMaterial.bitmap.transparent) {
			return true;
		}
		pointMapping = mapping.clone();
		pointMapping.invert();
		var p:Point = pointMapping.transformPoint(new Point());
		if (p.x < 0) {
			p.x = 0;
		}
		if (p.y < 0) {
			p.y = 0;
		}
		if (p.x >= uvMaterial.width) {
			p.x = uvMaterial.width - 1;
		}
		if (p.y >= uvMaterial.height) {
			p.y = uvMaterial.height - 1;
		}
		var pixelValue:Int = uvMaterial.bitmap.getPixel32(Std.int(p.x), Std.int(p.y));
		return Std.int(pixelValue >> 24) > 0x80;
	}

	// autogenerated
	public function new () {
		super();
		this.topleft = new ScreenVertex();
		this.topright = new ScreenVertex();
		this.bottomleft = new ScreenVertex();
		this.bottomright = new ScreenVertex();
		this.left = new ScreenVertex();
		this.top = new ScreenVertex();
		this.mapping = new Matrix();
		
	}

	

}

