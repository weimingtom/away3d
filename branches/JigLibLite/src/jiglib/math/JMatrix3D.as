package jiglib.math
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class JMatrix3D
	{
		public static function getTranslationMatrix(x:Number, y:Number, z:Number):Matrix3D
		{
			var matrix3d:Matrix3D = new Matrix3D();
			matrix3d.appendTranslation(x, y, z);
			return matrix3d;
		}
		
		public static function getScaleMatrix(x:Number, y:Number, z:Number):Matrix3D
		{
			var matrix3d:Matrix3D = new Matrix3D();
			matrix3d.prependScale(x, y, z);
			return matrix3d;
		}
		
		public static function getRotationMatrix(x:Number, y:Number, z:Number, rad:Number, pivotPoint:Vector3D=null):Matrix3D
		{
			var nCos:Number = Math.cos(rad);
			var nSin:Number = Math.sin(rad);
			var scos:Number = 1 - nCos;

			var sxy:Number = x * y * scos;
			var syz:Number = y * z * scos;
			var sxz:Number = x * z * scos;
			var sz:Number = nSin * z;
			var sy:Number = nSin * y;
			var sx:Number = nSin * x;

			var rawData:Vector.<Number> = new Vector.<Number>(16, true);
			
			rawData[0] = nCos + x * x * scos;
			rawData[4] = -sz + sxy;
			rawData[8] = sy + sxz;
			
			rawData[1] = sz + sxy;
			rawData[5] = nCos + y * y * scos;
			rawData[9] = -sx + syz;

			rawData[2] = -sy + sxz;
			rawData[6] = sx + syz;
			rawData[10] = nCos + z * z * scos;
			
			rawData[15] = 1;
			
			var matrix3d:Matrix3D = new Matrix3D(rawData);
			return matrix3d;
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
		
		public static function getRotationMatrixAxis(rad:Number, rotateAxis:Vector3D = Vector3D.X_AXIS):Matrix3D
		{
    		var matrix3d:Matrix3D = new Matrix3D();
    		matrix3d.appendRotation(rad, rotateAxis);
    		return matrix3d;
		}
		
		public static function getCols(matrix3d:Matrix3D):Vector.<Vector3D>
		{
			var _rawData:Vector.<Number> =  matrix3d.rawData;
			var cols:Vector.<Vector3D> = new Vector.<Vector3D>();
			
			cols[0] = new Vector3D(_rawData[0], _rawData[4], _rawData[8]);
			cols[1] = new Vector3D(_rawData[1], _rawData[5], _rawData[9]);
			cols[2] = new Vector3D(_rawData[2], _rawData[6], _rawData[10]);
			
			return cols;
		}

		public static function getMultiplyVector(matrix3d:Matrix3D, v:Vector3D):void
		{
			var vx:Number = v.x;
			var vy:Number = v.y;
			var vz:Number = v.z;
			
			var _rawData:Vector.<Number> =  matrix3d.rawData;
			
			v.x = vx * _rawData[0] + vy * _rawData[4] + vz * _rawData[8] + _rawData[12];
			v.y = vx * _rawData[1] + vy * _rawData[5] + vz * _rawData[9] + _rawData[13];
			v.z = vx * _rawData[2] + vy * _rawData[6] + vz * _rawData[10] + _rawData[14];
		}
	}
}