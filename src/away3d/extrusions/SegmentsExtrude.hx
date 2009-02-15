package away3d.extrusions;

import flash.geom.Point;
import away3d.core.utils.ValueObject;
import away3d.core.base.Face;
import away3d.core.base.Mesh;
import away3d.core.utils.Init;
import away3d.core.math.Number3D;
import away3d.core.base.UV;
import away3d.core.base.Vertex;


class SegmentsExtrude extends Mesh  {
	
	private var varr:Array<Dynamic>;
	private var varr2:Array<Dynamic>;
	private var uvarr:Array<Dynamic>;
	

	public function new(aPoints:Dynamic, ?init:Dynamic=null) {
		this.varr = new Array<Dynamic>();
		this.varr2 = new Array<Dynamic>();
		this.uvarr = new Array<Dynamic>();
		
		
		if (init.material != null) {
			init.materials = {defaultmaterial:init.material};
		}
		if (init.material == null && init.materials != null) {
			init.material = init.materials.defaultmaterial;
		}
		init = Init.parse(init);
		super(init);
		var axis:String = init.getString("axis", "y");
		var offset:Float = init.getNumber("offset", 10);
		var subdivision:Int = init.getInt("subdivision", 1, {min:1});
		var thickness:Float = Math.abs(init.getNumber("thickness", 0));
		var thickness_subdivision:Float = init.getInt("thickness_subdivision", 1, {min:1});
		var flip:Bool = init.getBoolean("flip", false);
		var scaling:Float = init.getNumber("scaling", 1);
		var oMat:Dynamic = init.getObject("materials", null);
		var omit:String = init.getString("omit", "");
		var coverall:Bool = init.getBoolean("coverall", false);
		var recenter:Bool = init.getBoolean("recenter", false);
		var closepath:Bool = init.getBoolean("closepath", false);
		if (closepath) {
			omit += "left,right";
		}
		if (Std.is(aPoints[0], Array<Dynamic>)) {
			var i:Int = 0;
			while (i < aPoints.length) {
				if (aPoints[i].length > 1) {
					varr = new Array<Dynamic>();
					varr2 = new Array<Dynamic>();
					uvarr = new Array<Dynamic>();
					generate(aPoints[i], oMat, axis, offset, subdivision, thickness, thickness_subdivision, scaling, omit, coverall, closepath, flip);
				} else {
					trace("SegmentsExtrude error: at index " + i + " , at least 2 points are required per extrude!");
				}
				
				// update loop variables
				i++;
			}

		} else {
			if (closepath) {
				aPoints.push(new Number3D());
			}
			if (aPoints.length > 1) {
				generate(aPoints, oMat, axis, offset, subdivision, thickness, thickness_subdivision, scaling, omit, coverall, closepath, flip);
			} else {
				trace("SegmentsExtrude error: at least 2 points in an array are required per extrude!");
			}
		}
		if (recenter) {
			applyPosition((this.minX + this.maxX) * .5, (this.minY + this.maxY) * .5, (this.minZ + this.maxZ) * .5);
		} else {
			var isArr:Bool = (Std.is(aPoints[0], Array<Dynamic>));
			x = (isArr) ? aPoints[0][0].x : aPoints[0].x;
			y = (isArr) ? aPoints[0][0].y : aPoints[0].y;
			z = (isArr) ? aPoints[0][0].z : aPoints[0].z;
		}
		varr = null;
		varr2 = null;
		uvarr = null;
		type = "SegmentsExtrude";
		url = "Extrude";
	}

