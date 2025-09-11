#!/usr/bin/env python3

import asyncio
import websockets
import time
import random
import json
import read_data

# Store connected clients
connected_clients = set()


async def handle_client(websocket):
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


async def send_data(fpga):
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
        await asyncio.sleep(0.1)


async def main():
    """Main server function"""
    print("Starting WebSocket server on localhost:8080")
    print("Your HTML page can now connect to ws://localhost:8080")

    # Start the WebSocket server
    server = await websockets.serve(handle_client, "localhost", 8080)

    # Start the data generation task
    fpga = read_data.fpga()
    fpga.setup()
    data_task = asyncio.create_task(send_data(fpga))

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
    asyncio.run(main())