# Time Tagger Quick Reference Guide

## Quick Start

### Python API

```python
from fpga import FPGA

# Initialize
fpga = FPGA()

# Check status
status = fpga.get_time_tagger_status()
print(f"Time tagger available: {status['available']}")
print(f"Resolution: {status['resolution_ps']} ps")

# Get timestamps
tags = fpga.get_time_tags(channel=0, max_events=100)

# Find coincidences
coincidences = fpga.get_coincidence_tags(
    channel1=0, 
    channel2=1, 
    window_ns=1.0
)
```

### REST API Endpoints

```bash
# Get status
curl http://localhost:8082/api/time_tagger/status

# Get resolution
curl http://localhost:8082/api/time_tagger/resolution

# Get time tags
curl http://localhost:8082/api/time_tagger/tags/0?count=100

# Find coincidences
curl -X POST http://localhost:8082/api/time_tagger/coincidences \
  -H "Content-Type: application/json" \
  -d '{"channel1": 0, "channel2": 1, "window_ns": 1.0}'

# Decode timestamp
curl http://localhost:8082/api/time_tagger/decode/123456789
```

## Key Specifications

- **Channels**: 8 input channels (0-7)
- **Resolution**: ~50-100 ps (typ. 62.5 ps per LSB)
- **Timestamp Format**: 54 bits (48-bit coarse + 6-bit fine)
- **Time Range**: >1000 seconds continuous measurement
- **Clock Frequency**: 250 MHz (4 ns period)

## Timestamp Format

```
54-bit Timestamp:
┌──────────────────────────┬──────────┐
│   Coarse Time (48 bit)   │ Fine (6) │
└──────────────────────────┴──────────┘
[53:6] - Coarse: 4 ns steps
[5:0]  - Fine: ~62.5 ps steps

Time (ns) = Coarse + (Fine × 0.0625)
```

## Common Operations

### 1. Measure Single Channel Timing

```python
# Get 1000 timestamps
tags = fpga.get_time_tags(channel=0, max_events=1000)

# Decode timestamps
for raw_tag in tags:
    time_ns = fpga.decode_time_tag(raw_tag)
    print(f"{time_ns:.6f} ns")
```

### 2. Find Coincidences

```python
# Find events within 1 ns window
coincidences = fpga.get_coincidence_tags(
    channel1=0,
    channel2=1,
    window_ns=1.0,
    max_events=1000
)

# Analyze results
for t1, t2 in coincidences:
    diff = abs(t1 - t2)
    print(f"Δt = {diff:.6f} ns ({diff*1000:.1f} ps)")
```

### 3. Calculate Count Rate

```python
tags = fpga.get_time_tags(channel=0, max_events=10000)

if len(tags) >= 2:
    time_span_s = (tags[-1] - tags[0]) / 1e9
    rate_hz = len(tags) / time_span_s
    print(f"Count rate: {rate_hz:.1f} Hz")
```

### 4. Create Histogram

```python
from time_tagger import TimeTaggerHistogram

# Get time differences
coincidences = fpga.get_coincidence_tags(0, 1, 1.0)
time_diffs = [abs(t1 - t2) for t1, t2 in coincidences]

# Build histogram
histogram = TimeTaggerHistogram(bin_width_ps=10.0)
bin_edges, counts = histogram.build_histogram(
    time_diffs, 
    max_time_ns=5.0
)
```

## Integration Notes

### Hardware Integration

The time tagger modules are located in:
- `fpga/po_co_counter/po_co_counter.srcs/sources_1/new/time_tagger_simple.v`
- `fpga/po_co_counter/po_co_counter.srcs/sources_1/new/time_tag_fifo.v`

See `integration_example.v` for how to add to existing design.

### Key Signals

```verilog
// Inputs
clk_250mhz       // 250 MHz reference clock
reset            // Synchronous reset
ch_in            // Input channel signal
coarse_time      // 48-bit coarse counter

// Outputs
time_tag[53:0]   // 54-bit timestamp
time_tag_valid   // Valid flag (1 clock cycle pulse)
```

## Calibration

### 1. Delay Calibration

Use known reference delays to calibrate:

```python
# Apply known delay and measure
measured_delay = measure_delay()
correction = known_delay - measured_delay
```

### 2. Channel-to-Channel Calibration

Connect same source to multiple channels:

```python
# Measure offset
coincidences = fpga.get_coincidence_tags(0, 1, 10.0)
time_diffs = [t1 - t2 for t1, t2 in coincidences]
offset = sum(time_diffs) / len(time_diffs)

# Apply correction in FPGA delay settings
fpga.set_delay(channel=0, delay=int(offset/4))
```

## Troubleshooting

### No timestamps received
- Check if FPGA bitstream is loaded
- Verify input signals are connected
- Check if channels are enabled

### Poor timing resolution
- Verify FPGA routing constraints
- Check temperature stability
- Perform calibration

### FIFO overflow
- Reduce event rate
- Increase read frequency
- Increase FIFO depth in design

### Timing drift
- Monitor FPGA temperature
- Use external reference clock
- Periodic recalibration

## Performance Tips

1. **Optimize Read Frequency**: Read tags regularly to prevent FIFO overflow
2. **Use Appropriate Window**: Larger coincidence windows increase processing time
3. **Batch Processing**: Process events in batches for better throughput
4. **Hardware Filtering**: Use FPGA thresholding if available

## Examples

Run example scripts:

```bash
# Interactive examples
python3 server/time_tagger_examples.py

# Or run individual examples
python3 -c "from time_tagger_examples import example_1_basic_timing; example_1_basic_timing()"
```

## References

- Full documentation: `TIME_TAGGER_README.md`
- Hardware modules: `fpga/po_co_counter/po_co_counter.srcs/sources_1/new/`
- Python API: `server/time_tagger.py`
- Tests: `tests/time_tagger_test.py`
- API endpoints: `server/APIServer.py`

## Support

For issues:
1. Check FPGA bitstream is loaded
2. Verify PYNQ installation
3. Review hardware connections
4. Check system logs
5. Run tests: `python3 tests/time_tagger_test.py`