	private function generate(points:Array<Dynamic>, ?oMat:Dynamic=null, ?axis:String="y", ?origoffset:Float=0, ?subdivision:Int=1, ?thickness:Float=0, ?thickness_subdivision:Int=1, ?scaling:Float=1, ?omit:String="", ?coverall:Bool=false, ?closepath:Bool=false, ?flip:Bool=false):Void {
		
		var i:Int;
		var j:Int;
		var vector:Dynamic;
		var vector2:Dynamic;
		var increase:Float = (subdivision == 1) ? origoffset : origoffset / subdivision;
		var basemaxX:Float = points[0].x;
		var baseminX:Float = points[0].x;
		var basemaxY:Float = points[0].y;
		var baseminY:Float = points[0].y;
		var basemaxZ:Float = points[0].z;
		var baseminZ:Float = points[0].z;
		i = 0;
		while (i < points.length) {
			if (scaling != 1) {
				points[i].x *= scaling;
				points[i].y *= scaling;
				points[i].z *= scaling;
			}
			basemaxX = Math.max(points[i].x, basemaxX);
			baseminX = Math.min(points[i].x, baseminX);
			basemaxY = Math.max(points[i].y, basemaxY);
			baseminY = Math.min(points[i].y, baseminY);
			basemaxZ = Math.max(points[i].z, basemaxZ);
			baseminZ = Math.min(points[i].z, baseminZ);
			
			// update loop variables
			i++;
		}

		var basemax:Float;
		var basemin:Float;
		var offset:Float = 0;
		switch (axis) {
			case "x" :
				basemax = Math.abs(basemaxX) - Math.abs(baseminX);
				if (baseminZ > 0 && basemaxZ > 0) {
					basemin = basemaxZ - baseminZ;
					offset = -baseminZ;
				} else if (baseminZ < 0 && basemaxZ < 0) {
					basemin = Math.abs(baseminZ - basemaxZ);
					offset = -baseminZ;
				} else {
					basemin = Math.abs(basemaxZ) + Math.abs(baseminZ);
					offset = Math.abs(baseminZ) + ((basemaxZ < 0) ? -basemaxZ : 0);
				}
			case "y" :
				basemax = Math.abs(basemaxY) - Math.abs(baseminY);
				if (baseminX > 0 && basemaxX > 0) {
					basemin = basemaxX - baseminX;
					offset = -baseminX;
				} else if (baseminX < 0 && basemaxX < 0) {
					basemin = Math.abs(baseminX - basemaxX);
					offset = -baseminX;
				} else {
					basemin = Math.abs(basemaxX) + Math.abs(baseminX);
					offset = Math.abs(baseminX) + ((basemaxX < 0) ? -basemaxX : 0);
				}
			case "z" :
				basemax = Math.abs(basemaxZ) - Math.abs(baseminZ);
				if (baseminY > 0 && basemaxY > 0) {
					basemin = basemaxY - baseminY;
					offset = -baseminY;
				} else if (baseminY < 0 && basemaxY < 0) {
					basemin = Math.abs(baseminY - basemaxY);
					offset = -baseminY;
				} else {
					basemin = Math.abs(basemaxY) + Math.abs(baseminY);
					offset = Math.abs(baseminY) + ((basemaxY < 0) ? -basemaxY : 0);
				}
			

		}
		var Lines:Array<Dynamic>;
		var prop1:String;
		var prop2:String;
		var prop3:String;
		var aListsides:Array<Dynamic> = ["top", "bottom", "right", "left", "front", "back"];
		if (thickness != 0) {
			var oRenderside:Dynamic = {};
			i = 0;
			while (i < aListsides.length) {
				Reflect.setField(oRenderside, aListsides[i], (omit.indexOf(aListsides[i]) == -1));
				
				// update loop variables
				i++;
			}

			switch (axis) {
				case "x" :
					prop1 = "z";
					prop2 = "y";
					prop3 = "x";
				case "y" :
					prop1 = "x";
					prop2 = "z";
					prop3 = "y";
				case "z" :
					prop1 = "y";
					prop2 = "x";
					prop3 = "z";
				

			}
			Lines = buildThicknessPoints(points, thickness, prop1, prop2, closepath);
			var oPoints:Dynamic;
			var oPrevPoints:Dynamic;
			var vector3:Dynamic;
			var vector4:Dynamic;
			i = 0;
			while (i < Lines.length) {
				oPoints = Lines[i];
				vector = {};
				vector2 = {};
				if (i == 0) {
					Reflect.setField(vector, prop1, oPoints.pt2.x.toFixed(4));
					Reflect.setField(vector, prop2, oPoints.pt2.y.toFixed(4));
					Reflect.setField(vector, prop3, points[0][prop3]);
					varr.push(new Vertex());
					Reflect.setField(vector2, prop1, oPoints.pt1.x.toFixed(4));
					Reflect.setField(vector2, prop2, oPoints.pt1.y.toFixed(4));
					Reflect.setField(vector2, prop3, points[0][prop3]);
					varr2.push(new Vertex());
					elevate(subdivision, axis, vector, vector2, basemin, basemax, increase);
					if (Lines.length == 1) {
						vector3 = {};
						vector4 = {};
						Reflect.setField(vector3, prop1, oPoints.pt4.x.toFixed(4));
						Reflect.setField(vector3, prop2, oPoints.pt4.y.toFixed(4));
						Reflect.setField(vector3, prop3, points[0][prop3]);
						varr.push(new Vertex());
						Reflect.setField(vector4, prop1, oPoints.pt3.x.toFixed(4));
						Reflect.setField(vector4, prop2, oPoints.pt3.y.toFixed(4));
						Reflect.setField(vector4, prop3, points[0][prop3]);
						varr2.push(new Vertex());
						elevate(subdivision, axis, vector3, vector4, basemin, basemax, increase);
					}
				} else if (i == Lines.length - 1) {
					Reflect.setField(vector, prop1, oPoints.pt2.x);
					Reflect.setField(vector, prop2, oPoints.pt2.y);
					Reflect.setField(vector, prop3, points[i][prop3]);
					varr.push(new Vertex());
					Reflect.setField(vector2, prop1, oPoints.pt1.x);
					Reflect.setField(vector2, prop2, oPoints.pt1.y);
					Reflect.setField(vector2, prop3, points[i][prop3]);
					varr2.push(new Vertex());
					elevate(subdivision, axis, vector, vector2, basemin, basemax, increase);
					vector3 = {};
					vector4 = {};
					Reflect.setField(vector3, prop1, oPoints.pt4.x);
					Reflect.setField(vector3, prop2, oPoints.pt4.y);
					Reflect.setField(vector3, prop3, points[i][prop3]);
					varr.push(new Vertex());
					Reflect.setField(vector4, prop1, oPoints.pt3.x);
					Reflect.setField(vector4, prop2, oPoints.pt3.y);
					Reflect.setField(vector4, prop3, points[i][prop3]);
					varr2.push(new Vertex());
					elevate(subdivision, axis, vector3, vector4, basemin, basemax, increase);
				} else {
					Reflect.setField(vector, prop1, oPoints.pt2.x);
					Reflect.setField(vector, prop2, oPoints.pt2.y);
					Reflect.setField(vector, prop3, points[i][prop3]);
					varr.push(new Vertex());
					Reflect.setField(vector2, prop1, oPoints.pt1.x);
					Reflect.setField(vector2, prop2, oPoints.pt1.y);
					Reflect.setField(vector2, prop3, points[i][prop3]);
					varr2.push(new Vertex());
					elevate(subdivision, axis, vector, vector2, basemin, basemax, increase);
				}
				
				// update loop variables
				i++;
			}

		} else {
			i = 0;
			while (i < points.length) {
				vector = {x:points[i].x, y:points[i].y, z:points[i].z};
				varr.push(new Vertex());
				switch (axis) {
					case "x" :
						uvarr.push(new UV());
					case "y" :
						uvarr.push(new UV());
					case "z" :
						uvarr.push(new UV());
					

				}
				j = 0;
				while (j < subdivision) {
					Reflect.field(vector, axis) += increase;
					switch (axis) {
						case "x" :
							uvarr.push(new UV());
						case "y" :
							uvarr.push(new UV());
						case "z" :
							uvarr.push(new UV());
						

					}
					varr.push(new Vertex());
					
					// update loop variables
					j++;
				}

				
				// update loop variables
				i++;
			}

		}
		//axis switch for elevation
		switch (axis) {
			case "x" :
				axis = "z";
			case "y" :
				axis = "x";
			case "z" :
				axis = "y";
			

		}
		var index:Int = 0;
		var k:Int;
		var aProps:Array<Dynamic> = ["x", "y", "z"];
		if (thickness != 0) {
			var mf:Dynamic;
			var mb:Dynamic;
			var mt:Dynamic;
			var mbo:Dynamic;
			var mr:Dynamic;
			var ml:Dynamic;
			if (oMat != null) {
				mf = (oMat.front != null) ? oMat.front : null;
				mb = (oMat.back != null) ? oMat.back : null;
				mt = (oMat.top != null) ? oMat.top : null;
				mbo = (oMat.bottom != null) ? oMat.bottom : null;
				mr = (oMat.right != null) ? oMat.right : null;
				ml = (oMat.left != null) ? oMat.left : null;
			}
		}
		var uva:UV;
		var uvb:UV;
		var uvc:UV;
		var uvd:UV;
		i = 0;
		while (i < points.length - 1) {
			var pt1:Float = (Math.abs(points[i][axis] + offset) / basemin) / 1;
			var pt2:Float = (Math.abs(points[i + 1][axis] + offset) / basemin) / 1;
			j = 0;
			while (j < subdivision) {
				if (coverall) {
					uva = new UV();
					uvb = new UV();
					uvc = new UV();
					uvd = new UV();
				} else {
					uva = new UV();
					uvb = new UV();
					uvc = new UV();
					uvd = new UV();
				}
				if (thickness == 0) {
					if (flip) {
						addFace(new Face());
						addFace(new Face());
					} else {
						addFace(new Face());
						addFace(new Face());
					}
				} else {
					var v1a:Vertex = varr[index + j];
					var v1b:Vertex = varr[(index + j) + 1];
					var v1c:Vertex = varr[((index + j) + (subdivision + 2))];
					var v2a:Vertex = varr[(index + j)];
					var v2b:Vertex = varr[((index + j) + (subdivision + 2))];
					var v2c:Vertex = varr[((index + j) + (subdivision + 1))];
					//body side 2
					var v3a:Vertex = varr2[index + j];
					var v3b:Vertex = varr2[(index + j) + 1];
					var v3c:Vertex = varr2[((index + j) + (subdivision + 2))];
					var v4a:Vertex = varr2[(index + j)];
					var v4b:Vertex = varr2[((index + j) + (subdivision + 2))];
					var v4c:Vertex = varr2[((index + j) + (subdivision + 1))];
					//body + reversed uv's
					if (oRenderside.front) {
						if (flip) {
							addFace(new Face());
							addFace(new Face());
						} else {
							addFace(new Face());
							addFace(new Face());
						}
					}
					if (oRenderside.back) {
						if (flip) {
							addFace(new Face());
							addFace(new Face());
						} else {
							addFace(new Face());
							addFace(new Face());
						}
					}
					//bottom
					if (j == 0 && oRenderside.bottom) {
						addThicknessSubdivision([v2c, v1a], [v4c, v3a], thickness_subdivision, uvd.u, uvb.u, mt, flip);
					}
					//top
					if (j == subdivision - 1 && oRenderside.top) {
						addThicknessSubdivision([v1b, v1c], [v3b, v3c], thickness_subdivision, 1 - uva.u, 1 - uvc.u, mt, flip);
					}
					//left
					if (i == 0 && oRenderside.left) {
						if (flip) {
							addFace(new Face());
							addFace(new Face());
						} else {
							addFace(new Face());
							addFace(new Face());
						}
					}
					//right
					if (i == points.length - 2 && oRenderside.right) {
						if (flip) {
							addFace(new Face());
							addFace(new Face());
						} else {
							addFace(new Face());
							addFace(new Face());
						}
					}
				}
				
				// update loop variables
				j++;
			}

			index += subdivision + 1;
			
			// update loop variables
			i++;
		}

	}

