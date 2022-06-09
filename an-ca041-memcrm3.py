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
def connectdatabase(databasename):
     server = 'an-ca041-memcrm.database.chinacloudapi.cn'
     database = databasename
     username = 'btsadmin'
     password = 'R+Ay*eE!Gdjt&4%=67EWT+qMh+fuC9Q?'
     driver= '{ODBC Driver 17 for SQL Server}'
     cnxn = pyodbc.connect('DRIVER='+driver+';SERVER='+server+';PORT=1433;DATABASE='+database+';UID='+username+';PWD='+ password)
     cursor = cnxn.cursor()
     return cursor



drop_last_last_month_records='''
drop table if exists [last_month_audit_records];

drop table if exists [last_month_audit_records_for_privilege_accounts];

'''

collect_privilege_accounts_last_month_records='''
select * into last_month_audit_records_for_privilege_accounts from last_month_audit_records where server_principal_name in(
'SONGRX3');
commit;
'''


try:
   collect_last_month_records='''
   select 
   	af.event_time,
   	af.action_id,
   	af.server_principal_name,
   	af.server_instance_name,
   	af.database_name,
   	af.schema_name,
   	af.object_name,
   	af.statement into [last_month_audit_records]
   from fn_get_audit_file ('https://anca041datalogprod.blob.core.chinacloudapi.cn/sqldbauditlogs/an-ca041-memcrm/ABBOTTCRM',default,default) af	
   where event_time>=DATEADD(mm, DATEDIFF(m,0,getdate())-1, 0) 
   and event_time<=dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,getdate()), 0));
   commit;
   '''
   cursor=connectdatabase('ABBOTTCRM')
   cursor.execute(drop_last_last_month_records)
   cursor.execute(collect_last_month_records)
   cursor.execute(collect_privilege_accounts_last_month_records)
   cursor.close()
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())



try:
   collect_last_month_records='''
   select 
   	af.event_time,
   	af.action_id,
   	af.server_principal_name,
   	af.server_instance_name,
   	af.database_name,
   	af.schema_name,
   	af.object_name,
   	af.statement into [last_month_audit_records]
   from fn_get_audit_file ('https://anca041datalogprod.blob.core.chinacloudapi.cn/sqldbauditlogs/an-ca041-memcrm/ABTCRMARC',default,default) af	
   where event_time>=DATEADD(mm, DATEDIFF(m,0,getdate())-1, 0) 
   and event_time<=dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,getdate()), 0));
   commit;
   '''
   cursor=connectdatabase('ABTCRMARC')
   cursor.execute(drop_last_last_month_records)
   cursor.execute(collect_last_month_records)
   cursor.execute(collect_privilege_accounts_last_month_records)
   cursor.close()
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())




try:
   collect_last_month_records='''
   select 
   	af.event_time,
   	af.action_id,
   	af.server_principal_name,
   	af.server_instance_name,
   	af.database_name,
   	af.schema_name,
   	af.object_name,
   	af.statement into [last_month_audit_records]
   from fn_get_audit_file ('https://anca041datalogprod.blob.core.chinacloudapi.cn/sqldbauditlogs/an-ca041-memcrm/ABTPOINTSMALL',default,default) af	
   where event_time>=DATEADD(mm, DATEDIFF(m,0,getdate())-1, 0) 
   and event_time<=dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,getdate()), 0));
   commit;
   '''
   cursor=connectdatabase('ABTPOINTSMALL')
   cursor.execute(drop_last_last_month_records)
   cursor.execute(collect_last_month_records)
   cursor.execute(collect_privilege_accounts_last_month_records)
   cursor.close()
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())




try:
   collect_last_month_records='''
   select 
   	af.event_time,
   	af.action_id,
   	af.server_principal_name,
   	af.server_instance_name,
   	af.database_name,
   	af.schema_name,
   	af.object_name,
   	af.statement into [last_month_audit_records]
   from fn_get_audit_file ('https://anca041datalogprod.blob.core.chinacloudapi.cn/sqldbauditlogs/an-ca041-memcrm/ITEMSRC',default,default) af	
   where event_time>=DATEADD(mm, DATEDIFF(m,0,getdate())-1, 0) 
   and event_time<=dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,getdate()), 0));
   commit;
   '''
   cursor=connectdatabase('ITEMSRC')
   cursor.execute(drop_last_last_month_records)
   cursor.execute(collect_last_month_records)
   cursor.execute(collect_privilege_accounts_last_month_records)
   cursor.close()
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())



try:
   collect_last_month_records='''
   select 
   	af.event_time,
   	af.action_id,
   	af.server_principal_name,
   	af.server_instance_name,
   	af.database_name,
   	af.schema_name,
   	af.object_name,
   	af.statement into [last_month_audit_records]
   from fn_get_audit_file ('https://anca041datalogprod.blob.core.chinacloudapi.cn/sqldbauditlogs/an-ca041-memcrm/WECHATBACKEND',default,default) af	
   where event_time>=DATEADD(mm, DATEDIFF(m,0,getdate())-1, 0) 
   and event_time<=dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,getdate()), 0));
   commit;
   '''
   cursor=connectdatabase('WECHATBACKEND')
   cursor.execute(drop_last_last_month_records)
   cursor.execute(collect_last_month_records)
   cursor.execute(collect_privilege_accounts_last_month_records)
   cursor.close()
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())
