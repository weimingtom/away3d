package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;
    import flash.utils.*;

    public class Animation
    {
        private var _frame:Number = 0;
        private var _fps:Number = 24;
        private var _loop:Boolean = false;
        private var _smooth:Boolean = false;
        private var _sequence:Array = [];
        private var _lastframe:Number = NaN;

        public function Animation(startframe:Number = -1, endframe:Number = -1)
        {
            for (var i:int = 0; startframe + i <= endframe; i++)
                _sequence.push(i);
        }

        public function get renderframe():Object
        {
            return _sequence[int(Math.round(_frame))];
        /*
            var result:Dictionary = new Dictionary();
            if ((!_smooth) || (Math.round(_frame) == _frame))
            {
                result[1]
                return
            }
            
            return _smooth ? _frame : Math.round(_frame);
        */
        }

        public function get frame():Number
        {
            return _frame;
        }

        public function set frame(value:Number):void
        {
            _frame = value;

            if (!_loop)
                if (_frame > _sequence.length - 1)
                {
                    _frame = _sequence.length - 1;
                    stop();
                }

            /*
            var fr:Number = _frame;

            if (!_smooth)
                fr = Math.round(fr);

            if (fr == _lastframe)
                return;

            _lastframe = fr;

            var ceil:int = Math.ceil(_lastframe);
            var floor:int = Math.floor(_lastframe);
                
            if (ceil == floor)
            {
                _sequence[_lastframe]
            }
            // !!!
            */
        }

        public function get fps():Number
        {
            return _fps;
        }
        public function set fps(value:Number):void
        {
            _fps = value;
        }

        public function get loop():Boolean
        {
            return _loop;
        }
        public function set loop(value:Boolean):void
        {
            _loop = value;
        }

        public function get smooth():Boolean
        {
            return _smooth;
        }
        public function set smooth(value:Boolean):void
        {
            _smooth = value;
        }

        private var _running:Boolean;
        private var _time:uint;
        private var _endframe:uint;

        public function start():void
        {
            _time = getTimer();
            _running = true;

            frame = 0;
        }

        public function update():void
        {
            if (!_running)
                return;

            var now:uint = getTimer();

            frame += (now - _time) / (fps * 1000);

            _time = now;
        }

        public function stop():void
        {
            _running = false;    
        }

    }
}
