package jiglib.math
{
	import flash.geom.Vector3D;

	public class JNumber3D extends Vector3D
	{
		public function JNumber3D(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 0)
		{
			super(x, y, z, w);
		}

		public function copy():JNumber3D
		{
			return new JNumber3D(x, y, z, w);
		}

		public static function toJNumber3D(v:Vector3D):JNumber3D
		{
			return new JNumber3D(v.x, v.y, v.z, v.w);
		}

		public static function toVector3D(jn:JNumber3D):Vector3D
		{
			return new Vector3D(jn.x, jn.y, jn.z, jn.w);
		}

		public function copyTo(n:Vector3D):void
		{
			n.x = x;
			n.y = y;
			n.z = z;
		}

		/**
		 * Dot product.
		 */
		public static function dot(v:Vector3D, w:Vector3D):Number
		{
			return (v.x * w.x + v.y * w.y + w.z * v.z);
		}

		/**
		 * Cross product.
		 */
		public static function cross(v:Vector3D, w:Vector3D):Vector3D
		{
			return new JNumber3D((w.y * v.z) - (w.z * v.y), (w.z * v.x) - (w.x * v.z), (w.x * v.y) - (w.y * v.x));
		}

		public function isFinite():Boolean
		{
			if (x > 1000000 || x < -1000000)
				return true;
			if (y > 1000000 || y < -1000000)
				return true;
			if (z > 1000000 || z < -1000000)
				return true;
			return false;
		}

		public static function toArray(v:Vector3D):Array
		{
			return [v.x, v.y, v.z];
		}

		public static function scaleVector(v:Vector3D, s:Number):Vector3D
		{
			return new Vector3D(v.x * s, v.y * s, v.z * s);
		}

		public static function divideVector(v:Vector3D, w:Number):Vector3D
		{
			if (w != 0)
			{
				return new Vector3D(v.x / w, v.y / w, v.z / w);
			}
			else
			{
				return new Vector3D(0, 0, 0);
			}
		}

		public static function getNormal(v0:Vector3D, v1:Vector3D, v2:Vector3D):Vector3D
		{
			var E:Vector3D = v1.clone();
			var F:Vector3D = v2.clone();
			var N:Vector3D = E.subtract(v0).crossProduct(F.subtract(v1));
			N.normalize();

			return JNumber3D.toJNumber3D(N);
		}

		public static function copyFromArray(v:Vector3D, arr:Array):void
		{
			if (arr.length >= 3)
			{
				v.x = arr[0];
				v.y = arr[1];
				v.z = arr[2];
			}
		}

		public static function limiteNumber(num:Number, min:Number, max:Number):Number
		{
			var n:Number = num;
			if (n < min)
			{
				n = min;
			}
			else if (n > max)
			{
				n = max;
			}
			return n;
		}

		static public function get NUM_TINY():Number
		{
			return 0.00001;
		}

		static public function get NUM_HUGE():Number
		{
			return 100000;
		}
	}
}