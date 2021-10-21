#
# Copyright (c) 2021 Galois, Inc.
# SPDX-License-Identifier: Apache-2.0 OR MIT
#

# Read a json proof summary produced by SAW, and emit an HTML table

# There are also some functions here to emit csv, in case we want a spreadsheet view

import json
import sys
import re

class DiGraph():
    '''Barely-functional version.'''
    def __init__(self):
        # invariant: self.nverts  = len(self.outgoing)
        # invariant: for all o in outgoing, o is a sequence
        # invariant: for all o in outgoing, for all d in o: d in range(self.nverts)
        self.nverts = 0
        self.outgoing = []

    def _adjust_nverts(self, v):
        '''Make room for a vertex numbered `v`'''
        if v < self.nverts: return
        self.outgoing.extend( [] for _ in range(self.nverts, v+1) )
        self.nverts = v+1

    def add_edge(self, src, dst):
        self._adjust_nverts(max(src,dst))
        o = self.outgoing[src]
        if dst not in o:
            o.append(dst)

    def add_edges(self, edges):
        for s,d in edges:
            self.add_edge(s,d)

    def outgoing_edges(self, src):
        '''a list of all nodes at the end of an edge from `src`'''
        if 0 <= src and src < self.nverts:
            return self.outgoing[src] # sloppy, should really return a copy for safety
        return []

    def indegree(self, v):
        '''the number of edges with destination `v`, that is, the number of incoming edges.'''
        # inefficient implementation!
        if 0 <= v and v < self.nverts:
            return sum(1 if v in self.outgoing_edges(s) else 0 for s in range(self.nverts))
        return 0

    def transitive_closure(self):
        '''Transitive closure, only for acyclic digraphs. Returns a new DiGraph.'''
        # unsophisticated depth-first algorithm
        #   seen[s] = true iff we have started or are finished processing node s
        #   reachable[s] = None iff we have not finished processing s, and a list otherwise.
        seen = [False] * self.nverts
        reachable = [None] * self.nverts
        def reachables_of(s):
            if seen[s]:
                if reachable[s] is None:
                    raise Error('Graph has a cycle from node %d'%s)
                return reachable[s]
            seen[s] = True # processing has started
            r = []
            for d in self.outgoing[s]:
                if d not in r:
                    r.append(d)
                new = [x for x in reachables_of(d) if x not in r]
                r.extend(new)
            reachable[s] = r # processing is done, and these are the reachable nodes
            return r
        G = DiGraph()
        for s in range(self.nverts):
            reachables_of(s)
        G.nverts = self.nverts
        G.outgoing = reachable
        return G

def read_summary(filename):
    s = None
    with open(filename, 'r') as f:
        s = json.load(f)
    return s

def summary_event_digraph(s):
    '''A digraph with edges from elements to the elements they depend on.
    Vertices are labeled by their index in sequence `s`, which should be a list
    of proof records.'''
    G = DiGraph()
    label = {e['id']:i for i,e in enumerate(s)} # map from id to index in s
    for i,e in enumerate(s):
        G.add_edges([(i, label[d]) for d in e['dependencies']])
    return G

# method proofs can depend on subgoal proofs
def show_method_summaries(s):
    print ('id, loc, status, deps(overrides), deps(properties)')
    label = {e['id']:i for i,e in enumerate(s)}
    for i, e in enumerate(s):
        if e['type'] != 'method': continue
        dep_o = []
        dep_p = []
        for d in e['dependencies']:
            if d not in label:
                print ("Missing item", d)
                continue
            di = label[d]
            if s[di]['type'] != 'property':
                # raise Exception('dep %s (item %d) of item %d is not a property'%(d,di,i))
                        if di not in dep_o:
                            dep_o.append(di)
            elif 'ploc' in s[di]:
                for dd in s[di]['dependencies']:
                    ddi = label[dd]
                    if s[ddi]['type'] == 'property':
                        if ddi not in dep_p:
                            dep_p.append(ddi)
                    else:
                        if ddi not in dep_o:
                            dep_o.append(ddi)
            else:
                if di not in dep_p:
                    dep_p.append(di)
        print ('%s, %s, %s, %s, %s'%(i, e['loc'], e['status'], ' '.join(['%d'%d for d in dep_o]), ' '.join(['%d'%d for d in dep_p])))

def show_property_summaries(s, f = sys.stdout):
    print ('id, status, loc, time, deps', file=f)
    label = {e['id']:i for i,e in enumerate(s)}
    for i, e in enumerate(s):
        if e['type'] != 'property': continue
        dep_p = []
        for d in e['dependencies']:
            if d not in label:
                print ("Missing item", d)
                continue
            di = label[d]
            dep_p.append(di)
        print ('%s, %s, %s, %.2f, %s'%(i, e['status'], e['loc'], e['elapsedtime'], ' '.join(['%d'%d for d in dep_p])), file=f)

def show_property_summaries_to_file(s, fname):
    with open(fname, 'w') as f:
         show_property_summaries(s, f)


