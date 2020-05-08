#C:\Python38\python3.exe
#scans logs for excessivly long draw loops
import argparse
import time
import datetime
def scan(log,max,find):
    file=open(log,"r");
    line=file.readline();
    lastDate=-1;
    lastTime=0;
    lastTimestamp="";
    while line:
        if(line.find(find)>0):
            timestamp=line[1:line.find(']')]
            day=time.mktime(datetime.datetime.strptime(timestamp[0:timestamp.find(" ")], "%Y/%m/%d").timetuple())
            daytime=timestamp[timestamp.find(" ")+1:].split(":")
            hour=int(daytime[0])
            minute=int(daytime[1])+hour*60
            
            second=float(daytime[2])+minute*60
            if(lastDate>0):
                durration=(day-lastDate)+(second-lastTime)
                if(durration>max):
                    print(lastTimestamp+" - "+timestamp+" "+str(durration))
            lastDate=day
            lastTime=second
            lastTimestamp=timestamp
        line=file.readline()
    file.close()
parser = argparse.ArgumentParser(description='scans logs for excessivly long draw loops')
parser.add_argument('-l', help='log file to scan')
parser.add_argument('-t', help='Maximum time each itteration should take (in seconds)')
parser.add_argument('-f',help='String to look for to start itteration')

args = parser.parse_args()
scan(args.l,float(args.t),args.f)
