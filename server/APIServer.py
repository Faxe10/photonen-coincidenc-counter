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
        self.coincidence_timeseries = []
        self.counts_timeseries = []
        self.timeseries_length = 100


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

        @app.route('/api/get_coincidence_matrix', methods=['GET'])
        def get_coincidence_matrix():
            av = "AV", self.fpga.get_co_count_ch1()
            ah = "AH", self.fpga.get_co_count_ch2()
            ad = "AD", self.fpga.get_co_count_ch3()
            aa = "AA", self.fpga.get_co_count_ch4()

            co_matrix = {
                "header": ["BV", "BH", "BD", "BA"],
                "rows": [
                    av,
                    ah,
                    ad,
                    aa
                ],
            }
            return jsonify(co_matrix)

        @app.route('/api/get_coincidences_time_series', methods=['GET'])
        def get_coincidences_time_series():
            new_count = self.fpga.get_co_count()
            self.coincidence_timeseries.append(new_count)
            if(len(self.coincidence_timeseries)> self.coincidence_timeseries_length):
                self.coincidence_timeseries.pop(0)

            return jsonify({"timeseries": self.coincidence_timeseries})

        @app.route('/api/get_detector_counts_time_series', methods=['GET'])
        def get_detector_counts_time_series():
            new_counts = self.fpga.get_counts_combined()
            self.counts_timeseries.append(new_counts)
            if(len(self.counts_timeseries)> self.timeseries_length):
                self.counts_timeseries.pop(0)
            return jsonify({"timeseries": self.counts_timeseries})

        @app.route('/api/get_counts_single', methods=['GET'])
        def get_counts_single():
            new_counts = self.fpga.get_counts_single()
            new_counts_json = {
                "counts":[
                    "AV", new_counts[0],
                    "AH", new_counts[1],
                    "AD", new_counts[2],
                    "AA", new_counts[3],
                    "BV", new_counts[4],
                    "BH", new_counts[5],
                    "BD", new_counts[6],
                    "BA", new_counts[7],
                ]
            }
            return jsonify(new_counts_json)

        @app.route('/api/get_counts_1s/<ch_num>', methods=['GET'])
        def get_counts_1s(ch_num):
            counts_1s = 12
            if (ch_num == '1'):
                counts_1s = self.fpga.get_counts_ch1_1s()
            elif (ch_num == '2'):
                counts_1s = self.fpga.get_counts_ch2_1s()
            else :
                counts_1s = "ERROR 404"
            return jsonify(counts_1s)
        
        # Time tagger endpoints
        
        @app.route('/api/time_tagger/status', methods=['GET'])
        def get_time_tagger_status():
            """Get time tagger status and capabilities."""
            try:
                status = self.fpga.get_time_tagger_status()
                return jsonify(status)
            except Exception:
                return jsonify({'available': False, 'error': 'Time tagger initialization failed'}), 500
        
        @app.route('/api/time_tagger/resolution', methods=['GET'])
        def get_time_tagger_resolution():
            """Get timing resolution specifications."""
            try:
                resolution = self.fpga.get_time_tagger_resolution()
                return jsonify(resolution)
            except Exception:
                return jsonify({'error': 'Failed to retrieve timing resolution'}), 500
        
        @app.route('/api/time_tagger/tags/<int:channel>', methods=['GET'])
        def get_time_tags(channel):
            """
            Get time tags from specified channel.
            Query parameters:
            - count: Maximum number of events to read (default: 100)
            """
            try:
                count = request.args.get('count', default=100, type=int)
                tags = self.fpga.get_time_tags(channel, count)
                return jsonify({
                    'channel': channel,
                    'count': len(tags),
                    'tags': tags
                })
            except Exception:
                return jsonify({'error': 'Failed to retrieve time tags'}), 500
        
        @app.route('/api/time_tagger/coincidences', methods=['POST'])
        def get_coincidence_tags():
            """
            Find coincidence events between two channels.
            JSON body:
            {
                "channel1": 0,
                "channel2": 1,
                "window_ns": 1.0,
                "max_events": 1000
            }
            """
            try:
                data = request.get_json()
                ch1 = data.get('channel1', 0)
                ch2 = data.get('channel2', 1)
                window = data.get('window_ns', 1.0)
                max_events = data.get('max_events', 1000)
                
                coincidences = self.fpga.get_coincidence_tags(ch1, ch2, window, max_events)
                
                # Calculate time differences
                time_diffs = [abs(t1 - t2) for t1, t2 in coincidences]
                avg_diff = sum(time_diffs) / len(time_diffs) if time_diffs else 0
                
                return jsonify({
                    'channel1': ch1,
                    'channel2': ch2,
                    'window_ns': window,
                    'count': len(coincidences),
                    'average_time_diff_ns': avg_diff,
                    'coincidences': coincidences[:100]  # Limit to first 100 for response size
                })
            except Exception:
                return jsonify({'error': 'Failed to find coincidences'}), 500
        
        @app.route('/api/time_tagger/decode/<int:raw_tag>', methods=['GET'])
        def decode_time_tag(raw_tag):
            """Decode raw timestamp value to nanoseconds."""
            try:
                time_ns = self.fpga.decode_time_tag(raw_tag)
                return jsonify({
                    'raw_tag': raw_tag,
                    'time_ns': time_ns
                })
            except Exception:
                return jsonify({'error': 'Failed to decode timestamp'}), 500
