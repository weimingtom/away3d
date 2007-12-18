package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.scene.*;

    /** Traverser that gathers drawing primitives to render the scene */
    public class PrimitiveTraverser extends Traverser
    {
    	protected var view:View3D;
    	protected var session:RenderSession;
    	protected var sessions:Array = new Array();
        private var consumer:IPrimitiveConsumer;
        private var lights:ILightConsumer;
		
		private var projection:Projection;
		
        public function PrimitiveTraverser(consumer:IPrimitiveConsumer, lights:ILightConsumer, view:View3D, session:RenderSession)
        {
        	this.view = view;
        	this.session = session;
            this.consumer = consumer;
            this.lights = lights;
        }
		
		public override function match(node:Object3D):Boolean
        {
            if (!node.visible)
                return false;
            if (node is ILODObject)
                return (node as ILODObject).matchLOD(view);
            return true;
        }
                
        public override function enter(node:Object3D):void
        {
        	sessions.push(session);
        }
        
        public override function apply(node:Object3D):void
        {
            if (node is IPrimitiveProvider)
            {
                projection = new Projection(node.viewTransform, view.camera.focus, view.camera.zoom);
                (node as IPrimitiveProvider).primitives(projection, consumer, session);
                session = node.session;
            }

            if (node is ILightProvider)
            {
                (node as ILightProvider).light(node.viewTransform, lights);
            }
        }
        
        public override function leave(node:Object3D):void
        {
        	session = sessions.pop();
        }

    }
}
