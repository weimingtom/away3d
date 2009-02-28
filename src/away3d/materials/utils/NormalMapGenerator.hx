package away3d.materials.utils;

import flash.display.BitmapData;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.filters.ConvolutionFilter;
import flash.filters.DisplacementMapFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.utils.setTimeout;
import flash.events.EventDispatcher;
import away3d.core.math.Number3D;
import away3d.events.TraceEvent;
import flash.events.Event;
import away3d.core.base.Face;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


/**
 * Dispatched while the class is busy tracing. Note that the source can already be used for a Material
 * 
 * @eventType away3d.events.TraceEvent
 */
// [Event(name="tracecomplete", type="away3d.events.TraceEvent")]

/**
 * Dispatched full trace is done.
 * 
 * @eventType away3d.events.TraceEvent
 */
// [Event(name="traceprogress", type="away3d.events.TraceEvent")]

// use namespace arcane;

class NormalMapGenerator extends EventDispatcher  {
	public var normalmap(getNormalmap, null) : BitmapData;
	public var bumpmap(getBumpmap, null) : BitmapData;
	
	private var _width:Int;
	private var _height:Int;
	private var _normalmap:BitmapData;
	private var _bumpsource:BitmapData;
	private var _mesh:Mesh;
	private var _lines:Array<Dynamic>;
	private var _bumpmap:BitmapData;
	private var _blur:Int;
	private var _state:Int;
	private var _step:Int;
	private var n0:Number3D;
	private var n1:Number3D;
	private var n2:Number3D;
	private var intPt0:Point;
	private var intPt1:Point;
	private var intPt2:Point;
	private var rect:Rectangle;
	

