package away3d.graphs.bsp
{
	import away3d.arcane;
	import away3d.graphs.TreeIterator;
	import away3d.graphs.VectorIterator;
	import away3d.events.BSPBuildEvent;
	import away3d.events.IteratorEvent;

	import flash.utils.setTimeout;

	use namespace arcane;

	internal class BSPPortalBuilder extends AbstractBuilderDecorator implements IBSPPortalProvider
	{
		private var _portals : Vector.<BSPPortal>;
		private var _portalsSwitch : Vector.<BSPPortal>;
		private var _treeIterator : TreeIterator;
		private var _portalIterator : VectorIterator;
		private var _index : int;
		private var _pushIndex : int;

		public function BSPPortalBuilder(wrapped : IBSPBuilder)
		{
			super(wrapped, 2);
		}

		public function get portals() : Vector.<BSPPortal>
		{
			return _portals;
		}

		override public function destroy() : void
		{
			_portals = null;
			_portalIterator = null;
			_portalsSwitch = null;
			// to do: loop through leaves, removing all portals
		}

		// build initial portals first
		override protected function buildPart() : void
		{
			_portals = new Vector.<BSPPortal>();

			setProgressMessage("Building Portals");

			_index = 0;
			_treeIterator = new TreeIterator(rootNode);
			_treeIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onBuildPortalsComplete);
			_treeIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onBuildPortalsTick);
			_treeIterator.performMethodAsync(createPortalStep, maxTimeOut);
		}

		private function createPortalStep(node : BSPNode) : void
		{
			var portals : Vector.<BSPPortal> = node.generatePortals(rootNode);
			
			++_index;

			if (portals)
				_portals = _portals.concat(portals);
		}

		private function onBuildPortalsTick(event : IteratorEvent) : void
		{
			notifyProgress(_index, numNodes);
		}

		private function onBuildPortalsComplete(event : IteratorEvent) : void
		{
			_treeIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onBuildPortalsComplete);
			_treeIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onBuildPortalsTick);

			setTimeout(removeOneSided, 1);
		}

		private function removeOneSided() : void
		{
			_index = 0;
			_pushIndex = -1;
			_portalsSwitch = new Vector.<BSPPortal>();

			setProgressMessage("Removing one-sided portals");
			updateNextStep();
			
			_portalIterator = new VectorIterator(Vector.<Object>(_portals));
			_portalIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onRemoveOneSidedComplete);
			_portalIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onRemoveOneSidedTick);
			_portalIterator.performMethodAsync(removeOneSidedStep, maxTimeOut);
		}

		private function removeOneSidedStep(portal : BSPPortal) : void
		{
			var front : BSPNode = portal.frontNode;
			var back : BSPNode = portal.backNode;

			++_index;
			if (front && back && front.isLeaf && back.isLeaf) {
				_portalsSwitch[++_pushIndex] = portal;
			}
		}

		private function onRemoveOneSidedTick(event : IteratorEvent) : void
		{
			notifyProgress(_index, portals.length);
		}

		private function onRemoveOneSidedComplete(event : IteratorEvent) : void
		{
			_portalIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onRemoveOneSidedComplete);
			_portalIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onRemoveOneSidedTick);
			_portals = _portalsSwitch;
			_portalsSwitch = null;
			notifyComplete();
		}
	}
}