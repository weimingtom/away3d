package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.scene.*;

    /** Traverser that gathers drawing primitives to render the scene */
    public class PrimitiveTraverser extends Traverser
    {
        private var _consumer:IPrimitiveConsumer;
    	private var _session:RenderSession;
    	
    	private var _view:View3D;
    	private var _focus:Number;
    	private var _zoom:Number;
    	private var _sessions:Array;
        private var _lights:ILightConsumer;
		
		public function set consumer(val:IPrimitiveConsumer):void
		{
			_consumer = val;
		}
		
		public function set session(val:RenderSession):void
		{
			_session = val;
			_sessions = [];
			_lights = _session.lightarray;
			_view = _session.view;
			_focus = _view.camera.focus;
			_zoom = _view.camera.zoom;
		}
				
        public function PrimitiveTraverser()
        {
        }
		
		public override function match(node:Object3D):Boolean
        {
            if (!node.visible)
                return false;
            if (node is ILODObject)
                return (node as ILODObject).matchLOD(_view);
            return true;
        }
                
        public override function enter(node:Object3D):void
        {
        	_sessions.push(_session);
        }
        
        public override function apply(node:Object3D):void
        {
            if (node is IPrimitiveProvider)
            {
                (node as IPrimitiveProvider).primitives(_consumer, _session);
                _session = node.session;
            }

            if (node is ILightProvider)
            {
                (node as ILightProvider).light(node.viewTransform, _lights);
            }
        }
        
        public override function leave(node:Object3D):void
        {
        	_session = _sessions.pop();
        }

    }
}
