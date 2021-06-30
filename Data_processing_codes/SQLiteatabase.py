# -*- coding: utf-8 -*-
"""
Created on Wed Feb 17 13:36:09 2021

@author: Hanning Su
"""

import sqlite3
from sqlite3 import Error
import csv

#conn = sqlite3.connect('test.db')
#cur = conn.cursor()

#%% Database Creation
def create_connection(db_file):
    """ create a database connection to a SQLite database """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        print(sqlite3.version)
    except Error as e:
        print(e)
    finally:
        if conn:
            conn.close()


if __name__ == '__main__':
    create_connection(r"C:\Users\Hanning Su\Desktop\CS230 Project\Data\Citation_data_processing\patent.db")

#%% Table Creation
db_file = "patent.db"


def create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        return conn
    except Error as e:
        print(e)

    return conn


def create_table(conn, create_table_sql):
    """ create a table from the create_table_sql statement
    :param conn: Connection object
    :param create_table_sql: a CREATE TABLE statement
    :return:
    """
    try:
        c = conn.cursor()
        c.execute(create_table_sql)
    except Error as e:
        print(e)


def main():
    database = r"C:\Users\Hanning Su\Desktop\CS230 Project\Data\Citation_data_processing\patent.db"

    sql_create_patent_title_abstract_table = """CREATE TABLE IF NOT EXISTS patent_title_abstract (
                                    patent_id text PRIMARY KEY,
                                    title text NOT NULL,
                                    abstract text NOT NULL
                                );"""
    
    sql_create_patent_date_table = """ CREATE TABLE IF NOT EXISTS patent_date (
                                        patent_id text PRIMARY KEY,
                                        grant_date date NOT NULL,
                                        FOREIGN KEY (patent_id) REFERENCES patent_title_abstract (patent_id)
                                    ); """

    sql_create_citing_cited_table = """CREATE TABLE IF NOT EXISTS citing_cited (
                                    id integer PRIMARY KEY,
                                    cited_id text NOT NULL,
                                    citing_id text NOT NULL,
                                    FOREIGN KEY (cited_id) REFERENCES patent_title_abstract (patent_id)
                                );"""

    
    # create a database connection
    conn = create_connection(database)

    # create tables
    if conn is not None:
        # create patent_title_abstract table
        create_table(conn, sql_create_patent_title_abstract_table)

        # create patent_date table
        create_table(conn, sql_create_patent_date_table)
        
        # create citing_cited table
        create_table(conn, sql_create_citing_cited_table)
    else:
        print("Error! cannot create the database connection.")


if __name__ == '__main__':
    main()

#%%
#Connect to database
con = sqlite3.connect("patent.db")
cur = con.cursor()

# Open CSV file for reading
filename = "patent_abstract_title.csv"

with open(filename, "r", encoding='cp932', errors='ignore') as patent_abstract_title:
    reader = csv.DictReader(patent_abstract_title)
    to_db = [(i['patent_id'], i['title'], i['abstract']) for i in reader]

cur.executemany("INSERT INTO patent_title_abstract (patent_id, title, abstract) VALUES (?, ?, ?);", to_db)
con.commit()
con.close()

#%%
con = sqlite3.connect("patent.db")
cur = con.cursor()

# Open CSV file for reading
filename = "citing_cited.csv"

with open(filename, "r") as citing_cited:
    reader = csv.DictReader(citing_cited)
    to_db = [(i['cited_id'], i['citing_id']) for i in reader]

cur.executemany("INSERT INTO citing_cited (cited_id, citing_id) VALUES (?, ?);", to_db)
con.commit()
con.close()

#%%
con = sqlite3.connect("patent.db")
cur = con.cursor()

# Open CSV file for reading
filename = "patent_date.csv"

with open(filename, "r") as patent_date:
    reader = csv.DictReader(patent_date)
    to_db = [(i['date'], i['patent_id']) for i in reader]

cur.executemany("INSERT INTO patent_date (grant_date, patent_id) VALUES (?, ?);", to_db)
con.commit()
con.close()

#%% do the queries

# Create a SQL connection to our SQLite database
con = sqlite3.connect("patent.db")
cur = con.cursor()

# The result of a "cursor.execute" can be iterated over by row
#for row in cur.execute('SELECT * FROM citing_cited;'):
    #print(row)
 
#Eliminated entries in the citing_cited table where cited patent has no date record in patent_date table
#cur.execute('DELETE FROM citing_cited \
 #WHERE cited_id NOT IN (SELECT patent_date.patent_id  \
                        #FROM patent_date);')
                        
#cur.execute('SELECT COUNT(*) FROM citing_cited;')
#print(cur.fetchall()) #Nothing eliminated in the previous step #[(113129077,)]
#cur.execute('ALTER TABLE patent_date ADD COLUMN max_date date;')
#cur.execute( 'UPDATE patent_date SET max_date=DATE(grant_date, '+5 year');') #Use dbbrowser to do the execution
 #DATE('2018-11-01','-1 day')

