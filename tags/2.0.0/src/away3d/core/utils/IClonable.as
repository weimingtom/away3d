package away3d.core.utils
{
    import away3d.core.*;
    import away3d.core.math.*;

    /** Interface for object that can be cloned */
    public interface IClonable
    {
        function clone(object:* = null):*;
    }
}