def show_property_summaries_alt(s, f = sys.stdout):
    '''Shows which assumptions are used (even if via some intermediary)'''
    print ('id, status, loc, time, assumptions used', file=f)
    # label = {e['id']:i for i,e in enumerate(s)}
    G = summary_event_digraph(s).transitive_closure()
    for i, e in enumerate(s):
        # if e['type'] != 'property': continue
        dep_p = []
        for _,d,_ in G.outgoing_edge_iterator([i]):
            if s[d]['status'] != 'verified':
                dep_p.append(d)
        print ('%s, %s, %s, %.2f, %s'%(i, e['status'], e['loc'], e['elapsedtime'], ' '.join(['%d'%d for d in dep_p])), file=f)

def show_property_summaries_to_file_alt(s, fname):
    with open(fname, 'w') as f:
         show_property_summaries_alt(s, f)

def show_assumptions_file(s, fname=None):
    G = summary_event_digraph(s).transitive_closure()
    def show_assumptions(f):
        print("number, status, source location, number of times used", file=f)
        for i, e in enumerate(s):
            if e['status'] != 'verified':
                print('%d, %s, %s, %d'%(i, e['status'], e['loc'], len(Gt.incoming_edges([i]))), file=f)
    if fname is None:
        show_assumptions(sys.stdout)
    else:
        with open(fname, 'w') as f:
            show_assumptions(f)

################
#
# With links to the sources
# in general, a pathname ...proof/foo.saw:nnn:kkk
# goes to https://github.com/GaloisInc/BLST-Verification/blob/main/proof/foo.saw#Lnnn

def pathname_to_uri(p):
    a = p.split(':')
    b = re.findall(r'proof/(.*)', a[0])
    if len(a) < 2:
        # raise Exception('Too few colons in %s => %s'%(p,a))
        return None
    if len(b) == 0:
        return None
    return 'https://github.com/GaloisInc/BLST-Verification/blob/main/proof/%s#L%s'%(b[0], a[1])

def show_method_summaries_html_1(s, f = sys.stdout):
    '''Shows which assumptions are used (even if via some intermediary)'''
    print ('<html><body><table>', file=f)
    print ('<tr> <th> loc </th> <th> assumptions used</th></tr>', file=f)
    uris = [pathname_to_uri(e['loc']) for e in s]
    G = summary_event_digraph(s).transitive_closure()
    for i, e in enumerate(s):
        if e['type'] != 'method': continue
        print('<tr><td> %s </td>'% (uris[i]), file=f)
        print('<tr><td>', file=f)
        for d in G.outgoing_edges(i):
            if s[d]['status'] != 'verified':
                print ('<a href="', uris[d], '">', d, '</a>', file=f)
    print('</table></body></html>', file=f)

def show_method_summaries_html(s, f = sys.stdout, deps_per_row=10, only_items = None):
    '''Shows which assumptions are used (even if via some intermediary).  If `only_items` is `None`,
    then has a row for every method; otherwise only events whose index (in s) in in that list.
    Uses multiple rows if needed, with no more than `deps_per_row` dependents listed on any row.'''

    print ('<html><head><style> table, th, td {border: 1px solid black;}</style><body><table>', file=f)
    print ('<tr> <th> loc </th> <th> assumptions used</th></tr>', file=f)
    uris = [pathname_to_uri(e['loc']) for e in s]
    G = summary_event_digraph(s).transitive_closure()
    for i, e in enumerate(s):
        # if only_items is None and (e['type'] != 'method' or G.indegree(i) > 0): continue
        if only_items is None and G.indegree(i) > 0: continue
        if only_items is not None and i not in only_items: continue # clumsy way to do this!
        dep_p = []
        for d in G.outgoing_edges(i):
            if s[d]['status'] != 'verified':
                dep_p.append(d)
        dep_p.sort()
        nrows = (len(dep_p) + deps_per_row - 1)//deps_per_row
        print('<tr><td rowspan=%d> <a href="%s"> %d </a> </td>'% (nrows, uris[i], i), file=f)
        n = 0
        first_row = True
        for d in dep_p:
          if n==0:
              if first_row:
                  print('<td>', file=f)
                  first_row=False
              else:
                  print('<tr><td>', file=f)
          print (', ' if n > 0 else '', '<a href="', uris[d], '">', d, '</a>', file=f)
          n = (n+1)%deps_per_row
          if n==0: print('</td></tr>', file=f)
        if n>0:
            print('</td></tr>', file=f)
    print('</table></body></html>', file=f)

def show_method_summaries_html_file(s, filename, deps_per_row=10, only_items = None):
    with open(filename, 'w') as f:
         show_method_summaries_html(s, f, deps_per_row, only_items)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description="Read SAW's proof summary output and produce an html table.")
    #parser.add_argument('--in', '-i', dest='infile',
    #                    help = 'input json filename; read from stdin if absent')
    parser.add_argument('infilename', help = 'input json filename')
    parser.add_argument('--deps_per_row', '-d', dest='deps_per_row', type=int, default=10,
                        help = 'number of dependents to show per row of table')
    parser.add_argument('--outfile', '-o', nargs='?', type=argparse.FileType('w'),
                        default=sys.stdout)
    parser.add_argument('roots', metavar='N', type=int, nargs='*',
                    help='if given, a list of items to show; if absent, all unused items are shown')
    args = parser.parse_args()
    items = None if len(args.roots)==0 else args.roots
    show_method_summaries_html(read_summary(args.infilename), args.outfile, args.deps_per_row, items)
