package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
                               
    import flash.display.DisplayObject;

    public class DrawDisplayObject extends DrawPrimitive
    {
        public var displayobject:DisplayObject;

        public var v:ScreenVertex;

        public function DrawDisplayObject(source:Object3D, displayobject:DisplayObject, v:ScreenVertex)
        {
            this.source = source;
            this.displayobject = displayobject;
            this.v = v;
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

        public override function render(session:RenderSession):void
        {
            displayobject.x = v.x - displayobject.width/2;
            displayobject.y = v.y - displayobject.height/2;
            session.addDisplayObject(displayobject);
        }

        public override function contains(x:Number, y:Number):Boolean
        {   
            return true;
        }
    }
}
