package away3d.animators.skin;

	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	
    class SkinVertex
     {
    	
    	var _i:Int;
    	var _skinController:SkinController;
    	var _position:Number3D ;
		var _sceneTransform:Matrix3D ;
		
		public var baseVertex:Vertex;
        public var skinnedVertex:Vertex;
        public var weights:Array<Dynamic> ;
        public var controllers:Array<Dynamic> ;
		
        public function new(vertex:Vertex)
        {
            
            _position = new Number3D();
            _sceneTransform = new Matrix3D();
            weights = new Array();
            controllers = new Array();
            skinnedVertex = vertex;
            baseVertex = vertex.clone();
        }

        public function update() : Void
        {
        	var updated:Bool = false;
        	for each (_skinController in controllers)
        		updated = updated || _skinController.updated;
        	
        	if (!updated)
        		return;
        	
        	//reset values
            skinnedVertex.reset();
            
            _i = weights.length;
            while (_i--) {
				_position.transform(baseVertex.position, (cast( controllers[_i], SkinController)).sceneTransform);
				_position.scale(_position, weights[_i]);
				skinnedVertex.add(_position);
            }
        }
    }
