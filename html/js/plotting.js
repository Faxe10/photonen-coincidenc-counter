 class RealTimePlotter {
            constructor() {
                this.canvas = document.getElementById('chart');
                this.ctx = this.canvas.getContext('2d');
                this.data = [];
                this.maxPoints = 100;
                this.showTraces = [true, true, true]; // A, B, Sum
                this.isSimulating = false;
                this.isPaused = false;
                this.simulationInterval = null;
                this.animationId = null;
                this.websocket = null;
                this.updateRate = 100;

                this.setupCanvas();
                this.setupEventListeners();
                this.startAnimation();
            }

            setupCanvas() {
                this.canvas.width = this.canvas.offsetWidth * window.devicePixelRatio;
                this.canvas.height = this.canvas.offsetHeight * window.devicePixelRatio;
                this.ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
            }

            setupEventListeners() {
                // Checkbox event listeners
                document.getElementById('showValueA').addEventListener('change', (e) => {
                    this.showTraces[0] = e.target.checked;
                    this.draw();
                });

                document.getElementById('showValueB').addEventListener('change', (e) => {
                    this.showTraces[1] = e.target.checked;
                    this.draw();
                });

                document.getElementById('showSum').addEventListener('change', (e) => {
                    this.showTraces[2] = e.target.checked;
                    this.draw();
                });

                document.getElementById('maxPoints').addEventListener('change', (e) => {
                    this.maxPoints = parseInt(e.target.value);
                    this.trimData();
                    this.draw();
                });

                document.getElementById('updateRate').addEventListener('change', (e) => {
                    this.updateRate = parseInt(e.target.value);
                    if (this.isSimulating) {
                        this.stopSimulation();
                        this.startSimulation();
                    } else {
                        this.change_updaterate()
                    }
                });

                document.getElementById('connectBtn').addEventListener('click', () => {
                    this.connectToPython();
                });

                document.getElementById('simulateBtn').addEventListener('click', () => {
                    this.toggleSimulation();
                });

                document.getElementById('clearBtn').addEventListener('click', () => {
                    this.clearData();
                });

                document.getElementById('pauseBtn').addEventListener('click', () => {
                    this.togglePause();
                });

                document.getElementById('exportBtn').addEventListener('click', () => {
                    this.exportData();
                });

                settingsbtn.onclick = ()=> overlay.hidden = false;
                closeOverlay.onclick  = ()=> overlay.hidden = true;


                window.addEventListener('resize', () => {
                    this.setupCanvas();
                    this.draw();
                });
            }

            connectToPython() {
                const status = document.getElementById('status');

                if (this.websocket) {
                    this.websocket.close();
                }

                status.textContent = 'Connecting to Python script...';
                status.className = 'status';

                try {
                    const proto = location.protocol === 'https:' ? 'wss://' : 'ws://';
                    this.websocket = new WebSocket(`${proto}${location.hostname}:8080`);

                    this.websocket.onopen = () => {
                        status.textContent = 'Connected to Python script';
                        status.className = 'status connected';
                        console.log('WebSocket connected');
                    };

                    this.websocket.onmessage = (event) => {
                        try {
                            const values = event.data.trim().split(/\s+/).map(Number);
                            if (values.length >= 3) {
                                this.addDataPoint([values[0], values[1], values[2]]);
                            }
                        } catch (error) {
                            console.error('Error parsing data:', error);
                        }
                    };

                    this.websocket.onclose = (event) => {
                        status.textContent = 'Connection closed';
                        status.className = 'status disconnected';
                        console.log('WebSocket closed:', event);
                        this.websocket = null;
                    };

                    this.websocket.onerror = (error) => {
                        status.textContent = 'Connection failed - Check if Python script is running';
                        status.className = 'status disconnected';
                        console.error('WebSocket error:', error);
                        this.websocket = null;
                    };

                } catch (error) {
                    status.textContent = 'Failed to connect - Use simulation mode';
                    status.className = 'status disconnected';
                    console.error('Connection error:', error);
                }
            }

            toggleSimulation() {
                const btn = document.getElementById('simulateBtn');
                const status = document.getElementById('status');

                if (this.isSimulating) {
                    this.stopSimulation();
                    btn.textContent = 'Start Simulation';
                    btn.className = 'btn btn-secondary';
                    status.textContent = 'Simulation stopped';
                    status.className = 'status disconnected';
                } else {
                    this.startSimulation();
                    btn.textContent = 'Stop Simulation';
                    btn.className = 'btn btn-secondary';
                    status.textContent = 'Simulation running';
                    status.className = 'status simulating';
                }
            }

            startSimulation() {
                this.isSimulating = true;
                this.simulationInterval = setInterval(() => {
                    const a = Math.floor(Math.random() * 100000);
                    const b = Math.floor(Math.random() * 100000);
                    const sum = a + b;
                    this.addDataPoint([a, b, sum]);
                }, this.updateRate);
            }

            stopSimulation() {
                this.isSimulating = false;
                if (this.simulationInterval) {
                    clearInterval(this.simulationInterval);
                    this.simulationInterval = null;
                }
            }

            togglePause() {
                const btn = document.getElementById('pauseBtn');
                this.isPaused = !this.isPaused;

                if (this.isPaused) {
                    btn.textContent = 'Resume';
                    btn.className = 'btn btn-primary';
                    if (this.animationId) {
                        cancelAnimationFrame(this.animationId);
                        this.animationId = null;
                    }
                } else {
                    btn.textContent = 'Pause';
                    btn.className = 'btn btn-primary';
                    this.startAnimation();
                }
            }

            exportData() {
                if (this.data.length === 0) {
                    alert('No data to export');
                    return;
                }

                const csvContent = "data:text/csv;charset=utf-8,"
                    + "Timestamp,Value A,Value B,Sum\n"
                    + this.data.map(row => {
                        const date = new Date(row.time);
                        return `${date.toISOString()},${row.values[0]},${row.values[1]},${row.values[2]}`;
                    }).join('\n');

                const encodedUri = encodeURI(csvContent);
                const link = document.createElement("a");
                link.setAttribute("href", encodedUri);
                link.setAttribute("download", `realtime_data_${new Date().toISOString().slice(0,19).replace(/:/g,'-')}.csv`);
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }

            addDataPoint(values) {
                if (this.isPaused) return;

                const timestamp = Date.now();
                this.data.push({
                    time: timestamp,
                    values: values
                });

                this.trimData();
                this.updateCurrentValues(values);
            }

            trimData() {
                while (this.data.length > this.maxPoints) {
                    this.data.shift();
                }
            }

            updateCurrentValues(values) {
                document.getElementById('valueA').textContent = values[0].toLocaleString();
                document.getElementById('valueB').textContent = values[1].toLocaleString();
                document.getElementById('valueSum').textContent = values[2].toLocaleString();
            }

            clearData() {
                this.data = [];
                document.getElementById('valueA').textContent = '-';
                document.getElementById('valueB').textContent = '-';
                document.getElementById('valueSum').textContent = '-';
                this.draw();
            }

            startAnimation() {
                if (this.animationId) return;

                const animate = () => {
                    if (!this.isPaused) {
                        this.draw();
                        this.animationId = requestAnimationFrame(animate);
                    }
                };
                animate();
            }

            draw() {
                const canvas = this.canvas;
                const ctx = this.ctx;
                const width = canvas.width / window.devicePixelRatio;
                const height = canvas.height / window.devicePixelRatio;

                // Clear canvas
                ctx.clearRect(0, 0, width, height);

                if (this.data.length === 0) {
                    // Draw empty state
                    ctx.fillStyle = '#999';
                    ctx.font = '18px Arial';
                    ctx.textAlign = 'center';
                    ctx.fillText('No data to display', width / 2, height / 2);
                    return;
                }

                // Calculate bounds for all visible traces
                let allValues = [];
                if (this.showTraces[0]) allValues = allValues.concat(this.data.map(d => d.values[0]));
                if (this.showTraces[1]) allValues = allValues.concat(this.data.map(d => d.values[1]));
                if (this.showTraces[2]) allValues = allValues.concat(this.data.map(d => d.values[2]));

                if (allValues.length === 0) return;

                const minValue = Math.min(...allValues);
                const maxValue = Math.max(...allValues);
                const valueRange = maxValue - minValue || 1;

                const padding = 50;
                const chartWidth = width - 2 * padding;
                const chartHeight = height - 2 * padding;

                // Draw grid
                ctx.strokeStyle = '#e0e0e0';
                ctx.lineWidth = 1;

                // Horizontal grid lines
                for (let i = 0; i <= 10; i++) {
                    const y = padding + (i * chartHeight / 10);
                    ctx.beginPath();
                    ctx.moveTo(padding, y);
                    ctx.lineTo(width - padding, y);
                    ctx.stroke();
                }

                // Vertical grid lines
                for (let i = 0; i <= 10; i++) {
                    const x = padding + (i * chartWidth / 10);
                    ctx.beginPath();
                    ctx.moveTo(x, padding);
                    ctx.lineTo(x, height - padding);
                    ctx.stroke();
                }

                // Draw axes
                ctx.strokeStyle = '#333';
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.moveTo(padding, padding);
                ctx.lineTo(padding, height - padding);
                ctx.lineTo(width - padding, height - padding);
                ctx.stroke();

                // Draw value labels
                ctx.fillStyle = '#333';
                ctx.font = '12px Arial';
                ctx.textAlign = 'right';

                for (let i = 0; i <= 5; i++) {
                    const value = minValue + (i * valueRange / 5);
                    const y = height - padding - (i * chartHeight / 5);
                    ctx.fillText(Math.round(value).toLocaleString(), padding - 5, y + 4);
                }

                // Draw time axis labels
                ctx.fillStyle = '#666';
                ctx.font = '10px Arial';
                ctx.textAlign = 'center';

                if (this.data.length > 1) {
                    const timeSpan = this.data[this.data.length - 1].time - this.data[0].time;
                    const labels = 5;

                    for (let i = 0; i <= labels; i++) {
                        const x = padding + (i * chartWidth / labels);
                        const timeOffset = (i / labels) * timeSpan;
                        const time = new Date(this.data[0].time + timeOffset);
                        const timeStr = time.toLocaleTimeString([], {hour12: false, minute: '2-digit', second: '2-digit'});
                        ctx.fillText(timeStr, x, height - padding + 15);
                    }
                }

                // Draw data lines for each trace
                const traceColors = ['#FF6B6B', '#4ECDC4', '#45B7D1'];
                const traceNames = ['Value A', 'Value B', 'Sum (A+B)'];

                if (this.data.length > 1) {
                    for (let traceIndex = 0; traceIndex < 3; traceIndex++) {
                        if (!this.showTraces[traceIndex]) continue;

                        ctx.strokeStyle = traceColors[traceIndex];
                        ctx.lineWidth = 2;
                        ctx.beginPath();

                        let firstPoint = true;
                        for (let i = 0; i < this.data.length; i++) {
                            const x = padding + (i * chartWidth / (this.data.length - 1));
                            const value = this.data[i].values[traceIndex];
                            const y = height - padding - ((value - minValue) / valueRange * chartHeight);

                            if (firstPoint) {
                                ctx.moveTo(x, y);
                                firstPoint = false;
                            } else {
                                ctx.lineTo(x, y);
                            }
                        }

                        ctx.stroke();

                        // Draw data points
                        ctx.fillStyle = traceColors[traceIndex];
                        for (let i = 0; i < this.data.length; i++) {
                            const x = padding + (i * chartWidth / (this.data.length - 1));
                            const value = this.data[i].values[traceIndex];
                            const y = height - padding - ((value - minValue) / valueRange * chartHeight);

                            ctx.beginPath();
                            ctx.arc(x, y, 2, 0, 2 * Math.PI);
                            ctx.fill();
                        }
                    }
                }

                // Draw legend
                ctx.font = '14px Arial';
                ctx.textAlign = 'left';
                let legendY = 30;
                for (let i = 0; i < 3; i++) {
                    if (!this.showTraces[i]) continue;

                    ctx.fillStyle = traceColors[i];
                    ctx.fillRect(width - 150, legendY - 10, 15, 3);
                    ctx.fillText(traceNames[i], width - 130, legendY);
                    legendY += 20;
                }

                // Draw title
                ctx.fillStyle = '#333';
                ctx.font = 'bold 16px Arial';
                ctx.textAlign = 'center';
                ctx.fillText('Real-time Multi-trace Plot', width / 2, 25);
            }

        }

        // Initialize the plotter when the page loads
        let plotter;
        window.addEventListener('load', () => {
            plotter = new RealTimePlotter();
        });
