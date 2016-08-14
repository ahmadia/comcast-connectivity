#!/Users/aron/miniconda/bin/python

import os
import time
import datetime
import subprocess
import pickle

RESULTS_FILE = 'results.pickle'
LOG_FILE = open('test.log', 'w')

def print_log(x):
    print(x, file=LOG_FILE)
    print(x)

print_log("hello from test.py")


results = {}


up_minutes = 1
down_minutes = 0

while 1:
    d = datetime.datetime.today()
    print_log(str(d))
    print_log("Connection has been up {} minutes and down {} minutes".format(up_minutes, down_minutes))
    print_log("{:.2%} uptime".format(up_minutes/(up_minutes + down_minutes)))
    workdir="{}/{}/{}/{}".format(d.year, d.month, d.day, d.hour)
    os.makedirs(workdir, exist_ok=True)
    fname = "{}/{}.txt".format(workdir, d.minute)
    if os.path.exists(fname):
        time.sleep(20)
        continue
    try:
        x = subprocess.check_output('./test.sh')
        result = True
    except subprocess.CalledProcessError as err:
        result = False
        x = err.output
    with open(fname, 'wb') as f:
        f.write(x)

    results[(d.year, d.month, d.day, d.hour, d.minute)] = result
    if result:
        up_minutes += 1
    else:
        down_minutes += 1
    pickle.dump(results, open(RESULTS_FILE, "wb" ) )
 
