package away3d.animators.skin
{
	import away3d.animators.SkinAnimation;
	import away3d.animators.skin.Bone;
	import away3d.core.math.Number3D;
	
	/**
    * Defines an inverse kinematics chain
	* author:  Nathaniel Warner
    */
	public class IKChain
	{
		private var _jointArray:Array = new Array();
		private var _jacColArray:Array = new Array();
		private var _dTheta:Array = new Array();
		private var _damp:Number;
		private var _jColAng:Number3D = new Number3D();
		
		private var _effector:Bone;
		private var _error:Number3D = new Number3D();
		private var _worldRotationX:Number3D = new Number3D();
		private var _worldRotationY:Number3D = new Number3D();
		private var _worldRotationZ:Number3D = new Number3D();
		
		private var _skinAnimation:SkinAnimation;
	
		public function IKChain(damp:Number = 0.01, skinAnimation:SkinAnimation = null)
		{
			_damp = damp;
			_skinAnimation = skinAnimation;
		}
		
		/**
		 * Declares an existing bone object as part of an IKChain
		 * 
		 * @param	bone	The bone object that you want to be part of your IKChain
		 * @param	hasXDOF	allow the bone to rotate on it's x axis
		 * @param	hasYDOF	allow the bone to rotate on it's y axis
		 * @param	hasZDOF	allow the bone to rotate on it's z axis
		 */
		public function defineJoint( bone:Bone, hasXDOF:Boolean=true, hasYDOF:Boolean=false, hasZDOF:Boolean=false):void
		{
			bone.joint.xDOF = hasXDOF;
			bone.joint.yDOF = hasYDOF;
			bone.joint.zDOF = hasZDOF;
			
			_jointArray.push(bone);
			
			if(!_skinAnimation)
				return;
			_skinAnimation.setInteractive(bone.name);
		}
		
		/**
		 * Declares an existing bone object as the effector of your IKChain
		 * An effector is what the IKChain tries to place in the same 
		 * position ( and eventually orientation) as your target
		 *
		 * @param	bone	The bone object that you want to be the effector
		 */
		public function defineEffector(bone:Bone):void
		{
			_effector = bone;
		}
		
		/**
		 * Updates your chain based on the position of your target
		 *
		 * @param	target	The position that you wish the IKChain's effector to be located
		 */
		public function updateIKChain(target:Number3D):void
		{
			_error.sub( new Number3D(_effector.scenePosition.x, _effector.scenePosition.y, _effector.scenePosition.z), target);
			
			calculateJacobian();
			calculateAngles(target);
			updateJoints();
		}
		
		//not used for now
		private function calculateWorldAxis(v:Number3D, joint:Bone ):Number3D
		{
			var vx:Number = v.x;
			var vy:Number = v.y;
			var vz:Number = v.z;
			
			v.x = vx * joint.transform.sxx + vy * joint.transform.sxy + vz * joint.transform.sxz;
			v.y = vx * joint.transform.syx + vy * joint.transform.syy + vz * joint.transform.syz;
			v.z = vx * joint.transform.szx + vy * joint.transform.szy + vz * joint.transform.szz;
			
			v.normalize();
			return v;
		}
		
		/**
		 * Most of the math happens here.  A 'jacobian' describes the relationship between
		 * the angles of the joints and the position of the effector
		 *
		 */
		private function calculateJacobian():void
		{
			
			var jC1:Number3D 	= new Number3D();
			var jC2:Number3D 	= new Number3D();
			var jC3:Number3D 	= new Number3D();
			
			for each (var ikJoint:Bone in _jointArray)
			{

				var effPivVector:Number3D = new Number3D();
				effPivVector.sub(_effector.scenePosition, ikJoint.scenePosition );
				
				if(ikJoint.joint.xDOF)
				{
					_worldRotationX.x = ikJoint.joint.sceneTransform.sxx;
					_worldRotationX.y = ikJoint.joint.sceneTransform.syx;
					_worldRotationX.z = ikJoint.joint.sceneTransform.szx;
					jC1.cross( _worldRotationX, effPivVector);
					_jacColArray.push(jC1);
				}
				
				if(ikJoint.joint.yDOF)
				{
					_worldRotationY.x = ikJoint.joint.sceneTransform.sxy;
					_worldRotationY.y = ikJoint.joint.sceneTransform.syy;
					_worldRotationY.z = ikJoint.joint.sceneTransform.szy;
					jC2.cross( _worldRotationY, effPivVector);
					_jacColArray.push(jC2);
					
				}
				
				if(ikJoint.joint.zDOF)
				{
					_worldRotationZ.x = ikJoint.joint.sceneTransform.sxz;
					_worldRotationZ.y = ikJoint.joint.sceneTransform.syz;
					_worldRotationZ.z = ikJoint.joint.sceneTransform.szz;
					jC3.cross( _worldRotationZ, effPivVector);
					_jacColArray.push(jC3);
					
				}
			}
		}
		
		/**
		 * The rest of the math happens here.  A 'jacobian' describes the relationship between
		 * the angles of the joints and the position of the effector and if you multiply the 
		 * appropriate column of jacobian by the difference between the target and the current
		 * location of the effector then you get an angle that when applied to the joint
		 * moves the effector closer to the target.
		 *
		 */
		private function calculateAngles(target:Number3D):void
		{
			while(_jacColArray.length)
			{
				_jColAng = _jacColArray.pop();
				
				if(_jColAng.modulo>1)
					_jColAng.normalize();
				
				_dTheta.push((_error.dot(_jColAng)*_damp));
			}
			
		}
		
		/**
		 * 
		 *
		 */
		private function updateJoints():void
		{
			
			for each (var ikJoint:Bone in _jointArray)
			{
				
				if(ikJoint.joint.xDOF)
				{
					var dXRot:Number = _dTheta.pop();
					
					if(dXRot)
					{
						ikJoint.joint.pitch(dXRot);
					}
				}
				
				if(ikJoint.joint.yDOF)
				{
					var dYRot:Number = _dTheta.pop();
					if(dYRot)
					{
						ikJoint.joint.yaw(dYRot);
					}
				}
				
				if(ikJoint.joint.zDOF)
				{
					var dZRot:Number = _dTheta.pop();
					if(dZRot)
					{
						ikJoint.joint.roll(dZRot);
					}
				}
			}
		}
	}
}

