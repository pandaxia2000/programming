import mysql.connector
from mysql.connector import errorcode
import pyodbc
import psycopg2
import xlwt
import time
import os
import re
import sys
import traceback
import logging

logging.basicConfig(filename='databases_user_priviliges_log.txt', level=logging.DEBUG,
     format='%(asctime)s - %(levelname)s - %(message)s')


#define excel file sheet name

source='C:\Temp\\'

now = time.strftime("%Y-%m-%d-%H_%M_%S",time.localtime(time.time())) 
book = xlwt.Workbook(encoding = 'utf-8')
vm_sql = book.add_sheet('vm_sql')
Azure_sql = book.add_sheet('Azure_sql')
Azure_MI = book.add_sheet('Azure_MI')
Azure_mysql = book.add_sheet('Azure_mysql')
Azure_postgresql = book.add_sheet('Azure_postgresql')
excelfilename=source+"databases_user_priviliges_"+now+".xls"


# database connection

def connpostgresql(hostname,database,username,password):
    conn = psycopg2.connect(database=database,user=username,password=password,host=hostname,port='5432')
    cursor = conn.cursor()
    return cursor


def connect2(Server,database):
   cnxn = pyodbc.connect(r'Driver={SQL Server};Server='+Server+r';Database='+database+';Trusted_Connection=yes;')
   cursor = cnxn.cursor()
   return cursor

def connect(server,database,username,password):
   driver= '{ODBC Driver 17 for SQL Server}'
   cnxn = pyodbc.connect('DRIVER='+driver+';SERVER='+server+';PORT=1433;DATABASE='+database+';UID='+username+';PWD='+ password)
   cursor = cnxn.cursor()
   return cursor

def connectmysql(host,user,password):
    try:
       conn = mysql.connector.connect(host=host,user=user,password=password)
       print("Connection established")
    except mysql.connector.Error as err:
      if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("Something is wrong with the user name or password")
      elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("Database does not exist")
      else:
        print(err)
    return conn


def sqlserver2(serverlist,queryprivs,sheetname):
     i2=0
     server=[]
     with open(source + serverlist, "r") as f:
         for line in f.readlines():
             line1 = line.strip('\n').split(',')
             server=line1[0]
             database='tempdb'
             azure_sql_type='VM_SQL'
             cursor=connect2(server,database)
             cursor.execute("select name from sys.databases where database_id not in ('1')")
             database_list = cursor.fetchall()
             for h in database_list:
                 database = h[0]
                 cursor=connect2(server,database)	   
                 datalist1=[]
                 with open(source+queryprivs, "r") as f1:
                        for data in f1:
                           datalist1.append(data)
                        sql1 = "".join(datalist1)
                        sql2 = re.sub('#hostname#',database,sql1)
                        sql3 = re.sub('#azure_sql_type#',azure_sql_type,sql2)
                        cursor.execute(sql3)
                        result1 = cursor.fetchall()
                        if i2<1:
                           columns = [column[0] for column in cursor.description]
                           for z,f in enumerate(columns):
                               sheetname.write(0,z,f)
                           i2=i2+1
                        for i,j in enumerate(result1,start=1):
                            for x in range(len(j)):	   
                               sheetname.write(i2,x,str(j[x]))
                            i2=i2+1

def sqlserver(serverlist,queryprivs,sheetname):
     i2=0
     server=[]
     with open(source + serverlist, "r") as f:
         for line in f.readlines():
             line1 = line.strip('\n').split(',')
             print(line1[0])
             server=line1[0]
             database = 'master'
             username=line1[1]
             password=line1[2]
             azure_sql_type=line1[3]
             cursor=connect(server,database,username,password)
             cursor.execute("select name from sys.databases where database_id not in ('1')")
             database_list = cursor.fetchall()
             for h in database_list:
                 database = h[0]
                 cursor=connect(server,database,username,password)
                 datalist1=[]
                 with open(source+queryprivs, "r") as f1:
                        for data in f1:
                           datalist1.append(data)
                        sql1 = "".join(datalist1)
                        sql2 = re.sub('#hostname#',database,sql1)
                        sql3 = re.sub('#azure_sql_type#',azure_sql_type,sql2)
                        cursor.execute(sql3)
                        result1 = cursor.fetchall()
                        if i2<1:
                           columns = [column[0] for column in cursor.description]
                           for z,f in enumerate(columns):
                               sheetname.write(0,z,f)
                           i2=i2+1
                        for i,j in enumerate(result1,start=1):
                            for x in range(len(j)):	   
                               sheetname.write(i2,x,str(j[x]))
                            i2=i2+1

