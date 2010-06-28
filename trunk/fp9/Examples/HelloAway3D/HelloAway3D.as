package 
{
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    
    import away3d.containers.*;
    import away3d.primitives.*;
    import away3d.materials.*;
    
    [SWF(backgroundColor="#222266", frameRate="60", width="600", height="400")]
    public class HelloAway3D extends Sprite
    {
        public var view:View3D;
        public var sphere:Sphere;
        
        public function HelloAway3D()
        {
            view = new View3D();
            view.x = 300;
            view.y = 200;
            addChild(view);

            sphere = new Sphere({material:new WireColorMaterial(0xFF7700, {wireColor:0xCC4400}), radius:250, segmentsW:12, segmentsH:9, y:50});

            view.scene.addChild(sphere);
            view.camera.lookAt(sphere.position);

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onEnterFrame(event:Event):void
        {
            view.render();
            sphere.rotationY = getTimer() / 100;
        }

    }

}
