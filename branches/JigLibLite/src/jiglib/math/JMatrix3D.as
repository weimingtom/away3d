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
		
		public static function getRotationMatrix(x:Number, y:Number, z:Number, degree:Number, pivotPoint:Vector3D=null):Matrix3D
		{
			var matrix3D:Matrix3D = new Matrix3D();
			matrix3D.appendRotation(degree, new Vector3D(x,y,z),pivotPoint);
			return matrix3D;
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
		
		public static function getRotationMatrixAxis(degree:Number, rotateAxis:Vector3D = null):Matrix3D
		{
    		var matrix3d:Matrix3D = new Matrix3D();
    		matrix3d.appendRotation(degree, rotateAxis?rotateAxis:Vector3D.X_AXIS);
    		return matrix3d;
		}
		
		public static function getCols(matrix3d:Matrix3D):Vector.<Vector3D>
		{
			var _rawData:Vector.<Number> =  matrix3d.rawData;
			var cols:Vector.<Vector3D> = new Vector.<Vector3D>();
			
			cols[0] = new Vector3D(_rawData[0], _rawData[1], _rawData[2]);
			cols[1] = new Vector3D(_rawData[4], _rawData[5], _rawData[6]);
			cols[2] = new Vector3D(_rawData[8], _rawData[9], _rawData[10]);
			
			return cols;
		}

		public static function multiplyVector(matrix3d:Matrix3D, v:Vector3D):void
		{
			var vx:Number = v.x;
			var vy:Number = v.y;
			var vz:Number = v.z;
			var _rawData:Vector.<Number> =  matrix3d.rawData;
			
			v.x = vx * _rawData[0] + vy * _rawData[4] + vz * _rawData[8]  + _rawData[12];
			v.y = vx * _rawData[1] + vy * _rawData[5] + vz * _rawData[9]  + _rawData[13];
			v.z = vx * _rawData[2] + vy * _rawData[6] + vz * _rawData[10] + _rawData[14];
			
			v = matrix3d.transformVector(v);
		}
	}
}