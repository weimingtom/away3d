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
    public class SessionTraverser extends Traverser
    {
    	use namespace arcane;
    	
    	private var _view:View3D;
    	private var _session:AbstractRenderSession;
    	private var _sessions:Array;
    	
		/**
		 * Defines the render session being used.
		 */
		public function get view():View3D
		{
			return _view;
		}
		public function set view(val:View3D):void
		{
			_view = val;
			
			_sessions = [];
			_session = _view.session;
		}
		    	
		/**
		 * Creates a new <code>PrimitiveTraverser</code> object.
		 */
        public function SessionTraverser()
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
                return (node as ILODObject).matchLOD(_view);
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function enter(node:Object3D):void
        {
        	_sessions.push(_session);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function apply(node:Object3D):void
        {
            if (node is IPrimitiveProvider)
            {
                (node as IPrimitiveProvider).sessions(_session);
                _session = node.session;
            }
        }
        
		/**
		 * @inheritDoc
		 */
        public override function leave(node:Object3D):void
        {
        	_session = _sessions.pop();
        }

    }
}
