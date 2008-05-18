package away3d.events
{
    import away3d.core.base.*;
    import away3d.loaders.Object3DLoader;
    
    import flash.events.Event;
    
    public class LoaderEvent extends Event
    {
    	static public var LOAD_SUCCESS:String = "loadsuccess";
    	static public var LOAD_ERROR:String = "loaderror";
    	
        public var loader:Object3DLoader;

        public function LoaderEvent(type:String, loader:Object3DLoader)
        {
            super(type);
            this.loader = loader;
        }

        public override function clone():Event
        {
            return new LoaderEvent(type, loader);
        }
    }
}