	private function generate(from:Int, to:Int):Void {
		
		var i:Int;
		var j:Int;
		var p0:Point;
		var p1:Point;
		var p2:Point;
		var col0r:Int;
		var col0g:Int;
		var col0b:Int;
		var col1r:Int;
		var col1g:Int;
		var col1b:Int;
		var col2r:Int;
		var col2g:Int;
		var col2b:Int;
		var line0:Array<Dynamic>;
		var line1:Array<Dynamic>;
		var line2:Array<Dynamic>;
		var per0:Float;
		var per1:Float;
		var per2:Float;
		var face:Face;
		var fn:Number3D;
		var row:Int;
		var s:Int;
		var e:Int;
		var colorpt:Point = new Point();
		function meet(pt:Point, x1:Int, y1:Int, x2:Int, y2:Int, x3:Int, y3:Int, x4:Int, y4:Int):Point {
			var d:Int = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
			if (d == 0) {
				return null;
			}
			pt.x = ((x3 - x4) * (x1 * y2 - y1 * x2) - (x1 - x2) * (x3 * y4 - y3 * x4)) / d;
			pt.y = ((y3 - y4) * (x1 * y2 - y1 * x2) - (y1 - y2) * (x3 * y4 - y3 * x4)) / d;
			return pt;
		}

		function applyColorAt(x:Int, y:Int):Void {
			colorpt.x = x;
			colorpt.y = y;
			var cross0:Point = meet(intPt0, line1[0].x, line1[0].y, line1[1].x, line1[1].y, p0.x, p0.y, x, y);
			var cross1:Point = meet(intPt1, line2[0].x, line2[0].y, line2[1].x, line2[1].y, p1.x, p1.y, x, y);
			var cross2:Point = meet(intPt2, line0[0].x, line0[0].y, line0[1].x, line0[1].y, p2.x, p2.y, x, y);
			per0 = (cross0 == null) ? 1 : Point.distance(cross0, colorpt) / Point.distance(p0, cross0);
			per1 = (cross1 == null) ? 1 : Point.distance(cross1, colorpt) / Point.distance(p1, cross1);
			per2 = (cross2 == null) ? 1 : Point.distance(cross2, colorpt) / Point.distance(p2, cross2);
			var r:Int = Std.int((per0 * col0r) + (per1 * col1r) + (per2 * col2r));
			var g:Int = Std.int((per0 * col0g) + (per1 * col1g) + (per2 * col2g));
			var b:Int = Std.int((per0 * col0b) + (per1 * col1b) + (per2 * col2b));
			_normalmap.setPixel(x, y, ((r > 255) ? 255 : r) << 16 | ((g > 255) ? 255 : g) << 8 | ((b > 255) ? 255 : b));
		}

		_normalmap.lock();
		i = from;
		while (i < to) {
			face = _mesh.faces[i];
			fn = face.normal;
			n0 = averageNormals(face.v0, n0, fn);
			p0 = new Point(face.uv0.u * _width, (1 - face.uv0.v) * _height);
			col0r = Std.int(255 - ((127 * n0.x) + 127));
			col0g = Std.int(255 - ((127 * n0.y) + 127));
			col0b = Std.int((127 * n0.z) + 127);
			n1 = averageNormals(face.v1, n1, fn);
			p1 = new Point(face.uv1.u * _width, (1 - face.uv1.v) * _height);
			col1r = Std.int(255 - ((127 * n1.x) + 127));
			col1g = Std.int(255 - ((127 * n1.y) + 127));
			col1b = Std.int((127 * n1.z) + 127);
			n2 = averageNormals(face.v2, n2, fn);
			p2 = new Point(face.uv2.u * _width, (1 - face.uv2.v) * _height);
			col2r = Std.int(255 - ((127 * n2.x) + 127));
			col2g = Std.int(255 - ((127 * n2.y) + 127));
			col2b = Std.int((127 * n2.z) + 127);
			_lines = [];
			setBounds(p0.x, p0.y, p1.x, p1.y, col0r, col0g, col0b, col1r, col1g, col1b, Point.distance(p0, p1));
			setBounds(p1.x, p1.y, p2.x, p2.y, col1r, col1g, col1b, col2r, col2g, col2b, Point.distance(p1, p2));
			setBounds(p2.x, p2.y, p0.x, p0.y, col2r, col2g, col2b, col0r, col0g, col0b, Point.distance(p2, p0));
			line0 = [p0, p1];
			line1 = [p1, p2];
			line2 = [p2, p0];
			_lines.sortOn("y", 16);
			row = 0;
			rect.x = _lines[0].x;
			rect.y = _lines[0].y;
			rect.width = 1;
			j = 0;
			while (j < _lines.length) {
				if (row == _lines[j].y) {
					if (s > _lines[j].x) {
						s = _lines[j].x;
						rect.x = s;
					}
					if (e < _lines[j].x) {
						e = _lines[j].x;
					}
					rect.width = e - s + 1;
				} else {
					if (rect.width > 2) {
						var k:Int = Std.int(rect.x + 1);
						while (k < rect.x + rect.width) {
							applyColorAt(k, rect.y);
							
							// update loop variables
							++k;
						}

					}
					s = _lines[j].x;
					e = _lines[j].x;
					row = _lines[j].y;
					rect.x = _lines[j].x;
					rect.y = _lines[j].y;
					rect.width = 1;
				}
				
				// update loop variables
				++j;
			}

			j = 0;
			while (j < _lines.length) {
				if (_lines[j].col != null) {
					_normalmap.setPixel(_lines[j].x, _lines[j].y, _lines[j].col);
					_lines[j] = null;
				}
				
				// update loop variables
				++j;
			}

			
			// update loop variables
			++i;
		}

		_normalmap.unlock();
		_state = i;
		var te:TraceEvent;
		if (_state == _mesh.faces.length) {
			grow();
			if (_bumpsource != null) {
				applyBump(_bumpsource, _normalmap);
			}
			if (_blur != 0) {
				applyBlur(_normalmap);
			}
			_lines = null;
			if (hasEventListener(TraceEvent.TRACE_COMPLETE)) {
				te = new TraceEvent(TraceEvent.TRACE_COMPLETE);
				te.procent = 100;
				dispatchEvent(te);
			}
		} else {
			if (hasEventListener(TraceEvent.TRACE_PROGRESS)) {
				te = new TraceEvent(TraceEvent.TRACE_PROGRESS);
				te.procent = (_state / _mesh.faces.length) * 100;
				dispatchEvent(te);
			}
			setTimeout(generate, 1, _state, (_state + _step > _mesh.faces.length) ? _mesh.faces.length : _state + _step);
		}
	}

	private function applyBlur(map:BitmapData):Void {
		
		var bf:BlurFilter = new BlurFilter(_blur, _blur);
		var pt:Point = new Point(0, 0);
		map.applyFilter(map, map.rect, pt, bf);
		bf = null;
		pt = null;
	}

