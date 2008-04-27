package away3d.events
{
	import away3d.containers.*;
    import away3d.core.draw.*;
    import away3d.materials.*;
    import away3d.core.base.*;
    import away3d.core.render.*;
    
    import flash.events.Event;
    
    /** Event that gets dispatched in case of mouse click or mouse move */ 
    public class MouseEvent3D extends Event
    {
    	static	public var MOUSE_OVER:String = "mouseOver3D";
    	static	public var MOUSE_OUT:String = "mouseOut3D";
    	static	public var MOUSE_UP:String = "mouseUp3D";
    	static	public var MOUSE_DOWN:String = "mouseDown3D";
    	static	public var MOUSE_MOVE:String = "mouseMove3D";
    	
        public var screenX:Number;
        public var screenY:Number;
        public var screenZ:Number;

        public var sceneX:Number;
        public var sceneY:Number;
        public var sceneZ:Number;

        public var view:View3D;
        public var object:Object3D;
        public var element:Object;
        public var drawpri:DrawPrimitive;
        public var material:IUVMaterial;
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
                                     
            result.sceneX = sceneX;
            result.sceneY = sceneY;
            result.sceneZ = sceneZ;
                                     
            result.view = view;
            result.object = object;
            result.element = element;
            result.drawpri = drawpri;
            result.material = material;
            result.uv = uv;
                                     
            result.ctrlKey = ctrlKey;
            result.shiftKey = shiftKey;

            return result;
        }
    }
}
