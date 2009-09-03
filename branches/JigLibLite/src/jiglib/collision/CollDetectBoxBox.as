/*
   Copyright (c) 2007 Danny Chapman
   http://www.rowlhouse.co.uk

   This software is provided 'as-is', without any express or implied
   warranty. In no event will the authors be held liable for any damages
   arising from the use of this software.
   Permission is granted to anyone to use this software for any purpose,
   including commercial applications, and to alter it and redistribute it
   freely, subject to the following restrictions:
   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
   3. This notice may not be removed or altered from any source
   distribution.
 */

/**
 * @author Muzer(muzerly@gmail.com)
 * @link http://code.google.com/p/jiglibflash
 */

package jiglib.collision
{
	import flash.geom.Vector3D;

	import jiglib.cof.JConfig;
	import jiglib.data.SpanData;
	import jiglib.geometry.*;
	import jiglib.math.*;
	import jiglib.physics.MaterialProperties;
	import jiglib.physics.PhysicsState;

	public class CollDetectBoxBox extends CollDetectFunctor
	{
		private const MAX_SUPPORT_VERTS:Number = 10;
		private var combinationDist:Number;

		public function CollDetectBoxBox()
		{
			name = "BoxBox";
			type0 = "BOX";
			type1 = "BOX";
		}

		private function disjoint(out:SpanData, axis:Vector3D, box0:JBox, box1:JBox):Boolean
		{
			var obj0:SpanData = box0.getSpan(axis);
			var obj1:SpanData = box1.getSpan(axis);

			if (obj0.min > (obj1.max + JConfig.collToll + JNumber3D.NUM_TINY) || obj1.min > (obj0.max + JConfig.collToll + JNumber3D.NUM_TINY))
			{
				out.flag = true;
				return true;
			}
			if ((obj0.max > obj1.max) && (obj1.min > obj0.min))
			{
				out.depth = Math.min(obj0.max - obj1.min, obj1.max - obj0.min);
			}
			else if ((obj1.max > obj0.max) && (obj0.min > obj1.min))
			{
				out.depth = Math.min(obj1.max - obj0.min, obj0.max - obj1.min);
			}
			else
			{
				out.depth = Math.min(obj0.max, obj1.max);
				out.depth -= Math.max(obj0.min, obj1.min);
			}
			out.flag = false;
			return false;
		}

		private function addPoint(contactPoints:Vector.<Vector3D>, pt:Vector3D, combinationDistanceSq:Number):Boolean
		{
			for each (var contactPoint:Vector3D in contactPoints)
			{
				if (contactPoint.subtract(pt).lengthSquared < combinationDistanceSq)
				{
					contactPoint = JNumber3D.divide(contactPoint.add(pt), 2);
					return false;
				}
			}
			contactPoints.push(pt);
			return true;
		}

		private function getBox2BoxEdgesIntersectionPoints(contactPoint:Vector.<Vector3D>, box0:JBox, box1:JBox, newState:Boolean):Number
		{
			var num:Number = 0;
			var seg:JSegment;
			var box0State:PhysicsState = (newState) ? box0.currentState : box0.oldState;
			var box1State:PhysicsState = (newState) ? box1.currentState : box1.oldState;
			var boxPts:Vector.<Vector3D> = box1.getCornerPoints(box1State);
			var boxEdges:Vector.<Object> = box1.edges;
			var outObj:Object;
			for each (var boxEdge:*in boxEdges)
			{
				outObj = {};
				seg = new JSegment(boxPts[boxEdge.ind0], boxPts[boxEdge.ind1].subtract(boxPts[boxEdge.ind0]));
				if (box0.segmentIntersect(outObj, seg, box0State))
				{
					if (addPoint(contactPoint, outObj.posOut, combinationDist))
					{
						num += 1;
					}
				}
			}
			return num;
		}

		private function getBoxBoxIntersectionPoints(contactPoint:Vector.<Vector3D>, box0:JBox, box1:JBox, newState:Boolean):uint
		{
			getBox2BoxEdgesIntersectionPoints(contactPoint, box0, box1, newState);
			getBox2BoxEdgesIntersectionPoints(contactPoint, box1, box0, newState);
			return contactPoint.length;
		}



		/*
		 * Original Author: Olivier renault
		 * http://uk.geocities.com/olivier_rebellion/
		 */
		private function getPointPointContacts(PA:Vector3D, PB:Vector3D, CA:Vector.<Vector3D>, CB:Vector.<Vector3D>):void
		{
			CA.push(PA.clone());
			CB.push(PB.clone());
		}

		private function getPointEdgeContacts(PA:Vector3D, PB0:Vector3D, PB1:Vector3D, CA:Vector.<Vector3D>, CB:Vector.<Vector3D>):void
		{
			var B0A:Vector3D = PA.subtract(PB0);
			var BD:Vector3D = PB1.subtract(PB0);

			var t:Number = JNumber3D.dot(B0A, BD) / JNumber3D.dot(BD, BD);
			if (t < 0)
			{
				t = 0;
			}
			else if (t > 1)
			{
				t = 1;
			}

			CA.push(PA.clone());
			CB.push(PB0.add(JNumber3D.multiply(BD, t)));
		}

		private function getPointFaceContacts(PA:Vector3D, BN:Vector3D, BD:Number, CA:Vector.<Vector3D>, CB:Vector.<Vector3D>):void
		{
			var dist:Number = JNumber3D.dot(PA, BN) - BD;

			addPoint(CA, PA.clone(), combinationDist);
			addPoint(CB, PA.subtract(JNumber3D.multiply(BN, dist)), combinationDist);
			//CA.push(PA.clone());
			//CB.push(PA.subtract(JNumber3D.multiply(BN, dist)));
		}

		private function getEdgeEdgeContacts(PA0:Vector3D, PA1:Vector3D, PB0:Vector3D, PB1:Vector3D, CA:Vector.<Vector3D>, CB:Vector.<Vector3D>):void
		{
			var AD:Vector3D = PA1.subtract(PA0);
			var BD:Vector3D = PB1.subtract(PB0);
			var N:Vector3D = JNumber3D.cross(BD, AD);
			var M:Vector3D = JNumber3D.cross(BD, N);
			var md:Number = JNumber3D.dot(M, PB0);
			var at:Number = (md - JNumber3D.dot(PA0, M)) / JNumber3D.dot(AD, M);
			if (at < 0)
			{
				at = 0;
			}
			else if (at > 1)
			{
				at = 1;
			}

			getPointEdgeContacts(PA0.add(JNumber3D.multiply(AD, at)), PB0, PB1, CA, CB);
		}

		private function getPolygonContacts(Clipper:Vector.<Vector3D>, Poly:Vector.<Vector3D>, CA:Vector.<Vector3D>, CB:Vector.<Vector3D>):void
		{
			if (!polygonClip(Clipper, Poly, CB))
			{
				return;
			}
			var ClipperNormal:Vector3D = JNumber3D.getNormal(Clipper[0], Clipper[1], Clipper[2]);
			var clipper_d:Number = JNumber3D.dot(Clipper[0], ClipperNormal);

			var temp:Vector.<Vector3D> = new Vector.<Vector3D>();
			for each (var cb:Vector3D in CB)
			{
				getPointFaceContacts(cb, ClipperNormal, clipper_d, temp, CA);
			}
		}

		private function polygonClip(axClipperVertices:Vector.<Vector3D>, axPolygonVertices:Vector.<Vector3D>, axClippedPolygon:Vector.<Vector3D>):Boolean
		{
			if (axClipperVertices.length <= 2)
			{
				return false;
			}
			var ClipperNormal:Vector3D = JNumber3D.getNormal(axClipperVertices[0], axClipperVertices[1], axClipperVertices[2]);

			var i:int = axClipperVertices.length - 1;
			var N:Vector3D;
			var D:Vector3D;
			var temp:Vector.<Vector3D> = axPolygonVertices.concat();
			var len:int = axClipperVertices.length;
			for (var ip1:int = 0; ip1 < len; i = ip1, ip1++)
			{
				D = axClipperVertices[ip1].subtract(axClipperVertices[i]);
				N = JNumber3D.cross(ClipperNormal, D);
				var dis:Number = JNumber3D.dot(axClipperVertices[i], N);

				if (!planeClip(temp, axClippedPolygon, N, dis))
				{
					return false;
				}
				temp = axClippedPolygon.concat();
			}
			return true;
		}

		private function planeClip(A:Vector.<Vector3D>, B:Vector.<Vector3D>, xPlaneNormal:Vector3D, planeD:Number):Boolean
		{
			var bBack:Vector.<Boolean> = new Vector.<Boolean>();
			var bBackVerts:Boolean = false;
			var bFrontVerts:Boolean = false;

			var side:Number;
			for (var s:String in A)
			{
				side = JNumber3D.dot(A[s], xPlaneNormal) - planeD;
				bBack[s] = (side < 0) ? true : false;
				bBackVerts = bBackVerts || bBack[s];
				bFrontVerts = bBackVerts || !bBack[s];
			}

			if (!bBackVerts)
			{
				return false;
			}
			if (!bFrontVerts)
			{
				for (s in A)
				{
					B[s] = A[s].clone();
				}
				return true;
			}

			var n:int = 0;
			var i:int = A.length - 1;
			var max:int = (A.length > 2) ? A.length : 1;
			for (var ip1:int = 0; ip1 < max; i = ip1, ip1++)
			{
				if (bBack[i])
				{
					if (n >= MAX_SUPPORT_VERTS)
					{
						return true;
					}
					B[n++] = A[i].clone();
				}

				if (int(bBack[ip1]) ^ int(bBack[i]))
				{
					if (n >= MAX_SUPPORT_VERTS)
					{
						return true;
					}
					var D:Vector3D = A[ip1].subtract(A[i]);
					var t:Number = (planeD - JNumber3D.dot(A[i], xPlaneNormal)) / JNumber3D.dot(D, xPlaneNormal);
					B[n++] = A[i].add(JNumber3D.multiply(D, t));
				}
			}

			return true;
		}

		override public function collDetect(info:CollDetectInfo, collArr:Vector.<CollisionInfo>):void
		{
			var box0:JBox = info.body0 as JBox;
			var box1:JBox = info.body1 as JBox;

			if (!box0.hitTestObject3D(box1))
			{
				return;
			}

			var dirs0Arr:Vector.<Vector3D> = box0.currentState.orientation.getCols();
			var dirs1Arr:Vector.<Vector3D> = box1.currentState.orientation.getCols();

			var axes:Vector.<Vector3D> = Vector.<Vector3D>([dirs0Arr[0], dirs0Arr[1], dirs0Arr[2],
				dirs1Arr[0], dirs1Arr[1], dirs1Arr[2],
				JNumber3D.cross(dirs1Arr[0], dirs0Arr[0]),
				JNumber3D.cross(dirs1Arr[0], dirs0Arr[1]),
				JNumber3D.cross(dirs1Arr[0], dirs0Arr[2]),
				JNumber3D.cross(dirs1Arr[1], dirs0Arr[0]),
				JNumber3D.cross(dirs1Arr[1], dirs0Arr[1]),
				JNumber3D.cross(dirs1Arr[1], dirs0Arr[2]),
				JNumber3D.cross(dirs1Arr[2], dirs0Arr[0]),
				JNumber3D.cross(dirs1Arr[2], dirs0Arr[1]),
				JNumber3D.cross(dirs1Arr[2], dirs0Arr[2])]);

			var l2:Number;
			var overlapDepths:Vector.<SpanData> = new Vector.<SpanData>();
			var i:uint = 0;
			for (i = 0; i < axes.length; i++)
			{
				var _overlapDepth:SpanData = overlapDepths[i] = new SpanData();
				_overlapDepth.depth = JNumber3D.NUM_HUGE;

				l2 = axes[i].lengthSquared;
				if (l2 < JNumber3D.NUM_TINY)
				{
					continue;
				}
				var ax:Vector3D = axes[i].clone();
				ax.normalize();
				if (disjoint(overlapDepths[i], ax, box0, box1))
				{
					return;
				}
			}

			var minDepth:Number = JNumber3D.NUM_HUGE;
			var minAxis:int = -1;

			for (i = 0; i < axes.length; i++)
			{
				l2 = axes[i].lengthSquared;
				if (l2 < JNumber3D.NUM_TINY)
				{
					continue;
				}

				if (overlapDepths[i].depth < minDepth)
				{
					minDepth = overlapDepths[i].depth;
					minAxis = int(i);
				}
			}
			if (minAxis == -1)
			{
				return;
			}
			var N:Vector3D = axes[minAxis].clone();
			if (JNumber3D.dot(box1.currentState.position.subtract(box0.currentState.position), N) > 0)
			{
				N = JNumber3D.multiply(N, -1);
			}
			N.normalize();

			if (JConfig.boxCollisionsType == "EDGEBASE")
			{
				boxEdgesCollDetect(info, collArr, box0, box1, N, minDepth);
			}
			else
			{
				boxSortCollDetect(info, collArr, box0, box1, N, minDepth);
			}
		}

		private function boxEdgesCollDetect(info:CollDetectInfo, collArr:Vector.<CollisionInfo>, box0:JBox, box1:JBox, N:Vector3D, depth:Number):void
		{
			var contactPointsFromOld:Boolean = true;
			var contactPoints:Vector.<Vector3D> = new Vector.<Vector3D>();
			combinationDist = 0.5 * Math.min(Math.min(box0.sideLengths.x, box0.sideLengths.y, box0.sideLengths.z), Math.min(box1.sideLengths.x, box1.sideLengths.y, box1.sideLengths.z));
			combinationDist *= combinationDist;

			if (depth > -JNumber3D.NUM_TINY)
			{
				getBoxBoxIntersectionPoints(contactPoints, box0, box1, false);
			}
			if (contactPoints.length == 0)
			{
				contactPointsFromOld = false;
				getBoxBoxIntersectionPoints(contactPoints, box0, box1, true);
			}

			var bodyDelta:Vector3D = box0.currentState.position.subtract(box0.oldState.position).subtract(box1.currentState.position.subtract(box1.oldState.position));
			var bodyDeltaLen:Number = JNumber3D.dot(bodyDelta, N);
			var oldDepth:Number = depth + bodyDeltaLen;

			var collPts:Vector.<CollPointInfo> = new Vector.<CollPointInfo>();
			if (contactPoints.length > 0)
			{
				var cpInfo:CollPointInfo;
				for each (var contactPoint:Vector3D in contactPoints)
				{
					if (contactPointsFromOld)
					{
						cpInfo = new CollPointInfo();
						cpInfo.r0 = contactPoint.subtract( box0.oldState.position);
						cpInfo.r1 = contactPoint.subtract( box1.oldState.position);
						cpInfo.initialPenetration = oldDepth;
						collPts.push(cpInfo);
					}
					else
					{
						cpInfo = new CollPointInfo();
						cpInfo.r0 = contactPoint.subtract( box0.currentState.position);
						cpInfo.r1 = contactPoint.subtract( box1.currentState.position);
						cpInfo.initialPenetration = oldDepth;
						collPts.push(cpInfo);
					}
				}

				var collInfo:CollisionInfo = new CollisionInfo();
				collInfo.objInfo = info;
				collInfo.dirToBody = N;
				collInfo.pointInfo = collPts;

				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = Math.sqrt(box0.material.restitution * box1.material.restitution);
				mat.friction = Math.sqrt(box0.material.friction * box1.material.friction);
				collInfo.mat = mat;
				collArr.push(collInfo);

				info.body0.collisions.push(collInfo);
				info.body1.collisions.push(collInfo);
			}
		}

		private function boxSortCollDetect(info:CollDetectInfo, collArr:Vector.<CollisionInfo>, box0:JBox, box1:JBox, N:Vector3D, depth:Number):void
		{
			var contactA:Vector.<Vector3D> = new Vector.<Vector3D>();
			var contactB:Vector.<Vector3D> = new Vector.<Vector3D>();
			var supportVertA:Vector.<Vector3D> = box0.getSupportVertices(N);
			var supportVertB:Vector.<Vector3D> = box1.getSupportVertices(JNumber3D.multiply(N, -1));
			var iNumVertsA:int = supportVertA.length;
			var iNumVertsB:int = supportVertB.length;

			combinationDist = 0.2 * Math.min(Math.min(box0.sideLengths.x, box0.sideLengths.y, box0.sideLengths.z), Math.min(box1.sideLengths.x, box1.sideLengths.y, box1.sideLengths.z));
			combinationDist *= combinationDist;

			if (iNumVertsA == 1)
			{
				if (iNumVertsB == 1)
				{
					//trace("++++ iNumVertsA=1::::iNumVertsB=1");
					getPointPointContacts(supportVertA[0], supportVertB[0], contactA, contactB);
				}
				else if (iNumVertsB == 2)
				{
					//trace("++++ iNumVertsA=1::::iNumVertsB=2");
					getPointEdgeContacts(supportVertA[0], supportVertB[0], supportVertB[1], contactA, contactB);
				}
				else
				{
					//trace("++++ iNumVertsA=1::::iNumVertsB=4");
					var BN:Vector3D = JNumber3D.getNormal(supportVertB[0], supportVertB[1], supportVertB[2]);
					var BD:Number = JNumber3D.dot(BN, supportVertB[0]);
					getPointFaceContacts(supportVertA[0], BN, BD, contactA, contactB);
				}
			}
			else if (iNumVertsA == 2)
			{
				if (iNumVertsB == 1)
				{
					//trace("++++ iNumVertsA=2::::iNumVertsB=1");
					getPointEdgeContacts(supportVertB[0], supportVertA[0], supportVertA[1], contactB, contactA);
				}
				else if (iNumVertsB == 2)
				{
					//trace("++++ iNumVertsA=2::::iNumVertsB=2");
					getEdgeEdgeContacts(supportVertA[0], supportVertA[1], supportVertB[0], supportVertB[1], contactA, contactB);
				}
				else
				{
					//trace("++++ iNumVertsA=2::::iNumVertsB=4");
					getPolygonContacts(supportVertB, supportVertA, contactB, contactA);
				}
			}
			else
			{
				if (iNumVertsB == 1)
				{
					//trace("++++ iNumVertsA=4::::iNumVertsB=1");
					BN = JNumber3D.getNormal(supportVertA[0], supportVertA[1], supportVertA[2]);
					BD = JNumber3D.dot(BN, supportVertA[0]);
					getPointFaceContacts(supportVertB[0], BN, BD, contactB, contactA);
				}
				else
				{
					//trace("++++ iNumVertsA=4::::iNumVertsB=4");
					getPolygonContacts(supportVertA, supportVertB, contactA, contactB);
				}
			}
			if (contactB.length > contactA.length)
			{
				contactA = contactB;
			}
			if (contactA.length > contactB.length)
			{
				contactB = contactA;
			}

			var cpInfo:CollPointInfo;
			var collPts:Vector.<CollPointInfo> = new Vector.<CollPointInfo>();
			if (contactA.length > 0 && contactB.length > 0)
			{
				var num:int = (contactA.length > contactB.length) ? contactB.length : contactA.length;
				for (var j:int = 0; j < num; j++)
				{
					cpInfo = new CollPointInfo();
					cpInfo.r0 = contactA[j].subtract(box0.currentState.position);
					cpInfo.r1 = contactB[j].subtract(box1.currentState.position);
					cpInfo.initialPenetration = depth;
					collPts.push(cpInfo);
				}
			}
			else
			{
				cpInfo = new CollPointInfo();
				cpInfo.r0 = new JNumber3D();
				cpInfo.r1 = new JNumber3D();
				cpInfo.initialPenetration = depth;
				collPts.push(cpInfo);
			}

			var collInfo:CollisionInfo = new CollisionInfo();
			collInfo.objInfo = info;
			collInfo.dirToBody = N;
			collInfo.pointInfo = collPts;

			var mat:MaterialProperties = new MaterialProperties();
			mat.restitution = Math.sqrt(box0.material.restitution * box1.material.restitution);
			mat.friction = Math.sqrt(box0.material.friction * box1.material.friction);
			collInfo.mat = mat;
			collArr.push(collInfo);

			info.body0.collisions.push(collInfo);
			info.body1.collisions.push(collInfo);
		}
	}
}