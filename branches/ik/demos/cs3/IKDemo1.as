package {
	
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	
	//Away3D
	import away3d.animators.SkinAnimation;
	import away3d.animators.skin.Bone;
	import away3d.animators.skin.IKChain;
	//
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	import away3d.events.LoaderEvent;
	import away3d.loaders.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	//tweener
	import caurina.transitions.*;
	import caurina.transitions.properties.DisplayShortcuts;
	DisplayShortcuts.init();
	
	public class IKDemo1 extends Sprite
	{
		private var view:View3D;
		private var headTarget:Sphere;
		private var tailTarget:Sphere;
		private var targetPos:Sphere;
		private var loader:Object3DLoader;
		private var effector:Bone;
		private var effectorTail:Bone;
		private var skinAnimation:SkinAnimation;
		private var neckChain:IKChain;
		private var tailChain:IKChain;
		private var animateRoot:Boolean=true;
		private var mouseIsDown:Boolean = false;
		private var targetGoto:Number3D = new Number3D;
		private var time:int = 0;
		
		private var sw:Number = 800;
		private var sh:Number = 450;
		
		private var playingBw:Boolean=false;
		
		public function IKDemo1()
		{
			
			away3dcreate();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
		}
	
		
		private function away3dcreate():void 
		{
			addChild(view=new View3D({x:sw, y:sh})); 
			//swapChildren(view, infoBox);
			//swapChildren(sig, infoBox);
			
			view.x-=sw/2;
			view.y-=sh/2;
			
			headTarget = new Sphere({material:"red#", name:"sphere", x: 0, y:-3000, z: 12000, radius:500, segmentsW:2, segmentsH:2});
			tailTarget = new Sphere({material:"red#", name:"sphere", x: 0, y:-300, z: -800, radius:5, segmentsW:2, segmentsH:2});
			
			var bodyBMD:bodybmp = new bodybmp(0, 0);
			var legsBMD:legsbmp = new legsbmp(0, 0);
			var head4BMD:head4bmp = new head4bmp(0, 0);
			
			loader=Collada.load("assets/model/dragon.DAE", { materials:{	Material__8:{bitmap:bodyBMD}, 
																			Material__9:{bitmap:legsBMD},
																			Material__3:{bitmap:head4BMD}}});
			loader.addOnSuccess(finishedLoading);
			view.scene.addChild(loader);

		}
		
		private function finishedLoading(e:LoaderEvent):void
		{
			
			loader.handle.scale(.0999);
			
		//create a reference to the keyframed animations
			skinAnimation = loader.handle.animationLibrary.getAnimation("default").animation as SkinAnimation;
			
		//create an IKChain for the neck and head
			//the first argument is a function of the distance between the joints and and depends on your application so should
			//be determined through trial and error.  Too big and the animation will oscillate out of control.  Too
			//small and the solver will take forever to find a solution.  The second argument is optional.
			neckChain = new IKChain(0.0003, skinAnimation);
			//define the joints and set their degrees of freedom
			neckChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone4"), false, true, false);
			neckChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone5"), false, false, true);
			neckChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone2"), false, true, false);
			//the effector is what the IKChain tries to position on the target
			effector=(loader.handle as ObjectContainer3D).getBoneByName("Bone3");
			neckChain.defineEffector(effector);
		
		//create an IKChain for the tail
			tailChain = new IKChain(0.0001);
			tailChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone12"), false, false, true);
			tailChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone13"), true, true, true);
			tailChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone14"), true, true, true);
			tailChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone15"), true, true, true);
			effectorTail=(loader.handle as ObjectContainer3D).getBoneByName("Bone16");
			tailChain.defineEffector(effectorTail);
		
		//tween the dragon model in dramatically =p
			(loader.handle as ObjectContainer3D).y=-1000;
			Tweener.addTween((loader.handle as ObjectContainer3D), {y:0, time:5});
		
		//position the camera
			tweenCamera();
			addEventListener(Event.ENTER_FRAME,away3dloop);
			
			 
		}
		
		private function away3dloop(event:Event):void 
		{
			if(mouseIsDown)
				tweenTarget();
			
			//update the chain based on the position of the target
			if(!playingBw)
				neckChain.updateIKChain(headTarget.position);
			else
				tailChain.updateIKChain(tailTarget.position);
					
			if(animateRoot)
			{
				time++;
				skinAnimation.update(time/30);
				if(time==59)
					time=0;
			}
			view.render();
		}
		
		private function tweenTarget():void
		{
			
			headTarget.z = 17000;
			if(playingBw)
				targetGoto.x = (mouseX-sw/2)<<6;
			else
				targetGoto.x = -(mouseX-sw/2)<<6;
				
			targetGoto.y = (300-mouseY)<<7;
			
			headTarget.x = targetGoto.x;
			headTarget.y = targetGoto.y;
			
			tailTarget.z = -29500;
			tailTarget.x = targetGoto.x<<1;
			tailTarget.y = targetGoto.y<<1;
			
		}
		
		private function tweenCamera():void
		{
			
			view.camera.moveTo(loader.x, loader.y+75, loader.z);
			
			
			if(!playingBw)
			{
				view.camera.rotationY=180;
				view.camera.rotationX=-17;
			}
			else
			{
				view.camera.rotationX=17;
				view.camera.rotationY=0;
			}
			view.camera.moveBackward(500);
			trace(playingBw);
			
		}
		
		private function handleMouseDown(e:Event):void
		{
			mouseIsDown=true;
		}
		
		private function handleMouseUp(e:Event):void
		{
			mouseIsDown=false;
		}
		
		
		private function handleKeyDown(e:KeyboardEvent):void
		{

			switch(e.keyCode)
			{
				
				case 83:
					playingBw=false;
					tweenCamera();
					animateRoot=!animateRoot;
					break;
					
				case 32:
					if(animateRoot)
						return;
					playingBw=!playingBw;
					
					var mesh:Mesh = (loader.handle as ObjectContainer3D).getChildByName("Dragon-node") as Mesh;
					if(playingBw)
						mesh.bothsides=true;
					else
						mesh.bothsides=false;
					tweenCamera();
					
					break;
					
			}
		}
	}
}
