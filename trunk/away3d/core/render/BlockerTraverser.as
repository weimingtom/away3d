package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.block.*;
    import away3d.core.draw.*;
    import away3d.core.scene.*;
    
    import flash.geom.*;

    /** Traverser that gathers blockers for occlusion culling */
    public class BlockerTraverser extends Traverser
    {
    	private var _view:View3D;
        private var _consumer:IBlockerConsumer;
		
		private var projection:Projection;
		
		public function set view(val:View3D):void
		{
			_view = val;
		}
		
		public function set consumer(val:IBlockerConsumer):void
		{
			_consumer = val;
		}
		
        public function BlockerTraverser()
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
        
        public override function apply(node:Object3D):void
        {
            if (node is IBlockerProvider)
            {
                projection = new Projection(node.viewTransform, _view.camera.focus, _view.camera.zoom);
                (node as IBlockerProvider).blockers(projection, _consumer);
            }
        }

    }
}
