package away3d.core.clip;

import flash.events.EventDispatcher;
import away3d.core.geom.Plane3D;
import away3d.core.utils.Init;
import away3d.core.utils.FaceVO;
import away3d.core.render.AbstractRenderSession;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.base.VertexClassification;
import away3d.core.geom.Frustum;


/**
 * Rectangle clipping
 */
class RectangleClipping extends Clipping  {
	
	private var tri:DrawTriangle;
	private var _v0C:VertexClassification;
	private var _v1C:VertexClassification;
	private var _v2C:VertexClassification;
	private var _v0d:Float;
	private var _v1d:Float;
	private var _v2d:Float;
	private var _v0w:Float;
	private var _v1w:Float;
	private var _v2w:Float;
	private var _p:Float;
	private var _d:Float;
	private var _session:AbstractRenderSession;
	private var _frustum:Frustum;
	private var _pass:Bool;
	private var _v0Classification:Plane3D;
	private var _v1Classification:Plane3D;
	private var _v2Classification:Plane3D;
	private var _plane:Plane3D;
	private var _v0:Vertex;
	private var _v01:Vertex;
	private var _v1:Vertex;
	private var _v12:Vertex;
	private var _v2:Vertex;
	private var _v20:Vertex;
	private var _uv0:UV;
	private var _uv01:UV;
	private var _uv1:UV;
	private var _uv12:UV;
	private var _uv2:UV;
	private var _uv20:UV;
	private var _f0:FaceVO;
	private var _f1:FaceVO;
	

	public function new(?init:Dynamic=null) {
		
		
		super(init);
		objectCulling = ini.getBoolean("objectCulling", false);
	}

	/**
	 * @inheritDoc
	 */
	public override function checkPrimitive(pri:DrawPrimitive):Bool {
		
		if (pri.maxX < minX) {
			return false;
		}
		if (pri.minX > maxX) {
			return false;
		}
		if (pri.maxY < minY) {
			return false;
		}
		if (pri.minY > maxY) {
			return false;
		}
		return true;
	}

	public override function clone(?object:Clipping=null):Clipping {
		
		var clipping:RectangleClipping = (cast(object, RectangleClipping));
		if (clipping == null)  {
			clipping = new RectangleClipping();
		};
		super.clone(clipping);
		return clipping;
	}

}

