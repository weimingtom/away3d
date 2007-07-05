package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;

    import flash.display.Graphics;

    /** Solid color material */
    public class ColorMaterial extends WireColorMaterial
    {
        public function ColorMaterial(color:int = -1, alpha:Number = 1.0)
        {
            if (color == -1)
                color = int(0xFFFFFF * Math.random());

            super(color, 0, alpha, 0, 0);
        }
    }
}