def mysqlpoc(serverlist,queryprivs,sheetname):
     i2=1
     x2=0
     server=[]
     with open(source+serverlist, "r") as f:
         for line in f.readlines():
             line1 = line.strip('\n').split(',')
             host=line1[0]
             user=line1[1]
             password=line1[2]
             azure_sql_type=line1[3]
             print(azure_sql_type)
             cn=connectmysql(host,user,password)
             print('cn is created')
             cursor=cn.cursor()
             datalist1=[]
             with open(source+queryprivs, "r") as f1:
                    for data in f1:
                       print(data)
                       datalist1.append(data)
                       sql1 = "".join(datalist1)
                       sql2 = re.sub('#hostname#',host,sql1)
                       sql3 = re.sub('#azure_sql_type#',azure_sql_type,sql2)
                       cursor.execute(sql3)
                       result1 = cursor.fetchall()
                       if i2<2:
                           columns = [column[0] for column in cursor.description]
                           for z,f in enumerate(columns):
                              sheetname.write(0,z,f)
                       for i,j in enumerate(result1,start=1):
                                 for x in range(len(j)):					  
                                     sheetname.write(i2,x,str(j[x]))
                                 i2=i2+1
                                 x2=x2+x


def postgresqlpoc(serverlist,queryprivs,sheetname):
     i2=0
     server=[]
     with open(source + serverlist, "r") as f:
         for line in f.readlines():
             line1 = line.strip('\n').split(',')
             server=line1[0]
             database = 'postgres'
             username=line1[1]
             password=line1[2]
             azure_sql_type=line1[3]
             cursor=connpostgresql(server,database,username,password)
             cursor.execute("SELECT datname FROM pg_database where datallowconn = true and datdba > 10")
             database_list = cursor.fetchall()
             #conn_postgres.close
             for h in database_list:
                 database = h[0]
                 datalist1=[]
                 with open(source+queryprivs, "r") as f1:
                        for data in f1:
                           datalist1.append(data)
                        sql1 = "".join(datalist1)
                        sql2 = re.sub('#hostname#',server,sql1)
                        sql3 = re.sub('#azure_sql_type#',azure_sql_type,sql2)
                        cursor=connpostgresql(server,database,username,password)
                        cursor.execute(sql3)
                        result1 = cursor.fetchall()
                        if i2<1:
                           columns = [column[0] for column in cursor.description]
                           for z,f in enumerate(columns):
                               sheetname.write(0,z,f)
                           i2=i2+1
                        for i,j in enumerate(result1,start=1):
                            for x in range(len(j)):	   
                               sheetname.write(i2,x,str(j[x]))
                            i2=i2+1
#
#
##sqlserver('Azure_MI_SERVERLIST.txt','queryprivs_sqlserver.txt',Azure_MI)
##print('step1 completed')
##sqlserver('Azure_SQL_SERVERLIST.csv','queryprivs_sqlserver.txt',Azure_sql)
##print('step2 completed')
#sqlserver2('VM_SQL_SERVERLIST.csv','queryprivs_sqlserver.txt',vm_sql)
##print('step3 completed')
##mysqlpoc('Azure_mysql_stage_serverlist.txt','queryprivs_mysql.txt',Azure_mysql)
##print('step4 completed')
##postgresqlpoc('Azure_postgresql_stage_serverlist.txt','queryprivs_postgresql.txt',Azure_postgresql)
##print('step5 completed')
#







try:
   sqlserver('Azure_MI_SERVERLIST.txt','queryprivs_sqlserver.txt',Azure_MI)
   print('step1 completed')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())


#try:
#   sqlserver('Azure_SQL_SERVERLIST.csv','queryprivs_sqlserver.txt',Azure_sql)
#   print('step2 completed')
#except:
#   logging.debug(traceback.format_exc())
#else:
#   logging.debug(traceback.format_exc())

try:
   sqlserver2('VM_SQL_SERVERLIST.csv','queryprivs_sqlserver.txt',vm_sql)
   print('step3 completed')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())

try:
   mysqlpoc('Azure_mysql_prod_serverlist.txt','queryprivs_mysql.txt',Azure_mysql)
   print('step4 completed')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())

try:
   postgresqlpoc('Azure_postgresql_stage_serverlist.txt','queryprivs_postgresql.txt',Azure_postgresql)
   print('step5 completed')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())


errorFile = open('log.txt', 'a')
errorFile.write(traceback.format_exc())
errorFile.close()



book.save(excelfilename)
