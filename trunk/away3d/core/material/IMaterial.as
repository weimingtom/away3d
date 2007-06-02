package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    import flash.display.Graphics;

    /** Interface for all objects that can serve as material */
    public interface IMaterial 
    {
        function get visible():Boolean;
    }
}
