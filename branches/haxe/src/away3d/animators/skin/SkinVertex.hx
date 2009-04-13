package away3d.animators.skin;

import away3d.core.math.Number3D;
import away3d.core.math.Matrix3D;
import away3d.core.base.Vertex;
import away3d.haxeutils.Hashable;

class SkinVertex extends Hashable {
	
	private var _i:Int;
	private var _skinController:SkinController;
	private var _position:Number3D;
	private var _sceneTransform:Matrix3D;
	public var baseVertex:Vertex;
	public var skinnedVertex:Vertex;
	public var weights:Array<Dynamic>;
	public var controllers:Array<Dynamic>;
	

	public function new(vertex:Vertex) {
		super();
		this._position = new Number3D();
		this._sceneTransform = new Matrix3D();
		this.weights = new Array();
		this.controllers = new Array();
		
		
		skinnedVertex = vertex;
		baseVertex = vertex.clone();
	}

	public function update():Void {
		
		var updated:Bool = false;
		for (__i in 0...controllers.length) {
			_skinController = controllers[__i];

			if (_skinController != null) {
				updated = updated || _skinController.updated;
			}
		}

		if (!updated) {
			return;
		}
		//reset values
		skinnedVertex.reset();
		_i = weights.length;
		while ((_i-- > 0)) {
			_position.transform(baseVertex.position, (cast(controllers[_i], SkinController)).sceneTransform);
			_position.scale(_position, weights[_i]);
			skinnedVertex.add(_position);
		}

	}

}

