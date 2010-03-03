package away3d.core.graphs.bsp
{
	import away3d.core.graphs.VectorIterator;
	import away3d.events.IteratorEvent;

	// decorator for IBSPPortalProvider
	internal class BSPCollisionPlaneBuilder extends AbstractBuilderDecorator implements IBSPPortalProvider
	{
		private var _index : int;
		private var _iterator : VectorIterator;

		public function BSPCollisionPlaneBuilder(wrapped : IBSPPortalProvider)
		{
			super(wrapped, 1);
			setProgressMessage("Building collision beveling planes");
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
			_iterator.performMethodAsync(buildBevelPlanes, maxTimeOut);
		}

		private function buildBevelPlanes(portal : BSPPortal) : void
		{
			if (canceled) {
				notifyCanceled();
				return;
			}
			++_index;
			portal.backNode.generateBevelPlanes(portal.frontNode);
			portal.frontNode.generateBevelPlanes(portal.backNode);
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