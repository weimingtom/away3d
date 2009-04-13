package away3d.extrusions;

import away3d.haxeutils.Error;
import flash.display.BitmapData;
import flash.events.EventDispatcher;
import away3d.core.base.Face;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


/**
 * Class ElevationModifier updates the vertexes of a flat Mesh such as a Plane, RegularPolygon with a bimap information<ElevationModifier></code>
 * 
 */
class ElevationModifier  {
	
	private var _mesh:Mesh;
	private var _channel:String;
	private var _elevate:Float;
	private var _sourceBmd:BitmapData;
	private var _axis:String;
	

	public function new() {
		
		
	}

	/**
	 * Updates the vertexes of a Mesh on the z axis according to color information stored into a BitmapData
	 *
	 * @param	sourceBmd				Bitmapdata. The bitmapData to read from.
	 * @param	mesh						Object3D. The mesh Object3D to be updated.
	 * @param	channel					[optional] String. The channel information to read. supported "a", alpha, "r", red, "g", green, "b", blue and "av" (averages and luminance). Default is red channel "r".
	 * @param	elevate					[optional] Number. The scale multiplier along the z axis. Default is .5.
	 * @param	axis						[optional] String. The axis to influence. Default is "z".
	 */
	public function update(sourceBmd:BitmapData, mesh:Object3D, ?channel:String="r", ?elevate:Float=.5, ?axis:String="z"):Void {
		
		if ((cast(mesh, Mesh)).geometry.faces != null) {
			var i:Int = 0;
			_channel = channel.toLowerCase();
			_elevate = elevate;
			_sourceBmd = sourceBmd;
			_mesh = (cast(mesh, Mesh));
			_axis = axis;
			var flist:Array<Face> = _mesh.geometry.faces;
			var face:Face;
			var vr0:Vertex;
			var vr1:Vertex;
			var vr2:Vertex;
			var u0:Float;
			var u1:Float;
			var u2:Float;
			var v0:Float;
			var v1:Float;
			var v2:Float;
			var w:Float = sourceBmd.width;
			var h:Float = sourceBmd.height;
			i = 0;
			while (i < flist.length) {
				face = flist[i];
				vr0 = face.v0;
				vr1 = face.v1;
				vr2 = face.v2;
				u0 = w * face.uv0.u;
				u1 = w * face.uv1.u;
				u2 = w * face.uv2.u;
				v0 = h * (1 - face.uv0.v);
				v1 = h * (1 - face.uv1.v);
				v2 = h * (1 - face.uv2.v);
				updateVertex(vr0, u0, v0);
				updateVertex(vr1, u1, v1);
				updateVertex(vr2, u2, v2);
				
				// update loop variables
				++i;
			}

		} else {
			throw new Error("ElevationModifier error: unvalid mesh");
		}
	}

	private function updateVertex(vertex:Vertex, x:Float, y:Float):Void {
		
		var color:Int = (_channel == "a") ? _sourceBmd.getPixel32(x, y) : _sourceBmd.getPixel(x, y);
		var cha:Float;
		switch (_channel) {
			case "a" :
				cha = color >> 24 & 0xFF;
			case "r" :
				cha = color >> 16 & 0xFF;
			case "g" :
				cha = color >> 8 & 0xFF;
			case "b" :
				cha = color & 0xFF;
			case "av" :
				cha = ((color >> 16 & 0xFF) * 0.212671) + ((color >> 8 & 0xFF) * 0.715160) + ((color >> 8 & 0xFF) * 0.072169);
			

		}
		switch (_axis) {
			case "x" :
				_mesh.updateVertex(vertex, cha * _elevate, vertex.y, vertex.z, false);
			case "y" :
				_mesh.updateVertex(vertex, vertex.x, cha * _elevate, vertex.z, false);
			case "z" :
				_mesh.updateVertex(vertex, vertex.x, vertex.y, cha * _elevate, false);
			

		}
	}

}

