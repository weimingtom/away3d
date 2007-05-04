package away3d.test
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.*;
    import flash.ui.Keyboard;
    import flash.geom.*;

    import away3d.core.proto.*;
    import away3d.core.render.*;
    
    public class Slide
    {
        public var scene:Scene3D;
        public var renderer:IRenderer;
        public var title:String;
        public var desc:String;

        public function Slide(title:String, desc:String, scene:Scene3D, renderer:IRenderer)
        {
            this.scene = scene;
            this.renderer = renderer;
            this.title = title;
            this.desc = desc;
        }

    }
}
