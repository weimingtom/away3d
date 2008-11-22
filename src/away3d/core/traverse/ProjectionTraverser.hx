package away3d.core.traverse;

	import away3d.cameras.Camera3D;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.light.*;
	import away3d.core.math.*;
	import away3d.core.project.*;
	import away3d.core.render.*;
	
	import flash.utils.*;
	
    /**
    * Traverser that resolves the transform tree in a scene, ready for rendering.
    */
    class ProjectionTraverser extends Traverser {
        public var view(getView, setView) : View3D;
        
        var _view:View3D;
        var _mesh:Mesh;
        var _camera:Camera3D;
        var _cameraview:Matrix3D;
		var _cameraviewtransforms:Dictionary;
		
		/**
		 * Defines the view being used.
		 */
		public function getView():View3D{
			return _view;
		}
		public function setView(val:View3D):View3D{
			_view = val;
			_camera = _view.camera;
            _cameraview = _camera.view;
            _cameraviewtransforms = _camera.viewTransforms;
			if (_view.statsOpen)
				_view.statsPanel.clearObjects();
			return val;
		}
		    	
		/**
		 * Creates a new <code>ProjectionTraverser</code> object.
		 */
        public function new()
        {
        }
        
		/**
		 * @inheritDoc
		 */
        public override function match(node:Object3D):Bool
        {
        	//check if node is visible
            if (!node.visible)
                return false;
            
            //compute viewTransform matrix
            _camera.createViewTransform(node).multiply(_cameraview, node.sceneTransform);
            
            //check which LODObject is visible
            if (Std.is( node, ILODObject))
                return (cast( node, ILODObject)).matchLOD(_camera);
            
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function enter(node:Object3D):Void
        {
        	if (_view.statsOpen && Std.is( node, Mesh))
        		_view.statsPanel.addObject(cast( node, Mesh));
        }
        
        public override function apply(node:Object3D):Void
        {
            if (Std.is( node.projector, ConvexBlockProjector))
                (cast( node.projector, ConvexBlockProjector)).blockers(_view, _camera.viewTransforms[node], _view.blockerarray);
            
        	//add to scene meshes dictionary
            if ((_mesh = cast( node, Mesh)))
            	_view.scene.meshes[node] = node;
        }
        
        public override function leave(node:Object3D):Void
        {
            //update object
            node.updateObject();
        }
    }
