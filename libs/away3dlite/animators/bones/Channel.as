package away3dlite.animators.bones
{
	import away3dlite.containers.*;
	import away3dlite.core.base.*;

	import flash.geom.*;

	/**
	 * Stores the varying transformations of a single <code>Bone</code> or <code>Object3D</code> object over the dureation of a bones animation
	 *
	 * @see away3dlite.animators.BonesAnimator
	 */
	public class Channel
	{
		private var i:int;
		private var _index:int;
		private var _length:int;
		private var _oldlength:int;

		/**
		 * 	@private
		 */
		private static const NO_SCALE:Vector3D = new Vector3D(1, 1, 1);

		public var name:String;
		public var target:Object3D;

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

		/**
		 * Updates the channel's target with the data point at the given time in seconds.
		 *
		 * @param	time						Defines the time in seconds of the playhead of the animation.
		 * @param	interpolate		[optional]	Defines whether the animation interpolates between channel points Defaults to true.
		 */
		public function update(time:Number, interpolate:Boolean = true):void
		{
			if (!target)
				return;

			i = type.length;

			if (time < times[0])
			{
				while (i--)
				{
					if (type[int(i)] == "transform")
					{
						target.transform.matrix3D = param[0][int(i)];
					}
					else if (type[int(i)] == "visibility")
					{
						target.visible = param[0][int(i)] > 0;
					}
					else
					{
						target[type[int(i)]] = param[0][int(i)];
					}
				}
			}
			else if (time > times[int(times.length - 1)])
			{
				while (i--)
				{
					if (type[int(i)] == "transform")
					{
						target.transform.matrix3D = param[int(times.length - 1)][int(i)];
					}
					else if (type[int(i)] == "visibility")
					{
						target.visible = param[int(times.length - 1)][int(i)] > 0;
					}
					else
					{
						target[type[int(i)]] = param[int(times.length - 1)][int(i)];
					}
				}
			}
			else
			{
				_index = _length = _oldlength = times.length - 1;

				while (_length > 1)
				{
					_oldlength = _length;
					_length >>= 1;

					if (times[_index - _length] > time)
					{
						_index -= _length;
						_length = _oldlength - _length;
					}
				}

				_index--;

				//NOTE: currently the interpolation is only CONSTANT or LINEAR. There's no BEZIER support currently
				while (i--)
				{
					if (type[int(i)] == "transform")
					{
						if (interpolate)
						{
							// Note: Matrix3D.interpolate should interpolate full pose (including position, orientation and scales)
							//       but it seems that Matrix3D.interpolate doesn't take into account scales!
							//       Moreover Matrix3D.interpolate is only performing LINEAR interpolation not BEZIER.
							//       So we should do the full computation by ourself:
							//          - We need to extract scale, translation and rotation-as-a-whole
							//          - Then we can interpolate each separatly and finally recombine them into a Matrix3D
							//       But because we currently only support LINEAR interpolation, we can still use Matrix3D.interpolate
							//       by just removing scales from src and dst matrices, then interpolate scales, separatly apply matrix
							//       interpolation (that contains only rotation and translation), and finally blend interpolated scale
							//       into interpolated matrix.

							var factor:Number = (time - times[_index]) / (times[int(_index + 1)] - times[_index]);

							var v3A:Vector.<Vector3D> = (param[_index][int(i)] as Matrix3D).decompose(Orientation3D.QUATERNION);
							var v3B:Vector.<Vector3D> = (param[int(_index + 1)][int(i)] as Matrix3D).decompose(Orientation3D.QUATERNION);

							var scalesA:Vector3D = v3A[2];
							var scalesB:Vector3D = v3B[2];
							scalesA.scaleBy(1 - factor);
							scalesB.scaleBy(factor);
							var scale:Vector3D = scalesA.add(scalesB);

							v3A[2] = NO_SCALE;
							v3B[2] = NO_SCALE;
							var matA:Matrix3D = new Matrix3D();
							matA.recompose(v3A, Orientation3D.QUATERNION);
							var matB:Matrix3D = new Matrix3D();
							matB.recompose(v3B, Orientation3D.QUATERNION);

							target.transform.matrix3D = Matrix3D.interpolate(matA, matB, factor);
							target.transform.matrix3D.prependScale(scale.x, scale.y, scale.z);
						}
						else
						{
							target.transform.matrix3D = param[_index][int(i)];
						}
					}
					else if (type[int(i)] == "visibility")
					{
						// NOTE: There's no need to take into account 'interpolate' here because visibility is not an interpolable concept : it's a boolean value.
						target.visible = param[_index][int(i)] > 0;
					}
					else
					{
						if (interpolate)
							target[type[int(i)]] = ((time - times[_index]) * param[int(_index + 1)][int(i)] + (times[int(_index + 1)] - time) * param[_index][int(i)]) / (times[int(_index + 1)] - times[_index]);
						else
							target[type[int(i)]] = param[_index][int(i)];
					}
				}
			}
		}

		public function clone(object:ObjectContainer3D):Channel
		{
			var channel:Channel = new Channel(name);

			channel.target = object.getChildByName(name) as Object3D;
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
