# -*- coding: utf-8 -*-

import pyodbc
import xlwt
import time
import os
import re
import sys

reload(sys) 
sys.setdefaultencoding('utf8')

cwd=os.getcwd()
source='\Scripts\WQ00662P\\'


# database connection
cnxn = pyodbc.connect(r'Driver={SQL Server};Server=WQ00662P;Database=tempdb;Trusted_Connection=yes;')
cursor = cnxn.cursor()

#define excel file sheet name



now = time.strftime("%Y-%m-%d-%H_%M_%S",time.localtime(time.time())) 
book = xlwt.Workbook(encoding = 'utf-8')

data_change_actions = book.add_sheet('data_change_actions')
Permission_actions = book.add_sheet('Permission_actions')
LOGINOUT = book.add_sheet('LOGINOUT')
userlist = book.add_sheet('userlist')
comparison = book.add_sheet('comparison')
excelfilename="WQ00662P_"+now+".xls"



##data change actions

datalist1=[]
with open(cwd+source+'data_change_actions.txt', "r") as f1:
      for data in f1:
          datalist1.append(data)

sql1 = "".join(datalist1)

cursor.execute(sql1)

result1 = cursor.fetchall()

if result1:
   columns = [column[0] for column in cursor.description]
   for z,f in enumerate(columns):
        data_change_actions.write(0,z,f)

   for i,j in enumerate(result1,start=1):
      for x in range(len(j)):
         data_change_actions.write(i,x,str(j[x]))

actions1=[]

for i in range(0,len(result1)):
    actions1.append(result1[i][0])

data_change_actions_templete_name='data_change_actions_templete.txt'
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




##permission actions

datalist2=[]
with open(cwd+source+'Permission_actions.txt', "r") as f2:
      for data in f2:
          datalist2.append(data)

sql2 = "".join(datalist2)

cursor.execute(sql2)

result2 = cursor.fetchall()

if result2:
   columns = [column[0] for column in cursor.description]
   for z,f in enumerate(columns):
        Permission_actions.write(0,z,f)

   for i,j in enumerate(result2,start=1):
      for x in range(len(j)):
         Permission_actions.write(i,x,str(j[x]))


actions2=[]

for i in range(0,len(result2)):
    actions2.append(result2[i][0])


permission_actions_templete_name='permission_actions_templete.txt'
for action in actions2:
  with open(cwd+source+permission_actions_templete_name, "r") as f2:
      sql=[]
      for line in f2:
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



##userlist

datalist4=[]
with open(cwd+source+'userlist.txt', "r") as f4:
      for data in f4:
          datalist4.append(data)

sql4 = "".join(datalist4)

cursor.execute(sql4)


while cursor.nextset():
    try:  
      result4 = cursor.fetchall() 
      break
    except pyodbc.ProgrammingError:
      continue

columns = [column[0] for column in cursor.description]
for z,f in enumerate(columns):
     userlist.write(0,z,f)

for i,j in enumerate(result4,start=1):
   for x in range(len(j)):
      userlist.write(i,x,str(j[x]))




##comparison

datalist5=[]
with open(cwd+source+'comparison.txt', "r") as f5:
      for data in f5:
          datalist5.append(data)

sql5 = "".join(datalist5)

cursor.execute(sql5)


while cursor.nextset():
    try:  
      result5 = cursor.fetchall() 
      break
    except pyodbc.ProgrammingError:
      continue

columns = [column[0] for column in cursor.description]
for z,f in enumerate(columns):
     comparison.write(0,z,f)

for i,j in enumerate(result5,start=1):
   for x in range(len(j)):
      comparison.write(i,x,str(j[x]))







##loginout

datalist6=[]
with open(cwd+source+'LOGINOUT.txt', "r") as f6:
      for data in f6:
          datalist6.append(data)

sql6 = "".join(datalist6)

cursor.execute(sql6)

result6 = cursor.fetchall()

if result6:
   columns = [column[0] for column in cursor.description]
   for z,f in enumerate(columns):
       LOGINOUT.write(0,z,f)

   for i,j in enumerate(result6,start=1):
       for x in range(len(j)):
          LOGINOUT.write(i,x,str(j[x]))


book.save(excelfilename)
