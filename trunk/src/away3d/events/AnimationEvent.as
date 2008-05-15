package away3d.events
{
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.materials.*;
    
    import flash.events.Event;
    
    public class AnimationEvent extends Event
    {
    	static public var CYCLE:String = "cycle";
    	static public var SQUENCE_UPDATE:String = "squenceupdate";
    	static public var SQUENCE_DONE:String = "squencedone";
    	
        public var animation:Animation;

        public function AnimationEvent(type:String, animation:Animation)
        {
            super(type);
            this.animation = animation;
        }

        public override function clone():Event
        {
            return new AnimationEvent(type, animation);
        }
    }
}