	private function averageNormals(v:Vertex, n:Number3D, fn:Number3D):Number3D {
		
		n.x = 0;
		n.y = 0;
		n.z = 0;
		var m0:Int = 0;
		var m1:Int = 0;
		var m2:Int = 0;
		var f:Face;
		var norm:Number3D;
		var l:Float;
		var i:Int = 0;
		while (i < _mesh.faces.length) {
			f = _mesh.faces[i];
			if ((f.v0.x == v.x && f.v0.y == v.y && f.v0.z == v.z) || (f.v1.x == v.x && f.v1.y == v.y && f.v1.z == v.z) || (f.v2.x == v.x && f.v2.y == v.y && f.v2.z == v.z)) {
				norm = f.normal;
				if ((Math.max(fn.x, norm.x) - Math.min(fn.x, norm.x) < .8)) {
					n.x += norm.x;
					m0++;
				}
				if ((Math.max(fn.y, norm.y) - Math.min(fn.y, norm.y) < .8)) {
					n.y += norm.y;
					m1++;
				}
				if ((Math.max(fn.z, norm.z) - Math.min(fn.z, norm.z) < .8)) {
					n.z += norm.z;
					m2++;
				}
			}
			
			// update loop variables
			++i;
		}

		n.x /= m0;
		n.y /= m1;
		n.z /= m2;
		n.normalize();
		return n;
	}

	private function setBounds(x1:Int, y1:Int, x2:Int, y2:Int, r0:Float, g0:Float, b0:Float, r1:Float, g1:Float, b1:Float, dist:Float):Void {
		
		var line:Array<Dynamic> = [x1, y1];
		var dist2:Float;
		var scale:Float;
		var r:Float;
		var g:Float;
		var b:Float;
		var o:Dynamic;
		o = {x:x1, y:y1, col:r0 << 16 | g0 << 8 | b0};
		_lines[_lines.length] = o;
		o = {x:x2, y:y2, col:r1 << 16 | g1 << 8 | b1};
		_lines[_lines.length] = o;
		var error:Int;
		var dx:Int;
		var dy:Int;
		if (x1 > x2) {
			var tmp:Int = x1;
			x1 = x2;
			x2 = tmp;
			tmp = y1;
			y1 = y2;
			y2 = tmp;
		}
		dx = x2 - x1;
		dy = y2 - y1;
		var yi:Int = 1;
		if (dx < dy) {
			x1 ^= x2;
			x2 ^= x1;
			x1 ^= x2;
			y1 ^= y2;
			y2 ^= y1;
			y1 ^= y2;
		}
		if (dy < 0) {
			dy = -dy;
			yi = -yi;
		}
		if (dy > dx) {
			error = -(dy >> 1);
			;
			while (y2 < y1) {
				dist2 = Math.sqrt((x2 - line[0]) * (x2 - line[0]) + (y2 - line[1]) * (y2 - line[1]));
				scale = dist2 / dist;
				r = (r1 * scale) + (r0 * (1 - scale));
				g = (g1 * scale) + (g0 * (1 - scale));
				b = (b1 * scale) + (b0 * (1 - scale));
				o = {x:x2, y:y2, col:r << 16 | g << 8 | b};
				_lines[_lines.length] = o;
				error += dx;
				if (error > 0) {
					x2 += yi;
					dist2 = Math.sqrt((x2 - line[0]) * (x2 - line[0]) + (y2 - line[1]) * (y2 - line[1]));
					scale = dist2 / dist;
					r = (r1 * scale) + (r0 * (1 - scale));
					g = (g1 * scale) + (g0 * (1 - scale));
					b = (b1 * scale) + (b0 * (1 - scale));
					o = {x:x2, y:y2, col:r << 16 | g << 8 | b};
					_lines[_lines.length] = o;
					error -= dy;
				}
				
				// update loop variables
				++y2;
			}

		} else {
			error = -(dx >> 1);
			;
			while (x1 < x2) {
				dist2 = Math.sqrt((x1 - line[0]) * (x1 - line[0]) + (y1 - line[1]) * (y1 - line[1]));
				scale = dist2 / dist;
				r = (r1 * scale) + (r0 * (1 - scale));
				g = (g1 * scale) + (g0 * (1 - scale));
				b = (b1 * scale) + (b0 * (1 - scale));
				o = {x:x1, y:y1, col:r << 16 | g << 8 | b};
				_lines[_lines.length] = o;
				error += dy;
				if (error > 0) {
					y1 += yi;
					dist2 = Math.sqrt((x1 - line[0]) * (x1 - line[0]) + (y1 - line[1]) * (y1 - line[1]));
					scale = dist2 / dist;
					r = (r1 * scale) + (r0 * (1 - scale));
					g = (g1 * scale) + (g0 * (1 - scale));
					b = (b1 * scale) + (b0 * (1 - scale));
					o = {x:x1, y:y1, col:r << 16 | g << 8 | b};
					_lines[_lines.length] = o;
					error -= dx;
				}
				
				// update loop variables
				++x1;
			}

		}
	}

