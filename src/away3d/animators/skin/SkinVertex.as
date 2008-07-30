package away3d.animators.skin
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	
    public class SkinVertex
    {
    	private var _i:int;
    	private var _skinController:SkinController;
    	private var _position:Number3D = new Number3D();
		private var _sceneTransform:Matrix3D = new Matrix3D();
		
		public var baseVertex:Vertex;
        public var skinnedVertex:VertexPosition;
        public var weights:Array = new Array();
        public var controllers:Array = new Array();
		
        public function SkinVertex(vertex:Vertex)
        {
            skinnedVertex = new VertexPosition(vertex);
            baseVertex = vertex.clone();
        }

        public function update(mesh:Mesh) : void
        {
        	//reset values
            skinnedVertex.reset();
            
            _i = weights.length;
            while (_i--) {
            	_skinController = controllers[_i] as SkinController;
            	if (_skinController)
					_sceneTransform.clone(_skinController.sceneTransform);
				else
					_sceneTransform.clear();
				
				_position.transform(baseVertex.position, _sceneTransform);
				_position.scale(_position, weights[_i]);
				skinnedVertex.add(_position);
            }
            
            skinnedVertex.transform(mesh.parent.inverseSceneTransform);
        }
    }
}
