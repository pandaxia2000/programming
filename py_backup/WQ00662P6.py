# -*- coding: utf-8 -*-

import pyodbc
import xlwt
import time
import os
import re
import sys
import traceback
import logging

reload(sys)
sys.setdefaultencoding('utf8')

cwd=os.getcwd()
source='\Scripts\WQ00662P\\'

server='WQ00662P'

logging.basicConfig(filename=server+'6_log.txt', level=logging.DEBUG,
     format='%(asctime)s - %(levelname)s - %(message)s')




#define excel file sheet name
now = time.strftime("%Y-%m-%d-%H_%M_%S",time.localtime(time.time())) 
book = xlwt.Workbook(encoding = 'utf-8')
#data_change_actions = book.add_sheet('data_change_actions')
#Permission_actions = book.add_sheet('Permission_actions')
#LOGINOUT = book.add_sheet('LOGINOUT')
#userlist = book.add_sheet('userlist')
#comparison = book.add_sheet('comparison')
excelfilename=server+"6"+now+".xls"


# database connection
def connectdatabase(server):
     cnxn = pyodbc.connect(r'Driver={SQL Server};Server='+server+';Database=tempdb;Trusted_Connection=yes;')
     cursor = cnxn.cursor()
     return cursor



def get_result_datachange(actions_filename,templete_filename):
     datalist1=[]
     with open(cwd+source+actions_filename + '.txt', "r") as f1:
           for data in f1:
               datalist1.append(data)
     
     sql1 = "".join(datalist1)
     cursor=connectdatabase(server)
     cursor.execute(sql1)
     
     result1 = cursor.fetchall()
     
     if result1:
        exec(actions_filename.strip()+'='+'book.add_sheet('+"\'"+actions_filename.strip()+'_datachange'"\'"+')')
        columns = [column[0] for column in cursor.description]
        for z,f in enumerate(columns):
             eval(actions_filename).write(0,z,f)
     
        for i,j in enumerate(result1,start=1):
           for x in range(len(j)):
              eval(actions_filename).write(i,x,str(j[x]))
     
     actions1=[]
     
     for i in range(0,len(result1)):
         actions1.append(result1[i][0])
     
     data_change_actions_templete_name=templete_filename + '.txt'
     for action in actions1:
       with open(cwd+source+data_change_actions_templete_name, "r") as f1:
           sql=[]
           for line in f1:
               users_of_actions=re.sub('########',action,line)
               sql.append(users_of_actions)
           sql3="".join(sql)
           cursor.execute(sql3)
           result_of_users_of_actions = cursor.fetchall()
           if result_of_users_of_actions:
              exec(action.strip()+'='+'book.add_sheet('+"\'"+action.strip()+'_datachange'"\'"+')')
              columns = [column[0] for column in cursor.description]
              for z,f in enumerate(columns):
                   eval(action).write(0,z,f)
           
              for i,j in enumerate(result_of_users_of_actions,start=1):
                 for x in range(len(j)):
                    eval(action).write(i,x,str(j[x]))


def get_result_permission(actions_filename,templete_filename):
     datalist1=[]
     with open(cwd+source+actions_filename + '.txt', "r") as f1:
           for data in f1:
               datalist1.append(data)
     
     sql1 = "".join(datalist1)
     cursor=connectdatabase(server)
     cursor.execute(sql1)
     
     result1 = cursor.fetchall()
     
     if result1:
        exec(actions_filename.strip()+'='+'book.add_sheet('+"\'"+actions_filename.strip()+'_permission'"\'"+')')
        columns = [column[0] for column in cursor.description]
        for z,f in enumerate(columns):
             eval(actions_filename).write(0,z,f)
     
        for i,j in enumerate(result1,start=1):
           for x in range(len(j)):
              eval(actions_filename).write(i,x,str(j[x]))
     
     actions1=[]
     
     for i in range(0,len(result1)):
         actions1.append(result1[i][0])
     
     data_change_actions_templete_name=templete_filename + '.txt'
     for action in actions1:
       with open(cwd+source+data_change_actions_templete_name, "r") as f1:
           sql=[]
           for line in f1:
               users_of_actions=re.sub('########',action,line)
               sql.append(users_of_actions)
           sql3="".join(sql)
           cursor.execute(sql3)
           result_of_users_of_actions = cursor.fetchall()
           if result_of_users_of_actions:
              exec(action.strip()+'='+'book.add_sheet('+"\'"+action.strip()+'_permission'"\'"+')')
              columns = [column[0] for column in cursor.description]
              for z,f in enumerate(columns):
                   eval(action).write(0,z,f)
           
              for i,j in enumerate(result_of_users_of_actions,start=1):
                 for x in range(len(j)):
                    eval(action).write(i,x,str(j[x]))


def loginout(filename):
     datalist6=[]
     with open(cwd+source+filename+'.txt', "r") as f6:
           for data in f6:
               datalist6.append(data)
     
     sql6 = "".join(datalist6)

     cursor=connectdatabase(server)
     cursor.execute(sql6)
     
     result6 = cursor.fetchall()
     
     if result6:
        exec(filename.strip()+'='+'book.add_sheet('+"\'"+filename.strip()+"\'"+')')
        columns = [column[0] for column in cursor.description]
        for z,f in enumerate(columns):
            eval(filename).write(0,z,f)
     
        for i,j in enumerate(result6,start=1):
            for x in range(len(j)):
               eval(filename).write(i,x,str(j[x]))

def userlist(filename):
     datalist4=[]
     with open(cwd+source+filename+'.txt', "r") as f4:
           for data in f4:
               datalist4.append(data)
     
     sql4 = "".join(datalist4)
     cursor=connectdatabase(server)
     cursor.execute(sql4)
     
     
     while cursor.nextset():
         try:  
           result4 = cursor.fetchall() 
           break
         except pyodbc.ProgrammingError:
           continue

     exec(filename.strip()+'='+'book.add_sheet('+"\'"+filename.strip()+"\'"+')')
     columns = [column[0] for column in cursor.description]
     for z,f in enumerate(columns):
          eval(filename).write(0,z,f)
     
     for i,j in enumerate(result4,start=1):
        for x in range(len(j)):
           eval(filename).write(i,x,str(j[x]))





try:
   get_result_datachange('data_change_actions','data_change_actions_templete')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())


try:
   get_result_permission('Permission_actions','permission_actions_templete')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())


try:
   userlist('userlist')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())


try:
   userlist('comparison')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())


try:
   loginout('LOGINOUT')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())



book.save(excelfilename)
