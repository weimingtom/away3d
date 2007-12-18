package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.block.*;

    import flash.geom.*;

    /** Traverser that gathers blockers for occlusion culling */
    public class BlockerTraverser extends Traverser
    {
    	protected var view:View3D;
        private var consumer:IBlockerConsumer;
		
		private var projection:Projection;
		
        public function BlockerTraverser(consumer:IBlockerConsumer, view:View3D)
        {
        	this.view = view;
            this.consumer = consumer;
        }
		
		public override function match(node:Object3D):Boolean
        {
            if (!node.visible)
                return false;
            if (node is ILODObject)
                return (node as ILODObject).matchLOD(view);
            return true;
        }
        
        public override function apply(node:Object3D):void
        {
            if (node is IBlockerProvider)
            {
                projection = new Projection(node.viewTransform, view.camera.focus, view.camera.zoom);
                (node as IBlockerProvider).blockers(projection, consumer);
            }
        }

    }
}
