package away3d.materials.shaders;

import flash.events.EventDispatcher;
import away3d.containers.View3D;
import flash.utils.Dictionary;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import flash.geom.Matrix;
import flash.display.Sprite;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;
import flash.display.Shape;
import flash.display.Graphics;


// use namespace arcane;

/**
 * Shader class for ambient lighting
 * 
 * @see away3d.lights.AmbientLight3D
 */
class AmbientShader extends AbstractShader  {
	
	/**
	 * Defines a 24 bit color value used by the shader
	 */
	public var color:Int;
	

	/**
	 * Creates a new <code>AmbientShader</code> object.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		
		
		super(init);
	}

	/**
	 * @inheritDoc
	 */
	public override function updateMaterial(source:Object3D, view:View3D):Void {
		
		clearLightingShapeDictionary();
	}

	/**
	 * @inheritDoc
	 */
	private function clearFaces(source:Object3D, view:View3D):Void {
		
		notifyMaterialUpdate();
		var __keys:Iterator<Dynamic> = untyped (__keys__(_faceDictionary)).iterator();
		for (__key in __keys) {
			_faceMaterialVO = _faceDictionary[cast __key];

			if (source == _faceMaterialVO.source) {
				if (!_faceMaterialVO.cleared) {
					_faceMaterialVO.clear();
				}
			}
		}

	}

	/**
	 * @inheritDoc
	 */
	public override function renderLayer(tri:DrawTriangle, layer:Sprite, level:Int):Void {
		
		super.renderLayer(tri, layer, level);
		for (__i in 0...tri.source.lightarray.ambients.length) {
			ambient = tri.source.lightarray.ambients[__i];

			if (_lights.numLights > 1) {
				_shape = getLightingShape(layer, ambient);
				_shape.blendMode = blendMode;
				_graphics = _shape.graphics;
			} else {
				_graphics = layer.graphics;
			}
			_source.session.renderTriangleBitmap(ambient.ambientBitmap, _mapping, tri.v0, tri.v1, tri.v2, smooth, false, _graphics);
		}

		if (debug) {
			tri.source.session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
		}
	}

	/**
	 * @inheritDoc
	 */
	private override function renderShader(tri:DrawTriangle):Void {
		
		for (__i in 0..._source.lightarray.ambients.length) {
			ambient = _source.lightarray.ambients[__i];

			_faceMaterialVO.bitmap.draw(ambient.ambientBitmap, null, null, blendMode);
		}

		for (__i in 0..._source.lightarray.directionals.length) {
			directional = _source.lightarray.directionals[__i];

			_faceMaterialVO.bitmap.draw(directional.ambientBitmap, null, null, blendMode);
		}

	}

}

