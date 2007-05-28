package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    import flash.geom.*;
    import flash.display.*;

    public class QuadrantRenderer implements IRenderer
    {
        private var qdrntfilters:Array;

        public function QuadrantRenderer(...params)
        {
            qdrntfilters = [];

            for each (var filter:IPrimitiveQuadrantFilter in params)
                qdrntfilters.push(filter);
        }

        public function render(view:View3D/*scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping*/):void
        {
            var scene:Scene3D = view.scene;
            var camera:Camera3D = view.camera;
            var container:Sprite = view.canvas;
            var clip:Clipping = view.clip;
            
            var graphics:Graphics = container.graphics;
            
            var pritree:PrimitiveQuadrantTree = new PrimitiveQuadrantTree(clip);
            var lightarray:LightArray = new LightArray();
            var pritraverser:PrimitiveTraverser = new PrimitiveTraverser(pritree, lightarray, view);

            scene.traverse(pritraverser);

            var session:RenderSession = new RenderSession(scene, camera, container, clip, lightarray);

            for each (var qdrntfilter:IPrimitiveQuadrantFilter in qdrntfilters)
                qdrntfilter.filter(pritree, scene, camera, container, clip);

            pritree.render(session);
        }

        public function desc():String
        {
            return "Quadrant ["+qdrntfilters.join("+")+"]";
        }

        public function stats():String
        {
            return "";
        }

    }
}
