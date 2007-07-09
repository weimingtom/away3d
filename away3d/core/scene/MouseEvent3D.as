package away3d.core.scene
{
    import away3d.core.draw.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    import away3d.core.material.*;
    import away3d.core.mesh.*;
    
    import flash.display.Sprite;
    import flash.utils.getTimer;
    import flash.utils.Dictionary;
    import flash.events.MouseEvent;
    import flash.events.Event;
    
    /** Event that gets dispatched in case of mouse click or mouse move */ 
    public class MouseEvent3D extends Event
    {
        public var screenX:Number;
        public var screenY:Number;
        public var screenZ:Number;

        public var worldX:Number;
        public var worldY:Number;
        public var worldZ:Number;

        public var view:View3D;
        public var object:Object3D;
        public var element:Object;
        public var drawpri:DrawPrimitive;
        public var uv:UV;

        public var ctrlKey:Boolean;
        public var shiftKey:Boolean;

        public function MouseEvent3D(type:String)
        {
            super(type);
        }

        public override function clone():Event
        {
            var result:MouseEvent3D = new MouseEvent3D(type);

            result.screenX = screenX;
            result.screenY = screenY;
            result.screenZ = screenZ;
                                     
            result.worldX = worldX;
            result.worldY = worldY;
            result.worldZ = worldZ;
                                     
            result.view = view;
            result.object = object;
            result.element = element;
            result.drawpri = drawpri;
            result.uv = uv;
                                     
            result.ctrlKey = ctrlKey;
            result.shiftKey = shiftKey;

            return result;
        }
    }
}
