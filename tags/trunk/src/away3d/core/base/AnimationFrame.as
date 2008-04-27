package away3d.core.base
{
    import away3d.core.*;
    import away3d.materials.*;
    import away3d.core.math.*;
    import away3d.core.base.*;
    
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