#cur.execute('INSERT INTO patent_max_date (max_date, patent_id) 
            #SELECT max_date, patent_id FROM patent_date' ) #Use dbbrower to do the execution

#cur.execute('ALTER TABLE patent_date DROP COLUMN max_date;') #created grant_date table and max_date table in dbbrowser
# Be sure to close the connection

cur.execute('CREATE TABLE citing_cited_max_grant_date\
            AS SELECT * FROM citing_cited \
            INNER JOIN patent_max_date \
            ON citing_cited.cited_id = patent_max_date.patent_id \
            INNER JOIN patent_grant_date \
            ON citing_cited.citing_id = patent_grant_date.patent_id')
con.close()

#%% Sanity Check of citing_cited_max_grant_date

# Create a SQL connection to our SQLite database
con = sqlite3.connect("patent.db")
cur = con.cursor()

cur.execute('SELECT * FROM citing_cited_max_grant_date')

counter = 0
for row in cur.fetchall():
     # can convert to dict if you want:
     print(row)
     counter += 1
     if counter > 20:
         break

con.close()

###Output for further inspection:

#('4875247', '5354551', '4875247', '1994-10-24', '5354551', '1994-10-11')
#('6642945', '8683318', '6642945', '2008-11-04', '8683318', '2014-03-25')
#('7386701', '8250307', '7386701', '2013-06-10', '8250307', '2012-08-21')
#('5242647', '9199394', '5242647', '1998-09-07', '9199394', '2015-12-01')
#('4894880', '7398575', '4894880', '1995-01-23', '7398575', '2008-07-15')
#('6312295', '9575510', '6312295', '2006-11-06', '9575510', '2017-02-21')
#('6179710', '7051923', '6179710', '2006-01-30', '7051923', '2006-05-30')
#('5334216', '7905900', '5334216', '1999-08-02', '7905900', '2011-03-15')
#('9358364', '10688280', '9358364', '2021-06-07', '10688280', '2020-06-23')
#('6011437', '7450915', '6011437', '2005-01-04', '7450915', '2008-11-11')
#('6245295', '8431384', '6245295', '2006-06-12', '8431384', '2013-04-30')
#('6609122', '10025801', '6609122', '2008-08-19', '10025801', '2018-07-17')
#('4695852', '8393702', '4695852', '1992-09-22', '8393702', '2013-03-12')
#('4726380', '5431689', '4726380', '1993-02-23', '5431689', '1995-07-11')
#('5228657', '8083192', '5228657', '1998-07-20', '8083192', '2011-12-27')
#('7264387', '9869441', '7264387', '2012-09-04', '9869441', '2018-01-16')
#('5879351', '10182844', '5879351', '2004-03-09', '10182844', '2019-01-22')
#('5069404', '6524488', '5069404', '1996-12-03', '6524488', '2003-02-25')
#('6514007', '7938596', '6514007', '2008-02-04', '7938596', '2011-05-10')
#('4357844', '5931062', '4357844', '1987-11-09', '5931062', '1999-08-03')
#('4341419', 'D338114', '4341419', '1987-07-27', 'D338114', '1993-08-10') 

#Sanity Check seems okay


#%%

# Create a SQL connection to our SQLite database
con = sqlite3.connect("patent.db")
cur = con.cursor()

cur.execute('CREATE TABLE citing_cited_max_grant_date_updated \
            AS SELECT cited_id, citing_id FROM citing_cited_max_grant_date \
            WHERE grant_date <= max_date;')
con.close()

#%% Sanity Check of citing_cited_max_grant_date

# Create a SQL connection to our SQLite database
con = sqlite3.connect("patent.db")
cur = con.cursor()

cur.execute('SELECT * FROM citing_cited_max_grant_date_updated')

counter = 0
for row in cur.fetchall():
     # can convert to dict if you want:
     print(row)
     counter += 1
     if counter > 20:
         break

con.close()

###Output for further inspection:

#('4875247', '5354551')
#('7386701', '8250307')
#('9358364', '10688280')
#('6933491', '7556093')
#('7715413', '8885639')
#('6877462', '7380522')
#('7275398', '7921679')
#('5575539', '5718485')
#('7639343', '8004650')
#('5393739', '5776193')
#('6578104', '6993032')
#('9470906', '10417831')
#('4174123', '4324616')
#('9102046', '9975224')
#('8516593', '10033759')
#('5750654', '6261548')
#('9483161', '10606463')
#('6909950', '7072751')
#('4063068', '4234783')
#('5186922', '5540909')
#('5941538', '6354606')

#Sanity Check seems okay

#%%
# Open CSV file for reading
