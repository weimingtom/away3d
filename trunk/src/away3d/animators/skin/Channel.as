package away3d.animators.skin
{
    import away3d.containers.*;
    import away3d.core.math.*;
	
    public class Channel
    {
    	private var i:int;
    	private var _index:int;
    	private var _length:int;
    	private var _oldlength:int;
    	
    	public var name:String;
        public var target:ObjectContainer3D;
        
        public var type:Array;
		
		public var param:Array;
		public var inTangent:Array;
        public var outTangent:Array;
        
        public var times:Array;
        public var interpolations:Array;
		
        public function Channel(name:String):void
        {
        	this.name = name;
        	
        	type = [];
        	
            param = [];
            inTangent = [];
            outTangent = [];
			times = [];
			
            interpolations = [];
        }

        public function update(time:Number):void
        {	
            if (!target)
                return;
			
			i = type.length;
				
            if (time < times[0]) {
            	while (i--)
	                target[type[i]] = param[0][i];
            } else if (time > times[int(times.length-1)]) {
            	while (i--)
	                target[type[i]] = param[int(times.length-1)][i];
            } else {
				_index = _length = _oldlength = times.length - 1;
				
				while (_length > 1)
				{
					_oldlength = _length;
					_length >>= 1;
					
					if (times[_index - _length] > time) {
						_index -= _length;
						_length = _oldlength - _length;
					}
				}
				
				_index--;
				
				while (i--) {
					if (type[i] == "transform") {
						target.transform = param[_index][i];
					} else {
						target[type[i]] = ((time - times[_index]) * param[int(_index + 1)][i] + (times[int(_index + 1)] - time) * param[_index][i]) / (times[int(_index + 1)] - times[_index]);
					}
				}
			}
        }
        
        public function clone(object:ObjectContainer3D):Channel
        {
        	var channel:Channel = new Channel(name);
        	
        	channel.target = object.getBoneByName(name);
        	channel.type = type.concat();
        	channel.param = param.concat();
        	channel.inTangent = inTangent.concat();
        	channel.outTangent = outTangent.concat();
        	channel.times = times.concat();
        	channel.interpolations = interpolations.concat();
        	
        	return channel;
        }
    }
}
