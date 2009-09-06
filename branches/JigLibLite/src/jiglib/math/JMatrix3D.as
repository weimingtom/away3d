package jiglib.math
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class JMatrix3D
	{
		public var n11:Number;
		public var n12:Number;
		public var n13:Number;
		public var n14:Number;

		public var n21:Number;
		public var n22:Number;
		public var n23:Number;
		public var n24:Number;

		public var n31:Number;
		public var n32:Number;
		public var n33:Number;
		public var n34:Number;

		public var n41:Number;
		public var n42:Number;
		public var n43:Number;
		public var n44:Number;

		public var sid:String;
		public var type:String = "";

		public function JMatrix3D(args:Vector.<Number>=null)
		{
			if (!args || args.length < 12)
			{
				n11 = n22 = n33 = n44 = 1;
				n12 = n13 = n14 = n21 = n23 = n24 = n31 = n32 = n34 = n41 = n42 = n43 = 0;
			}
			else
			{
				n11 = args[0];
				n12 = args[1];
				n13 = args[2];
				n14 = args[3];
				n21 = args[4];
				n22 = args[5];
				n23 = args[6];
				n24 = args[7];
				n31 = args[8];
				n32 = args[9];
				n33 = args[10];
				n34 = args[11];

				if (args.length == 16)
				{
					n41 = args[12];
					n42 = args[13];
					n43 = args[14];
					n44 = args[15];
				}
			}
		}

		// _________________________________________________________________________________ IDENTITY

		public static function get IDENTITY():JMatrix3D
		{
			return new JMatrix3D();
		/*
		   return new JMatrix3D([1, 0, 0, 0,
		   0, 1, 0, 0,
		   0, 0, 1, 0,
		   0, 0, 0, 1]);
		 */
		}

		// dirty proxy for testing perpose, to be remove
		public static function toMatrix3D(m:JMatrix3D):Matrix3D
		{
			return new Matrix3D(Vector.<Number>([
				m.n11, m.n21, m.n31, m.n41,
				m.n12, m.n22, m.n32, m.n42,
				m.n13, m.n23, m.n33, m.n43,
				m.n14, m.n24, m.n34, m.n44
				]));
		}

		public static function toJMatrix3D(m:Matrix3D):JMatrix3D
		{
			var _rawData:Vector.<Number> = m.rawData;
			return new JMatrix3D(Vector.<Number>([
				_rawData[0], _rawData[4], _rawData[8], _rawData[12],
				_rawData[1], _rawData[5], _rawData[9], _rawData[13],
				_rawData[2], _rawData[6], _rawData[10], _rawData[14],
				_rawData[3], _rawData[7], _rawData[11], _rawData[15]
				]));
		}

		// _________________________________________________________________________________ trace

		public function toString():String
		{
			var s:String = "";

			s += int(n11 * 1000) / 1000 + "\t\t" + int(n12 * 1000) / 1000 + "\t\t" + int(n13 * 1000) / 1000 + "\t\t" + int(n14 * 1000) / 1000 + "\n";
			s += int(n21 * 1000) / 1000 + "\t\t" + int(n22 * 1000) / 1000 + "\t\t" + int(n23 * 1000) / 1000 + "\t\t" + int(n24 * 1000) / 1000 + "\n";
			s += int(n31 * 1000) / 1000 + "\t\t" + int(n32 * 1000) / 1000 + "\t\t" + int(n33 * 1000) / 1000 + "\t\t" + int(n34 * 1000) / 1000 + "\n";
			s += int(n41 * 1000) / 1000 + "\t\t" + int(n42 * 1000) / 1000 + "\t\t" + int(n43 * 1000) / 1000 + "\t\t" + int(n44 * 1000) / 1000 + "\n";

			return s;
		}

		// _________________________________________________________________________________ OPERATIONS

		public function calculateMultiply(a:JMatrix3D, b:JMatrix3D):void
		{
			var a11:Number = a.n11;
			var b11:Number = b.n11;
			var a21:Number = a.n21;
			var b21:Number = b.n21;
			var a31:Number = a.n31;
			var b31:Number = b.n31;
			var a12:Number = a.n12;
			var b12:Number = b.n12;
			var a22:Number = a.n22;
			var b22:Number = b.n22;
			var a32:Number = a.n32;
			var b32:Number = b.n32;
			var a13:Number = a.n13;
			var b13:Number = b.n13;
			var a23:Number = a.n23;
			var b23:Number = b.n23;
			var a33:Number = a.n33;
			var b33:Number = b.n33;
			var a14:Number = a.n14;
			var b14:Number = b.n14;
			var a24:Number = a.n24;
			var b24:Number = b.n24;
			var a34:Number = a.n34;
			var b34:Number = b.n34;

			this.n11 = a11 * b11 + a12 * b21 + a13 * b31;
			this.n12 = a11 * b12 + a12 * b22 + a13 * b32;
			this.n13 = a11 * b13 + a12 * b23 + a13 * b33;
			this.n14 = a11 * b14 + a12 * b24 + a13 * b34 + a14;

			this.n21 = a21 * b11 + a22 * b21 + a23 * b31;
			this.n22 = a21 * b12 + a22 * b22 + a23 * b32;
			this.n23 = a21 * b13 + a22 * b23 + a23 * b33;
			this.n24 = a21 * b14 + a22 * b24 + a23 * b34 + a24;

			this.n31 = a31 * b11 + a32 * b21 + a33 * b31;
			this.n32 = a31 * b12 + a32 * b22 + a33 * b32;
			this.n33 = a31 * b13 + a32 * b23 + a33 * b33;
			this.n34 = a31 * b14 + a32 * b24 + a33 * b34 + a34;
		}

		public static function multiply(a:JMatrix3D, b:JMatrix3D):JMatrix3D
		{
			var m:JMatrix3D = new JMatrix3D();
			m.calculateMultiply(a, b);
			return m;
		}

		public function calculateMultiply3x3(a:JMatrix3D, b:JMatrix3D):void
		{
			var a11:Number = a.n11;
			var b11:Number = b.n11;
			var a21:Number = a.n21;
			var b21:Number = b.n21;
			var a31:Number = a.n31;
			var b31:Number = b.n31;
			var a12:Number = a.n12;
			var b12:Number = b.n12;
			var a22:Number = a.n22;
			var b22:Number = b.n22;
			var a32:Number = a.n32;
			var b32:Number = b.n32;
			var a13:Number = a.n13;
			var b13:Number = b.n13;
			var a23:Number = a.n23;
			var b23:Number = b.n23;
			var a33:Number = a.n33;
			var b33:Number = b.n33;

			this.n11 = a11 * b11 + a12 * b21 + a13 * b31;
			this.n12 = a11 * b12 + a12 * b22 + a13 * b32;
			this.n13 = a11 * b13 + a12 * b23 + a13 * b33;

			this.n21 = a21 * b11 + a22 * b21 + a23 * b31;
			this.n22 = a21 * b12 + a22 * b22 + a23 * b32;
			this.n23 = a21 * b13 + a22 * b23 + a23 * b33;

			this.n31 = a31 * b11 + a32 * b21 + a33 * b31;
			this.n32 = a31 * b12 + a32 * b22 + a33 * b32;
			this.n33 = a31 * b13 + a32 * b23 + a33 * b33;
		}

		public function calculateMultiply4x4(a:JMatrix3D, b:JMatrix3D):void
		{
			var a11:Number = a.n11;
			var b11:Number = b.n11;
			var a21:Number = a.n21;
			var b21:Number = b.n21;
			var a31:Number = a.n31;
			var b31:Number = b.n31;
			var a41:Number = a.n41;
			//var b41:Number = b.n41;

			var a12:Number = a.n12;
			var b12:Number = b.n12;
			var a22:Number = a.n22;
			var b22:Number = b.n22;
			var a32:Number = a.n32;
			var b32:Number = b.n32;
			var a42:Number = a.n42;
			//var b42:Number = b.n42;

			var a13:Number = a.n13;
			var b13:Number = b.n13;
			var a23:Number = a.n23;
			var b23:Number = b.n23;
			var a33:Number = a.n33;
			var b33:Number = b.n33;
			var a43:Number = a.n43;
			//var b43:Number = b.n43;

			var a14:Number = a.n14;
			var b14:Number = b.n14;
			var a24:Number = a.n24;
			var b24:Number = b.n24;
			var a34:Number = a.n34;
			var b34:Number = b.n34;
			var a44:Number = a.n44;
			//var b44:Number = b.n44;

			this.n11 = a11 * b11 + a12 * b21 + a13 * b31;
			this.n12 = a11 * b12 + a12 * b22 + a13 * b32;
			this.n13 = a11 * b13 + a12 * b23 + a13 * b33;
			this.n14 = a11 * b14 + a12 * b24 + a13 * b34 + a14;

			this.n21 = a21 * b11 + a22 * b21 + a23 * b31;
			this.n22 = a21 * b12 + a22 * b22 + a23 * b32;
			this.n23 = a21 * b13 + a22 * b23 + a23 * b33;
			this.n24 = a21 * b14 + a22 * b24 + a23 * b34 + a24;

			this.n31 = a31 * b11 + a32 * b21 + a33 * b31;
			this.n32 = a31 * b12 + a32 * b22 + a33 * b32;
			this.n33 = a31 * b13 + a32 * b23 + a33 * b33;
			this.n34 = a31 * b14 + a32 * b24 + a33 * b34 + a34;

			this.n41 = a41 * b11 + a42 * b21 + a43 * b31;
			this.n42 = a41 * b12 + a42 * b22 + a43 * b32;
			this.n43 = a41 * b13 + a42 * b23 + a43 * b33;
			this.n44 = a41 * b14 + a42 * b24 + a43 * b34 + a44;
		}

		public static function scaleVector3x3(a:JMatrix3D, b:JMatrix3D):JMatrix3D
		{
			var m:JMatrix3D = new JMatrix3D();

			m.calculateMultiply3x3(a, b);

			return m;
		}


		public function calculateAdd(a:JMatrix3D, b:JMatrix3D):void
		{
			this.n11 = a.n11 + b.n11;
			this.n12 = a.n12 + b.n12;
			this.n13 = a.n13 + b.n13;
			this.n14 = a.n14 + b.n14;

			this.n21 = a.n21 + b.n21;
			this.n22 = a.n22 + b.n22;
			this.n23 = a.n23 + b.n23;
			this.n24 = a.n24 + b.n24;

			this.n31 = a.n31 + b.n31;
			this.n32 = a.n32 + b.n32;
			this.n33 = a.n33 + b.n33;
			this.n34 = a.n34 + b.n34;
		}

		public static function add(a:JMatrix3D, b:JMatrix3D):JMatrix3D
		{
			var m:JMatrix3D = new JMatrix3D();

			m.calculateAdd(a, b);

			return m;
		}


		public function calculateInverse(m:JMatrix3D):void
		{
			var d:Number = m.det;

			if (Math.abs(d) > 0.001)
			{
				d = 1 / d;

				var m11:Number = m.n11;
				var m21:Number = m.n21;
				var m31:Number = m.n31;
				var m12:Number = m.n12;
				var m22:Number = m.n22;
				var m32:Number = m.n32;
				var m13:Number = m.n13;
				var m23:Number = m.n23;
				var m33:Number = m.n33;
				var m14:Number = m.n14;
				var m24:Number = m.n24;
				var m34:Number = m.n34;

				this.n11 = d * (m22 * m33 - m32 * m23);
				this.n12 = -d * (m12 * m33 - m32 * m13);
				this.n13 = d * (m12 * m23 - m22 * m13);
				this.n14 = -d * (m12 * (m23 * m34 - m33 * m24) - m22 * (m13 * m34 - m33 * m14) + m32 * (m13 * m24 - m23 * m14));

				this.n21 = -d * (m21 * m33 - m31 * m23);
				this.n22 = d * (m11 * m33 - m31 * m13);
				this.n23 = -d * (m11 * m23 - m21 * m13);
				this.n24 = d * (m11 * (m23 * m34 - m33 * m24) - m21 * (m13 * m34 - m33 * m14) + m31 * (m13 * m24 - m23 * m14));

				this.n31 = d * (m21 * m32 - m31 * m22);
				this.n32 = -d * (m11 * m32 - m31 * m12);
				this.n33 = d * (m11 * m22 - m21 * m12);
				this.n34 = -d * (m11 * (m22 * m34 - m32 * m24) - m21 * (m12 * m34 - m32 * m14) + m31 * (m12 * m24 - m22 * m14));
			}
		}

		public static function inverse(m:JMatrix3D):JMatrix3D
		{
			var inv:JMatrix3D = new JMatrix3D();

			inv.calculateInverse(m);

			return inv;
		}

		public function get det():Number
		{
			return (this.n11 * this.n22 - this.n21 * this.n12) * this.n33 - (this.n11 * this.n32 - this.n31 * this.n12) * this.n23 + (this.n21 * this.n32 - this.n31 * this.n22) * this.n13;
		}


		public function get trace():Number
		{
			return this.n11 + this.n22 + this.n33 + 1;
		}

		// _________________________________________________________________________________ COPY

		public function copy(m:JMatrix3D):JMatrix3D
		{
			this.n11 = m.n11;
			this.n12 = m.n12;
			this.n13 = m.n13;
			this.n14 = m.n14;

			this.n21 = m.n21;
			this.n22 = m.n22;
			this.n23 = m.n23;
			this.n24 = m.n24;

			this.n31 = m.n31;
			this.n32 = m.n32;
			this.n33 = m.n33;
			this.n34 = m.n34;

			return this;
		}


		public function copy3x3(m:JMatrix3D):JMatrix3D
		{
			this.n11 = m.n11;
			this.n12 = m.n12;
			this.n13 = m.n13;
			this.n21 = m.n21;
			this.n22 = m.n22;
			this.n23 = m.n23;
			this.n31 = m.n31;
			this.n32 = m.n32;
			this.n33 = m.n33;

			return this;
		}


		public static function clone(m:JMatrix3D):JMatrix3D
		{
			return new JMatrix3D(Vector.<Number>([m.n11, m.n12, m.n13, m.n14,
				m.n21, m.n22, m.n23, m.n24,
				m.n31, m.n32, m.n33, m.n34]));
		}

		// _________________________________________________________________________________ VECTOR

		public static function multiplyVector3x3(m:JMatrix3D, v:Vector3D):void
		{
			var vx:Number = v.x;
			var vy:Number = v.y;
			var vz:Number = v.z;

			v.x = vx * m.n11 + vy * m.n12 + vz * m.n13;
			v.y = vx * m.n21 + vy * m.n22 + vz * m.n23;
			v.z = vx * m.n31 + vy * m.n32 + vz * m.n33;
		}


		public static function rotateAxis(m:JMatrix3D, v:Vector3D):void
		{
			var vx:Number = v.x;
			var vy:Number = v.y;
			var vz:Number = v.z;

			v.x = vx * m.n11 + vy * m.n12 + vz * m.n13;
			v.y = vx * m.n21 + vy * m.n22 + vz * m.n23;
			v.z = vx * m.n31 + vy * m.n32 + vz * m.n33;

			v.normalize();
		}

		/*
		   public static function projectVector( m:JMatrix3D, v:Vector3D ):void
		   {
		   var c:Number = 1 / ( v.x * m.n41 + v.y * m.n42 + v.z * m.n43 + 1 );
		   multiplyVector( m, v );

		   v.x = v.x * c;
		   v.y = v.y * c;
		   v.z = 0;
		   }
		 */

		// _________________________________________________________________________________ EULER

		/*
		   public static function matrix2eulerOLD( m:JMatrix3D ):Vector3D
		   {
		   var angle:Vector3D = new Vector3D();

		   var d :Number = -Math.asin( Math.max( -1, Math.min( 1, m.n13 ) ) ); // Calculate Y-axis angle
		   var c :Number =  Math.cos( d );

		   angle.y = d * toDEGREES;

		   var trX:Number, trY:Number;

		   if( Math.abs( c ) > 0.005 )  // Gimball lock?
		   {
		   trX =  m.n33 / c;  // No, so get X-axis angle
		   trY = -m.n23 / c;

		   angle.x = Math.atan2( trY, trX ) * toDEGREES;

		   trX =  m.n11 / c;  // Get Z-axis angle
		   trY = -m.n12 / c;

		   angle.z = Math.atan2( trY, trX ) * toDEGREES;
		   }
		   else  // Gimball lock has occurred
		   {
		   angle.x = 0;  // Set X-axis angle to zero

		   trX = m.n22;  // And calculate Z-axis angle
		   trY = m.n21;

		   angle.z = Math.atan2( trY, trX ) * toDEGREES;
		   }

		   // TODO: Clamp all angles to range

		   return angle;
		   }
		 */

		public static function matrix2euler(m:JMatrix3D, euler:Vector3D = null, scale:Vector3D = null):Vector3D
		{
			euler = euler || new Vector3D();

			// need to get rid of scale
			// TODO: whene scale is uniform, we can save some cycles. s = 3x3 determinant i beleive
			var sx:Number = (scale && scale.x == 1) ? 1 : Math.sqrt(m.n11 * m.n11 + m.n21 * m.n21 + m.n31 * m.n31);
			var sy:Number = (scale && scale.y == 1) ? 1 : Math.sqrt(m.n12 * m.n12 + m.n22 * m.n22 + m.n32 * m.n32);
			var sz:Number = (scale && scale.z == 1) ? 1 : Math.sqrt(m.n13 * m.n13 + m.n23 * m.n23 + m.n33 * m.n33);

			var n11:Number = m.n11 / sx;
			var n21:Number = m.n21 / sy;
			var n31:Number = m.n31 / sz;
			var n32:Number = m.n32 / sz;
			var n33:Number = m.n33 / sz;

			n31 = n31 > 1 ? 1 : n31;
			n31 = n31 < -1 ? -1 : n31;

			// zyx
			euler.y = Math.asin(-n31);
			euler.z = Math.atan2(n21, n11);
			euler.x = Math.atan2(n32, n33);

			// TODO: fix singularities

			// yzx
			//euler.z = Math.asin(-m.n21);
			//euler.y = Math.atan2(m.n31, m.n11);
			//euler.x = Math.atan2(-m.n23, m.n22);

			// zxy
			//euler.x = Math.asin(-m.n32);
			//euler.z = Math.atan2(-m.n12, m.n22);
			//euler.y = Math.atan2(-m.n31, m.n33);

			euler.x *= toDEGREES;
			euler.y *= toDEGREES;
			euler.z *= toDEGREES;

			//  Clamp values
			// euler.x = euler.x < 0 ? euler.x + 360 : euler.x;
			// euler.y = euler.y < 0 ? euler.y + 360 : euler.y;
			// euler.z = euler.z < 0 ? euler.z + 360 : euler.z;

			return euler;
		}


		public static function euler2matrix(deg:Vector3D):JMatrix3D
		{
			var m:JMatrix3D = IDENTITY;

			var ax:Number = deg.x * toRADIANS;
			var ay:Number = deg.y * toRADIANS;
			var az:Number = deg.z * toRADIANS;

			var a:Number = Math.cos(ax);
			var b:Number = Math.sin(ax);
			var c:Number = Math.cos(ay);
			var d:Number = Math.sin(ay);
			var e:Number = Math.cos(az);
			var f:Number = Math.sin(az);

			var ad:Number = a * d;
			var bd:Number = b * d;

			m.n11 = c * e;
			m.n12 = -c * f;
			m.n13 = d;
			m.n21 = bd * e + a * f;
			m.n22 = -bd * f + a * e;
			m.n23 = -b * c;
			m.n31 = -ad * e + b * f;
			m.n32 = ad * f + b * e;
			m.n33 = a * c;

			return m;
		}

		// _________________________________________________________________________________ ROTATION

		public static function rotationX(rad:Number):JMatrix3D
		{
			var m:JMatrix3D = IDENTITY;
			var c:Number = Math.cos(rad);
			var s:Number = Math.sin(rad);

			m.n22 = c;
			m.n23 = -s;
			m.n32 = s;
			m.n33 = c;

			return m;
		}

		public static function rotationY(rad:Number):JMatrix3D
		{
			var m:JMatrix3D = IDENTITY;
			var c:Number = Math.cos(rad);
			var s:Number = Math.sin(rad);

			m.n11 = c;
			m.n13 = -s;
			m.n31 = s;
			m.n33 = c;

			return m;
		}

		public static function rotationZ(rad:Number):JMatrix3D
		{
			var m:JMatrix3D = IDENTITY;
			var c:Number = Math.cos(rad);
			var s:Number = Math.sin(rad);

			m.n11 = c;
			m.n12 = -s;
			m.n21 = s;
			m.n22 = c;

			return m;
		}

		public static function rotationMatrix(x:Number, y:Number, z:Number, rad:Number):JMatrix3D
		{
			var m:JMatrix3D = IDENTITY;

			var nCos:Number = Math.cos(rad);
			var nSin:Number = Math.sin(rad);
			var scos:Number = 1 - nCos;

			var sxy:Number = x * y * scos;
			var syz:Number = y * z * scos;
			var sxz:Number = x * z * scos;
			var sz:Number = nSin * z;
			var sy:Number = nSin * y;
			var sx:Number = nSin * x;

			m.n11 = nCos + x * x * scos;
			m.n12 = -sz + sxy;
			m.n13 = sy + sxz;

			m.n21 = sz + sxy;
			m.n22 = nCos + y * y * scos;
			m.n23 = -sx + syz;

			m.n31 = -sy + sxz;
			m.n32 = sx + syz;
			m.n33 = nCos + z * z * scos;

			return m;
		}
		
		public static function rotationMatrixWithReference(axis:Vector3D, rad:Number, ref:Vector3D):JMatrix3D
		{
			var m:JMatrix3D = JMatrix3D.translationMatrix(ref.x, -ref.y, ref.z);

			m.calculateMultiply(m, JMatrix3D.rotationMatrix(axis.x, axis.y, axis.z, rad));
			m.calculateMultiply(m, JMatrix3D.translationMatrix(-ref.x, ref.y, -ref.z));

			return m;
		}

		// _________________________________________________________________________________ TRANSFORM

		public static function translationMatrix(x:Number, y:Number, z:Number):JMatrix3D
		{
			var m:JMatrix3D = IDENTITY;

			m.n14 = x;
			m.n24 = y;
			m.n34 = z;

			return m;
		}

		// _________________________________________________________________________________ QUATERNIONS

		public static function magnitudeQuaternion(q:Vector3D):Number
		{
			return (Math.sqrt(q.w * q.w + q.x * q.x + q.y * q.y + q.z * q.z));
		}

		public static function normalizeQuaternion(q:Vector3D):Object
		{
			var mag:Number = magnitudeQuaternion(q);

			q.x /= mag;
			q.y /= mag;
			q.z /= mag;
			q.w /= mag;

			return q;
		}

		public static function axis2quaternion(x:Number, y:Number, z:Number, angle:Number):Object
		{
			var sin:Number = Math.sin(angle / 2);
			var cos:Number = Math.cos(angle / 2);

			var q:Vector3D = new Vector3D();

			q.x = x * sin;
			q.y = y * sin;
			q.z = z * sin;
			q.w = cos;

			return normalizeQuaternion(q);
		}


		public static function euler2quaternion(ax:Number, ay:Number, az:Number):Object
		{
			var fSinPitch:Number = Math.sin(ax * 0.5);
			var fCosPitch:Number = Math.cos(ax * 0.5);
			var fSinYaw:Number = Math.sin(ay * 0.5);
			var fCosYaw:Number = Math.cos(ay * 0.5);
			var fSinRoll:Number = Math.sin(az * 0.5);
			var fCosRoll:Number = Math.cos(az * 0.5);
			var fCosPitchCosYaw:Number = fCosPitch * fCosYaw;
			var fSinPitchSinYaw:Number = fSinPitch * fSinYaw;

			var q:Vector3D = new Vector3D();

			q.x = fSinRoll * fCosPitchCosYaw - fCosRoll * fSinPitchSinYaw;
			q.y = fCosRoll * fSinPitch * fCosYaw + fSinRoll * fCosPitch * fSinYaw;
			q.z = fCosRoll * fCosPitch * fSinYaw - fSinRoll * fSinPitch * fCosYaw;
			q.w = fCosRoll * fCosPitchCosYaw + fSinRoll * fSinPitchSinYaw;

			return q;
		}


		public static function quaternion2matrix(x:Number, y:Number, z:Number, w:Number):JMatrix3D
		{
			var xx:Number = x * x;
			var xy:Number = x * y;
			var xz:Number = x * z;
			var xw:Number = x * w;

			var yy:Number = y * y;
			var yz:Number = y * z;
			var yw:Number = y * w;

			var zz:Number = z * z;
			var zw:Number = z * w;

			var m:JMatrix3D = IDENTITY;

			m.n11 = 1 - 2 * (yy + zz);
			m.n12 = 2 * (xy - zw);
			m.n13 = 2 * (xz + yw);

			m.n21 = 2 * (xy + zw);
			m.n22 = 1 - 2 * (xx + zz);
			m.n23 = 2 * (yz - xw);

			m.n31 = 2 * (xz - yw);
			m.n32 = 2 * (yz + xw);
			m.n33 = 1 - 2 * (xx + yy);

			return m;
		}


		public static function scaleVectorQuaternion(a:Vector3D, b:Vector3D):Vector3D
		{
			var ax:Number = a.x;
			var ay:Number = a.y;
			var az:Number = a.z;
			var aw:Number = a.w;
			var bx:Number = b.x;
			var by:Number = b.y;
			var bz:Number = b.z;
			var bw:Number = b.w;

			var q:Vector3D = new Vector3D();

			q.x = aw * bx + ax * bw + ay * bz - az * by;
			q.y = aw * by + ay * bw + az * bx - ax * bz;
			q.z = aw * bz + az * bw + ax * by - ay * bx;
			q.w = aw * bw - ax * bx - ay * by - az * bz;

			return q;
		}


		// _________________________________________________________________________________ TRIG

		static private var toDEGREES:Number = 180 / Math.PI;
		static private var toRADIANS:Number = Math.PI / 180;

		static private var _sin:Function = Math.sin;
		static private var _cos:Function = Math.cos;

		/*
		 * modify by Muzer
		 */
		public function getCols():Vector.<Vector3D>
		{
			var cols:Vector.<Vector3D> = new Vector.<Vector3D>();
			cols[0] = new Vector3D(n11, n21, n31);
			cols[1] = new Vector3D(n12, n22, n32);
			cols[2] = new Vector3D(n13, n23, n33);
			return cols;
		}

		public function calculateSub(a:JMatrix3D, b:JMatrix3D):void
		{
			this.n11 = a.n11 - b.n11;
			this.n12 = a.n12 - b.n12;
			this.n13 = a.n13 - b.n13;
			this.n14 = a.n14 - b.n14;

			this.n21 = a.n21 - b.n21;
			this.n22 = a.n22 - b.n22;
			this.n23 = a.n23 - b.n23;
			this.n24 = a.n24 - b.n24;

			this.n31 = a.n31 - b.n31;
			this.n32 = a.n32 - b.n32;
			this.n33 = a.n33 - b.n33;
			this.n34 = a.n34 - b.n34;
		}

		public static function sub(a:JMatrix3D, b:JMatrix3D):JMatrix3D
		{
			var m:JMatrix3D = new JMatrix3D();

			m.calculateSub(a, b);

			return m;
		}
		
		public static function multiplyVector( m:JMatrix3D, v:Vector3D ):void {
			var vx:Number = v.x;
			var vy:Number = v.y;
			var vz:Number = v.z;
		
			v.x = vx * m.n11 + vy * m.n12 + vz * m.n13 + m.n14;
			v.y = vx * m.n21 + vy * m.n22 + vz * m.n23 + m.n24;
			v.z = vx * m.n31 + vy * m.n32 + vz * m.n33 + m.n34;
		}
		
		public static function __multiplyVector(matrix3d:Matrix3D, v:Vector3D):void
		{
			var vx:Number = v.x;
			var vy:Number = v.y;
			var vz:Number = v.z;

			v.x = vx * matrix3d.rawData[0] + vy * matrix3d.rawData[1] + vz * matrix3d.rawData[2] + matrix3d.rawData[3];
			v.y = vx * matrix3d.rawData[4] + vy * matrix3d.rawData[5] + vz * matrix3d.rawData[6] + matrix3d.rawData[7];
			v.z = vx * matrix3d.rawData[8] + vy * matrix3d.rawData[9] + vz * matrix3d.rawData[10] + matrix3d.rawData[11];
		}
		
		public static function __rotationMatrix(x:Number, y:Number, z:Number, rad:Number):Matrix3D
		{
			var matrix3d:Matrix3D = new Matrix3D();
			matrix3d.appendRotation(rad, new Vector3D(x, y, z));
			return matrix3d;
		}
		
		// utils
		public static function getInverseMatrix(m:Matrix3D):Matrix3D
		{
			var matrix3d:Matrix3D = m.clone();
			matrix3d.invert();
			return matrix3d;
		}
		
		public static function getTransposeMatrix(m:Matrix3D):Matrix3D
		{
			var matrix3d:Matrix3D = m.clone();
			matrix3d.transpose();
			return matrix3d;
		}
		
		public static function getTranslationMatrix(x:Number, y:Number, z:Number):Matrix3D
		{
			var matrix3d:Matrix3D = new Matrix3D();
			matrix3d.appendTranslation(x, y, z);
			return matrix3d;
		}

		public static function getAppendMatrix3D(a:Matrix3D, b:Matrix3D):Matrix3D
		{
			var matrix3D:Matrix3D = new Matrix3D();
			matrix3D.append(a);
			matrix3D.append(b);
			return matrix3D;
		}
	}
}