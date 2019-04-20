
#%%


import pandas as pd
import pyodbc



ServerInput = 'BT4SQL11QA\sqlcol' #input("Enter Server Name: ")
DatabaseInput = 'MRI_Source' #input("Enter Database Name: ")

conn_str = (
     r'DRIVER={SQL Server};'
     r'SERVER=' + ServerInput + ';'
     r'Trusted_Connection=Yes;'
     r'DATABASE=' + DatabaseInput + ';'
)

conn_str = str(conn_str)
conn = pyodbc.connect(conn_str)
edges = pd.read_sql("SELECT RTRIM(LTRIM(IA.InvestorID)) as InvestorID, RTRIM(LTRIM(IA.InvestmentID)) as InvestmentID, RTRIM(LTRIM(IA.OwnershipPct)) as label FROM BKUSLP.HARMONY_IMPL.DBO.IA_RELATIONSHIP2 IA, BKUSLP.HARMONY_IMPL.DBO.ENTITY EN WHERE IA.InvestorID = EN.ENTITYID AND EN.LEDGCODE = 'BK'", conn)

G = nx.from_pandas_edgelist(edges, source='InvestorID', target='InvestmentID', edge_attr='label' , create_using=G)











import sys

PY2 = sys.version_info[0] == 2
if PY2:
    def make_str(x):
        """Return the string representation of t."""
        if isinstance(x, unicode):
            return x
        else:
            # Note, this will not work unless x is ascii-encoded.
            # That is good, since we should be working with unicode anyway.
            # Essentially, unless we are reading a file, we demand that users
            # convert any encoded strings to unicode before using the library.
            #
            # Also, the str() is necessary to convert integers, etc.
            # unicode(3) works, but unicode(3, 'unicode-escape') wants a buffer
            #
            return unicode(str(x), 'unicode-escape')
else:
    def make_str(x):
        """Return the string representation of t."""
        return str(x)








__author__ = """Aric Hagberg (hagberg@lanl.gov)\nDan Schult (dschult@colgate.edu)"""
#    Copyright (C) 2004-2018 by
#    Aric Hagberg <hagberg@lanl.gov>
#    Dan Schult <dschult@colgate.edu>
#    Pieter Swart <swart@lanl.gov>
#    All rights reserved.
#    BSD license.

__all__ = ['generate_edgelist']



# from networkx.utils import open_file, make_str
import networkx as nx


def generate_edgelist(G, delimiter=' ', data=True):
    """Generate a single line of the graph G in edge list format.

    Parameters
    ----------
    G : NetworkX graph

    delimiter : string, optional
       Separator for node labels

    data : bool or list of keys
       If False generate no edge data.  If True use a dictionary
       representation of edge data.  If a list of keys use a list of data
       values corresponding to the keys.

    Returns
    -------
    lines : string
        Lines of data in adjlist format.

    Examples
    --------
    >>> G = nx.lollipop_graph(4, 3)
    >>> G[1][2]['weight'] = 3
    >>> G[3][4]['capacity'] = 12
    >>> for line in nx.generate_edgelist(G, data=False):
    ...     print(line)
    0 1
    0 2
    0 3
    1 2
    1 3
    2 3
    3 4
    4 5
    5 6

    >>> for line in nx.generate_edgelist(G):
    ...     print(line)
    0 1 {}
    0 2 {}
    0 3 {}
    1 2 {'weight': 3}
    1 3 {}
    2 3 {}
    3 4 {'capacity': 12}
    4 5 {}
    5 6 {}

    >>> for line in nx.generate_edgelist(G,data=['weight']):
    ...     print(line)
    0 1
    0 2
    0 3
    1 2 3
    1 3
    2 3
    3 4
    4 5
    5 6

     """
    if data is True:
        for u, v, d in G.edges(data=True):
            e = u, v, dict(d)
            yield delimiter.join(map(make_str, e))
    elif data is False:
        for u, v in G.edges(data=False):
            e = u, v
            yield delimiter.join(map(make_str, e))
    else:
        for u, v, d in G.edges(data=True):
            e = [u, v]
            try:
                e.extend(d[k] for k in data)
            except KeyError:
                pass  # missing data for this edge, should warn?
            yield delimiter.join(map(make_str, e))


# @open_file(1, mode='wb')