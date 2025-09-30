from http.client import responses

from flask import Flask, request, jsonify, Response
from flask_cors import CORS
import fpga
class APIServer:
    def __init__(self,fpga,update_rate,host = '0.0.0.0',port = 8082):
        self.app = Flask(__name__)
        CORS(self.app, resources={r"/*": {"origins": "*"}})
        self.host = host
        self.port = port
        self.load_routes()
        self.fpga = fpga
        self.update_rate = update_rate

    def read_value(self):
        """Erwartet JSON-Body {"value": <int>} oder eine rohe Zahl als Body."""
        data = request.get_json(silent=True)
        if isinstance(data, dict) and "value" in data:
            try:
                return int(data["value"])
            except Exception:
                return None
        # Fallback: roher Body nur Zahl, z.B. body: "123"
        raw = (request.data or b"").strip()
        if raw:
            try:
                return int(raw)
            except Exception:
                return None
        return None

    def load_routes(self):
        app = self.app

        @app.route('/api/reset', methods=['POST'])
        def reset():
            self.fpga.reset()
            return Response('OK')

        @app.route('/api/set_delay/<ch_num>',methods=['POST'])
        def set_ch(ch_num):
            delay = self.read_value()
            if(self.fpga.set_delay(ch_num,delay)):
                return Response('OK')
            else:
                return Response('Error')

        @app.route('/api/set_time_window', methods=['POST'])
        def set_time_window():
            time_window = self.read_value()
            if(self.fpga.set_time_window(time_window)):
                return Response('OK')
            else:
                return Response('Error')

        @app.route('/api/calibrate', methods=['POST'])
        def calibrate():
            self.fpga.trigger()
            time_ch1, time_ch2 = self.fpga.read_time()
            if (time_ch1 > time_ch2):
                    delay = time_ch1 - time_ch2
                    self.fpga.set_delay(1,delay)
            else:
                    delay = time_ch2 - time_ch1
                    self.fpga.set_delay(2,delay)
            return Response('OK')

        @app.route('/api/read_time', methods=['GET'])
        def read_time():
            print()
            t1, t2 = self.fpga.read_time()
            return jsonify({"ch1": int(t1), "ch2": int(t2)})

        @app.route('/api/set_update_rate', methods=['POST'])
        def set_update_rate():
            self.update_rate = self.read_value()
            return Response('OK')

        @app.route('/api/get_delay', methods=['GET'])
        def get_delay():
            delay = self.fpga.get_delay()
            return jsonify({"delay": delay})

        @app.route('/api/get_times', methods=['GET'])
        def get_times():
            times = self.fpga.get_times()
            jsonified_times = jsonify({"ch1": times[0],
                                       "ch2" : times[1],
                                       "ch3" : times[2],
                                       "ch4" : times[3],
                                       "ch5" : times[4],
                                       "ch6" : times[5],
                                       "ch7" : times[6],
                                       "ch8" : times[7]})
            return jsonified_times

