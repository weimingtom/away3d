package jiglib.math
{
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

		public function JMatrix3D(args:Vector.<Number> = null)
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

		public static function getMatrix3D(m:JMatrix3D):Matrix3D
		{
			return new Matrix3D(Vector.<Number>([m.n11, m.n21, m.n31, m.n41, m.n12, m.n22, m.n32, m.n42, m.n13, m.n23, m.n33, m.n43, m.n14, m.n24, m.n34, m.n44]));
		}

		public static function getJMatrix3D(m:Matrix3D):JMatrix3D
		{
			var _rawData:Vector.<Number> = m.rawData;
			return new JMatrix3D(Vector.<Number>([_rawData[0], _rawData[4], _rawData[8], _rawData[12], _rawData[1], _rawData[5], _rawData[9], _rawData[13], _rawData[2], _rawData[6], _rawData[10], _rawData[14], _rawData[3], _rawData[7], _rawData[11], _rawData[15]]));
		}

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

		public static function rotationX(rad:Number):JMatrix3D
		{
			var m:JMatrix3D = new JMatrix3D();
			var c:Number = Math.cos(rad);
			var s:Number = Math.sin(rad);

			m.n22 = c;
			m.n23 = -s;
			m.n32 = s;
			m.n33 = c;

			return m;
			
    		/*
    		var m:Matrix3D = new Matrix3D();
    		m.appendRotation(rad, Vector3D.X_AXIS);
    		
    		return getJMatrix3D(m);
    		*/
    		
			/*
			var matrix3d:Matrix3D = new Matrix3D();
			var c:Number = Math.cos(rad);
			var s:Number = Math.sin(rad);

			matrix3d.rawData[5] = c;
			matrix3d.rawData[9] = -s;
			matrix3d.rawData[6] = s;
			matrix3d.rawData[10] = c;

			return getJMatrix3D(matrix3d);
			*/
		}

		public static function rotationY(rad:Number):JMatrix3D
		{
			var m:JMatrix3D = new JMatrix3D();
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
			var m:JMatrix3D = new JMatrix3D();
			var c:Number = Math.cos(rad);
			var s:Number = Math.sin(rad);

			m.n11 = c;
			m.n12 = -s;
			m.n21 = s;
			m.n22 = c;

			return m;
		}
		
		public static function __getCols(matrix3d:Matrix3D):Vector.<Vector3D>
		{
			var cols:Vector.<Vector3D> = new Vector.<Vector3D>();
			cols[0] = new Vector3D(matrix3d.rawData[0], matrix3d.rawData[4], matrix3d.rawData[8]);
			cols[1] = new Vector3D(matrix3d.rawData[1], matrix3d.rawData[5], matrix3d.rawData[9]);
			cols[2] = new Vector3D(matrix3d.rawData[2], matrix3d.rawData[6], matrix3d.rawData[10]);
			return cols;
		}

		public static function __multiplyVector(matrix3d:Matrix3D, v:Vector3D):void
		{
			var vx:Number = v.x;
			var vy:Number = v.y;
			var vz:Number = v.z;
			
			/*
			v.x = vx * m.n11 + vy * m.n12 + vz * m.n13 + m.n14;
			v.y = vx * m.n21 + vy * m.n22 + vz * m.n23 + m.n24;
			v.z = vx * m.n31 + vy * m.n32 + vz * m.n33 + m.n34;
			*/
			v.x = vx * matrix3d.rawData[0] + vy * matrix3d.rawData[4] + vz * matrix3d.rawData[8] + matrix3d.rawData[12];
			v.y = vx * matrix3d.rawData[1] + vy * matrix3d.rawData[5] + vz * matrix3d.rawData[9] + matrix3d.rawData[13];
			v.z = vx * matrix3d.rawData[2] + vy * matrix3d.rawData[6] + vz * matrix3d.rawData[10] + matrix3d.rawData[14];
		}
		
		public static function getTranslationMatrix(x:Number, y:Number, z:Number):Matrix3D
		{
			var matrix3d:Matrix3D = new Matrix3D();
			matrix3d.appendTranslation(x, y, z);
			return matrix3d;
		}
		
		public static function getRotationMatrix(x:Number, y:Number, z:Number, rad:Number, piveotPoint:Vector3D=null):Matrix3D
		{
			var matrix3d:Matrix3D = new Matrix3D();
			
			//matrix3d.appendRotation(rad, new Vector3D(x, y, z), piveotPoint);
			
			var m:JMatrix3D = getJMatrix3D(matrix3d);

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

			
			return getMatrix3D(m);
		}
		
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

		public static function getAppendMatrix3D(a:Matrix3D, b:Matrix3D):Matrix3D
		{
			var matrix3D:Matrix3D = new Matrix3D();
			matrix3D.append(a);
			matrix3D.append(b);
			return matrix3D;
		}

		public static function getPrependMatrix(a:Matrix3D, b:Matrix3D):Matrix3D
		{
			var matrix3D:Matrix3D = new Matrix3D();
			matrix3D.prepend(a);
			matrix3D.prepend(b);
			return matrix3D;
		}
	}
}