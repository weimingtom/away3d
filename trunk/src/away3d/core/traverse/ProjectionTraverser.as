package away3d.core.traverse
{
	import away3d.cameras.Camera3D;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.light.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
	
	import flash.utils.*;
	
    /**
    * Traverser that resolves the transform tree in a scene, ready for rendering.
    */
    public class ProjectionTraverser extends Traverser
    {
		private var _projection:Projection;
        private var _view:View3D;
        private var _mesh:Mesh;
        private var _time:int;
        private var _camera:Camera3D;
        private var _cameraview:Matrix3D;
		private var _cameraviewtransforms:Dictionary;
		
		/**
		 * Defines the view being used.
		 */
		public function get view():View3D
		{
			return _view;
		}
		public function set view(val:View3D):void
		{
			_view = val;
			_time = getTimer();
			_camera = _view.camera;
            _cameraview = _camera.view;
            _cameraviewtransforms = _camera.viewTransforms;
			if (_view.statsOpen)
				_view.statsPanel.clearObjects();
		}
		    	
		/**
		 * Creates a new <code>ProjectionTraverser</code> object.
		 */
        public function ProjectionTraverser()
        {
        }
        
		/**
		 * @inheritDoc
		 */
        public override function match(node:Object3D):Boolean
        {
        	//check if node is visible
            if (!node.visible)
                return false;
            
            //compute viewTransform matrix
            _camera.createViewTransform(node).multiply(_cameraview, node.sceneTransform);
            
            //check which LODObject is visible
            if (node is ILODObject)
                return (node as ILODObject).matchLOD(_camera);
            
            //clear light arrays
            if (node.ownLights)
            	node.lightarray.clear();
            
            if (node is ILightProvider)
                (node as ILightProvider).light();
            
            if ((_mesh = node as Mesh)) {
            	//add to scene meshes dictionary
            	_view.scene.meshes[node] = node;
	            //update elements
	        	_mesh.geometry.updateElements(_time);
            }
            
            //update projection object
            _projection = node.projection;
            _projection.view = _cameraviewtransforms[node];
            _projection.focus = _view.camera.focus;
            _projection.zoom = _view.camera.zoom;
            _projection.time = _time;
            
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function enter(node:Object3D):void
        {
        	if (_view.statsOpen && node is Mesh)
        		_view.statsPanel.addObject(node as Mesh);
        }
        
        public override function leave(node:Object3D):void
        {
            //update object
            node.updateObject();
        }
    }
}
