package away3d.core.physics
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.physics.*;

    import flash.geom.*;

    public class CollisionTraverser extends Traverser
    {
		private var i:Number;
		//private var constraint:Constraint;
		
        public function CollisionTraverser()
        {
        }
        
        public override function match(node:Object3D):Boolean
        {
        	return (!node.immovable && node.active);
        }
        
		public override function apply(node:Object3D):void
        {
        	i = 0;
        	var iterations:int = node.iterations;
        	while(i < iterations){      		
        		//for each (constraint in node.constraints)
        		//	constraint.solve();
        		if (node.innerCollisions)
        			CollisionDetection.findInnerCollisions(node);
				i++;
			}
        }
        
    }
}