	private function addThicknessSubdivision(points1:Array<Dynamic>, points2:Array<Dynamic>, subdivision:Int, u1:Float, u2:Float, ?material:Dynamic=null, ?flip:Bool=false):Void {
		
		var i:Int;
		var j:Int;
		var stepx:Float;
		var stepy:Float;
		var stepz:Float;
		var uva:UV;
		var uvb:UV;
		var uvc:UV;
		var uvd:UV;
		var va:Vertex;
		var vb:Vertex;
		var vc:Vertex;
		var vd:Vertex;
		//var u1:Number;
		//var u2:Number;
		var index:Int = 0;
		//var bu:Number = 0;
		//var bincu = 1/(points1.length-1);
		var v1:Float = 0;
		var v2:Float = 0;
		var tmp:Array<Dynamic> = new Array<Dynamic>();
		i = 0;
		while (i < points1.length) {
			stepx = (points2[i].x - points1[i].x) / subdivision;
			stepy = (points2[i].y - points1[i].y) / subdivision;
			stepz = (points2[i].z - points1[i].z) / subdivision;
			j = 0;
			while (j < subdivision + 1) {
				tmp.push(new Vertex());
				
				// update loop variables
				j++;
			}

			
			// update loop variables
			i++;
		}

		i = 0;
		while (i < points1.length - 1) {
			j = 0;
			while (j < subdivision) {
				v1 = j / subdivision;
				v2 = (j + 1) / subdivision;
				uva = new UV();
				uvb = new UV();
				uvc = new UV();
				uvd = new UV();
				va = tmp[index + j];
				vb = tmp[(index + j) + 1];
				vc = tmp[((index + j) + (subdivision + 2))];
				vd = tmp[((index + j) + (subdivision + 1))];
				if (flip) {
					addFace(new Face());
					addFace(new Face());
				} else {
					addFace(new Face());
					addFace(new Face());
				}
				
				// update loop variables
				j++;
			}

			index += subdivision + 1;
			
			// update loop variables
			i++;
		}

	}

