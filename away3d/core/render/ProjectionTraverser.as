package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    /** Base traverser for all traversers that rely on camera transform. */
    public class ProjectionTraverser extends Traverser
    {
        protected var view:View3D;
        protected var transform:Matrix3D;
        protected var transforms:Array = [];

        public function ProjectionTraverser(view:View3D)
        {
            this.view = view;
            this.transform = view.camera.getView();
        }

        public override function match(node:Object3D):Boolean
        {
            if (!node.visible)
                return false;
            if (node is ILODObject)
                return (node as ILODObject).matchLOD(view, transform);
            return true;
        }

        public override function enter(node:Object3D):void
        {
            transforms.push(transform);
            transform = node.project(transform);
        }

        public override function leave():void
        {
            transform = transforms.pop();
        }

    }
}
