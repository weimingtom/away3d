package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    
    import flash.display.DisplayObject;

    public class DrawDisplayObject extends DrawPrimitive
    {
        public var displayobject:DisplayObject;
		public var session:RenderSession;
        public var v:ScreenVertex;

        public function DrawDisplayObject(object:Object3D, displayobject:DisplayObject, v:ScreenVertex, session:RenderSession)
        {
            this.object = object;
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
            minX = int(Math.floor(v.x - displayobject.width/2));
            minY = int(Math.floor(v.y - displayobject.height/2));
            maxX = int(Math.ceil(v.x + displayobject.width/2));
            maxY = int(Math.ceil(v.y + displayobject.height/2));
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

        public override function contains(x:Number, y:Number):Boolean
        {   
            return true;
        }
    }
}
