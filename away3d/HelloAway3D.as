package 
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.*;
    import flash.ui.Keyboard;
    import flash.geom.*;

    import mx.core.BitmapAsset;
    
    import away3d.cameras.*;
    import away3d.objects.*;
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.proto.*;
    import away3d.core.render.*;
    
    [SWF(backgroundColor="#222266", frameRate="60", width="600", height="400")]
    public class HelloAway3D extends Sprite
    {
        public var scene:Scene3D;
        public var sphere:Sphere;
        public var view:View3D;
        public var camera:Camera3D;
        
        public function HelloAway3D()
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.showDefaultContextMenu = false;
            stage.stageFocusRect = false;
            Debug.warningsAsErrors = true;

            scene = new Scene3D();

            sphere = new Sphere(new WireColorMaterial(0xFF7700, 0xCC4400), {radius:250, segmentsW:12, segmentsH:9, y:50});

            scene.addChild(sphere);

            camera = new Camera3D({zoom:4, focus:200, x:1000, y:1000, z:1000});
            camera.lookAt(sphere);

            view = new View3D(scene, camera, Renderer.BASIC);
            view.x = 300;
            view.y = 200;
            addChild(view);

            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            stage.addEventListener(Event.RESIZE, onResize);
        }

        private function onEnterFrame(event:Event):void
        {
            Init.checkUnusedArguments();

            view.render();
        }

        private function onResize(event:Event):void 
        {
            view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
        }

    }
}
