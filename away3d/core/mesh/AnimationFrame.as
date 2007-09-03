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
        public var frameid:String;
        public var framenum:Number;
        public var time:uint;

        public function AnimationFrame(frameid:String, framenum:Number)
        {
            this.frameid = frameid;
            this.framenum = framenum;
        }
    }
}
