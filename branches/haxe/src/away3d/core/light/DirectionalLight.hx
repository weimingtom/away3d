package away3d.core.light;

import flash.filters.ColorMatrixFilter;
import flash.utils.Dictionary;
import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.containers.View3D;
import away3d.lights.DirectionalLight3D;
import away3d.core.base.Object3D;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import away3d.events.Object3DEvent;
import flash.display.Sprite;
import away3d.core.math.Quaternion;
import away3d.core.math.Number3D;
import flash.filters.BitmapFilter;
import away3d.core.math.Matrix3D;
import flash.display.Shape;
import flash.display.GradientType;


// use namespace arcane;

/**
 * Directional light primitive.
 */
class DirectionalLight extends LightPrimitive  {
	public var light(getLight, setLight) : DirectionalLight3D;
	
	private var _light:DirectionalLight3D;
	private var _colorMatrix:ColorMatrixFilter;
	private var _normalMatrix:ColorMatrixFilter;
	private var _matrix:Matrix;
	private var _shape:Shape;
	private var quaternion:Quaternion;
	private var invTransform:Matrix3D;
	private var transform:Matrix3D;
	private var nx:Float;
	private var ny:Float;
	private var mod:Float;
	private var cameraTransform:Matrix3D;
	private var cameraDirection:Number3D;
	private var halfVector:Number3D;
	private var halfQuaternion:Quaternion;
	private var halfTransform:Matrix3D;
	private var _red:Float;
	private var _green:Float;
	private var _blue:Float;
	private var _szx:Float;
	private var _szy:Float;
	private var _szz:Float;
	private var direction:Number3D;
	/**
	 * Transform dictionary for the diffuse lightmap used by shading materials.
	 */
	public var diffuseTransform:Dictionary;
	/**
	 * Transform dictionary for the specular lightmap used by shading materials.
	 */
	public var specularTransform:Dictionary;
	/**
	 * Color transform used in cached shading materials for combined ambient and diffuse color intensities.
	 */
	public var ambientDiffuseColorTransform:ColorTransform;
	/**
	 * Color transform used in cached shading materials for ambient intensities.
	 */
	public var diffuseColorTransform:ColorTransform;
	/**
	 * Colormatrix transform used in DOT3 materials for resolving color in the normal map.
	 */
	public var colorMatrixTransform:Dictionary;
	/**
	 * Colormatrix transform used in DOT3 materials for resolving normal values in the normal map.
	 */
	public var normalMatrixTransform:Dictionary;
	

	/**
	 * A reference to the <code>DirectionalLight3D</code> object used by the light primitive.
	 */
	public function getLight():DirectionalLight3D {
		
		return _light;
	}

	public function setLight(val:DirectionalLight3D):DirectionalLight3D {
		
		_light = val;
		val.addOnSceneTransformChange(updateDirection);
		return val;
	}

	/**
	 * Updates the bitmapData object used as the lightmap for ambient light shading.
	 * 
	 * @param	ambient		The coefficient for ambient light intensity.
	 */
	public function updateAmbientBitmap():Void {
		
		ambientBitmap = new BitmapData(256, 256, false, Std.int(ambient * red * 0xFF) << 16 | Std.int(ambient * green * 0xFF) << 8 | Std.int(ambient * blue * 0xFF));
		ambientBitmap.lock();
	}

	/**
	 * Updates the bitmapData object used as the lightmap for diffuse light shading.
	 * 
	 * @param	diffuse		The coefficient for diffuse light intensity.
	 */
	public function updateDiffuseBitmap():Void {
		
		diffuseBitmap = new BitmapData(256, 256, false, 0x000000);
		diffuseBitmap.lock();
		_matrix.createGradientBox(256, 256, 0, 0, 0);
		var colArray:Array<Int> = new Array<Int>();
		var alphaArray:Array<Int> = new Array<Int>();
		var pointArray:Array<Int> = new Array<Int>();
		var i:Int = 15;
		while ((i-- > 0)) {
			var r:Float = (i * diffuse / 14);
			if (r > 1) {
				r = 1;
			}
			var g:Float = (i * diffuse / 14);
			if (g > 1) {
				g = 1;
			}
			var b:Float = (i * diffuse / 14);
			if (b > 1) {
				b = 1;
			}
			colArray.push((Std.int(r * red * 0xFF) << 16) | (Std.int(g * green * 0xFF) << 8) | Std.int(b * blue * 0xFF));
			alphaArray.push(1);
			pointArray.push(Std.int(30 + 225 * 2 * Math.acos(i / 14) / Math.PI));
		}

		_shape.graphics.clear();
		_shape.graphics.beginGradientFill(GradientType.LINEAR, colArray, alphaArray, pointArray, _matrix);
		_shape.graphics.drawRect(0, 0, 256, 256);
		diffuseBitmap.draw(_shape);
		//update colortransform
		diffuseColorTransform = new ColorTransform(diffuse * red, diffuse * green, diffuse * blue, 1, 0, 0, 0, 0);
	}

