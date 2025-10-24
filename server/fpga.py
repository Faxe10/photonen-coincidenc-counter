from unittest import case

from pynq import Overlay,allocate
from pynq.lib import AxiGPIO
import time
import numpy as np
import sys

# Import time tagger module
try:
    from time_tagger import TimeTagger
    TIME_TAGGER_AVAILABLE = True
except ImportError:
    TIME_TAGGER_AVAILABLE = False
    print("Warning: TimeTagger module not available")

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
        #self.ps_trigger = self.overlay.AFGtrigger
        self.setup_pl_counts_1s()

        self.ps_time_window = self.overlay.time_window
       # self.ps_time_ch1 = self.overlay.time_ch_1_2.channel1
       # self.ps_time_ch2 = self.overlay.time_ch_1_2.channel2
        self.ps_reset = self.overlay.resetcount
        #self.ps_count_coincidence = self.overlay.count_coincidenc
        #self.ps_counts_combined = self.overlay.counts_combined
        #self.ps_dead_time = self.overlay.dead_time
        
        # Initialize time tagger if available
        self.time_tagger = None
        if TIME_TAGGER_AVAILABLE:
            try:
                self.time_tagger = TimeTagger(self.overlay)
                print("Time tagger initialized successfully")
            except Exception as e:
                print(f"Warning: Could not initialize time tagger: {e}")

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

    def setup_pl_counts_1s(self):
        self.pl_counts_ch1_1s = self.overlay.count1_2_1S.channel1
        self.pl_counts_ch2_1s = self.overlay.count1_2_1S.channel2

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
            if (ch_num == 1):
                    self.ps_delay_ch1.write(0,delay)
                    return True
            elif (ch_num == 2):
                    self.ps_delay_ch2.write(0,delay)
                    return True
            elif (ch_num == 3):
                    self.ps_delay_ch3.write(0,delay)
                    return True
            elif (ch_num ==4):
                    self.ps_delay_ch4.write(0,delay)
                    return True
            elif (ch_num == 5):
                    self.ps_delay_ch5.write(0,delay)
                    return True
            elif (ch_num == 6):
                    self.ps_delay_ch6.write(0,delay)
                    return True
            elif (ch_num == 7):
                    self.ps_delay_ch7.write(0,delay)
                    return True
            elif (ch_num == 8):
                    self.ps_delay_ch8.write(0,delay)
                    return True
            else:
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
        return [ co_count1_5, co_count1_6, co_count1_7, co_count1_8]

    def get_co_count_ch2(self):
        co_count2_5 = self.ps_co_count2_5.read()
        co_count2_6 = self.ps_co_count2_6.read()
        co_count2_7 = self.ps_co_count2_7.read()
        co_count2_8 = self.ps_co_count2_8.read()
        return [co_count2_5, co_count2_6, co_count2_7, co_count2_8]

    def get_co_count_ch3(self):
        co_count3_5 = self.ps_co_count3_5.read()
        co_count3_6 = self.ps_co_count3_6.read()
        co_count3_7 = self.ps_co_count3_7.read()
        co_count3_8 = self.ps_co_count3_8.read()
        return [co_count3_5, co_count3_6, co_count3_7, co_count3_8]

    def get_co_count_ch4(self):
        co_count4_5 = self.ps_co_count4_5.read()
        co_count4_6 = self.ps_co_count4_6.read()
        co_count4_7 = self.ps_co_count4_7.read()
        co_count4_8 = self.ps_co_count4_8.read()
        return [co_count4_5, co_count4_6, co_count4_7, co_count4_8]

    def get_counts_combined(self):
        counts_combined = self.ps_counts_combined.read()
        return counts_combined

    def get_co_count(self):
        count = self.ps_count_coincidence.read()
        return count

    def get_counts_single(self):
        count_ch1 = self.ps_count_ch1.read()
        count_ch2 = self.ps_count_ch2.read()
        count_ch3 = self.ps_count_ch3.read()
        count_ch4 = self.ps_count_ch4.read()
        count_ch5 = self.ps_count_ch5.read()
        count_ch6 = self.ps_count_ch6.read()
        count_ch7 = self.ps_count_ch7.read()
        count_ch8 = self.ps_count_ch8.read()
        return [count_ch1, count_ch2, count_ch3, count_ch4,count_ch5, count_ch6, count_ch7, count_ch8]

    def get_counts_ch1(self):
        count_ch1 = self.ps_count_ch1.read()
        return count_ch1

    #functions used for testing the FPGA

    def get_counts_ch1_1s(self):
        print("get counts ch1 1s ")
        time.sleep(0.5)
        count_1s = self.pl_counts_ch1_1s.read()
        print('read done')
        return count_1s

    def get_counts_ch2_1s(self):
        print("get_counts ch 2 1s")
        time.sleep(0.5)
        count_1s = self.pl_counts_ch2_1s.read()
        print('read done')
        return count_1s
    
    # Time tagger methods
    
    def get_time_tags(self, channel, max_events=100):
        """
        Get time tags from specified channel using high-resolution time tagger.
        
        Args:
            channel: Channel number (0-7)
            max_events: Maximum number of events to read
            
        Returns:
            List of timestamps in nanoseconds
        """
        if self.time_tagger is None:
            raise RuntimeError("Time tagger not initialized")
        return self.time_tagger.get_time_tags(channel, max_events)
    
    def get_coincidence_tags(self, channel1, channel2, window_ns=1.0, max_events=1000):
        """
        Find coincidence events between two channels.
        
        Args:
            channel1: First channel number (0-7)
            channel2: Second channel number (0-7)
            window_ns: Coincidence window in nanoseconds
            max_events: Maximum number of events to process
            
        Returns:
            List of (time1, time2) tuples for coincident events
        """
        if self.time_tagger is None:
            raise RuntimeError("Time tagger not initialized")
        return self.time_tagger.get_coincidences(channel1, channel2, window_ns, max_events)
    
    def get_time_tagger_resolution(self):
        """
        Get timing resolution specifications.
        
        Returns:
            Dictionary with resolution information
        """
        if self.time_tagger is None:
            raise RuntimeError("Time tagger not initialized")
        return self.time_tagger.get_timing_resolution()
    
    def get_time_tagger_status(self):
        """
        Get time tagger status information.
        
        Returns:
            Dictionary with status information
        """
        if self.time_tagger is None:
            return {'available': False, 'error': 'Time tagger not initialized'}
        status = self.time_tagger.get_status()
        status['available'] = True
        return status
    
    def decode_time_tag(self, raw_tag):
        """
        Decode raw timestamp value to nanoseconds.
        
        Args:
            raw_tag: 54-bit raw timestamp value
            
        Returns:
            Time in nanoseconds (float)
        """
        if self.time_tagger is None:
            raise RuntimeError("Time tagger not initialized")
        return self.time_tagger.decode_timestamp(raw_tag)
