package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    import flash.display.Graphics;

    public class WireframeMaterial extends WireColorMaterial
    {
        public function WireframeMaterial(wirecolor:int = -1, wirealpha:Number = 1.0, wirewidth:Number = 1)
        {
            if (wirecolor == -1)
                wirecolor = int(0xFFFFFF * Math.random());

            super(0, wirecolor, 0, wirealpha, wirewidth);
        }
    }
}