	private function grow():Void {
		
		var tmp0:BitmapData = new BitmapData(_normalmap.width, _normalmap.height, true, 0);
		var tmp1:BitmapData = new BitmapData(_normalmap.width, _normalmap.height, false, 0);
		var tmp2:BitmapData = tmp1.clone();
		var tmp3:BitmapData = tmp0.clone();
		var cf:ConvolutionFilter = new ConvolutionFilter(3, 3, null, 0, 127);
		var dp:DisplacementMapFilter = new DisplacementMapFilter(tmp1, tmp1.rect.topLeft, 1, 2, 2, 2, "color", 0, 0);
		var zeropt:Point = new Point(0, 0);
		var mat0:Array<Dynamic> = [-1, 0, 1, -2, 0, 2, -1, 0, 1];
		var mat1:Array<Dynamic> = [-1, -2, -1, 0, 0, 0, 1, 2, 1];
		var i:Int = 0;
		while (i < 10) {
			tmp0.draw(_normalmap);
			tmp0.threshold(tmp0, _normalmap.rect, zeropt, "==", 0, 0xFFFFFF, 0xFFFFFF);
			tmp1.copyChannel(tmp0, _normalmap.rect, _normalmap.rect.topLeft, 8, 1);
			tmp2.draw(tmp1);
			cf.matrix = mat0;
			tmp1.applyFilter(tmp1, tmp1.rect, tmp1.rect.topLeft, cf);
			cf.matrix = mat1;
			tmp2.applyFilter(tmp2, tmp2.rect, tmp2.rect.topLeft, cf);
			tmp1.copyChannel(tmp2, tmp1.rect, tmp1.rect.topLeft, 1, 2);
			tmp3.draw(tmp0);
			tmp0.applyFilter(tmp0, _normalmap.rect, _normalmap.rect.topLeft, dp);
			tmp0.draw(tmp3);
			_normalmap.draw(tmp0);
			
			// update loop variables
			++i;
		}

		tmp0.dispose();
		tmp1.dispose();
		tmp2.dispose();
		tmp3.dispose();
	}

	/**
	 * Applys a bump to a given normal map. If you do not generate the map from a mesh, just pass null in the constructor.
	 *
	 * @param	bm						BitmapData. The source bumpmap.
	 * @param	nm						BitmapData. The source normalmap.
	 *
	 *@ return BitmapData. The source normalmap with the bump applied to it
	 */
	public function applyBump(bm:BitmapData, nm:BitmapData):BitmapData {
		
		if (nm.width != bm.width || nm.height != bm.height) {
			var gs:BitmapData = bm.clone();
			var sclmat:Matrix = new Matrix();
			var Wscl:Float = nm.width / gs.width;
			var Hscl:Float = nm.height / gs.height;
			sclmat.scale(Wscl, Hscl);
			_bumpmap = new BitmapData(gs.width * Wscl, gs.height * Hscl, false, 0);
			_bumpmap.draw(gs, sclmat, null, "normal", _bumpmap.rect, true);
		} else {
			_bumpmap = new BitmapData(bm.width, bm.height, false, 0x000000);
			_bumpmap.copyPixels(bm, bm.rect, new Point(0, 0));
		}
		var zero:Point = new Point(0, 0);
		var ct:ColorMatrixFilter = new ColorMatrixFilter([0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0]);
		_bumpmap.applyFilter(_bumpmap, nm.rect, zero, ct);
		var cf:ConvolutionFilter = new ConvolutionFilter(3, 6, null, 1, 127);
		var dumX:BitmapData = new BitmapData(nm.width, nm.height, false, 0x000000);
		cf.matrix = [0, 0, 0, -1, 0, 1, 0, 0, 0];
		dumX.applyFilter(_bumpmap, nm.rect, zero, cf);
		_bumpmap.copyChannel(dumX, nm.rect, zero, 1, 1);
		var dumY:BitmapData = new BitmapData(nm.width, nm.height, false, 0x000000);
		cf.matrix = new Array(0, -1, 0, 0, 0, 0, 0, 1, 0);
		dumY.applyFilter(_bumpmap, nm.rect, zero, cf);
		_bumpmap.copyChannel(dumY, nm.rect, zero, 2, 2);
		dumX.dispose();
		dumY.dispose();
		var dp:DisplacementMapFilter = new DisplacementMapFilter();
		dp.mapBitmap = _bumpmap;
		dp.mapPoint = zero;
		dp.componentX = 1;
		dp.componentY = 2;
		dp.scaleX = -127;
		dp.scaleY = -127;
		dp.mode = "wrap";
		dp.color = 0;
		dp.alpha = 0;
		nm.applyFilter(nm, _bumpmap.rect, zero, dp);
		return nm;
	}

