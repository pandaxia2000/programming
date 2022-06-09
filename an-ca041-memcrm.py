# -*- coding: utf-8 -*-

import pyodbc
import xlwt
import time
import os
import re
import sys
import traceback
import logging
import smtplib 
from email.mime.text import MIMEText 
from email.mime.multipart import MIMEMultipart
import socket

#reload(sys)
#sys.setdefaultencoding('utf8')

cwd=os.getcwd()
server='an-ca041-memcrm'
source='\Scripts\\'+server+'\\'
outputfilepath = '\\'
now = time.strftime("%Y-%m-%d-%H_%M_%S",time.localtime(time.time())) 
current_date = time.strftime("%B %Y",time.localtime(time.time()))


logging.basicConfig(filename=server+'_'+now+'_log.txt', level=logging.DEBUG,
     format='%(asctime)s - %(levelname)s - %(message)s')




#define excel file sheet name
book = xlwt.Workbook(encoding = 'utf-8')
#data_change_actions = book.add_sheet('data_change_actions')
#Permission_actions = book.add_sheet('Permission_actions')
#LOGINOUT = book.add_sheet('LOGINOUT')
userlist3 = book.add_sheet('userlist')
#comparison = book.add_sheet('comparison')
summary = book.add_sheet('summary')
reference = book.add_sheet('reference')
excelfilename=server+now+".xls"


# database connection
def connectdatabase(databasename):
     server = 'an-ca041-memcrm.database.chinacloudapi.cn'
     database = databasename
     username = 'btsadmin'
     password = '54ES$hM+b?P$#@e7GwqPkc@92cZWgKjH'
     driver= '{ODBC Driver 17 for SQL Server}'
     cnxn = pyodbc.connect('DRIVER='+driver+';SERVER='+server+';PORT=1433;DATABASE='+database+';UID='+username+';PWD='+ password)
     cursor = cnxn.cursor()
     return cursor



def get_result_datachange(actions_filename,templete_filename):
     datalist1=[]
     with open(cwd+source+actions_filename + '.txt', "r") as f1:
           for data in f1:
               datalist1.append(data)
     
     sql1 = "".join(datalist1)
     cursor=connectdatabase()
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
     cursor=connectdatabase()
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
     cursor=connectdatabase()
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
     cursor=connectdatabase()
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


def userlist2(filename):
     datalist5=[]
     with open(cwd+source+filename+'.txt', "r") as f5:
           for data in f5:
               datalist5.append(data)
     sql5 = "".join(datalist5)
     cursor=connectdatabase()
     cursor.execute(sql5)
     result5 = cursor.fetchall()
     exec(filename.strip()+'='+'book.add_sheet('+"\'"+filename.strip()+"\'"+')')
     columns = [column[0] for column in cursor.description]
     for z,f in enumerate(columns):
          eval(filename).write(0,z,f)
     for i,j in enumerate(result5,start=1):
        for x in range(len(j)):
           eval(filename).write(i,x,str(j[x]))


def precondition(filename):
     cursor=connectdatabase()
     datalist6=[]
     with open(cwd+source+filename+'.txt', "r") as f6:
          for data in f6:
              datalist6.append(data)
     sql6 = "".join(datalist6)
     for statement in sql6.split(';'):
          cursor.execute(statement)



def precondition2(filename):
     cursor=connectdatabase('master')
     datalist7=[]
     with open(cwd+source+filename+'.txt', "r") as f7:
          for data in f7:
              datalist7.append(data)
     sql7 = "".join(datalist7)
     cursor.execute(sql7)
     result7 = cursor.fetchall()






