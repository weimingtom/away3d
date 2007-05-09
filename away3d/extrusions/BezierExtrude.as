
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
		public var shape:Vertices3D;
		
		public var segmentsH:int = 20;
		public var axisVertices:Array = [];
		public var axisMaterials:Array = [];
		
		function BezierExtrude(material:IMaterial, shape:Vertices3D, vertices:Array, init:Object = null)
		{
			super(material, init);
			if (init != null)
            {
            	segmentsH = Math.max(2, init.segmentsH) || segmentsH;
            	axisMaterials = init.axisMaterials || [];
            }
            this.shape = shape;
            this.vertices = vertices;
			buildExtrusion();
		}
		
		private function buildExtrusion():void
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
					oldPos = fPos;
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
			var lengthH:Number, oldLengthH:Number;
			var mScale:Number2D = getMaterialScale(material);
			var mat:IUVMaterial = material as IUVMaterial;
			for (j=1;j<iVerNum;j++) {
				var len:int = aVtc[j].length;
				var iHorNum:int = len;
				if (shape.wrap) iHorNum++;
				lengthH = oldLengthH = 0;
				for (i=1;i<iHorNum;i++) {
					// select vertices
					var iWrapped:Number = i==len?0:i;
					aP1 = aVtc[j][iWrapped];
					aP2 = aVtc[j][i-1];
					aP3 = aVtc[j-1][i-1];
					aP4 = aVtc[j-1][iWrapped];
					// uv
					if (axisMaterials[i]) {
						mat = axisMaterials[i] as IUVMaterial;
						mScale = getMaterialScale(mat);
					} else if (mat != material) {
						mat = material as IUVMaterial;
						mScale = getMaterialScale(material);
					}
					if (mat.normal.modulo > 0) {
						aP1uv = new NumberUV(aP1.x*mScale.x,aP1.z*mScale.y);
						aP2uv = new NumberUV(aP2.x*mScale.x,aP2.z*mScale.y);
						aP3uv = new NumberUV(aP3.x*mScale.x,aP3.z*mScale.y);
						aP4uv = new NumberUV(aP4.x*mScale.x,aP4.z*mScale.y);
					} else {
						oldLengthH = lengthH;
						lengthH += Math.sqrt(Math.pow(aP1.x - aP2.x, 2) + Math.pow(aP1.y - aP2.y, 2) + Math.pow(aP1.z - aP2.z, 2)); 
						fJ0 = (mScale.y*j/(iVerNum - 1)) % 1;
						fJ1 = fJ0 - mScale.y/(iVerNum - 1);
						fI0 = (mScale.x*lengthH/shape.length) % 1;
						fI1 = fI0 - mScale.x*(lengthH - oldLengthH)/shape.length;
						aP1uv = new NumberUV(fI0,fJ0);
						aP2uv = new NumberUV(fI1,fJ0);
						aP3uv = new NumberUV(fI1,fJ1);
						aP4uv = new NumberUV(fI0,fJ1);
					}
					// 2 faces
					faces.push( new Face3D(aP1,aP2,aP3, mat as ITriangleMaterial, aP1uv,aP2uv,aP3uv) );
					faces.push( new Face3D(aP1,aP3,aP4, mat as ITriangleMaterial, aP1uv,aP3uv,aP4uv) );
				}
			}
		}
		
		private function getMaterialScale(m:IMaterial):Number2D
		{
			if (m is IUVMaterial) {
				var mat:IUVMaterial = (m as IUVMaterial);
				if (mat.normal.modulo > 0) {
					return new Number2D(mat.scale.x? 1/(mat.width*mat.scale.x) : 1/mat.width, mat.scale.y? 1/(mat.height*mat.scale.y) : 1/mat.height);									
				} else {
					return new Number2D(mat.scale.x? shape.length/(mat.width*mat.scale.x) : 1, mat.scale.y? length/(mat.height*mat.scale.y) : 1);				
				}
			} else {
				return new Number2D(1, 1);
			}
		}
	}
		
}