package away3d.core.utils;

    
    import flash.events.EventDispatcher;
    import flash.events.Event;
    
    class ValueObject extends EventDispatcher {
        
        public function addOnChange(listener:Dynamic):Void
        {
            addEventListener("changed", listener, false, 0, true);
        }

        public function removeOnChange(listener:Dynamic):Void
        {
            removeEventListener("changed", listener, false);
        }

        static var changed:Event;

        function notifyChange():Void
        {
            if (!hasEventListener("changed"))
                return;

            if (changed == null)
                changed = new Event("changed");
                
            dispatchEvent(changed);
        }
    }
