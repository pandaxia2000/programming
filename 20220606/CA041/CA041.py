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

now = time.strftime("%Y-%m-%d-%H_%M_%S",time.localtime(time.time())) 
current_date = time.strftime("%B %Y",time.localtime(time.time()))


logging.basicConfig(filename=server+"_"+now+'_log.txt', level=logging.DEBUG,
     format='%(asctime)s - %(levelname)s - %(message)s')

#define excel file sheet name
book = xlwt.Workbook(encoding = 'utf-8')
#data_change_actions = book.add_sheet('data_change_actions')
#Permission_actions = book.add_sheet('Permission_actions')
#LOGINOUT = book.add_sheet('LOGINOUT')
#userlist = book.add_sheet('userlist')
#comparison = book.add_sheet('comparison')
excelfilename=server+"_CA041_"+now+".xls"


# database connection
def connectdatabase(databasename):
     server = 'an-ca041-memcrm.database.chinacloudapi.cn'
     database = databasename
     username = 'btsadmin'
     password = 'R+Ay*eE!Gdjt&4%=67EWT+qMh+fuC9Q?'
     driver= '{ODBC Driver 17 for SQL Server}'
     cnxn = pyodbc.connect('DRIVER='+driver+';SERVER='+server+';PORT=1433;DATABASE='+database+';UID='+username+';PWD='+ password)
     cursor = cnxn.cursor()
     return cursor



def precondition(filename):
     cursor=connectdatabase(database)
     datalist6=[]
     with open(cwd+source+filename+'.txt', "r") as f6:
          for data in f6:
              datalist6.append(data)

     sql6 = "".join(datalist6)
     for statement in sql6.split(';'):
          cursor.execute(statement)


def userlist(filename):
     datalist4=[]
     with open(cwd+source+filename+'.txt', "r") as f4:
           for data in f4:
               datalist4.append(data)
     sql4 = "".join(datalist4)
     cursor=connectdatabase(database)
     cursor.execute(sql4)
     while cursor.nextset():
         try:  
           result4 = cursor.fetchall() 
           break
         except pyodbc.ProgrammingError:
           continue
     exec(filename.strip()+'='+'book.add_sheet('+"\'"+filename.strip()+"_"+database+"\'"+')')
     columns = [column[0] for column in cursor.description]
     for z,f in enumerate(columns):
          eval(filename).write(0,z,f)
     for i,j in enumerate(result4,start=1):
        for x in range(len(j)):
           eval(filename).write(i,x,str(j[x]))


def get_result(actions_filename):
     datalist1=[]
     with open(cwd+source+actions_filename + '.txt', "r") as f1:
           for data in f1:
               datalist1.append(data)
     
     sql1 = "".join(datalist1)
     cursor=connectdatabase(database)
     cursor.execute(sql1)
     result1 = cursor.fetchall()
     if result1:
        exec(actions_filename.strip()+'='+'book.add_sheet('+"\'"+database+'_datachange'"\'"+')')
        columns = [column[0] for column in cursor.description]
        for z,f in enumerate(columns):
             eval(actions_filename).write(0,z,f)
        for i,j in enumerate(result1,start=1):
             for x in range(len(j)):
                  eval(actions_filename).write(i,x,str(j[x]))



database='WECHATBACKEND'
source='\Scripts\\'+server+'\\'
outputfilepath = '\\'

try:
   precondition('WECHATBACKEND_precondition')
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
   get_result('get_result')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())




database='ABBOTTCRM'
source='\Scripts\\'+server+'\\'
outputfilepath = '\\'

try:
   precondition('ABBOTTCRM_precondition')
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
   get_result('get_result')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())





database='ABTCRMARC'
source='\Scripts\\'+server+'\\'
outputfilepath = '\\'

try:
   precondition('ABTCRMARC_precondition')
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
   get_result('get_result')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())




database='ABTPOINTSMALL'
source='\Scripts\\'+server+'\\'
outputfilepath = '\\'

try:
   precondition('ABTPOINTSMALL_precondition')
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
   get_result('get_result')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())




database='ITEMSRC'
source='\Scripts\\'+server+'\\'
outputfilepath = '\\'

try:
   precondition('ITEMSRC_precondition')
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
   get_result('get_result')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())



book.save(excelfilename)



sender = 'chen.pan1@abbott.com'
passwd = '123456'
#receivers = ['chen.pan1@abbott.com']
#cc_recivers =['chen.pan1@abbott.com']
receivers = ['xiaoqin.li4@abbott.com','weilan.yang@abbott.com','rongor@techgiven.com','peng.wang1@abbott.com','terry.ni@abbott.com','kevin.chen1@abbott.com','shirley.chen1@abbott.com']
cc_recivers =['chen.pan1@abbott.com']
receiver = ','.join(receivers)
cc_receiver = ','.join(cc_recivers)
allreceiver = receiver +','+ cc_receiver
mail_host = 'mail.oneabbott.com'  
msg = MIMEMultipart() 
msg['From'] = sender 
msg['To'] = receiver 
msg['Cc'] = cc_receiver 
msg['Subject'] = 'Audit logs of '+server+' for '+current_date 
attach_num=0
cwd=os.getcwd()
filepath='\\'

msg.attach(MIMEText('''
Hi, all,

The  audit review report of '''+server+''' has been enclosed as attachment for your visibility. Please check. Thank you.

 
Regards,

Pan, Chen

''', 'plain', 'utf-8')) 



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