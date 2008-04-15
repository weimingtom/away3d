package away3d.core.light
{
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.events.Object3DEvent;
	import away3d.lights.*;
	
	import flash.display.*;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.*;
	import flash.utils.Dictionary;

    /** Point light source */
    public class DirectionalLightSource extends AbstractLightSource
    {
    	use namespace arcane;
    	
        public var direction:Number3D;
        
        public var diffuseTransform:Dictionary;
        public var specularTransform:Dictionary;
        public var ambientDiffuseColorTransform:ColorTransform;
        public var diffuseColorTransform:ColorTransform;
        
        public var colorMatrixTransform:Dictionary = new Dictionary(true);
        public var normalMatrixTransform:Dictionary = new Dictionary(true);
        
        public var light:DirectionalLight3D;
    	
    	
        internal var _colorMatrix:ColorMatrixFilter = new ColorMatrixFilter();
        internal var _normalMatrix:ColorMatrixFilter = new ColorMatrixFilter();
    	internal var _matrix:Matrix = new Matrix();
    	internal var _shape:Shape = new Shape();
		
		public function updateAmbientBitmap(ambient:Number):void
        {
        	this.ambient = ambient;
        	ambientBitmap = new BitmapData(256, 256, false, int(ambient*red << 16) | int(ambient*green << 8) | int(ambient*blue));
        	ambientBitmap.lock();
        }
        	
        public function updateDiffuseBitmap(diffuse:Number):void
        {
        	this.diffuse = diffuse;
    		diffuseBitmap = new BitmapData(256, 256, false, 0x000000);
    		diffuseBitmap.lock();
    		_matrix.createGradientBox(256, 256, 0, 0, 0);
    		var colArray:Array = new Array();
    		var alphaArray:Array = new Array();
    		var pointArray:Array = new Array();
    		var i:int = 15;
    		while (i--) {
    			var r:Number = (i*diffuse/14);
    			if (r > 1) r = 1;
    			var g:Number = (i*diffuse/14);
    			if (g > 1) g = 1;
    			var b:Number = (i*diffuse/14);
    			if (b > 1) b = 1;
    			colArray.push((r*red << 16) | (g*green << 8) | b*blue);
    			alphaArray.push(1);
    			pointArray.push(int(30+225*2*Math.acos(i/14)/Math.PI));
    		}
    		_shape.graphics.clear();
    		_shape.graphics.beginGradientFill(GradientType.LINEAR, colArray, alphaArray, pointArray, _matrix);
    		_shape.graphics.drawRect(0, 0, 256, 256);
    		diffuseBitmap.draw(_shape);
        	
        	//update colortransform
        	diffuseColorTransform = new ColorTransform(diffuse*red/255, diffuse*green/255, diffuse*blue/255, 1, 0, 0, 0, 0);
        }
        
        public function updateAmbientDiffuseBitmap(ambient:Number, diffuse:Number):void
        {
        	this.diffuse = diffuse;
    		ambientDiffuseBitmap = new BitmapData(256, 256, false, 0x000000);
    		ambientDiffuseBitmap.lock();
    		_matrix.createGradientBox(256, 256, 0, 0, 0);
    		var colArray:Array = new Array();
    		var alphaArray:Array = new Array();
    		var pointArray:Array = new Array();
    		var i:int = 15;
    		while (i--) {
    			var r:Number = (i*diffuse/14 + ambient);
    			if (r > 1) r = 1;
    			var g:Number = (i*diffuse/14 + ambient);
    			if (g > 1) g = 1;
    			var b:Number = (i*diffuse/14 + ambient);
    			if (b > 1) b = 1;
    			colArray.push((r*red << 16) | (g*green << 8) | b*blue);
    			alphaArray.push(1);
    			pointArray.push(int(30+225*2*Math.acos(i/14)/Math.PI));
    		}
    		_shape.graphics.clear();
    		_shape.graphics.beginGradientFill(GradientType.LINEAR, colArray, alphaArray, pointArray, _matrix);
    		_shape.graphics.drawRect(0, 0, 256, 256);
    		ambientDiffuseBitmap.draw(_shape);
        	
        	//update colortransform
        	ambientDiffuseColorTransform = new ColorTransform(diffuse*red/255, diffuse*green/255, diffuse*blue/255, 1, ambient*red, ambient*green, ambient*blue, 0);
        }
        		
        public function updateSpecularBitmap(specular:Number):void
        {
        	this.specular = specular;
    		specularBitmap = new BitmapData(512, 512, false, 0x000000);
    		specularBitmap.lock();
    		_matrix.createGradientBox(512, 512, 0, 0, 0);
    		var colArray:Array = new Array();
    		var alphaArray:Array = new Array();
    		var pointArray:Array = new Array();
    		var i:int = 14;
    		while (i--) {
    			colArray.push((i*specular*red/14 << 16) + (i*specular*green/14 << 8) + i*specular*blue/14);
    			alphaArray.push(1);
    			pointArray.push(int(30+225*2*Math.acos(Math.pow(i/14,1/20))/Math.PI));
    		}
    		_shape.graphics.clear();
    		_shape.graphics.beginGradientFill(GradientType.RADIAL, colArray, alphaArray, pointArray, _matrix);
    		_shape.graphics.drawCircle(255, 255, 255);
    		specularBitmap.draw(_shape);
        }
               
        public function clearTransform():void
        {
        	diffuseTransform = new Dictionary(true);
        	specularTransform = new Dictionary(true);
        	colorMatrixTransform = new Dictionary(true);
        	normalMatrixTransform = new Dictionary(true);
        }
		
        internal var quaternion:Quaternion = new Quaternion();
        internal var viewTransform:Matrix3D = new Matrix3D();
        internal var invTransform:Matrix3D = new Matrix3D();
    	internal var transform:Matrix3D = new Matrix3D();
    	internal var nx:Number;
    	internal var ny:Number;
    	internal var mod:Number;
    	
        public function updateDirection(e:Object3DEvent):void
        {
        	//update direction vector
        	direction = new Number3D(light.x, light.y, light.z);
        	direction.normalize();
        	
        	nx = direction.x;
        	ny = direction.y;
        	mod = Math.sqrt(nx*nx + ny*ny);
        	transform.rotationMatrix(ny/mod, -nx/mod, 0, -Math.acos(-direction.z));
        	clearTransform();
        }
        
        public function setDiffuseTransform(source:Object3D):void
        {
        	viewTransform.multiply3x3(transform, source._sceneTransform);
        	diffuseTransform[source] = viewTransform.clone();
        }
        
        internal var cameraTransform:Matrix3D;
        internal var cameraDirection:Number3D;
        internal var halfVector:Number3D = new Number3D();
        internal var halfQuaternion:Quaternion = new Quaternion();
        internal var halfTransform:Matrix3D = new Matrix3D();
        
        public function setSpecularTransform(source:Object3D, view:View3D):void
        {
			//find halfway matrix between camera and direction matricies
			cameraTransform = view.camera.transform;
			cameraDirection = new Number3D(-cameraTransform.sxz, -cameraTransform.syz, -cameraTransform.szz);
			halfVector.add(cameraDirection, direction);
			halfVector.normalize();
			
			nx = halfVector.x;
        	ny = halfVector.y;
        	mod = Math.sqrt(nx*nx + ny*ny);
        	halfTransform.rotationMatrix(-ny/mod, nx/mod, 0, Math.acos(-halfVector.z));
			
        	viewTransform.multiply3x3(halfTransform, source._sceneTransform);
        	specularTransform[source][view] = viewTransform.clone();
        }
        
        internal var _red:Number;
		internal var _green:Number;
		internal var _blue:Number;
		
        public function setColorMatrixTransform(source:Object3D):void
        {
        	_red = red/127;
			_green = green/127;
			_blue = blue/127;
        	_colorMatrix.matrix = [_red, _red, _red, 0, -381*_red, _green, _green, _green, 0, -381*_green, _blue, _blue, _blue, 0, -381*_blue, 0, 0, 0, 1, 0];
        	colorMatrixTransform[source] = _colorMatrix.clone();
        }
        
        internal var _szx:Number;
        internal var _szy:Number;
        internal var _szz:Number;
                
        public function setNormalMatrixTransform(source:Object3D):void
        {
        	_szx = diffuseTransform[source].szx;
			_szy = diffuseTransform[source].szy;
			_szz = diffuseTransform[source].szz;
        	_normalMatrix.matrix = [_szx, 0, 0, 0, 127 - _szx*127, 0, -_szy, 0, 0, 127 + _szy*127, 0, 0, _szz, 0, 127 - _szz*127, 0, 0, 0, 1, 0];
        	normalMatrixTransform[source] = _normalMatrix.clone();
        }
    }
}