	private function elevate(subdivision:Int, axis:String, vector:Dynamic, vector2:Dynamic, basemin:Float, basemax:Float, increase:Float):Void {
		
		switch (axis) {
			case "x" :
				uvarr.push(new UV());
			case "y" :
				uvarr.push(new UV());
			case "z" :
				uvarr.push(new UV());
			

		}
		var j:Int;
		j = 0;
		while (j < subdivision) {
			Reflect.field(vector, axis) += increase;
			Reflect.field(vector2, axis) += increase;
			switch (axis) {
				case "x" :
					uvarr.push(new UV());
				case "y" :
					uvarr.push(new UV());
				case "z" :
					uvarr.push(new UV());
				

			}
			varr.push(new Vertex());
			varr2.push(new Vertex());
			
			// update loop variables
			j++;
		}

	}

	private function buildThicknessPoints(aPoints:Array<Dynamic>, thickness:Float, prop1:String, prop2:String, closepath:Bool):Array<Dynamic> {
		
		var Anchors:Array<Dynamic> = new Array<Dynamic>();
		var Lines:Array<Dynamic> = new Array<Dynamic>();
		var i:Int;
		i = 0;
		while (i < aPoints.length - 1) {
			if (aPoints[i][prop1] == 0 && aPoints[i][prop2] == 0) {
				aPoints[i][prop1] = .0001;
			}
			if (aPoints[i + 1][prop2] != null && aPoints[i][prop2] == aPoints[i + 1][prop2]) {
				aPoints[i + 1][prop2] += .0001;
			}
			if (aPoints[i][prop1] != null && aPoints[i][prop1] == aPoints[i + 1][prop1]) {
				aPoints[i + 1][prop1] += .0001;
			}
			Anchors.push(defineAnchors(aPoints[i], aPoints[i + 1], thickness, prop1, prop2));
			
			// update loop variables
			i++;
		}

		var totallength:Int = Anchors.length;
		var oPointResult:Dynamic;
		if (totallength > 1) {
			i = 0;
			while (i < totallength) {
				if (i < totallength) {
					oPointResult = defineLines(i, totallength, Anchors[i], Anchors[i + 1], Lines);
				} else {
					oPointResult = defineLines(i, totallength, Anchors[i], Anchors[i - 1], Lines);
				}
				if (oPointResult != null) {
					Lines.push(oPointResult);
				}
				
				// update loop variables
				i++;
			}

			if (closepath && Anchors.length > 2) {
				Anchors.push(defineAnchors(aPoints[Anchors.length - 1], aPoints[0], thickness, prop1, prop2));
				var tmparray:Array<Dynamic> = [Anchors[Anchors.length - 1], Anchors[0], Anchors[1], Anchors[2]];
				var tmplines:Array<Dynamic> = new Array<Dynamic>();
				i = 0;
				while (i < 2) {
					oPointResult = defineLines(i, totallength, tmparray[i], tmparray[i + 1], tmparray);
					if (oPointResult != null) {
						tmplines.push(oPointResult);
					}
					
					// update loop variables
					i++;
				}

				Lines[0].pt1 = tmplines[0].pt3;
				Lines[0].pt2 = tmplines[0].pt4;
				Lines[0].pt3 = tmplines[1].pt1;
				Lines[0].pt4 = tmplines[1].pt2;
				Lines[Lines.length - 1].pt3 = tmplines[0].pt3;
				Lines[Lines.length - 1].pt4 = tmplines[0].pt4;
			}
		} else {
			Lines = [{pt1:Anchors[0].pt1, pt2:Anchors[0].pt2, pt3:Anchors[0].pt3, pt4:Anchors[0].pt4}];
		}
		return Lines;
	}

