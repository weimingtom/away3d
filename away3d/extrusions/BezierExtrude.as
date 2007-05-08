
package away3d.extrusions
{
	import away3d.objects.*;
	import away3d.shapes.*;
	import away3d.core.*;
	import away3d.core.draw.*;
	import away3d.core.geom.*;
	import away3d.core.material.*;
	import away3d.core.math.*;
	import away3d.core.proto.*;
	import away3d.core.render.*;
	
	
	public class BezierExtrude extends Mesh3D
	{
		public var segmentsH:int = 20;
		
		public var length:Number;
		public var axisVertices:Array = [];
		
		
		function BezierExtrude(material:IMaterial, shape:RegularShape, vertices:Array, init:Object = null)
		{
			super(material, init);
			if (init != null)
            {
            	segmentsH = Math.max(2, init.segmentsH) || segmentsH;
            }
			buildExtrusion(shape, vertices);
		}
		
		private function buildExtrusion(shape:RegularShape, vertices:Array):void
		{
			var i:Number, j:Number, k:Number;
			var iPoints:Number = vertices.length - 1;
			var aVtc:Array = new Array();
			
			var v:Vertex3D, vx:Number, vy:Number, vz:Number, sx:Number, sy:Number, sz:Number;
			
			var a1:Number, a2:Number, fDir1:Number3D, fDir2:Number3D, fPos:Number3D, oldPos:Number3D;
			
			length = 0;
			for (k=0;k<iPoints-2; k+=2) {
				var p0:Number3D = vertices[k];
				var p1:Number3D = vertices[k+1];
				var p2:Number3D = Number3D.sub(Number3D.scale(vertices[k+2], 2), vertices[k+3]);
				var p3:Number3D = vertices[k+2];
				
				var d2:Number3D = Number3D.scale(Number3D.sub(p1, p0), 2);
				var d1:Number3D = Number3D.sub(p2, Number3D.add(p0, d2));
				
				var d4:Number3D = Number3D.scale(Number3D.sub(p2, p1), 2);
				var d3:Number3D = Number3D.sub(p3, Number3D.add(p1, d4));
				
				var jStart:Number = k? 1 : 0;
				for (j=jStart;j<=segmentsH;j++) { // vertical
					if (j) oldPos = fPos;
					var aRow:Array = new Array();
					a1 = j/segmentsH;
					a2 = Math.pow(j/segmentsH, 2);
					fDir1 = Number3D.add(Number3D.add(Number3D.scale(d1, a2), Number3D.scale(d2, a1)), p0);
					fDir2 = Number3D.add(Number3D.add(Number3D.scale(d3, a2), Number3D.scale(d4, a1)), p1);
					fPos = Number3D.add(Number3D.scale(fDir1, 1 - a1), Number3D.scale(fDir2, a1));
					axisVertices.push(fPos);
					
					var iHor:Number = shape.vertices.length;
					var oVertices:Array = shape.vertices;
					shape.lookAt(Number3D.sub(fDir2,fDir1));
					var sTransform:Matrix3D = shape.transform;
					if (j) length += Math.sqrt(Math.pow(fPos.x - oldPos.x,2) + Math.pow(fPos.y - oldPos.y,2) + Math.pow(fPos.z - oldPos.z,2));
					
					for (i=0;i<iHor;i++) { // horizontal
						v = oVertices[i];
						vx = v.x;
						vy = v.y;
						vz = v.z;
						sx = vx * sTransform.n11 + vy * sTransform.n12 + vz * sTransform.n13 + sTransform.n14;
            			sy = vx * sTransform.n21 + vy * sTransform.n22 + vz * sTransform.n23 + sTransform.n24;
						sz = vx * sTransform.n31 + vy * sTransform.n32 + vz * sTransform.n33 + sTransform.n34;
						var oVtx:Vertex3D = new Vertex3D(sx + fPos.x, sy + fPos.y, sz + fPos.z);
						vertices.push(oVtx);
						aRow.push(oVtx);
					}
					aVtc.push(aRow);
				}
			}
			var iVerNum:int = aVtc.length;
	
			var aP4uv:NumberUV, aP1uv:NumberUV, aP2uv:NumberUV, aP3uv:NumberUV;
			var aP1:Vertex3D, aP2:Vertex3D, aP3:Vertex3D, aP4:Vertex3D;
			var fJ0:Number, fJ1:Number, fI0:Number, fI1:Number;
			var xScale:Number, yScale:Number;
			if (material is IUVMaterial) {
				var mat:IUVMaterial = (material as IUVMaterial);
				if (mat.normal.modulo > 0) {
					xScale = mat.scale.x? 1/(mat.width*mat.scale.x) : 1/mat.width;
					yScale = mat.scale.y? 1/(mat.height*mat.scale.y) : 1/mat.height;									
				} else {
					xScale = mat.scale.x? shape.length/(mat.width*mat.scale.x) : 1;
					yScale = mat.scale.y? length/(mat.height*mat.scale.y) : 1;				
				}
			} else {
				xScale = yScale = 1;
			}
			for (j=1;j<iVerNum;j++) {
				var iHorNum:int = aVtc[j].length;
				var iStart:Number = (iHorNum > 2)? 0 : 1;
				for (i=iStart;i<iHorNum;i++) {
					// select vertices
					var iWrapped:Number = i==0?iHorNum:i;
					aP1 = aVtc[j][i];
					aP2 = aVtc[j][iWrapped-1];
					aP3 = aVtc[j-1][iWrapped-1];
					aP4 = aVtc[j-1][i];
					// uv
					if (mat.normal.modulo > 0) {
						aP4uv = new NumberUV(aP4.x*xScale,aP4.z*yScale);
						aP1uv = new NumberUV(aP1.x*xScale,aP1.z*yScale);
						aP2uv = new NumberUV(aP2.x*xScale,aP2.z*yScale);
						aP3uv = new NumberUV(aP3.x*xScale,aP3.z*yScale);
					} else {
						fJ0 = (yScale*j/(iVerNum - 1)) % 1;
						fJ1 = fJ0 - yScale/(iVerNum - 1);
						fI0 = (xScale*iWrapped/(iHorNum - iStart)) % 1;
						fI1 = fI0 - xScale/(iHorNum - iStart);
						aP4uv = new NumberUV(fI0,fJ1);
						aP1uv = new NumberUV(fI0,fJ0);
						aP2uv = new NumberUV(fI1,fJ0);
						aP3uv = new NumberUV(fI1,fJ1);						
					}
					// 2 faces
					faces.push( new Face3D(aP1,aP2,aP3, null, aP1uv,aP2uv,aP3uv) );
					faces.push( new Face3D(aP1,aP3,aP4, null, aP1uv,aP3uv,aP4uv) );
				}
			}
		}
	}
		
}