package away3d.core.traverse
{
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.light.*;
	import away3d.core.render.*;
    

    /**
    * Traverser that gathers drawing primitives to render the scene.
    */
    public class PrimitiveTraverser extends Traverser
    {
    	use namespace arcane;
    	
    	private var _view:View3D;
    	private var _mouseEnabled:Boolean;
    	private var _mouseEnableds:Array;
		
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
			_mouseEnabled = true;
			_mouseEnableds = [];
		}
		    	
		/**
		 * Creates a new <code>PrimitiveTraverser</code> object.
		 */
        public function PrimitiveTraverser()
        {
        }
        
		/**
		 * @inheritDoc
		 */
		public override function match(node:Object3D):Boolean
        {
            if (!node.visible)
                return false;
            if (node is ILODObject)
                return (node as ILODObject).matchLOD(_view.camera);
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function enter(node:Object3D):void
        {
        	_mouseEnableds.push(_mouseEnabled);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function apply(node:Object3D):void
        {
            if (node is IPrimitiveProvider)
                (node as IPrimitiveProvider).primitives(_view, node.session.getConsumer(view));
            
            _mouseEnabled = node._mouseEnabled = (_mouseEnabled && node.mouseEnabled);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function leave(node:Object3D):void
        {
        	_mouseEnabled = _mouseEnableds.pop();
        }

    }
}
