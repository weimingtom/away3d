package away3d.materials.utils;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.filters.BlurFilter;
import flash.geom.Point;
import away3d.core.base.Vertex;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import away3d.core.math.Number3D;
import away3d.containers.ObjectContainer3D;
import away3d.primitives.Plane;
import away3d.materials.BitmapMaterial;
import away3d.containers.Scene3D;
import flash.events.EventDispatcher;


/**
 * This class generates a top projection shadow from vertex information of a given Object3D,
 * Most suitable for still objects. Can be updated at runtime but will offer very poor performance.
 */
class SimpleShadow  {
	public var source(getSource, null) : BitmapData;
	public var plane(getPlane, null) : Plane;
	public var color(getColor, setColor) : Int;
	public var object(null, setObject) : Object3D;
	public var blur(getBlur, setBlur) : Int;
	public var range(getRange, setRange) : Float;
	public var base(getBase, setBase) : Float;
	
	private var _graphic:Graphics;
	private var _color:Int;
	private var _alpha:Float;
	private var _distalpha:Float;
	private var _blur:Float;
	private var _level:Graphics;
	private var _object3d:Object3D;
	private var _shadesprite:Sprite;
	private var _shadebmd:BitmapData;
	private var _offsetx:Float;
	private var _offsety:Float;
	private var _zero:Point;
	private var _scaleX:Float;
	private var _scaleY:Float;
	private var _range:Float;
	private var _base:Float;
	private var _rad:Float;
	private var _plane:Plane;
	private var _scene:Scene3D;
	private var _width:Float;
	private var _height:Float;
	

	private function parse(?childObj:Object3D=null):BitmapData {
		
		var myObj:Object3D = (childObj == null) ? _object3d : childObj;
		if (Std.is(myObj, ObjectContainer3D)) {
			var obj:ObjectContainer3D = (cast(myObj, ObjectContainer3D));
			var i:Int = 0;
			while (i < obj.children.length) {
				if (Std.is(obj.children[i], ObjectContainer3D)) {
					parse(obj.children[i]);
				} else if (Std.is(obj.children[i], Mesh)) {
					drawObject(obj.children[i], obj.children[i].scenePosition.x, -obj.children[i].scenePosition.z);
				}
				
				// update loop variables
				++i;
			}

		} else {
			drawObject();
		}
		_shadebmd.draw(_shadesprite);
		return _shadebmd;
	}

	private function drawObject(?childObj:Mesh=null, ?offX:Float=0, ?offZ:Float=0):Void {
		
		var myObj:Mesh = (childObj == null) ? cast(_object3d, Mesh) : childObj;
		if (_range == 0) {
			_distalpha = _alpha;
		} else {
			var dist:Float = (myObj.scenePosition.y - Math.abs(myObj.minY)) - _base;
			if (dist > _range) {
				return;
			}
			_distalpha = 1 - (dist / _range);
		}
		if (myObj.rotationX == 0 && myObj.rotationY == 0 && myObj.rotationZ == 0) {
			var v0:Vertex;
			var v1:Vertex;
			var v2:Vertex;
			var i:Int;
			while (i < myObj.faces.length) {
				v0 = myObj.faces[i].v0;
				v1 = myObj.faces[i].v1;
				v2 = myObj.faces[i].v2;
				drawTri(v0.x + offX, -(v0.z - offZ), v1.x + offX, -(v1.z - offZ), v2.x + offX, -(v2.z - offZ));
				
				// update loop variables
				++i;
			}

		} else {
			applyRotations(myObj, offX, offZ);
		}
	}

	private function generatePlane(scene:Scene3D):Void {
		
		var w:Int = (_width <= 200) ? 4 : 4 + Math.round((_width / (100 % _width) * .5));
		var h:Int = (_height <= 200) ? 4 : 4 + Math.round((_height / (100 % _height) * .5));
		if (_plane != null) {
			scene.removeChild(_plane);
			_plane = null;
		}
		var mat:BitmapMaterial = new BitmapMaterial();
		_plane = new Plane();
		scene.addChild(_plane);
		positionPlane();
	}

