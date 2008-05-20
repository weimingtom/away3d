package away3d.core.render
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.events.*;
	import away3d.materials.*;

    /** 
    * Finds the object that is rendered under a certain view coordinate. Used for mouse click events.
    */
    public class FindHit
    {
        private var view:View3D;
        private var screenX:Number;
        private var screenY:Number;
        private var screenZ:Number = Infinity;
        private var element:Object;
        private var drawpri:DrawPrimitive;
        private var material:IUVMaterial;
        private var object:Object3D;
        private var uv:UV;
        private var sceneX:Number;
        private var sceneY:Number;
        private var sceneZ:Number;
        private var primitive:DrawPrimitive;
        private var inv:Matrix3D = new Matrix3D();
        private var persp:Number;
        
        private function checkPrimitive(pri:DrawPrimitive):void
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
                            if (!(tri.material is BitmapMaterialContainer) && !(testmaterial.getPixel32(testuv.u, testuv.v) >> 24))
                                return;
                            uv = testuv;
                        }
                        material = testmaterial;
                    } else {
                        uv = null;
                    }
                    screenZ = z;
                    persp = view.camera.zoom / (1 + screenZ / view.camera.focus);
                    inv = view.camera.viewTransform;

                    sceneX = screenX / persp * inv.sxx + screenY / persp * inv.sxy + screenZ * inv.sxz + inv.tx;
                    sceneY = screenX / persp * inv.syx + screenY / persp * inv.syy + screenZ * inv.syz + inv.ty;
                    sceneZ = screenX / persp * inv.szx + screenY / persp * inv.szy + screenZ * inv.szz + inv.tz;

                    drawpri = pri;
                    object = pri.source;
                    element = null; // TODO face or segment

                }
            }
        }
        
		/**
		 * Creates a new <code>FindHit</code> object.
		 * 
		 * @param	view		The view to be used.
		 * @param	primitives	The primitives that have been rendered in the last frame.
		 * @param	x			The x coordinate of the point to test.
		 * @param	y			The y coordinate of the point to test.
		 */
        public function FindHit(view:View3D, primitives:Array, x:Number, y:Number)
        {
            this.view = view;
            screenX = x;
            screenY = y;
            
            for each (primitive in primitives)
                checkPrimitive(primitive);
        }
        
        /**
        * Returns a 3d mouse event object populated with the properties from the hit point.
        */
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
