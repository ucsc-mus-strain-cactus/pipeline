#!/usr/bin/env python
"""
A simple SV caller from a breakpoint graph.

Requires the pip packages networkx and intervaltree.
"""
import networkx as nx
from collections import namedtuple
from intervaltree import Interval, IntervalTree

# A block is formed from one or more segments. The segment "thread" should
# uniquely identify a single sequence, and the "orientation" is
# whether the segment has the same orientation as the block, i.e. the
# block's head is at the end of the segment rather than the start.
Segment = namedtuple('Segment', ['thread', 'start', 'end', 'orientation'])

class BreakpointGraph():
    """A simple pairwise breakpoint graph."""
    _telomereEndID = -1
    def __init__(threadSizes, blocks=[]):
        """Create a new breakpoint graph.

        The threadSizes parameter is a dict keyed by sequence or
        "thread" identifier, and in which the values are the length of
        the sequence.

        Can optionally supply a list of blocks, all of which will be
        immediately added to the graph.
        """
        self.graph = nx.MultiGraph()
        self.uniqueID = 0
        self.adjacencyIntervals = dict((thread, Interval(0, size, (self._telomereEndID, self._telomereEndID))) for thread, size in threadSizes)
        for block in blocks:
            self.addBlock(block)

    def _getUniqueID(self):
        ret = self.uniqueID
        self.uniqueID += 2
        return ret

    def _getBlockHead(self, blockID):
        return blockID

    def _getBlockTail(self, blockID):
        return blockID + 1

    def addBlock(block):
        """Add a single block (a collection of Segments) to the graph.

        The block cannot overlap with any existing block in the graph."""
        # Add head and tail nodes
        blockID = self._getUniqueID()
        blockHead = self._getBlockHead(blockID)
        blockTail = self._getBlockTail(blockID)
        self.graph.add_node(blockHead)
        self.graph.add_node(blockTail)
        # Connect the head and tail nodes with a "reality" edge
        self.graph.add_edge(blockHead, blockTail, reality=True)

        # Now, we need to break adjacency edges by inserting this
        # block between them.
        for segment in block:
            threadAdjacencyIntervals = self.adjacencyIntervals[segment.thread]

            # Find which adjacency this block needs to interrupt
            # (there better be one and only one, else there is an
            # overlap!) and remove it from the graph and
            # adjacency-interval tree.
            interval = Interval(segment.start, segment.end)
            containingAdjacencies = list(threadAdjacencyIntervals.search(interval))
            if len(containingAdjacencies) != 1:
                raise ValueError('Block does not cleanly fit within an existing adjacency')
            containingAdjacency = containingAdjacencies[0]
            threadAdjacencyIntervals.remove(containingAdjacency)
            leftConnectedEndpoint, rightConnectedEndpoint = containingAdjacency.data
            self.graph.remove_edge(leftConnectedEndpoint, rightConnectedEndpoint)

            # Decide how the block endpoints are ordered on the
            # thread.
            if segment.orientation:
                orderedBlockEndpoints = (blockHead, blockTail)
            else:
                orderedBlockEndpoints = (blockTail, blockHead)

            # Add in the new adjacencies to the graph and
            # adjacency-interval tree.
            newLeftAdjacency = (leftConnectedEndpoint, orderedBlockEndpoints[0])
            self.graph.add_edge(newLeftAdjacency, reality=False, thread=segment.thread)
            threadAdjacencyIntervals.insert(containingAdjacency.start, segment.start, newLeftAdjacency)
            newRightAdjacency = (orderedBlockEndpoints[1], rightConnectedEndpoint)
            self.graph.add_edge(newRightAdjacency, reality=False, thread=segment.thread)
            threadAdjacencyIntervals.insert(segment.end, containingAdjacency.end, newRightAdjacency)

        def getRearrangements(self):
            # Filter the graph to remove the "reality" aka "obverse" edges.
            filteredGraph = nx.MultiGraph([(x, y, data) for x, y, data in self.graph.edges(data=True) if data['reality'] == False])
            cycles = nx.simple_cycles(filteredGraph)
            return filter(lambda x: len(x) != 2, cycles)
