package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.mesh.BaseMesh;
    import away3d.core.scene.*;
    import away3d.objects.Sphere;

    /** Base traverser for all traversers that rely on camera transform. */
    public class ProjectionTraverser extends Traverser
    {
        private var _view:View3D;
        private var _cameraview:Matrix3D;
		
		public function set view(val:View3D):void
		{
			_view = val;
            _cameraview = _view.camera.view;
			if (_view.statsOpen)
				_view.statsPanel.clearObjects();
		}
		
        public function ProjectionTraverser()
        {
        	
        }

        public override function match(node:Object3D):Boolean
        {
            if (!node.visible)
                return false;
            node.viewTransform.multiply(_cameraview, node.sceneTransform);
            if (node is ILODObject)
                return (node as ILODObject).matchLOD(_view);
            return true;
        }

        public override function enter(node:Object3D):void
        {
        	if (_view.statsOpen && node is BaseMesh)
        		_view.statsPanel.addObject(node as BaseMesh);
        }
    }
}