	/**
	 * Updates the bitmapData object used as the lightmap for the combined ambient and diffue light shading.
	 * 
	 * @param	ambient		The coefficient for ambient light intensity.
	 * @param	diffuse		The coefficient for diffuse light intensity.
	 */
	public function updateAmbientDiffuseBitmap():Void {
		
		ambientDiffuseBitmap = new BitmapData(256, 256, false, 0x000000);
		ambientDiffuseBitmap.lock();
		_matrix.createGradientBox(256, 256, 0, 0, 0);
		var colArray:Array<Int> = new Array<Int>();
		var alphaArray:Array<Int> = new Array<Int>();
		var pointArray:Array<Int> = new Array<Int>();
		var i:Int = 15;
		while ((i-- > 0)) {
			var r:Float = (i * diffuse / 14 + ambient);
			if (r > 1) {
				r = 1;
			}
			var g:Float = (i * diffuse / 14 + ambient);
			if (g > 1) {
				g = 1;
			}
			var b:Float = (i * diffuse / 14 + ambient);
			if (b > 1) {
				b = 1;
			}
			colArray.push((Std.int(r * red * 0xFF) << 16) | (Std.int(g * green * 0xFF) << 8) | Std.int(b * blue * 0xFF));
			alphaArray.push(1);
			pointArray.push(Std.int(30 + 225 * 2 * Math.acos(i / 14) / Math.PI));
		}

		_shape.graphics.clear();
		_shape.graphics.beginGradientFill(GradientType.LINEAR, colArray, alphaArray, pointArray, _matrix);
		_shape.graphics.drawRect(0, 0, 256, 256);
		ambientDiffuseBitmap.draw(_shape);
		//update colortransform
		ambientDiffuseColorTransform = new ColorTransform(diffuse * red, diffuse * green, diffuse * blue, 1, ambient * red * 0xFF, ambient * green * 0xFF, ambient * blue * 0xFF, 0);
	}

	/**
	 * Updates the bitmapData object used as the lightmap for specular light shading.
	 * 
	 * @param	specular		The coefficient for specular light intensity.
	 */
	public function updateSpecularBitmap():Void {
		
		specularBitmap = new BitmapData(512, 512, false, 0x000000);
		specularBitmap.lock();
		_matrix.createGradientBox(512, 512, 0, 0, 0);
		var colArray:Array<Int> = new Array<Int>();
		var alphaArray:Array<Int> = new Array<Int>();
		var pointArray:Array<Int> = new Array<Int>();
		var i:Int = 15;
		while ((i-- > 0)) {
			colArray.push((Std.int(i * specular * red * 0xFF / 14) << 16) + (Std.int(i * specular * green * 0xFF / 14) << 8) + Std.int(i * specular * blue * 0xFF / 14));
			alphaArray.push(1);
			pointArray.push(Std.int(30 + 225 * 2 * Math.acos(Math.pow(i / 14, 1 / 20)) / Math.PI));
		}

		_shape.graphics.clear();
		_shape.graphics.beginGradientFill(GradientType.RADIAL, colArray, alphaArray, pointArray, _matrix);
		_shape.graphics.drawCircle(255, 255, 255);
		specularBitmap.draw(_shape);
	}

	/**
	 * Clears the transform and matrix dictionaries used in the shading materials.
	 */
	public function clearTransform():Void {
		
		diffuseTransform = new Dictionary(true);
		specularTransform = new Dictionary(true);
		colorMatrixTransform = new Dictionary(true);
		normalMatrixTransform = new Dictionary(true);
	}