	private function applyRotations(myObj:Mesh, ?offX:Float=0, ?offZ:Float=0):Void {
		
		var x:Float;
		var y:Float;
		var z:Float;
		var x1:Float;
		var y1:Float;
		var z1:Float;
		var rotx:Float = myObj.rotationX * _rad;
		var roty:Float = myObj.rotationY * _rad;
		var rotz:Float = myObj.rotationZ * _rad;
		var sinx:Float = Math.sin(rotx);
		var cosx:Float = Math.cos(rotx);
		var siny:Float = Math.sin(roty);
		var cosy:Float = Math.cos(roty);
		var sinz:Float = Math.sin(rotz);
		var cosz:Float = Math.cos(rotz);
		var v0:Vertex;
		var v1:Vertex;
		var v2:Vertex;
		var n0:Number3D = new Number3D();
		var n1:Number3D = new Number3D();
		var n2:Number3D = new Number3D();
		var trifaces:Array<Dynamic> = [];
		var j:Int;
		var i:Int;
		while (i < myObj.faces.length) {
			v0 = myObj.faces[i].v0;
			v1 = myObj.faces[i].v1;
			v2 = myObj.faces[i].v2;
			n0.x = v0.x;
			n0.y = v0.y;
			n0.z = v0.z;
			n1.x = v1.x;
			n1.y = v1.y;
			n1.z = v1.z;
			n2.x = v2.x;
			n2.y = v2.y;
			n2.z = v2.z;
			trifaces[0] = n0;
			trifaces[1] = n1;
			trifaces[2] = n2;
			j = 0;
			while (j < trifaces.length) {
				x = trifaces[j].x;
				y = trifaces[j].y;
				z = trifaces[j].z;
				y1 = y;
				y = y1 * cosx + z * -sinx;
				z = y1 * sinx + z * cosx;
				x1 = x;
				x = x1 * cosy + z * siny;
				z = x1 * -siny + z * cosy;
				x1 = x;
				x = x1 * cosz + y * -sinz;
				y = x1 * sinz + y * cosz;
				trifaces[j].x = x;
				trifaces[j].y = y;
				trifaces[j].z = z;
				
				// update loop variables
				++j;
			}

			drawTri(trifaces[0].x + offX, -(trifaces[0].z - offZ), trifaces[1].x + offX, -(trifaces[1].z - offZ), trifaces[2].x + offX, -(trifaces[2].z - offZ));
			
			// update loop variables
			++i;
		}

	}

	private function check32(color:Int):Float {
		
		_color = color;
		if ((_color >> 24 & 0xFF) == 0) {
			addAlpha();
		}
		return (_color >> 24 & 0xFF) / 255;
	}

	private function addAlpha():Void {
		
		_color = 255 << 24 | _color;
	}

