from unittest import case

from pynq import Overlay,allocate
from pynq.lib import AxiGPIO
import time
import numpy as np
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
        self.setup_ps_singel_counter()
        self.setup_ps_delays()
        self.ps_trigger = self.overlay.AFGtrigger


        self.ps_time_window = self.overlay.time_window
       # self.ps_time_ch1 = self.overlay.time_ch_1_2.channel1
       # self.ps_time_ch2 = self.overlay.time_ch_1_2.channel2
        self.ps_reset = self.overlay.resetcount
        self.ps_count_coincidence = self.overlay.count_coincidenc
        #self.ps_dead_time = self.overlay.dead_time

    def setup_ps_singel_counter(self):
        self.ps_count_ch1 = self.overlay.count1_2.channel1
        self.ps_count_ch2 = self.overlay.count1_2.channel2
        self.ps_count_ch3 = self.overlay.count3_4.channel1
        self.ps_count_ch4 = self.overlay.count3_4.channel2
        self.ps_count_ch5 = self.overlay.count5_6.channel1
        self.ps_count_ch6 = self.overlay.count5_6.channel2
        self.ps_count_ch7 = self.overlay.count7_8.channel1
        self.ps_count_ch8 = self.overlay.count7_8.channel2

    def setup_ps_coincidence_counter(self):
        self.ps_co_count1_5 = self.overlay.co_count1_5_6.channel1
        self.ps_co_count1_6 = self.overlay.co_count1_5_6.channel2
        self.ps_co_count1_7 = self.overlay.co_count1_7_8.channel1
        self.ps_co_count1_8 = self.overlay.co_count1_7_8.channel2
        self.ps_co_count2_5 = self.overlay.co_count2_5_6.channel1
        self.ps_co_count2_6 = self.overlay.co_count2_5_6.channel2
        self.ps_co_count2_7 = self.overlay.co_count2_7_8.channel1
        self.ps_co_count2_8 = self.overlay.co_count2_7_8.channel2
        self.ps_co_count3_5 = self.overlay.co_count3_5_6.channel1
        self.ps_co_count3_6 = self.overlay.co_count3_5_6.channel2
        self.ps_co_count3_7 = self.overlay.co_count3_7_8.channel1
        self.ps_co_count3_8 = self.overlay.co_count3_7_8.channel2
        self.ps_co_count4_5 = self.overlay.co_count4_5_6.channel1
        self.ps_co_count4_6 = self.overlay.co_count4_5_6.channel2
        self.ps_co_count4_7 = self.overlay.co_count4_7_8.channel1
        self.ps_co_count4_8 = self.overlay.co_count4_7_8.channel2

    def setup_ps_delays(self):
        self.ps_delay_ch1 = self.overlay.delay_ch1
        self.ps_delay_ch2 = self.overlay.delay_ch2
        self.ps_delay_ch3 = self.overlay.delay_ch3
        self.ps_delay_ch4 = self.overlay.delay_ch4
        self.ps_delay_ch5 = self.overlay.delay_ch5
        self.ps_delay_ch6 = self.overlay.delay_ch6
        self.ps_delay_ch7 = self.overlay.delay_ch7
        self.ps_delay_ch8 = self.overlay.delay_ch8

    def read_data(self):
        count_ch1 = self.ps_count_ch1.read()
        count_ch2 = self.ps_count_ch2.read()
        count_coincidence = self.ps_count_coincidence.read()
        return count_ch1, count_ch2, count_coincidence

    def setup(self):
        self.ps_delay_ch1.write(0,self.delay_ch1)
        self.ps_delay_ch2.write(0,self.delay_ch2)
        self.ps_time_window.write(0,self.time_window)
       # self.ps_dead_time.write(0,self.dead_time)

    def reset(self):
        self.ps_reset.write(0,1)
        time.sleep(0.01)
        self.ps_reset.write(0,0)

    def read_time(self):
        #time_ch1 = self.ps_time_ch1.read()
        #time_ch2 = self.ps_time_ch2.read()
        time_ch1 = 1
        time_ch2 = 1
        return time_ch1, time_ch2

    def set_delay(self,ch_num,delay):
        if (isinstance(delay,int)):
            print("write Channel: ",ch_num, "Delay: ",delay)
            match ch_num:
                case 1:
                    self.ps_delay_ch1.write(0,delay)
                    return True
                case 2:
                    self.ps_delay_ch2.write(0,delay)
                    return True
                case 3:
                    self.ps_delay_ch3.write(0,delay)
                    return True
                case 4:
                    self.ps_delay_ch4.write(0,delay)
                    return True
                case 5:
                    self.ps_delay_ch5.write(0,delay)
                    return True
                case 6:
                    self.ps_delay_ch6.write(0,delay)
                    return True
                case 7:
                    self.ps_delay_ch7.write(0,delay)
                    return True
                case 8:
                    self.ps_delay_ch8.write(0,delay)
                    return True
                case _:
                    return False
        else:
            return False

    def set_dead_time(self,dead_time):
        try:
            #self.ps_dead_time.write(0,dead_time)
            print("Write Dead Time:",dead_time)
            return (True)
        except:
            return (False)

    def set_time_window(self,time_window):
        try:
            self.ps_time_window.write(0,time_window)
            print("Write Time Window:",time_window)
            return (True)
        except:
            return (False)
    def trigger(self):
        self.ps_trigger.write(0,1)
        self.ps_trigger.write(0,0)
    def get_co_count_ch1(self):
        co_count1_5 = self.ps_co_count1_5.read()
        co_count1_6 = self.ps_co_count1_6.read()
        co_count1_7 = self.ps_co_count1_7.read()
        co_count1_8 = self.ps_co_count1_8.read()
        return co_count1_5, co_count1_6, co_count1_7, co_count1_8

    def get_co_count_ch2(self):
        co_count2_5 = self.ps_co_count2_5.read()
        co_count2_6 = self.ps_co_count2_6.read()
        co_count2_7 = self.ps_co_count2_7.read()
        co_count2_8 = self.ps_co_count2_8.read()
        return co_count2_5, co_count2_6, co_count2_7, co_count2_8

    def get_co_count_ch3(self):
        co_count3_5 = self.ps_co_count3_5.read()
        co_count3_6 = self.ps_co_count3_6.read()
        co_count3_7 = self.ps_co_count3_7.read()
        co_count3_8 = self.ps_co_count3_8.read()
        return co_count3_5, co_count3_6, co_count3_7, co_count3_8

    def get_co_count_ch4(self):
        co_count4_5 = self.ps_co_count4_5.read()
        co_count4_6 = self.ps_co_count4_6.read()
        co_count4_7 = self.ps_co_count4_7.read()
        co_count4_8 = self.ps_co_count4_8.read()
        return co_count4_5, co_count4_6, co_count4_7, co_count4_8

    def read_dma(self):
