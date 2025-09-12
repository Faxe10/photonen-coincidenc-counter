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

        @app.route('/api/set_dead_time', methods=['POST'])
        def set_dead_time():
            dead_time = self.read_value()
            if(self.fpga.set_dead_time(dead_time)):
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

        @app.route('/api/set_update_rate', methods=['POST'])
        def set_update_rate():
            self.update_rate = self.read_value()
            return Response('OK')

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
            t1, t2 = self.fpga.read_time()
            return jsonify({"ch1": int(t1), "ch2": int(t2)})
