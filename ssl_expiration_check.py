import ssl
import socket
import datetime
import time
import smtplib
from email.mime.text import MIMEText
from email.header import Header
import traceback
import logging

now = time.strftime("%Y-%m-%d-%H_%M_%S",time.localtime(time.time())) 

logging.basicConfig(filename='ssl_expiration_check'+now+'_log.txt', level=logging.DEBUG,
     format='%(asctime)s - %(levelname)s - %(message)s')

def ssl_expiry_datetime(host, port=443):
    ssl_date_fmt = r'%b %d %H:%M:%S %Y %Z'
    now = time.strftime(r'%Y-%m-%d %H:%M:%S')
    context = ssl.create_default_context()
    conn = context.wrap_socket(
        socket.socket(socket.AF_INET),
        server_hostname=host,
    )
    conn.settimeout(3.0)
    conn.connect((host, port))
    ssl_info = conn.getpeercert()
    #print(ssl_info)
    name = (ssl_info['subject'][4][0][1])
    res = datetime.datetime.strptime(ssl_info['notAfter'], ssl_date_fmt)
    now=datetime.datetime.strptime(now, '%Y-%m-%d %H:%M:%S')
    leftdays=(res-now).days
    if leftdays < 30:
        full = '%(name)s : %(res)s left days to expiration: %(leftdays)s' % {"name": host,"res": res,"leftdays": leftdays}
        datalist4.append(full)


try:

     datalist4=[]
     with open('ssl_list.txt',"r",encoding="utf-8") as f1:
        for line in f1:
           line1=line.strip('\n')
           try:
              ssl_expiry_datetime(line1)
           except:
              #print(line1+' is not reachable.')
              pass
           continue
     
     
     ## sending email
     
     if len(datalist4)>0:
          datafile5=[]
          for i in datalist4:
              datafile5.append(i+'\n')
          
          content="".join(datafile5)
          
          
          smtpObj = smtplib.SMTP('mail.oneabbott.com','25','mail.oneabbott.com')
          
          sender = 'chen.pan1@abbott.com'
          receivers = ['chen.pan1@abbott.com','nick.wang2@abbott.com','jingbin.xue@abbott.com']
          #receivers = ['chen.pan1@abbott.com']
          message = MIMEText(content, 'plain', 'utf-8')
          message['From'] = Header(sender, 'utf-8')   # 发送者
          #message['From'] = Header(sender, 'utf-8')   # 发送者
          #message['To'] =  Header(receivers, 'utf-8')        # 接收者
          message['To'] = ','.join(receivers)
          
          content = 'hello, this is email content.'
          textApart = MIMEText(content)
          
          
          subject = 'SSL certification expiration warning'
          message['Subject'] = Header(subject, 'utf-8')
          
          try:
             smtpObj.sendmail(sender, message['To'].split(','), message.as_string())
             smtpObj.quit()
             print("mail sent successfully")
          except smtplib.SMTPException:
             print("Error: mail did not send")
     else:
          print('no expiration SSL is found.')
except:
   logging.debug(traceback.format_exc())
else:
   logging.debug(traceback.format_exc())