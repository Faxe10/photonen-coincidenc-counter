#!/usr/bin/env python3

import asyncio
import time
import random
import json
import threading
from fpga import FPGA
from APIServer import APIServer

# Store connected clients

connected_clients = set()


async def handle_client(websocket, path = None):
    """Handle a new WebSocket client connection"""
    connected_clients.add(websocket)
    print(f"Client connected. Total clients: {len(connected_clients)}")

    try:
        # Keep the connection alive
        await websocket.wait_closed()
    except websockets.exceptions.ConnectionClosed:
        pass
    finally:
        connected_clients.remove(websocket)
        print(f"Client disconnected. Total clients: {len(connected_clients)}")


async def send_data(fpga,api_server):
    """Generate and send data to all connected clients"""
    while True:
        if connected_clients:
            # Generate random values like your original script
            count_ch1, count_ch2, count_coincidence = fpga.read_data()
            # Format data as space-separated string
            data = f"{count_ch1} {count_ch2} {count_coincidence}"

            # Also print to console like your original script
            print(data)

            # Send to all connected clients
            disconnected = set()
            for client in connected_clients:
                try:
                    await client.send(data)
                except websockets.exceptions.ConnectionClosed:
                    disconnected.add(client)

            # Remove disconnected clients
            connected_clients.difference_update(disconnected)

        # Wait 0.1 seconds like your original script
        update_rate_ms = api_server.update_rate() / 1000
        await asyncio.sleep(update_rate_ms)

def run_flask(api_server):
    """Run the server"""
    api_server.app.run(host=api_server.host, port=api_server.port, threaded=True, use_reloader=False)
async def main():
    """Main server function"""
    print("Starting WebSocket server on localhost:8080")
    print("Your HTML page can now connect to ws://localhost:8080")

    # Start the WebSocket server
    server = await websockets.serve(handle_client, "0.0.0.0", 8080)
    # Start the data generation task
    fpga_connection = FPGA()
    fpga_connection.setup()
    api = APIServer(fpga_connection, update_rate=0.01, host='0.0.0.0', port=8082)
    t = threading.Thread(target=run_flask, args=(api,), daemon=True)
    t.start()
    loop = asyncio.get_event_loop()
    data_task = loop.create_task(send_data(fpga_connection,api))


    try:
        # Run forever
        await asyncio.gather(
            server.wait_closed(),
            data_task
        )
    except KeyboardInterrupt:
        print("\nShutting down server...")
        server.close()
        data_task.cancel()
        await server.wait_closed()


if __name__ == "__main__":
    # Install required package if not present
    try:
        import websockets
    except ImportError:
        print("Please install websockets package:")
        print("pip install websockets")
        exit(1)

    # Run the server
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