	/**
	 * Updates the direction vector of the directional light.
	 */
	public function updateDirection(e:Object3DEvent):Void {
		//update direction vector
		
		direction.x = _light.x;
		direction.y = _light.y;
		direction.z = _light.z;
		direction.normalize();
		nx = direction.x;
		ny = direction.y;
		mod = Math.sqrt(nx * nx + ny * ny);
		transform.rotationMatrix(ny / mod, -nx / mod, 0, -Math.acos(-direction.z));
		clearTransform();
	}

	/**
	 * Updates the transform matrix for the diffuse lightmap.
	 * 
	 * @see diffuseTransform
	 */
	public function setDiffuseTransform(source:Object3D):Void {
		
		if (diffuseTransform[untyped source] == null) {
			diffuseTransform[untyped source] = new Matrix3D();
		}
		diffuseTransform[untyped source].multiply3x3(transform, source.sceneTransform);
		diffuseTransform[untyped source].normalize(diffuseTransform[untyped source]);
	}

	/**
	 * Updates the transform matrix for the specular lightmap.
	 * 
	 * @see specularTransform
	 */
	public function setSpecularTransform(source:Object3D, view:View3D):Void {
		//find halfway matrix between camera and direction matricies
		
		cameraTransform = view.camera.transform;
		cameraDirection.x = -cameraTransform.sxz;
		cameraDirection.y = -cameraTransform.syz;
		cameraDirection.z = -cameraTransform.szz;
		halfVector.add(cameraDirection, direction);
		halfVector.normalize();
		nx = halfVector.x;
		ny = halfVector.y;
		mod = Math.sqrt(nx * nx + ny * ny);
		halfTransform.rotationMatrix(-ny / mod, nx / mod, 0, Math.acos(-halfVector.z));
		if (specularTransform[untyped source][untyped view] == null) {
			specularTransform[untyped source][untyped view] = new Matrix3D();
		}
		specularTransform[untyped source][untyped view].multiply3x3(halfTransform, source.sceneTransform);
		specularTransform[untyped source][untyped view].normalize(specularTransform[untyped source][untyped view]);
	}

	/**
	 * Updates the color transform matrix.
	 * 
	 * @see colorMatrixTransform
	 */
	public function setColorMatrixTransform(source:Object3D):Void {
		
		_red = red * 2;
		_green = green * 2;
		_blue = blue * 2;
		_colorMatrix.matrix = [_red, _red, _red, 0, -381 * _red, _green, _green, _green, 0, -381 * _green, _blue, _blue, _blue, 0, -381 * _blue, 0, 0, 0, 1, 0];
		colorMatrixTransform[untyped source] = _colorMatrix.clone();
	}

	/**
	 * Updates the normal transform matrix.
	 * 
	 * @see normalMatrixTransform
	 */
	public function setNormalMatrixTransform(source:Object3D):Void {
		
		_szx = diffuseTransform[untyped source].szx;
		_szy = diffuseTransform[untyped source].szy;
		_szz = diffuseTransform[untyped source].szz;
		_normalMatrix.matrix = [_szx, 0, 0, 0, 127 - _szx * 127, 0, -_szy, 0, 0, 127 + _szy * 127, 0, 0, _szz, 0, 127 - _szz * 127, 0, 0, 0, 1, 0];
		normalMatrixTransform[untyped source] = _normalMatrix.clone();
	}

	// autogenerated
	public function new () {
		super();
		this._colorMatrix = new ColorMatrixFilter();
		this._normalMatrix = new ColorMatrixFilter();
		this._matrix = new Matrix();
		this._shape = new Shape();
		this.quaternion = new Quaternion();
		this.invTransform = new Matrix3D();
		this.transform = new Matrix3D();
		this.cameraDirection = new Number3D();
		this.halfVector = new Number3D();
		this.halfQuaternion = new Quaternion();
		this.halfTransform = new Matrix3D();
		this.direction = new Number3D();
		this.colorMatrixTransform = new Dictionary(true);
		this.normalMatrixTransform = new Dictionary(true);
		
	}

	

}

