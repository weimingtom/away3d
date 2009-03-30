package {
	
	import away3d.animators.SkinAnimation;
	import away3d.animators.skin.Bone;
	import away3d.animators.skin.IKChain;
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
	import org.flintparticles.threeD.away3d.Away3DRenderer;
	import org.flintparticles.threeD.emitters.Emitter3D;	
	import emitters.*;
	import org.flintparticles.threeD.actions.*;
	import org.flintparticles.threeD.activities.*;
	import org.flintparticles.threeD.geom.*;
	import org.flintparticles.threeD.initializers.*;
	import org.flintparticles.threeD.zones.*;	
	import caurina.transitions.*;
	import caurina.transitions.properties.DisplayShortcuts;
	DisplayShortcuts.init();
	
	//import FlintFireSmoke.Flint_FireSmoke;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	public class IKApp1 extends Sprite
	{
		private var view:View3D;
		private var target:Sphere;
		private var tailTarget:Sphere;
		private var targetPos:Sphere;
		private var loader:Object3DLoader;
		private var boneTest:Bone;
		private var boneTest2:Bone;
		private var effector:Bone;
		private var effectorTail:Bone;
		private var o3DBip01:Object3D;
		private var skinAnimation:SkinAnimation;
		private var testChain:IKChain;
		private var tailChain:IKChain;
		private var animateRoot:Boolean=true;
		private var magnitude:Number=0;
		private var mouseIsDown:Boolean = false;
		private var targetGoto:Number3D = new Number3D;
		//private var fireball:Flint_FireSmoke;
		private var smoke:Emitter3D;
		private var fire:Emitter3D;
		private var renderer:Away3DRenderer;
		private var jaw:Bone;
		private var animateFlame:Boolean = false;
		private var sw:Number = 800;
		private var sh:Number = 450;
		private var dir:Vector3D;
		private var playingBw:Boolean=false;
		
		public function IKApp1()
		{
			stage.frameRate=30;
			
			away3dcreate();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
		}
	
		
		private function away3dcreate():void 
		{
			addChild(view=new View3D({x:sw, y:sh})); 
			swapChildren(view, infoBox);
			swapChildren(sig, infoBox);
			
			view.x-=sw/2;
			view.y-=sh/2;
			target = new Sphere({material:"red#", name:"sphere", x: 0, y:-3000, z: 12000, radius:500, segmentsW:2, segmentsH:2});
			tailTarget = new Sphere({material:"red#", name:"sphere", x: 0, y:-300, z: -800, radius:5, segmentsW:2, segmentsH:2});
			//target = new Sphere({material:"black#", name:"targetPos", x: 0, y:30, z: 0, radius:100, segmentsW:5, segmentsH:5});
			var bodyBMD:bodybmp = new bodybmp(0, 0);
			var legsBMD:legsbmp = new legsbmp(0, 0);
			var head4BMD:head4bmp = new head4bmp(0, 0);
			var cTransform:ColorTransform = new ColorTransform();
			
			cTransform.blueMultiplier=1.15;
			cTransform.redMultiplier=.8;
			cTransform.greenMultiplier=.8;
			//videoBG.filters=[new GlowFilter()];
			
			bodyBMD.colorTransform(new Rectangle(0,0, 4000, 4000),cTransform);
			legsBMD.colorTransform(new Rectangle(0,0, 4000, 4000),cTransform);
			head4BMD.colorTransform(new Rectangle(0,0, 40000, 40000),cTransform);
			
			loader=Collada.load("model/dragon.DAE", { materials:{	Material__8:{bitmap:bodyBMD}, 
																	Material__9:{bitmap:legsBMD},
																	Material__3:{bitmap:head4BMD}}});
			//loader.handle.children[0].bothSides=true;
			//(loader.handle as Mesh).bothsides=true;
			 
			
			//loader.y+=1000;
			//loader.rotationY+=180;
			loader.addOnSuccess(finishedLoading);
			//view.scene.addChild(tailTarget);
			view.scene.addChild(loader);
			//fireball = new Flint_FireSmoke(stage);
			//addChild(fireball);
			//fireball.x=target.x;
			//fireball.y=target.y;
			//fireball.z=target.z
			
		}
		
		private function finishedLoading(e:LoaderEvent):void
		{
			trace("finishedLoading");
			skinAnimation = loader.handle.animationLibrary.getAnimation("default").animation as SkinAnimation;
			//var mesh:Mesh = (loader.handle as ObjectContainer3D).getChildByName("Dragon-node") as Mesh;
			//mesh.bothsides=true;
			loader.handle.scale(.0999);
			//(loader.handle as ObjectContainer3D).ownCanvas=true;
			//(loader.handle as ObjectContainer3D).blendMode=BlendMode.HARDLIGHT;
			//bone1=chest
			//bone2=head
			//bone3=jaw
			//bone4=lowerneck
			//bone5=upperneck
			//boneTest=(loader.handle as ObjectContainer3D).getBoneByName("Bone-chest-node");
			//boneTest2=(loader.handle as ObjectContainer3D).getBoneByName("Bone5");
			effector=(loader.handle as ObjectContainer3D).getBoneByName("Bone3");
			effectorTail=(loader.handle as ObjectContainer3D).getBoneByName("Bone16");
			//jaw = (loader.handle as ObjectContainer3D).getBoneByName("Bone6");
			
			testChain = new IKChain(0.0003, view, skinAnimation);
			//testChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone1"), false, false, true);
			testChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone4"), false, true, false);
			testChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone5"), false, false, true);
			testChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone2"), false, true, false);
			testChain.defineEffector(effector);
			
			tailChain = new IKChain(0.0001, view);
			//testChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone1"), false, false, true);
			tailChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone12"), false, false, true);
			tailChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone13"), true, true, true);
			tailChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone14"), true, true, true);
			tailChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone15"), true, true, true);
			//tailChain.defineJoint((loader.handle as ObjectContainer3D).getBoneByName("Bone16"), false, true, false);
			tailChain.defineEffector(effectorTail);
			
			(loader.handle as ObjectContainer3D).y=-1000;
			Tweener.addTween((loader.handle as ObjectContainer3D), {y:0, time:5});
			fire = new Fire(stage);
			tweenCamera();
			addEventListener(Event.ENTER_FRAME,away3dloop);
			
			 
		}
		var time:int = 0;
		private function away3dloop(event:Event):void 
		{
			if(mouseIsDown)
				tweenTarget();
			//else
				//tweenCamera();
			
			
			//boneTest.rotationY++;
			//boneTest2.rotationY++;
			//trace(boneTest.name)
			//if(animateFlame)
			//{
				//fire.position.x = effector.scenePosition.x*.0999+dir.x*4;
				//fire.position.y = effector.scenePosition.y*.0999+dir.y*4;
				//fire.position.z = effector.scenePosition.z*.0999+dir.z*4;
				
				
				
			//}
			
			if(!animateFlame)
			{
				if(!playingBw)
					testChain.updateIKChain(target.position);
				else
					tailChain.updateIKChain(tailTarget.position);
			}
			if(animateRoot)
			{
				time++;
				skinAnimation.update(time/30);
				if(time==59)
				{
					var mesh:Mesh = (loader.handle as ObjectContainer3D).getChildByName("Dragon-node") as Mesh;
					mesh.bothsides=false;
					time=0;
					//createStreak();
				}
			}
				
			//}
			view.render();
		}
		
		private function createStreak():void
		{
			//trace("---------------z"+view.camera.z)
			var model:ObjectContainer3D = (loader.handle as ObjectContainer3D);
			var streak:LineSegment = new LineSegment({ edge:30, color:0x0000FF, width:200});
			streak.ownCanvas=true;
			streak.alpha=.5;
			streak.start = new Vertex(Math.random()*100+model.x, Math.random()*100+model.y, view.camera.z-50);
			//streak.rotationX-=65;
			streak.end = new Vertex( Math.random()*100+model.x, Math.random()*100+model.y, view.camera.z);
			view.scene.addChild(streak);
			Tweener.addTween(streak, {z: model.z-9700, time: 5, y:-3000,transition:"linear", onComplete:cleanUpStreak, onCompleteParams:[streak]});
			
		}
		
		private function cleanUpStreak( s:LineSegment):void
		{
			trace("cleaned");
			view.scene.removeChild(s);
		}
		
		private function tweenTarget():void
		{
			
			target.z = 17000;
			if(playingBw)
				targetGoto.x = (mouseX-sw/2)<<6;
			else
				targetGoto.x = -(mouseX-sw/2)<<6;
				
			targetGoto.y = (300-mouseY)<<7;
			
			target.x = targetGoto.x;
			target.y = targetGoto.y;
			
			tailTarget.z = -29500;
			//trace(view.camera.z);
			//trace(loader.handle.z)
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
		
		private function stopFlame():void
		{
			//fire.stop();
			//fire.counter._rate=0;
			Tweener.addTween(effector, {rotationY:0, time:2});
			animateFlame=!animateFlame;
		}
		
		private function startFlame():void
		{
			dir = new Vector3D( target.scenePosition.x-effector.scenePosition.x, 
								target.scenePosition.y-effector.scenePosition.y, 
								target.scenePosition.z-effector.scenePosition.z);
			dir.normalize();
			//dir.scaleBy(2);
			//fire.addAction( new Accelerate( dir ) );
			//trace(effector.scenePosition.z);
			
			var scaleV:Number=15;
			var scaleA:Number=-25;
			fire.addInitializer( new Velocity( new ConeZone( new Vector3D( 0, 0, 0 ), new Vector3D( scaleV*dir.x, scaleV*dir.y, scaleV*dir.z ), Math.PI/30, 150, 120 ) ) );
			fire.addAction( new Accelerate( new Vector3D( scaleA*dir.x, scaleA*dir.y, scaleA*dir.z ) ) );
			fire.addInitializer( new RotateVelocity( dir, 10, 2000 ) );
			fire.addAction(new Rotate());
			fire.addInitializer( new Position( new DiscZone( new Vector3D( 0, 0, 0 ), new Vector3D( 0, 1, 0 ), 3 ) ) );
			//fire.addAction( new RotateToDirection() );
			fire.position.x = effector.scenePosition.x*.0999+dir.x*3;
			fire.position.y = effector.scenePosition.y*.0999+dir.y*3;
			fire.position.z = effector.scenePosition.z*.0999+dir.z*3;
			
			fire.start();
			
			renderer = new Away3DRenderer(view.scene);
			renderer.addEmitter(fire);
		}
		
		private function changeView():void
		{
			var model:ObjectContainer3D = (loader.handle as ObjectContainer3D);
			Tweener.addTween(model, { y:-3000, time:5, transition:"easeInExpo", onComplete:reverseScene});
			Tweener.addTween(videoBG, { _frame:videoBG.currentFrame+200, time:4, transition:"easeInSin"});
		}
		
		private function reverseScene():void
		{
			
			playingBw=!playingBw;
			tweenCamera();
			var model:ObjectContainer3D = (loader.handle as ObjectContainer3D);
			Tweener.addTween(model, { y:0, time:5});
		}
		
		private function handleKeyDown(e:KeyboardEvent):void
		{
			var dis:Number = 700;
			trace(e.keyCode);
			switch(e.keyCode)
			{
				
				case 83:
					playingBw=false;
					tweenCamera();
					animateRoot=!animateRoot;
					if(animateRoot)
						videoBG.play();
					else
						videoBG.stop();
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
					//changeView();
					//I had to take the flame out for now.  IT's just to CPU intensiveß
					
					//animateFlame=!animateFlame;
					//if(animateFlame)
					//{
						//Tweener.addTween(effector, {rotationY:40, time:0.5});
						//Tweener.addTween(effector, {delay:1.8, onComplete:stopFlame});
						//startFlame();
					//}
					//else
					//{
						//Tweener.addTween(effector, {rotationY:0, time:2});
						//stopFlame();
					//}
						
					
					break;
					
			}
		}
	}
}
