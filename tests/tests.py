from tektronixAFG31252 import AFG31252

class test():
    def __init__(self):
        self.AFG_IP = "10.140.1.58"
        self.afg = AFG31252(self.AFG_IP)

    def