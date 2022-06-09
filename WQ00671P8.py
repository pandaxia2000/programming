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

reload(sys)
sys.setdefaultencoding('utf8')

cwd=os.getcwd()
server=socket.gethostname()
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
#userlist = book.add_sheet('userlist')
#comparison = book.add_sheet('comparison')
excelfilename=server+now+".xls"


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



def userlist2(filename):
     datalist5=[]
     with open(cwd+source+filename+'.txt', "r") as f5:
           for data in f5:
               datalist5.append(data)
     sql5 = "".join(datalist5)
     cursor=connectdatabase(server)
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
     cursor=connectdatabase(server)
     datalist6=[]
     with open(cwd+source+filename+'.txt', "r") as f6:
          for data in f6:
              datalist6.append(data)

     sql6 = "".join(datalist6)
     for statement in sql6.split(';'):
          cursor.execute(statement)



try:
   precondition('precondition')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())



try:
   userlist('summary')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())


try:
   userlist('reference_list')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())



try:
   userlist2('userlist')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())



try:
   userlist2('comparison')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())



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
   loginout('LOGINOUT')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())



book.save(excelfilename)



sender = 'chen.pan1@abbott.com'
passwd = '123456'
receivers = ['xiaoqin.li4@abbott.com','weilan.yang@abbott.com','peng.wang1@abbott.com']
cc_recivers =['alexandre.song@abbott.com','chen.pan1@abbott.com']
receiver = ','.join(receivers)
cc_receiver = ','.join(cc_recivers)
allreceiver = receiver +','+ cc_receiver
mail_host = 'mail.oneabbott.com'  
msg = MIMEMultipart() 
msg['From'] = sender 
msg['To'] = receiver 
msg['Cc'] = cc_receiver 
msg['Subject'] = 'Audit report of '+server+' for '+current_date 
attach_num=0
cwd=os.getcwd()
filepath='\\'

msg.attach(MIMEText('''
Hi, all,

The  audit review report of '''+server+''' has been enclosed as attachment. Please check. Thank you.

 
Regards,

Chen.pan

''', 'plain', 'utf-8')) 

#att1 = MIMEText(open(cwd+outputfilepath+excelfilename, 'rb').read(), 'base64', 'utf-8') 
#att1['Content-Type'] = 'application/octet-stream' 
#att1['Content-Disposition'] = 'attachment; filename='+excelfilename 
#msg.attach(att1) 
##smtpObj = smtplib.SMTP()
#smtpObj = smtplib.SMTP('mail.oneabbott.com','25','mail.oneabbott.com')
##smtpObj.connect(mail_host, 25)
##smtpObj.login(sender, passwd)
#smtpObj.sendmail(sender, receiver, msg.as_string())
#logging.debug(traceback.format_exc())


try:
     att1 = MIMEText(open(cwd+outputfilepath+excelfilename, 'rb').read(), 'base64', 'utf-8') 
     att1['Content-Type'] = 'application/octet-stream' 
     att1['Content-Disposition'] = 'attachment; filename='+excelfilename 
     msg.attach(att1)
     smtpObj = smtplib.SMTP('mail.oneabbott.com','25','mail.oneabbott.com')
     smtpObj.sendmail(sender, allreceiver.split(','), msg.as_string())
except:
     logging.debug(traceback.format_exc())
else:
     logging.debug(traceback.format_exc())