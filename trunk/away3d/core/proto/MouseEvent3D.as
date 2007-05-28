package away3d.core.proto
{
    import away3d.core.draw.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    import away3d.core.material.*;
    
    import flash.display.Sprite;
    import flash.utils.getTimer;
    import flash.utils.Dictionary;
    import flash.events.MouseEvent;
    import flash.events.Event;
    
    public class MouseEvent3D extends Event
    {
        public var screenX:Number;
        public var screenY:Number;
        public var screenZ:Number;

        public var view:View3D;
        public var object:Object3D;
        public var element:Object;
        public var drawpri:DrawPrimitive;
        public var uv:NumberUV;

        public function MouseEvent3D(type:String)
        {
            super(type);
        }
    }
}
