import csv
import time
import logging
import sys, os
from fileinput import filename

sys.path.append(os.path.dirname(os.path.dirname(__file__)))  # Projekt-Root
import requests
import numpy as np
import datetime
import pandas as pd
from tektronixAFG31252 import AFG31252

logger = logging.getLogger(__name__)
def main():
    time_now = str(datetime.date.today())
    log_filename = 'measurments' + time_now + '.log'
    logging.basicConfig(filename=log_filename,level=logging.INFO)
    logger.info('start_setup')
    afg_ip = '10.140.1.17'
    afg = AFG31252(afg_ip)
    afg.set_waveform(1,"PULSE")
    afg.set_waveform(2,"PULSE")
    f_min = 1
    f_max = 1e9
    N = 100
    freqs_mhz = np.logspace(np.log10(f_min), np.log10(f_max), N)
    sequenze1(afg,freqs_mhz)
    sequenze2(afg,freqs_mhz)
    sequenze3(afg,freqs_mhz)
    sequenze4(afg,freqs_mhz)

def sequenze1(afg,freqs_mhz):
    time_start_seq = datetime.datetime.now()
    file_name = "sequenz1.csv"
    v_low = 0
    v_high = 3.3
    new_csv(file_name)
    afg.set_output(1, 1)
    afg.set_output(2, 0)
    afg.set_high(1,v_high)
    afg.set_low(1,v_low)
    for freq in freqs_mhz :
        afg.set_frequency(1,freq)
        time.sleep(1.1)
        counts = request_counts(1)
        save_csv(file_name,freq,counts, v_high, v_low)
    time_passed = datetime.datetime.now() - time_start_seq
    time_now  = datetime.datetime.now()
    log_msg = str(time_now) + "  Sequenz 1 finished in: " + str(time_passed)
    logging.info(log_msg)

def sequenze2(afg,freqs_mhz):
    time_start_seq = datetime.datetime.now()
    file_name = "sequenz2.csv"
    v_low = 0
    v_high = 3.3
    new_csv(file_name)
    afg.set_output(1, 0)
    afg.set_output(2, 1)
    afg.set_high(2, v_high)
    afg.set_low(2, v_low)
    for freq in freqs_mhz:
        afg.set_frequency(2, freq)
        time.sleep(1.1)
        counts = request_counts(2)
        save_csv(file_name, freq, counts, v_high, v_low)
    time_passed = datetime.datetime.now() - time_start_seq
    time_now = datetime.datetime.now()
    log_msg = str(time_now) + "  Sequenz 2 finished in: " + str(time_passed)
    logging.info(log_msg)


def sequenze3(afg,freqs_mhz):
    time_start_seq = datetime.datetime.now()
    file_name_ch1 = "sequenz3_ch1.csv"
    file_name_ch2 = "sequenz3_ch2.csv"
    v_low = 0
    v_high = 3.3
    new_csv(file_name_ch1)
    new_csv(file_name_ch2)
    afg.set_output(1, 1)
    afg.set_output(2, 1)
    afg.set_high(1,v_high)
    afg.set_low(1,v_low)
    afg.set_high(2, v_high)
    afg.set_low(2, v_low)
    for freq in freqs_mhz:
        afg.set_frequency(1,freq)
        afg.set_frequency(2,freq)
        time.sleep(1.1)
        counts_ch1 = request_counts(1)
        counts_ch2 = request_counts(2)
        save_csv(file_name_ch1,freq,counts_ch1,v_high,v_low)
        save_csv(file_name_ch2,freq,counts_ch2,v_high,v_low)
    time_passed = datetime.datetime.now() - time_start_seq
    time_now = datetime.datetime.now()
    log_msg = str(time_now) + "  Sequenz 3 finished in: " + str(time_passed)
    logging.info(log_msg)


def sequenze4(afg,freqs_mhz):
    time_start_seq = datetime.datetime.now()
    file_name_ch1 = "sequenz4_ch1.csv"
    file_name_ch2 = "sequenz4_ch2.csv"
    afg.set_output(1,1)
    afg.set_output(2,1)
    v_high_ch1 = 3.3
    v_low_ch1 = 0
    v_high_ch2 = 3.3
    v_low_ch2 = 0
    while v_high_ch1 > 0:
        v_high_ch1 = v_high_ch1 - 0.1
        v_low_ch2 = v_low_ch2 + 0.1
        afg.set_high(1,v_high_ch1)
        afg.set_low(2,v_low_ch2)
        for freq in freqs_mhz:
            afg.set_frequency(1,freq)
            afg.set_frequency(2,freq)
            time.sleep(2)
            counts_ch1 = request_counts(1)
            counts_ch2 = request_counts(2)
            save_csv(file_name_ch1, freq, counts_ch1, v_high_ch1, v_low_ch1)
            save_csv(file_name_ch2, freq, counts_ch2, v_high_ch2, v_low_ch2)
    time_passed = datetime.datetime.now() - time_start_seq
    time_now = datetime.datetime.now()
    log_msg = str(time_now) + "  Sequenz 4 finished in: " + str(time_passed)
    logging.info(log_msg)



def request_counts(ch):
    url = "http://10.140.1.124:8082/api/get_counts_1s/"+str(ch)
    response = requests.get(url)
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

def save_csv(filename, frequenz,counts,v_high,v_low):
    row = {
        "Frequenz": frequenz,
        "counts": counts,
        "v_high": v_high,
        "v_low": v_low
    }
    df = pd.DataFrame([row])
    df.to_csv(filename,mode="a",header=False,index=False)

def new_csv(filename):
    row = {
        "Frequenz": 0,
        "counts": 0,
        "v_hight": 0,
        "v_low": 0
    }
    df = pd.DataFrame([row])
    df.to_csv(filename,mode="a",header=True,index=False)


if __name__ == '__main__':
    main()
