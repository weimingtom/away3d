package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.mesh.*;
    import away3d.core.math.*;

    /** Traverser that finds object that is rendered on certain screen coordinates. Used for mouse click event. */
    public class FindHitTraverser extends ProjectionTraverser implements IPrimitiveConsumer
    {
        public var screenX:Number;
        public var screenY:Number;

        public var screenZ:Number = Infinity;

        public var element:Object;
        public var drawpri:DrawPrimitive;
        public var object:Object3D;
        public var uv:UV;

        public var worldX:Number;
        public var worldY:Number;
        public var worldZ:Number;

        public function FindHitTraverser(view:View3D, x:Number, y:Number)
        {
            super(view);
            screenX = x;
            screenY = y;
        }

        public override function match(node:Object3D):Boolean
        {
            return super.match(node) && node.mousable;
        }

        public override function apply(object:Object3D):void
        {
            if (object is IPrimitiveProvider)
            {
                var provider:IPrimitiveProvider = (object as IPrimitiveProvider);
                var projection:Projection = new Projection(transform, view.camera.focus, view.camera.zoom);
                provider.primitives(projection, this);
            }
        }

        public function primitive(pri:DrawPrimitive):void
        {
            if (pri.minX > screenX)
                return;
            if (pri.maxX < screenX)
                return;
            if (pri.minY > screenY)
                return;
            if (pri.maxY < screenY)
                return;

            if (pri.contains(screenX, screenY))
            {
                var z:Number = pri.getZ(screenX, screenY);
                if (z < screenZ)
                {
                    screenZ = z;

                    var persp:Number = view.camera.zoom / (1 + screenZ / view.camera.focus);
                    var inv:Matrix3D = Matrix3D.inverse(view.camera.view);

                    worldX = screenX / persp * inv.sxx + screenY / persp * inv.sxy + screenZ * inv.sxz + inv.tx;
                    worldY = screenX / persp * inv.syx + screenY / persp * inv.syy + screenZ * inv.syz + inv.ty;
                    worldZ = screenX / persp * inv.szx + screenY / persp * inv.szy + screenZ * inv.szz + inv.tz;

                    drawpri = pri;
                    object = pri.source;
                    element = null; // TODO face or segment

                    uv = null;
                    if (pri is DrawTriangle)
                    {
                        var tri:DrawTriangle = pri as DrawTriangle;
                        uv = tri.getUV(screenX, screenY);
                    }
                }
            }
        }

        public function getMouseEvent(type:String):MouseEvent3D
        {
            var event:MouseEvent3D = new MouseEvent3D(type);
            event.screenX = screenX;
            event.screenY = screenY;
            event.screenZ = screenZ;
            event.worldX = worldX;
            event.worldY = worldY;
            event.worldZ = worldZ;
            event.view = view;
            event.drawpri = drawpri;
            event.element = element;
            event.object = object;
            event.uv = uv;

            return event;
        }
    }
}
