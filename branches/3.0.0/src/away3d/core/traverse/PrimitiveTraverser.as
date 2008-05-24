package away3d.core.traverse
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.light.*;
	import away3d.core.render.*;
    

    /**
    * Traverser that gathers drawing primitives to render the scene.
    */
    public class PrimitiveTraverser extends Traverser
    {
    	private var _session:AbstractRenderSession;
    	
    	private var _view:View3D;
    	private var _focus:Number;
    	private var _zoom:Number;
    	private var _sessions:Array;
        private var _lights:ILightConsumer;
		
		/**
		 * Defines the primitive consumer being used.
		 */
		public var consumer:IPrimitiveConsumer
		
		/**
		 * Defines the render session being used.
		 */
		public function get session():AbstractRenderSession
		{
			return _session;
		}
		public function set session(val:AbstractRenderSession):void
		{
			_session = val;
			_sessions = [];
			_lights = _session.lightarray;
			_view = _session.view;
			_focus = _view.camera.focus;
			_zoom = _view.camera.zoom;
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
                (node as IPrimitiveProvider).primitives(consumer, _session);
                _session = node.session;
            }

            if (node is ILightProvider)
            {
                (node as ILightProvider).light(_lights);
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
