import csv
import time
import logging
import sys, os
from fileinput import filename

sys.path.append(os.path.dirname(os.path.dirname(__file__)))  # Projekt-Root
import requests
import numpy as np
import datetime
from tektronixAFG31252 import AFG31252

logger = logging.getLogger(__name__)
def main():
    time_now = datetime.date.today()
    log_filename = 'measurments' + time_now + '.log'
    logging.basicConfig(filename=log_filename,level=logging.INFO)
    logger.info('start_setup')
    afg_ip = '10.140.1.17'
    afg = AFG31252(afg_ip)
    f_min = 1
    f_max = 1e6
    N = 100
    first = np.arange(1, 11, dtype=float)  # 1..10
    M = N - 10
    j = np.arange(M)  # 0..M
    rest = 10.0 * (f_max / 10.0) * -1 * ((j + 1) / M)  # startet >10, endet exakt bei f_max
    freqs_mhz = np.concatenate([first, rest])  # Länge N
    data = sequenze1(afg,freqs_mhz)
    save_csv("seq1.csv",data)
    data = sequenze2(afg,freqs_mhz)
    save_csv("sequenz2",data)
    data = sequenze3(afg,freqs_mhz)
    save_csv("seq3.csv",data)


def sequenze1(afg,freqs_mhz):
    data = []
    afg.set_output(1, 1)
    afg.set_output(2, 0)
    for freq in freqs_mhz :
        afg.set_frequency(afg,1,freq)
        time.sleep(2)
        counts = request_counts(1)
        data.append([freq,counts])
    logging.info("Sequenz 1 finished")
    return data

def sequenze2(afg,freqs_mhz):
    data = []
    afg.set_output(1, 0)
    afg.set_output(2, 1)
    for freq in freqs_mhz :
        afg.set_frequency(afg,2,freq)
        time.sleep(2)
        counts = request_counts(2)
        data.append([freq,counts])
    logging.info("Sequenz 2 finished")
    return data

def sequenze3(afg,freqs_mhz):
    data = []
    afg.set_output(1,1)
    afg.set_output(2,1)
    for freq in freqs_mhz:
        afg.set_frequenzy(afg,1,freq)
        afg.set_frequenzy(afg,2,freq)
        time.sleep(2)
        counts_ch1 = request_counts(1)
        counts_ch2 = request_counts(2)
        data.append([freq,counts_ch1,counts_ch2])
    logging.info("Sequenz 3 finished")
    return data
def request_counts(ch):
    url = "http://10.140.1.124:8082/api/get_counts_1s/1"
    response = requests.get(url)
    print(response.json())
    return response.json()
def setup_afg():
    afg = AFG31252()
    afg.set_waveform(1,"PULSE")
    afg.set_waveform(2,"PULSE")
    afg.set_high_limit(1, 3.3)
    afg.set_high_limit(2, 3.3)
    afg.set_low_limit(1, 0)
    afg.set_low_limit(2, 0)
    afg.set_low(1,0)
    afg.set_low(2,0)
    afg.set_high(1,3.3)
    afg.set_high(2,2.4)
    return afg()

def save_csv(filename, data):
    with open(filename, 'wb') as csvfile:
        writer = csv.writer(csvfile)
if __name__ == '__main__':
    main()