	private function defineLines(index:Int, maxindex:Int, oPoint1:Dynamic, ?oPoint2:Dynamic=null, ?Lines:Array<Dynamic>=null):Dynamic {
		
		var tmppt:Dynamic = Lines[index - 1];
		if (oPoint2 == null) {
			return {pt1:tmppt.pt3, pt2:tmppt.pt4, pt3:oPoint1.pt3, pt4:oPoint1.pt4};
		}
		var oLine1:Dynamic = buildObjectLine(oPoint1.pt1.x, oPoint1.pt1.y, oPoint1.pt3.x, oPoint1.pt3.y);
		var oLine2:Dynamic = buildObjectLine(oPoint1.pt2.x, oPoint1.pt2.y, oPoint1.pt4.x, oPoint1.pt4.y);
		var oLine3:Dynamic = buildObjectLine(oPoint2.pt1.x, oPoint2.pt1.y, oPoint2.pt3.x, oPoint2.pt3.y);
		var oLine4:Dynamic = buildObjectLine(oPoint2.pt2.x, oPoint2.pt2.y, oPoint2.pt4.x, oPoint2.pt4.y);
		var cross1:Point = lineIntersect(oLine3, oLine1);
		var cross2:Point = lineIntersect(oLine2, oLine4);
		if (cross1 != null && cross2 != null) {
			if (index == 0) {
				return {pt1:oPoint1.pt1, pt2:oPoint1.pt2, pt3:cross1, pt4:cross2};
			}
			return {pt1:tmppt.pt3, pt2:tmppt.pt4, pt3:cross1, pt4:cross2};
		} else {
			return null;
		}
		
		// autogenerated
		return null;
	}

