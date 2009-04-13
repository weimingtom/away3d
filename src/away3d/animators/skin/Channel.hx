package away3d.animators.skin;

import away3d.containers.ObjectContainer3D;
import flash.events.EventDispatcher;
import away3d.core.base.Object3D;
import away3d.core.math.Matrix3D;
import away3d.core.math.Number2D;

class Channel  {
	
	private var i:Int;
	private var _index:Int;
	private var _length:Int;
	private var _oldlength:Int;
	public var name:String;
	public var target:Object3D;
	public var type:Array<String>;
	public var param:Array<Array<Dynamic>>;
	public var inTangent:Array<Array<Number2D>>;
	public var outTangent:Array<Array<Number2D>>;
	public var times:Array<Float>;
	public var interpolations:Array<String>;
	

	public function new(name:String):Void {
		
		
		this.name = name;
		type = [];
		param = [];
		inTangent = [];
		outTangent = [];
		times = [];
		interpolations = [];
	}

	/**
	 * Updates the channel's target with the data point at the given time in seconds.
	 * 
	 * @param	time						Defines the time in seconds of the playhead of the animation.
	 * @param	interpolate		[optional]	Defines whether the animation interpolates between channel points Defaults to true.
	 */
	public function update(time:Float, ?interpolate:Bool=true):Void {
		
		if (target == null) {
			return;
		}
		i = type.length;
		if (time < times[0]) {
			while ((i-- > 0)) {
				Reflect.setField(target, type[i], param[0][i]);
			}

		} else if (time > times[Std.int(times.length - 1)]) {
			while ((i-- > 0)) {
				Reflect.setField(target, type[i], param[Std.int(times.length - 1)][i]);
			}

		} else {
			_index = _length = _oldlength = times.length - 1;
			while (_length > 1) {
				_oldlength = _length;
				_length >>= 1;
				if (times[_index - _length] > time) {
					_index -= _length;
					_length = _oldlength - _length;
				}
			}

			_index--;
			while ((i-- > 0)) {
				if (type[i] == "transform") {
					target.transform = param[_index][i];
				} else {
					if (interpolate) {
						Reflect.setField(target, type[i], ((time - times[_index]) * param[Std.int(_index + 1)][i] + (times[Std.int(_index + 1)] - time) * param[_index][i]) / (times[Std.int(_index + 1)] - times[_index]));
					} else {
						Reflect.setField(target, type[i], param[_index][i]);
					}
				}
			}

		}
	}

	public function clone(object:ObjectContainer3D):Channel {
		
		var channel:Channel = new Channel(name);
		channel.target = object.getChildByName(name);
		channel.type = type.concat([]);
		channel.param = param.concat([]);
		channel.inTangent = inTangent.concat([]);
		channel.outTangent = outTangent.concat([]);
		channel.times = times.concat([]);
		channel.interpolations = interpolations.concat([]);
		return channel;
	}

}