	private function drawTri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float):Void {
		
		_graphic.beginFill(_color, _distalpha);
		_graphic.moveTo((x1 + _offsetx) / _scaleX, (y1 + _offsety) / _scaleY);
		_graphic.lineTo((x2 + _offsetx) / _scaleX, (y2 + _offsety) / _scaleY);
		_graphic.lineTo((x3 + _offsetx) / _scaleX, (y3 + _offsety) / _scaleY);
		_graphic.lineTo((x1 + _offsetx) / _scaleX, (y1 + _offsety) / _scaleY);
	}

	private function buildSource():Void {
		
		if (_width > 2790) {
			_scaleX = _width / 2790;
			_width /= _scaleX;
		}
		if (_height > 2790) {
			_scaleY = _height / 2790;
			_height /= _scaleY;
		}
		if (_shadebmd != null) {
			if (_shadebmd.width != _width || _shadebmd.height != _height) {
				_shadebmd.dispose();
				_shadebmd = new BitmapData();
			} else {
				_shadebmd.fillRect(_shadebmd.rect, 0x00FFFFFF);
			}
		} else {
			_shadebmd = new BitmapData();
		}
	}

	private function updateSizes():Void {
		
		if (Std.is(_object3d, Mesh)) {
			_width = (cast(_object3d, Mesh)).objectWidth + (_blur * 2);
			_height = (cast(_object3d, Mesh)).objectDepth + (_blur * 2);
			_offsetx = Math.abs((cast(_object3d, Mesh)).minX) + _blur;
			_offsety = Math.abs((cast(_object3d, Mesh)).maxZ) + _blur;
		} else if (Std.is(_object3d, ObjectContainer3D)) {
			_width = 0;
			_height = 0;
			getSizesChildren(_object3d);
			_width += _blur * 2;
			_height += _blur * 2;
			_offsetx = (_width * .5) + _blur;
			_offsety = (_height * .5) + _blur;
		}
	}

	private function getSizesChildren(childObj:Object3D):Void {
		
		var myObj:Object3D = (childObj == null) ? _object3d : childObj;
		if (Std.is(myObj, ObjectContainer3D)) {
			var obj:ObjectContainer3D = (cast(myObj, ObjectContainer3D));
			var i:Int = 0;
			while (i < obj.children.length) {
				if (Std.is(obj.children[i], ObjectContainer3D)) {
					getSizesChildren(obj.children[i]);
				} else if (Std.is(obj.children[i], Mesh)) {
					_width = Math.max(_width, obj.children[i].objectWidth);
					_height = Math.max(_height, obj.children[i].objectDepth);
				}
				
				// update loop variables
				++i;
			}

		} else {
			_width = Math.max(_width, obj.children[i].objectWidth);
			_height = Math.max(_height, obj.children[i].objectDepth);
		}
	}

	function new(object3d:Object3D, ?color:Int=0xFF666666, ?blur:Float=4, ?base:Float=Math.NaN, ?range:Float=Math.NaN) {
		this._zero = new Point();
		this._scaleX = 1;
		this._scaleY = 1;
		this._rad = Math.PI / 180;
		this._width = 0;
		this._height = 0;
		
		
		_object3d = object3d;
		_object3d.applyPosition((_object3d.minX + _object3d.maxX) * .5, 0, (_object3d.minZ + _object3d.maxZ) * .5);
		_blur = (blur < 0) ? 0 : blur;
		_range = (range < 0) ? 0 : range;
		_base = (Math.isNaN(base)) ? object3d.y - Math.abs(object3d.minY) : base;
		_shadesprite = new Sprite();
		_graphic = _shadesprite.graphics;
		_graphic.beginFill(0x00FFFFFF, 1);
		updateSizes();
		_graphic.drawRect(0, 0, _width, _height);
		_graphic.endFill();
		if (_blur > 0) {
			_shadesprite.filters = [new BlurFilter()];
		}
		buildSource();
		this.color = color;
	}

	/**
	 * return the generated shadow projection BitmapData;
	 * 
	 * @return A BitmapData: the generated shadow projection bitmapdata;
	 */
	public function getSource():BitmapData {
		
		return _shadebmd;
	}

	/**
	 * return the plane where the shadow is set as Material
	 * 
	 * @return A Plane: the plane where the shadow is set as Material
	 */
	public function getPlane():Plane {
		
		return _plane;
	}

	/**
	 * return the color set for the shadow generation
	 * 
	 * @return the color set for the shadow generation
	 */
	public function getColor():Int {
		
		return _color;
	}

	public function setColor(val:Int):Int {
		
		_alpha = check32(val);
		return val;
	}

	/**
	 * generates the shadow projection
	 * 
	 */
	public function apply(?scene:Scene3D=null):BitmapData {
		
		_graphic.clear();
		_shadebmd.fillRect(_shadebmd.rect, 0x00FFFFFF);
		if (_plane == null && (scene != null || _scene != null)) {
			_scene = scene;
			generatePlane(_scene);
		}
		return parse();
	}

	/**
	 * generates the shadow projection
	 * 
	 */
	public function update(?color:Float=Math.NaN):Void {
		
		_graphic.clear();
		updateSizes();
		_graphic.drawRect(0, 0, _width, _height);
		_graphic.endFill();
		if (_blur > 0 && _shadesprite.filters.length == 0) {
			_shadesprite.filters = [new BlurFilter()];
		}
		if (_blur == 0 && _shadesprite.filters.length > 0) {
			_shadesprite.filters = [];
		}
		buildSource();
		if (!Math.isNaN(color)) {
			this.color = Std.int(color);
		}
		generatePlane(_scene);
		parse();
	}

	/**
	 * adjusts the shadow position to the model according to pivot of the object
	 * 
	 */
	public function positionPlane():Void {
		
		_plane.y = _base;
		_plane.x = _object3d.x;
		_plane.z = _object3d.z;
	}

	/**
	 * Defines the object3d that will be used for the projection
	 * Note that the update method is automaticaly called when set. The handler is only to be used if the previous class object3d was nulled.
	 */
	public function setObject(object3d:Object3D):Object3D {
		
		_object3d = object3d;
		_object3d.applyPosition((_object3d.minX + _object3d.maxX) * .5, 0, (_object3d.minZ + _object3d.maxZ) * .5);
		update();
		return object3d;
	}

	/**
	 * Defines the amount of blur for the projection
	 * @param	val  Blur value
	 */
	public function setBlur(val:Int):Int {
		
		_blur = (val < 0) ? 0 : val;
		return val;
	}

	public function getBlur():Int {
		
		return _blur;
	}

	/**
	 * Defines the range for the projection, the greater, the more alpha. when distance vertice to projection base is exceeded, no trace occurs.
	 * @param	val  Range value
	 */
	public function setRange(val:Float):Float {
		
		_range = (val < 0) ? 0 : val;
		return val;
	}

	public function getRange():Float {
		
		return _range;
	}

	/**
	 * Defines the base for the projection. It defines the y position of the plane object
	 * By default the plane is located at the base of the object
	 * @param	val  Base value
	 */
	public function setBase(val:Float):Float {
		
		_base = (Math.isNaN(base)) ? _object3d.y - Math.abs(_object3d.minY) : val;
		return val;
	}

	public function getBase():Float {
		
		return _base;
	}

}

