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




# database connection
def connectdatabase():
     server = 'an-ca041-memcrm.database.chinacloudapi.cn'
     database = 'ITEMSRC'
     username = 'btsadmin'
     password = '54ES$hM+b?P$#@e7GwqPkc@92cZWgKjH'
     driver= '{ODBC Driver 17 for SQL Server}'
     cnxn = pyodbc.connect('DRIVER='+driver+';SERVER='+server+';PORT=1433;DATABASE='+database+';UID='+username+';PWD='+ password)
     cursor = cnxn.cursor()
     return cursor


try:

   sql='''
   CREATE NONCLUSTERED INDEX [INX_PRD_CRMNO] ON [dbo].[DW_Product_919]
   (
   	[CRMNO] ASC
   )WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
   
   
   CREATE NONCLUSTERED INDEX [INX_PRD_SerialNO] ON [dbo].[DW_Product_919]
   (
   	[SerialNO] ASC
   )WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
   
   
   CREATE NONCLUSTERED INDEX [NCL_DW_Product_BatchNum] ON [dbo].[DW_Product_919]
   (
   	[BatchNum] ASC
   )WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
   
   
   CREATE NONCLUSTERED INDEX [NCL_DW_Product_LoadDate] ON [dbo].[DW_Product_919]
   (
   	[LoadDate] ASC
   )WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
   
   
   CREATE NONCLUSTERED INDEX [NCL_DW_Product_ProductCode] ON [dbo].[DW_Product_919]
   (
   	[ProductCode] ASC
   )WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
   commit;
   '''
   cursor=connectdatabase()
   cursor.execute(sql)
   cursor.close()
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())






sender = 'chen.pan1@abbott.com'
passwd = '123456'
#receivers = ['xiaoqin.li4@abbott.com','weilan.yang@abbott.com','peng.wang1@abbott.com']
#cc_recivers =['alexandre.song@abbott.com','chen.pan1@abbott.com']
#receivers = ['xiaoqin.li4@abbott.com']
#cc_recivers =['weilan.yang@abbott.com','chen.pan1@abbott.com']
receivers = ['cookerjin@techgiven.com','rongor@techgiven.com']
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
Hi, cooker and rongrong

Indexes's creation on DW_Product_919 which has been imported data have got done. Please be aware. Thank you.
 
Regards,

Pan, Chen

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