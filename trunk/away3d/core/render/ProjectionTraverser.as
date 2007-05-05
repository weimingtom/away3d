package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    import flash.geom.*;

    public class ProjectionTraverser extends Traverser
    {
        protected var camera:Camera3D;
        protected var view:Matrix3D;
        protected var views:Array = [];

        public function ProjectionTraverser(camera:Camera3D)
        {
            this.camera = camera;
            this.view = camera.getView();
        }

        public override function match(node:Object3D):Boolean
        {
            return node.visible;
        }

        public override function enter(node:Object3D):void
        {
            views.push(view);
            view = node.project(view);
        }

        public override function leave():void
        {
            view = views.pop();
        }

    }
}
