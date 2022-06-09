import mysql.connector
from mysql.connector import errorcode
import xlwt
import time
import os
import re
import sys

#define excel file sheet name

source='C:\Temp\\'

now = time.strftime("%Y-%m-%d-%H_%M_%S",time.localtime(time.time())) 
book = xlwt.Workbook(encoding = 'utf-8')
sheet = book.add_sheet('result')
excelfilename=source+"mysql_user_priviliges_"+now+".xls"


# Construct connection string
def connectmysql():
    try:
       conn = mysql.connector.connect(**config)
       print("Connection established")
    except mysql.connector.Error as err:
      if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("Something is wrong with the user name or password")
      elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("Database does not exist")
      else:
        print(err)
    return conn

i2=1
x2=0


with open(source+'Azure_mysql_prod_serverlist.txt', "r") as f:
    for line in f.readlines():
        line1 = line.strip('\n').split(',')
        config = {
          'host':line1[0],
          'user':line1[1],
          'password':line1[2]
        }
        cn=connectmysql()
        cursor=cn.cursor()
        datalist1=[]
        with open(source+'queryprivs_mysql.txt', "r") as f1:
               for data in f1:
                  datalist1.append(data)
                  sql1 = "".join(datalist1)
                  sql2 = re.sub('##########',config['host'],sql1)
                  cursor.execute(sql2)
                  result1 = cursor.fetchall()
                  if i2<2:
                      columns = [column[0] for column in cursor.description]
                      for z,f in enumerate(columns):
                         sheet.write(0,z,f)
                  for i,j in enumerate(result1,start=1):
                            print(i,len(j))
                            for x in range(len(j)):
                                print(i,x,str(j[x]))					  
                                sheet.write(i2,x,str(j[x]))
                            i2=i2+1
                            x2=x2+x

book.save(excelfilename)