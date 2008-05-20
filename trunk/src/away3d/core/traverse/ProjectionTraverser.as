package away3d.core.traverse
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
	
	import flash.utils.getTimer;
	
    /**
    * Traverser that resolves the transform tree in a scene, ready for rendering.
    */
    public class ProjectionTraverser extends Traverser
    {
		private var _projection:Projection;
        private var _view:View3D;
        private var _cameraview:Matrix3D;
		
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
            _cameraview = _view.camera.view;
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
            node.viewTransform.multiply(_cameraview, node.sceneTransform);
            
            //update projection object
            _projection = node.projection;
            _projection.view = node.viewTransform;
            _projection.focus = _view.camera.focus;
            _projection.zoom = _view.camera.zoom;
            _projection.time = getTimer();
            
            //check which LODObject is visible
            if (node is ILODObject)
                return (node as ILODObject).matchLOD(_view);
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function enter(node:Object3D):void
        {
        	if (_view.statsOpen && node is BaseMesh)
        		_view.statsPanel.addObject(node as BaseMesh);
        }
    }
}
