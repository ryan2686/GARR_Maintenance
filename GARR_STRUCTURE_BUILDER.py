#%%

# Importing necessary modules: NetworkX to generate DAG, MatPlotLib to view DAG
import pandas as pd
#import pyodbc
import sqlite3


# Connection string to be used by pyodbc to connect directly to the SQL database via linked server
#         pyodbc will be used to connect to database and execute raw SQL statements

# Added user inputs to define connection string
#ServerInput = 'BT4SQL11QA\sqlcol' #input("Enter Server Name: ")
#DatabaseInput = 'MRI_Source' #input("Enter Database Name: ")

conn = sqlite3.connect('sandbox.db')

# Loads SQL query into pandas dataframe
query_str = "SELECT RTRIM(LTRIM(GACC.ACCTNUM)) as AcctNum, RTRIM(LTRIM(GACC.ACCTNAME)) as AcctName, GACC.KEY, GACC.PARENT  FROM GACC;"

df = pd.read_sql_query(query_str, conn)

#GACC
#df1 = df.astype(object)
gacc_json = df.to_json(path_or_buf='gacc_json.json', orient='records')

print(gacc_json)
#arg_account_dict = pd.read_sql("SELECT RTRIM(LTRIM(GARR.GROUPID)) as GroupID, RTRIM(LTRIM(GACC.ACCTNUM)) as AcctNum, RTRIM(LTRIM(GACC.ACCTNAME)) as AcctName FROM BKUSLP.BKUSLP.dbo.GACC GACC, BKUSLP.BKUSLP.dbo.GARR GARR WHERE ((GACC.ACCTNUM >= GARR.BEGACCT AND GACC.ACCTNUM <= GARR.ENDACCT) AND ( GARR.GROUPID IN  (SELECT GROUPID FROM BKUSLP.BKUSLP.dbo.GARR WHERE LEDGCODE = 'BK')))", conn)

# edges = pd.read_sql("SELECT RTRIM(LTRIM(ARG.InvestorID)) as InvestorID, RTRIM(LTRIM(IA.InvestmentID)) as InvestmentID, RTRIM(LTRIM(IA.OwnershipPct)) as label FROM BKUSLP.HARMONY_IMPL.DBO.IA_RELATIONSHIP2 IA, BKUSLP.HARMONY_IMPL.DBO.ENTITY EN WHERE IA.InvestorID = EN.ENTITYID AND EN.LEDGCODE = 'BK'", conn)

# The below two lines have been commented out because this script now connects directly to
#         the database instead of dumping data into csv file via seperate query.
# csv_path = 'IA_RELATIONSHIP.csv'
# edges = pd.read_csv(csv_path)

# Added create_using parameter because graph wasn't rendering as directional
#G = nx.from_pandas_edgelist(arg_account_dict, source='GroupID', target='AcctNum', edge_attr='AcctName' , create_using=G)

# for line in nx.generate_edgelist(G, data=False):
#    print(line)



# I finally got this to work thanks to:
#         https://stackoverflow.com/questions/20885986/how-to-add-dots-graph-attribute-into-final-dot-output
# This lines updates the aspect-ratio to make the rendered svg longer rather than wider
#G.graph['graph']={'ratio':.25}

# Writing a dot file to be, later, rendered using GraphViz in a later iteration
#    I think this can be updated to P = nx.nx_pydot.to_pydot(G) so no dot file needs to be written and saved to directory
#write_dot(G, 'GARR_STRUCTURE.dot')

# Switched output from png to scalable vector graphics (svg) because svg files are clear at any scale
#         and svg files are searchable 
#         This should also help later on because each node is explicitly ID'd in rendered HTML which will 
#         help when making drag 'n' drop application.
#render('dot', 'svg', 'GARR_STRUCTURE.dot', renderer= None, formatter= None, quiet= False)


conn.close()
#%%
conn.close()