#precondition
try:

   databaselist_sql='''
   select name from sys.databases where name<>'master';
   '''
   servername_sql='''
   select @@servername;
   '''
   temptablesql='''
   select distinct username,action_id, session_server_principal_name,database_name into #all_actions
   from fn_get_audit_file('https://abtcndblogs.blob.core.chinacloudapi.cn/sqldbauditlogs/an-ca041-memcrm/##########',default,default)
   where event_time>=convert(varchar(10),getdate()-30,120);
   
   select distinct username,action_id, session_server_principal_name,database_name into #all_actions_last_month
   from fn_get_audit_file('https://abtcndblogs.blob.core.chinacloudapi.cn/sqldbauditlogs/an-ca041-memcrm/##########',default,default)
   where datediff(day,event_time,getdate()) between 30 and 60;
   
   
   select aa.* into #userlist from 
   (select a.name from sys.server_principals a 
   where a.is_disabled=0 and type in ('U','S')
   union
   select b.session_server_principal_name from #all_actions b) aa;

   '''
   cursor=connectdatabase('master')
   cursor.execute(databaselist_sql)
   databaselist=[]
   databaselist=cursor.fetchall()
   print(servername_sql)
   cursor.execute(servername_sql)
   servername=cursor.fetchall()
   cursor.close()
   for i in databaselist:
      cursor=connectdatabase(i[0])
      mid3=temptablesql
      mid4=re.sub('##########',servername[0][0],mid3)
      print(mid4)
      #cursor.execute(mid4)
   userlist_sql1='''
   select a.name,concat( CONVERT(varchar(10),GETDATE()-30,120), '~',CONVERT(varchar(10),GETDATE(),120)) "Audit Trace Period",
   '''
   userlist_sql2='''
    from #userlist a where len(a.name)>0;
   '''
   userlist_sql='''
   select distinct a.action_id from sys.dm_audit_actions a where a.action_id in ('ACDO','ACO')
   '''
   userlist_statement='''
   '########'= case when exists (select 1 from #all_actions ######## where ########.session_server_principal_name=a.name and ########.action_id='########') then 'Y' else 'N' end,'########_last_month'= case when exists (select 1 from #all_actions_last_month ########_last_month where ########_last_month.session_server_principal_name=a.name and ########_last_month.action_id='########') then 'Y' else 'N' end
   '''
   datalist99=[]
   cursor.execute(userlist_sql)
   datalist99=cursor.fetchall()
   datalist100=[]
   for i in datalist99:
      mid=userlist_statement
      mid2=re.sub('########',i[0].strip(),mid)
      datalist100.append(mid2)
   joinedlist = ','.join(datalist100)
   joinedlist = temptablesql+userlist_sql1+joinedlist+userlist_sql2
   print(joinedlist)
   cursor.execute(joinedlist)
   while cursor.nextset():
       try:  
         result4 = cursor.fetchall() 
         break
       except pyodbc.ProgrammingError:
         continue
   #exec(filename.strip()+'='+'book.add_sheet('+"\'"+filename.strip()+"\'"+')')
   columns = [column[0] for column in cursor.description]
   for z,f in enumerate(columns):
        userlist3.write(0,z,f)
   for i,j in enumerate(result4,start=1):
      for x in range(len(j)):
         userlist3.write(i,x,str(j[x]))
   summary_sql='''
   select xx.name,xx.[Audit Trace Period],xx.database_name,xx.type,xx.action,xx.create_date,xx.modify_date,
   'comment'= 
   case 
   when  xx.name like '%##' or xx.name like '%$' then 'application account'
   when xx.name in ('btsadmin') then 'Administrator'
   when exists (select 1 from sys.database_principals g where g.name=xx.name) then '' 
   else 'Come from local administrators group which is added by global team' 
   end
   from
   (select a.name,concat( CONVERT(varchar(10),GETDATE()-30,120), '~',CONVERT(varchar(10),GETDATE(),120)) "Audit Trace Period",actions.database_name,
   actions.action_id action,
   a.type,a.create_date,a.modify_date 
   from sys.database_principals a left join #all_actions actions on a.name=actions.username
   where  a.type in ('U','S') and a.owning_principal_id is null and type='S' and a.authentication_type=1 and len(a.sid)>5
   union
   select all_actions.username,concat( CONVERT(varchar(10),GETDATE()-30,120), '~',CONVERT(varchar(10),GETDATE(),120)) "Audit Trace Period",
   all_actions.database_name,
   all_actions.action_id datachange_action,
   a.type,a.create_date,a.modify_date 
   from #all_actions all_actions left join 
   sys.database_principals a on a.name=all_actions.username 
   where all_actions.username<>''
   ) xx
   '''
   cursor.execute(summary_sql)
   datalist_summary=cursor.fetchall()
   columns = [column[0] for column in cursor.description]
   for z,f in enumerate(columns):
        summary.write(0,z,f)
   for i,j in enumerate(datalist_summary,start=1):
      for x in range(len(j)):
         summary.write(i,x,str(j[x]))
   reference_sql='''
   select distinct a.action_id,name from sys.dm_audit_actions a;
   '''
   cursor.execute(reference_sql)
   datalist_reference=cursor.fetchall()
   columns = [column[0] for column in cursor.description]
   for z,f in enumerate(columns):
        reference.write(0,z,f)
   for i,j in enumerate(datalist_reference,start=1):
      for x in range(len(j)):
         reference.write(i,x,str(j[x]))
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())




#try:
#     filename='userlist'
#     sql1='''
#     select a.name,concat( CONVERT(varchar(10),GETDATE()-30,120), '~',CONVERT(varchar(10),GETDATE(),120)) "Audit Trace Period",
#     '''
#     sql2='''
#      from [master].[dbo].[userlist] a where len(a.name)>0;
#     '''
#     sql='''
#     select distinct a.action_id from sys.dm_audit_actions a where a.action_id in ('ACDO','ACO')
#     '''
#     statement='''
#     '########'= case when exists (select 1 from [master].[dbo].[all_actions] ######## where ########.session_server_principal_name=a.name and ########.action_id='########') then 'Y' else 'N' end,'########_last_month'= case when exists (select 1 from [master].[dbo].[all_actions_last_month] ########_last_month where ########_last_month.session_server_principal_name=a.name and ########_last_month.action_id='########') then 'Y' else 'N' end
#     '''
#     datalist99=[]
#     cursor=connectdatabase('master')
#     cursor.execute(sql)
#     datalist99=cursor.fetchall()
#     datalist100=[]
#     for i in datalist99:
#        mid=statement
#        mid2=re.sub('########',i[0].strip(),mid)
#        datalist100.append(mid2)
#     joinedlist = ','.join(datalist100)
#     joinedlist = sql1+joinedlist+sql2
#     cursor.execute(joinedlist)
#     while cursor.nextset():
#         try:  
#           result4 = cursor.fetchall() 
#           break
#         except pyodbc.ProgrammingError:
#           continue
#     exec(filename.strip()+'='+'book.add_sheet('+"\'"+filename.strip()+"\'"+')')
#     columns = [column[0] for column in cursor.description]
#     for z,f in enumerate(columns):
#          eval(filename).write(0,z,f)
#     for i,j in enumerate(result4,start=1):
#        for x in range(len(j)):
#           eval(filename).write(i,x,str(j[x]))
#except:
#   logging.debug(traceback.format_exc())
#else:
#   logging.debug(traceback.format_exc())






book.save(excelfilename)

