import csv
import time
import unittest

from pynq import Overlay
import numpy as np
import server.fpga
import fpga
from server.fpga import path_overlay
from tektronixAFG31252 import AFG31252


def main():
    afg = AFG31252()
    fpga = server.fpga.FPGA()

    f_min = 1
    f_max = 1e6
    N = 100

    first = np.arange(1, 11, dtype=float)  # 1..10
    M = N - 10
    j = np.arange(M)  # 0..M
    rest = 10.0 * (f_max / 10.0) * -1 * ((j + 1) / M)  # startet >10, endet exakt bei f_max
    freqs_mhz = np.concatenate([first, rest])  # Länge N
    afg = setup_afg()
    fpga.setup_pl_counts_1s()
    seq1 = sequenze1(afg,fpga,freqs_mhz)
    save_csv("seq1.csv",seq1)

def sequenze1(afg, fpga,freqs_mhz):
    data = []
    for freq in freqs_mhz :
        afg.set_frequency(freq)
        time.sleep(1.2)
        counts = fpga.get_counts_ch1_1s()
        data.append([freq, counts])
    return data
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