	/**
	 * Class NormalMapGenerator generates a normalmap from a given Mesh object and merge an additionl bump information to it.
	 *
	 * @param	mesh						Object3D. The mesh Object3D to be updated.
	 * @param	width						[optional] int. The width of the generated normalmap. Default is 512.
	 * @param	height					[optional] int. The height of the generated normalmap. Default is 512.
	 * @param	bumpsource			[optional] BitmapData. The source bitmapdata for an additional bump information. Default is null;
	 * @param	blur						[optional] int. Blur value if applyed, the surface of the object becomes smoother. Default is 0;
	 * @param	maxfaces				[optional] int. To avoid that the player generates a timout error, the class handles the trace of faces stepwize. Default is 50 faces.
	 */
	public function new(mesh:Mesh, ?width:Int=512, ?height:Int=512, ?bumpsource:BitmapData=null, ?blur:Int=0, ?maxfaces:Int=50) {
		// autogenerated
		super();
		this._blur = 0;
		this._state = 0;
		this._step = 50;
		this.n0 = new Number3D();
		this.n1 = new Number3D();
		this.n2 = new Number3D();
		this.intPt0 = new Point();
		this.intPt1 = new Point();
		this.intPt2 = new Point();
		this.rect = new Rectangle(0, 0, 1, 1);
		
		
		if (mesh != null && (cast(mesh, Mesh)).vertices != null) {
			_mesh = cast(mesh, Mesh);
			_width = width;
			_height = height;
			_state = 0;
			_step = Std.int(maxfaces * (1 - (1 / (2800 / Math.max(_width, _height)))));
			_bumpsource = bumpsource;
			_blur = blur;
			_normalmap = new BitmapData(_width, _height, false, 0x000000);
			generate(0, (_step > _mesh.faces.length) ? _mesh.faces.length : _step);
		}
	}

	/**
	 * Returns the normalMap generated by the class
	 *
	 * @return	normalmap		BitmapData. the normalMap generated by the class
	 */
	public function getNormalmap():BitmapData {
		
		return _normalmap;
	}

	/**
	 * Returns the generated bump source for a displacementfilter generated by the class
	 *
	 * @return	bumpMap		BitmapData. The bumpMap generated by the class
	 */
	public function getBumpmap():BitmapData {
		
		return _bumpmap;
	}

	/**
	 * Default method for adding a traceprogress event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnTraceProgress(listener:Dynamic):Void {
		
		addEventListener(TraceEvent.TRACE_PROGRESS, listener, false, 0, false);
	}

	/**
	 * Default method for removing a traceprogress event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnTraceProgress(listener:Dynamic):Void {
		
		removeEventListener(TraceEvent.TRACE_PROGRESS, listener, false);
	}

	/**
	 * Default method for adding a tracecomplete event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnTraceComplete(listener:Dynamic):Void {
		
		addEventListener(TraceEvent.TRACE_COMPLETE, listener, false, 0, false);
	}

	/**
	 * Default method for removing a tracecomplete event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnTraceComplete(listener:Dynamic):Void {
		
		removeEventListener(TraceEvent.TRACE_COMPLETE, listener, false);
	}

}

