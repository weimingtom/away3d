package away3d.events
{
    import away3d.core.base.*;

    import flash.events.Event;
    
    public class Object3DEvent extends Event
    {
    	static public var TRANSFORM_CHANGED:String = "transformchanged";
    	static public var SCENETRANSFORM_CHANGED:String = "scenetransformchanged";
    	static public var SCENE_CHANGED:String = "scenechanged";
    	static public var RADIUS_CHANGED:String = "radiuschanged";
    	static public var DIMENSIONS_CHANGED:String = "dimensionschanged";
    	
        public var object:Object3D;

        public function Object3DEvent(type:String, object:Object3D)
        {
            super(type);
            this.object = object;
        }

        public override function clone():Event
        {
            return new Object3DEvent(type, object);
        }
    }
}
