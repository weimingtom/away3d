package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;
    import flash.utils.*;

    public class AnimationFrame
    {
        public var frame:Number;
        public var time:uint;
        public var sort:String;

        public function AnimationFrame(frame:Number, sort:String = null)
        {
            this.frame = frame;
            this.sort = sort;
        }
    }
}
