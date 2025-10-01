import pyvisa
import time
class AFG31252:
    def __init__(self, host, timeout_ms = 5000):
                self.rm = pyvisa.ResourceManager(@py)
                self.dev = self.rm.open_resource(f"TCPIP0::{host}::INSTR")
                self.dev.timeout = timeout_ms

    def channel_setup(self):
        #channel conf

        self.set_impedance(1,"INF")
        self.set_impedance(2,"INF")
        self.set_high_limit(1,3.3)
        self.set_high_limit(2,3.3)
        self.set_low_limit(1,0)
        self.set_low_limit(2,0)

        #Signal conf
        self.set_waveform(1,"PULSE")
        self.set_waveform(2,"PULSE")
        self.set_low(1,0)
        self.set_low(2,0)
        self.set_high(1,3)
        self.set_high(2,3)
        self.configure_burst(1,1,"TRIG")
        self.configure_burst(2,1,"TRIG")
        self.set_output(1,1)
        self.set_output(2,1)
    def set_output(self,ch,on):
        if (on):
            self.dev.write(f"OUTP{ch} ON")
        else:
            self.dev.write(f"OUTP{ch} OFF")

    def set_frequency(self,ch,frequency):
        self.dev.write(f"SOUR{ch}:FREQ {frequency}")

    def set_impedance(self,ch,load):
        if isinstance(load,str):
            self.dev.write(f"OUTP{ch}:IMP {load}")
        else:
            self.dev.write(f"OUTP{ch}:IMP {float(load)}")

    def set_low(self,ch,v):
        self.dev.write(f"SOUR{ch}:VOLT:LEV:IMM:LOW {v}")

    def set_high(self,ch,v):
        self.dev.write(f"SOUR{ch}:VOLT:LEV:IMM:HIGH {v}")

    def configure_burst(self,ch,cycles,mode):
        self.dev.write(f"SOUR{ch}:BURS:STAT ON")
        self.dev.write(f"SOUR{ch}:BURS:MODE {mode}")
        self.dev.write(f"SOUR{ch}:BURS:NCYC {cycles}")
        self.dev.write(f"OUTP{2} TRIG:DEL 2")

    def set_waveform(self, ch,func):
        self.dev.write(f"SOUR{ch}:FUNC {func}")

    def set_low_limit(self,ch,v):
        self.dev.write(f"SOUR{ch}:VOLT:LIM:LOW {v}")

    def set_high_limit(self,ch,v):
        self.dev.write(f"SOUR{ch}:VOLT:LIM:HIGH {v}")

    def get_impedance(self, ch):
        return self.dev.query(f"OUTP{ch}:LOAD?").strip()
if __name__ == "__main__":
    print("Testing AFG31252")

    AFG_IP = "10.140.1.58"
    afg = AFG31252(AFG_IP)
    #afg.channel_setup()
    afg.set_output(1,1)
    afg.set_output(2,1)
