package away3d.core.utils
{
    import away3d.core.*;
    import away3d.core.math.*;
    
    import flash.events.EventDispatcher;
    import flash.display.Sprite;
    import flash.utils.Dictionary;
    import flash.events.Event;
    
    public class LazyEventDispatcher
    {
        private var _dispatcher:EventDispatcher;

        arcane function get dispatcher():EventDispatcher
        {
            return _dispatcher;
        }
        
        protected function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
        {
            if (_dispatcher == null)
                _dispatcher = new EventDispatcher();
                         
            _dispatcher.addEventListener(type, listener, useCapture, priority);
        }
               
        protected function dispatchEvent(evt:Event):Boolean
        {
            if (_dispatcher == null)
                return false;

            return _dispatcher.dispatchEvent(evt);
        }

        protected function hasEventListener(type:String):Boolean
        {
            if (_dispatcher == null)
                return false;

            return _dispatcher.hasEventListener(type);
        }
        
        protected function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
        {
            if (_dispatcher == null)
                return;

            _dispatcher.removeEventListener(type, listener, useCapture);
        }
                       
        protected function willTrigger(type:String):Boolean 
        {
            if (_dispatcher == null)
                return false;

            return _dispatcher.willTrigger(type);
        }
    }
}
