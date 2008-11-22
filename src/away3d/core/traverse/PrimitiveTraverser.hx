package away3d.core.traverse;

	import away3d.containers.*;
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.light.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
    
	use namespace arcane;
	
    /**
    * Traverser that gathers drawing primitives to render the scene.
    */
    class PrimitiveTraverser extends Traverser {
    	public var view(getView, setView) : View3D;
    	
    	var _view:View3D;
    	var _viewTransform:Matrix3D;
    	var _consumer:IPrimitiveConsumer;
    	var _mouseEnabled:Bool;
    	var _mouseEnableds:Array<Dynamic>;
		var _light:ILightProvider;
		/**
		 * Defines the view being used.
		 */
		public function getView():View3D{
			return _view;
		}
		public function setView(val:View3D):View3D{
			_view = val;
			_mouseEnabled = true;
			_mouseEnableds = [];
			return val;
		}
		    	
		/**
		 * Creates a new <code>PrimitiveTraverser</code> object.
		 */
        public function new()
        {
        }
        
		/**
		 * @inheritDoc
		 */
		public override function match(node:Object3D):Bool
        {
            if (!node.visible)
                return false;
            if (Std.is( node, ILODObject))
                return (cast( node, ILODObject)).matchLOD(_view.camera);
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function enter(node:Object3D):Void
        {
        	_mouseEnableds.push(_mouseEnabled);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function apply(node:Object3D):Void
        {
        	if (node.session.updated) {
	        	_viewTransform = _view.camera.viewTransforms[node];
	        	_consumer = node.session.getConsumer(_view);
	        	
	        	if (node.projector)
	            	node.projector.primitives(_view, _viewTransform, _consumer);
	            
	            if (node.debugbb && node.debugBoundingBox.visible) {
	            	node.debugBoundingBox._session = node.session;
	            	node.debugBoundingBox.projector.primitives(_view, _viewTransform, _consumer);
	            }
	            	
	            if (node.debugbs && node.debugBoundingSphere.visible) {
	            	node.debugBoundingSphere._session = node.session;
	            	node.debugBoundingSphere.projector.primitives(_view, _viewTransform, _consumer);
	            }
	            
	            if (Std.is( node, ILightProvider)) {
	            	_light = cast( node, ILightProvider);
	            	if (_light.debug) {
	            		_light.debugPrimitive._session = node.session;
	            		_light.debugPrimitive.projector.primitives(_view, _viewTransform, _consumer);
	            	}
	            }
	        }
	        
            _mouseEnabled = node._mouseEnabled = (_mouseEnabled && node.mouseEnabled);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function leave(node:Object3D):Void
        {
        	_mouseEnabled = _mouseEnableds.pop();
        }

    }
