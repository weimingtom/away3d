package away3d.core.draw
{
    import away3d.core.base.*;
    import away3d.core.render.*;
    
    import flash.display.DisplayObject;

    public class DrawDisplayObject extends DrawPrimitive
    {
        public var displayobject:DisplayObject;
		public var session:AbstractRenderSession;
        public var v:ScreenVertex;

        public function DrawDisplayObject(object:Object3D, displayobject:DisplayObject, v:ScreenVertex, session:AbstractRenderSession)
        {
            this.source = object;
            this.displayobject = displayobject;
            this.v = v;
            this.session = session;
            calc();
        }

        public function calc():void
        {
            screenZ = v.z;
            minZ = screenZ;
            maxZ = screenZ;
            minX = v.x - displayobject.width/2;
            minY = v.y - displayobject.height/2;
            maxX = v.x + displayobject.width/2;
            maxY = v.y + displayobject.height/2;
        }

        public override function clear():void
        {
            displayobject = null;
        }

        public override function render():void
        {
            displayobject.x = v.x;// - displayobject.width/2;
            displayobject.y = v.y;// - displayobject.height/2;
            session.addDisplayObject(displayobject);
        }
		
		//TODO: correct function for contains in DrawDisplayObject
        public override function contains(x:Number, y:Number):Boolean
        {   
            return true;
        }
    }
}