	private function defineAnchors(base:Number3D, baseEnd:Number3D, thickness:Float, prop1:String, prop2:String):Dynamic {
		
		var angle:Float = (Math.atan2(Reflect.field(base, prop2) - Reflect.field(baseEnd, prop2), Reflect.field(base, prop1) - Reflect.field(baseEnd, prop1)) * 180) / Math.PI;
		angle -= 270;
		var angle2:Float = angle + 180;
		//origin points
		var pt1:Point = new Point();
		var pt2:Point = new Point();
		//dest points
		var pt3:Point = new Point();
		var pt4:Point = new Point();
		var radius:Float = thickness * .5;
		pt1.x = pt1.x + Math.cos(-angle / 180 * Math.PI) * radius;
		pt1.y = pt1.y + Math.sin(angle / 180 * Math.PI) * radius;
		pt2.x = pt2.x + Math.cos(-angle2 / 180 * Math.PI) * radius;
		pt2.y = pt2.y + Math.sin(angle2 / 180 * Math.PI) * radius;
		pt3.x = pt3.x + Math.cos(-angle / 180 * Math.PI) * radius;
		pt3.y = pt3.y + Math.sin(angle / 180 * Math.PI) * radius;
		pt4.x = pt4.x + Math.cos(-angle2 / 180 * Math.PI) * radius;
		pt4.y = pt4.y + Math.sin(angle2 / 180 * Math.PI) * radius;
		return {pt1:pt1, pt2:pt2, pt3:pt3, pt4:pt4};
	}

	private function buildObjectLine(origX:Float, origY:Float, endX:Float, endY:Float):Dynamic {
		
		return {ax:origX, ay:origY, bx:endX - origX, by:endY - origY};
	}

	private function lineIntersect(Line1:Dynamic, Line2:Dynamic):Point {
		
		Line1.bx = (Line1.bx == 0) ? 0.0001 : Line1.bx;
		Line2.bx = (Line2.bx == 0) ? 0.0001 : Line2.bx;
		var a1:Float = Line1.by / Line1.bx;
		var b1:Float = Line1.ay - a1 * Line1.ax;
		var a2:Float = Line2.by / Line2.bx;
		var b2:Float = Line2.ay - a2 * Line2.ax;
		var nzero:Float = ((a1 - a2) == 0) ? 0.0001 : a1 - a2;
		var ptx:Float = (b2 - b1) / (nzero);
		var pty:Float = a1 * ptx + b1;
		if (isFinite(ptx) && isFinite(pty)) {
			return new Point();
		} else {
			trace("infinity");
			return null;
		}
		
		// autogenerated
		return null;
	}

}

