package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    import away3d.core.scene.*;

    /** Class that finds object that is rendered on certain screen coordinates. Used for mouse click event. */
    public class FindHit
    {
        protected var view:View3D;
        public var screenX:Number;
        public var screenY:Number;

        public var screenZ:Number = Infinity;

        public var element:Object;
        public var drawpri:DrawPrimitive;
        public var material:IUVMaterial;
        public var object:Object3D;
        public var uv:UV;

        public var sceneX:Number;
        public var sceneY:Number;
        public var sceneZ:Number;
        
        private var primitive:DrawPrimitive;
        
        internal var inv:Matrix3D = new Matrix3D();
        internal var persp:Number;
        
        public function FindHit(view:View3D, primitives:Array, x:Number, y:Number)
        {
            this.view = view;
            screenX = x;
            screenY = y;
            
            for each (primitive in primitives)
                checkPrimitive(primitive);
        }

        public function checkPrimitive(pri:DrawPrimitive):void
        {
            if (!pri.source.mouseEnabled)
                return;
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
                    if (pri is DrawTriangle)
                    {
                        var tri:DrawTriangle = pri as DrawTriangle;
                        var testuv:UV = tri.getUV(screenX, screenY);
                        if (tri.material is IUVMaterial) {
                            var testmaterial:IUVMaterial = (tri.material as IUVMaterial);
                            //return if material pixel is transparent
                            if (!(testmaterial.bitmap.getPixel32(testuv.u*testmaterial.width, (1 - testuv.v)*testmaterial.height) >> 24))
                                return;
                            uv = testuv;
                        }
                        material = testmaterial;
                    } else {
                        uv = null;
                    }
                    screenZ = z;
                    persp = view.camera.zoom / (1 + screenZ / view.camera.focus);
                    inv.inverse(view.camera.view);

                    sceneX = screenX / persp * inv.sxx + screenY / persp * inv.sxy + screenZ * inv.sxz + inv.tx;
                    sceneY = screenX / persp * inv.syx + screenY / persp * inv.syy + screenZ * inv.syz + inv.ty;
                    sceneZ = screenX / persp * inv.szx + screenY / persp * inv.szy + screenZ * inv.szz + inv.tz;

                    drawpri = pri;
                    object = pri.source;
                    element = null; // TODO face or segment

                }
            }
        }

        public function getMouseEvent(type:String):MouseEvent3D
        {
            var event:MouseEvent3D = new MouseEvent3D(type);
            event.screenX = screenX;
            event.screenY = screenY;
            event.screenZ = screenZ;
            event.sceneX = sceneX;
            event.sceneY = sceneY;
            event.sceneZ = sceneZ;
            event.view = view;
            event.drawpri = drawpri;
            event.material = material;
            event.element = element;
            event.object = object;
            event.uv = uv;

            return event;
        }
    }
}
