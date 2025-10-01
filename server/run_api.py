import threading
from fpga import FPGA
from APIServer import APIServer

def run_flask(api_server):
    """Run the server"""
    api_server.app.run(host=api_server.host, port=api_server.port, threaded=True, use_reloader=False)
if __name__ == '__main__':
    fpga_connection = FPGA()
    fpga_connection.setup()
    fpga_connection.setup_pl_counts_1s()
    api = APIServer(fpga_connection, update_rate=1000, host='0.0.0.0', port=8082)
    t = threading.Thread(target=run_flask, args=(api,), daemon=True)
    t.start()
    t.join()
