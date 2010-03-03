package away3d.graphs.bsp.builder
{
	import away3d.graphs.bsp.*;
	import away3d.graphs.VectorIterator;
	import away3d.events.IteratorEvent;
	import away3d.graphs.bsp.builder.AbstractBuilderDecorator;
	import away3d.graphs.bsp.builder.IBSPPortalProvider;

	// decorator for IBSPPortalProvider
	internal class BSPTJunctionFixer extends AbstractBuilderDecorator implements IBSPPortalProvider
	{
		private var _index : int;
		private var _iterator : VectorIterator;

		public function BSPTJunctionFixer(wrapped : IBSPPortalProvider)
		{
			super(wrapped, 1);
			setProgressMessage("Fixing T-Junctions");
		}

		override public function destroy() : void
		{
			
		}
		
		public function get portals() : Vector.<BSPPortal>
		{
			return IBSPPortalProvider(wrapped).portals;
		}

		override protected function buildPart() : void
		{
			_iterator = new VectorIterator(Vector.<Object>(portals));
			_iterator.addEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onIterationComplete);
			_iterator.addEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onIterationTick);
			_iterator.performMethodAsync(fixTJunctionStep, maxTimeOut);
		}

		private function fixTJunctionStep(portal : BSPPortal) : void
		{
			if (canceled) {
				notifyCanceled();
				return;
			}

			++_index;
			portal.backNode.removeTJunctions(portal.frontNode, portal);
			portal.frontNode.removeTJunctions(portal.backNode, portal);
		}

		private function onIterationComplete(event : IteratorEvent) : void
		{
			_iterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onIterationComplete);
			_iterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onIterationTick);
			notifyComplete();
		}

		private function onIterationTick(event : IteratorEvent) : void
		{
			notifyProgress(_index, portals.length);
		}
	}
}