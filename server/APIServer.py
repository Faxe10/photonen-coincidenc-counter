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

    def load_routes(self):
        app = self.app

        @app.route('/api/reset', methods=['POST'])
        def reset():
            self.fpga.reset()
            return Response('OK')

        @app.route('/api/set_delay/<ch_num>',methods=['POST'])
        def set_ch(ch_num):
            delay = int(request.data)
            if(self.fpga.set_delay(ch_num,delay)):
                return Response('OK')
            else:
                return Response('Error')

        @app.route('/api/set_dead_time', methods=['POST'])
        def set_dead_time():
            dead_time = int(request.data)
            if(self.fpga.set_dead_time(dead_time)):
                return Response('OK')
            else:
                return Response('Error')

        @app.route('/api/set_time_window', methods=['POST'])
        def set_time_window():
            time_window = int(request.data)
            if(self.fpga.set_time_window(time_window)):
                return Response('OK')
            else:
                return Response('Error')

        @app.route('/api/set_update_rate', methods=['POST'])
        def set_update_rate():
            self.update_rate = int(request.data)
            return Response('OK')