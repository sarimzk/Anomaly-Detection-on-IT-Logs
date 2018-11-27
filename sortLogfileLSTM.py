import csv
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import time
import datetime
import dateutil.parser
from datetime import datetime
from dateutil.parser import parse
import datetime
import dateutil.parser
import time
#re.compile('<title>(.*)</title>')
#%matplotlib inline
#Path to CSV Files
start = time.time()

path = "/Users/vikrant/jupyternotebooks/"
os.chdir(path)
print("pathset")
#Create DATAFRAME
start1 = time.time()
df1=pd.read_csv('50kmarch.csv', na_filter=False)
end1= time.time()
print("Took %f ms in reading complete logfile" % ((end1 - start1) * 1000.0))
df2= df1.iloc[0:10000000]
df2.columns=["Time", "Machine", "Daemon", "Log_Message"]
print("readfile 5 m logs")
#df2=df1
#Create Smaller Datasets
dft=df2
dft2=df2
print("Smaller datasets created")
#SORTING USING METHOD1
start2 = time.time()
dft[['date', 'time']] = dft2.Time.str.split(' ', expand = True)
dft.sort_values("date", inplace=True)
dft.to_csv('logfileSorted2extraColumns.csv')
print("CSV File dft.csv created")
end2= time.time()
print("Took %f ms in creating csv method1" % ((end2 - start2) * 1000.0))
#SORTING using method2
start3 = time.time()
dft3 = dft2.sort_values(by='Time',ascending=True)
dft3.to_csv('logfileSorted.csv')
print("CSV File dft3.csv created")
end3= time.time()
print("Took %f ms in creating csv method1" % ((end3 - start3) * 1000.0))
end = time.time()
print("Took %f ms in reading and running two methods" % ((end - start) * 1000.0))
