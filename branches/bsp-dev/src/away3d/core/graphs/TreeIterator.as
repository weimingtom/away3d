package away3d.core.graphs
{
	import away3d.arcane;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	use namespace arcane;

	public class TreeIterator extends EventDispatcher
	{
		private var _traverseNode : ITreeNode;
		private var _traverseState : int;

		private static const TRAVERSE_PRE : int = 0;
		private static const TRAVERSE_IN : int = 1;
		private static const TRAVERSE_POST : int = 2;

		private var _rootNode : ITreeNode;

		private var _asyncInProgress : Boolean;
		private var _maxTimeOut : Number;
		private var _asyncMethod : Function;
		private var _callBack : Function;
		private var _canceled : Boolean;

		public function TreeIterator(rootNode : ITreeNode)
		{
			_rootNode = rootNode;
		}

		/**
		 * Resets the traversal for the tree.
		 *
		 * @return The root node of the tree, where traversal begins
		 */
		public function startTraverse() : ITreeNode
		{
			if (_asyncInProgress)
				throw new Error("Cannot reset traversal while an asynchronous iteration is in progress!");
			
			_traverseState = TRAVERSE_PRE;
			_traverseNode = _rootNode;
			return _traverseNode;
		}

		/**
		 * Traverses through the tree and returns the first newly encountered node. The order does not depend on camera position etc.
		 *
		 * @return The next unvisited node in the tree.
		 */
		public function traverseNext() : ITreeNode
		{
			if (_asyncInProgress)
				throw new Error("Cannot traverse through a tree while an asynchronous iteration is in progress!");
			
			return traverseStep();
		}

		/**
		 * Traverses through the tree and applies the supplied function to each node
		 * @param function The function to be applied to each node. It must have the following signature: function someFunction(node : ITreeNode) : void.
		 */
		public function performMethod(method : Function) : void
		{
			var node : ITreeNode;

			if (_asyncInProgress)
				throw new Error("An asynchronous iteration is already in progress!");

			node = startTraverse();

			do {
				method(node);
			} while (node = traverseStep())
		}

		/**
		 * Traverses through the tree and applies the supplied function to each node in the tree asynchronously.
		 * The TreeIterator instance will dispatch Event.COMPLETE when done.
		 * @param method The function to be applied to each node. It must have the following signature: function someFunction(node : ITreeNode) : void.
		 * @param maxTimeOut The maximum timeout in milliseconds.
		 */
		public function performMethodAsync(method : Function, maxTimeOut : Number = 500) : void
		{
			if (_asyncInProgress)
				throw new Error("An asynchronous iteration is already in progress!");

			startTraverse();

			_canceled = false;
			_maxTimeOut = maxTimeOut;
			_asyncInProgress = true;
			_asyncMethod = method;

			performMethodStep();
		}

		public function cancelAsyncTraversal() : void
		{
			_canceled = true;
			_asyncInProgress = false;
		}

		private function traverseStep() : ITreeNode
		{
			var left : ITreeNode = _traverseNode.leftChild;
			var right : ITreeNode = _traverseNode.rightChild;
			var newVisited : Boolean;

			do {
				switch (_traverseState) {
					case TRAVERSE_PRE:
						if (left) {
							_traverseNode = left;
							newVisited = true;
						}
						else
							_traverseState = TRAVERSE_IN;
						break;

					case TRAVERSE_IN:
						if (right) {
							_traverseNode = right;
							_traverseState = TRAVERSE_PRE;
							newVisited = true;
						}
						else
							_traverseState = TRAVERSE_POST;
						break;
					case TRAVERSE_POST:
						if (_traverseNode == _traverseNode.parent.leftChild)
							_traverseState = TRAVERSE_IN;
						_traverseNode = _traverseNode.parent;
						break;
				}

				// end of the line
				if (_traverseNode == _rootNode && _traverseState == TRAVERSE_POST)
					return null;

			} while (!newVisited);

			return _traverseNode;
		}

		private function performMethodStep() : void
		{
			var node : ITreeNode = _traverseNode;
			var startTime : int = getTimer();

			if (_canceled) {
				dispatchEvent(new Event(Event.CANCEL));
				return;
			}

			do {
				_asyncMethod(node);
			} while (node = traverseStep() && getTimer() - startTime < _maxTimeOut);

			if (node)
				setTimeout(performMethodStep, 1);
			else {
				_asyncInProgress = false;
				_asyncMethod = null;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
	}
}