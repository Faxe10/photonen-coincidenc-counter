from pynq import Overlay, overlay
from pynq.lib import AxiGPIO
import time
import sys
path_overlay = "./fpga/counter.bit"

class FPGA:
    def __init__(self):
        self.overlay = Overlay(path_overlay)
        # setup Data
        self.delay_ch1 = 0
        self.delay_ch2 = 0
        self.time_window = 0
        self.dead_time = 0
        # setup ps connections
        self.ps_count_ch1 = self.overlay.count.channel1
        self.ps_count_ch2 = self.overlay.count.channel2
        self.ps_delay_ch1 = self.overlay.delay_ch1
        self.ps_delay_ch2 = self.overlay.delay_ch2
        self.ps_time_window = self.overlay.time_window
        self.ps_time_ch1 = self.overlay.time_ch_1_2.channel1
        self.ps_time_ch2 = self.overlay.time_ch_1_2.channel2
        self.ps_reset = self.overlay.resetcount
        self.ps_count_coincidence = self.overlay.count_coincidenc
        self.ps_dead_time = self.overlay.dead_time

    def read_data(self):
        count_ch1 = self.ps_count_ch1.read()
        count_ch2 = self.ps_count_ch2.read()
        count_coincidence = self.ps_count_coincidence.read()
        return count_ch1, count_ch2, count_coincidence

    def setup(self):
        self.ps_delay_ch1.write(0,self.delay_ch1)
        self.ps_delay_ch2.write(0,self.delay_ch2)
        self.ps_time_window.write(0,self.time_window)
        self.ps_dead_time.write(0,self.dead_time)

    def reset(self):
        self.ps_reset.write(0,1)
        time.sleep(0.01)
        self.ps_reset.write(0,0)

    def read_time(self):
        time_ch1 = self.ps_time_ch1.read()
        time_ch2 = self.ps_time_ch2.read()
        return time_ch1, time_ch2
