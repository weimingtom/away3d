package away3d.cameras
{
    import away3d.core.base.*;
    import away3d.core.utils.*;

    /** Camera that hovers around an object */
    public class HoverCamera3D extends TargetCamera3D
    {
        public var yfactor:Number = 2;

        /** Distance the camera keeps to the target */
        public var distance:Number = 400;
        public var panangle:Number = 0;
        public var tiltangle:Number = 90;
        public var targetpanangle:Number = 0;
        public var targettiltangle:Number = 90;
        public var mintiltangle:Number = 0;
        public var maxtiltangle:Number = 90;
        public var steps:Number = 8;

        public function HoverCamera3D(init:Object = null)
        {
            super(init);
    
            init = Init.parse(init);

            distance = (init as Init).getNumber("distance", 800);

            update();
        }

        /** Hover camera around the object @return <code>true</code> if camera changed position */
        public function hover():Boolean
        {
            if ((targettiltangle == tiltangle) && (targetpanangle == panangle))
                return update();

            targettiltangle = Math.max(mintiltangle, Math.min(maxtiltangle, targettiltangle));
            tiltangle += (targettiltangle - tiltangle) / (steps + 1);
            panangle += (targetpanangle - panangle) / (steps + 1);

            if ((Math.abs(targettiltangle - tiltangle) < 0.01) && (Math.abs(targetpanangle - panangle) < 0.01))
            {
                tiltangle = targettiltangle;
                panangle = targetpanangle;
            }

            return update();
        }

        /** Update camera position @return <code>true</code> if camera changed position */
        public function update():Boolean
        {
            var gx:Number = distance * Math.sin(panangle * toRADIANS) * Math.cos(tiltangle * toRADIANS);
            var gz:Number = distance * Math.cos(panangle * toRADIANS) * Math.cos(tiltangle * toRADIANS);
            var gy:Number = distance * Math.sin(tiltangle * toRADIANS) * yfactor;
			
            if ((x == gx) && (y == gy) && (z == gz))
                return false;
			
            x = gx;
            y = gy;
            z = gz;
			
            return true;
        }

        static private var toRADIANS:Number = Math.PI / 180;
    }

}   
