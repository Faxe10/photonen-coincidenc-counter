#!/usr/bin/env python3
"""
Example usage of the Time Tagger for EBAZ4205 Photon Coincidence Counter

This script demonstrates how to use the time tagger functionality
for high-resolution timing measurements.

Requirements:
- FPGA with time tagger loaded
- PYNQ framework
- Connected photon detectors
"""

import sys
import time

try:
    from fpga import FPGA
except ImportError:
    print("Error: Cannot import FPGA module")
    print("Make sure you're running on the EBAZ4205 with PYNQ")
    sys.exit(1)


def print_separator():
    """Print a separator line."""
    print("=" * 70)


def example_1_basic_timing():
    """
    Example 1: Basic timing measurement
    Capture timestamps from a single channel
    """
    print_separator()
    print("Example 1: Basic Timing Measurement")
    print_separator()
    
    # Initialize FPGA
    print("Initializing FPGA...")
    fpga = FPGA()
    
    # Check if time tagger is available
    status = fpga.get_time_tagger_status()
    if not status.get('available', False):
        print(f"Error: Time tagger not available - {status.get('error', 'Unknown error')}")
        return
    
    print(f"Time tagger status: {status}")
    
    # Get timing resolution
    resolution = fpga.get_time_tagger_resolution()
    print(f"\nTiming Resolution:")
    print(f"  - Coarse: {resolution['coarse_resolution_ns']:.1f} ns")
    print(f"  - Fine: {resolution['fine_resolution_ps']:.1f} ps")
    print(f"  - Total: {resolution['total_resolution_ps']:.1f} ps")
    
    # Capture timestamps from channel 0
    print("\nCapturing 10 events from channel 0...")
    tags = fpga.get_time_tags(channel=0, max_events=10)
    
    print(f"\nCaptured {len(tags)} events:")
    for i, tag_raw in enumerate(tags[:10]):
        time_ns = fpga.decode_time_tag(tag_raw)
        print(f"  Event {i+1}: {time_ns:.3f} ns (raw: 0x{tag_raw:013X})")


def example_2_coincidence_measurement():
    """
    Example 2: Coincidence measurement
    Find coincident events between two channels
    """
    print_separator()
    print("Example 2: Coincidence Measurement")
    print_separator()
    
    # Initialize FPGA
    print("Initializing FPGA...")
    fpga = FPGA()
    
    # Set coincidence window (1 nanosecond)
    window_ns = 1.0
    
    print(f"\nSearching for coincidences between channels 0 and 1")
    print(f"Coincidence window: {window_ns} ns")
    
    # Get coincidences
    coincidences = fpga.get_coincidence_tags(
        channel1=0,
        channel2=1,
        window_ns=window_ns,
        max_events=1000
    )
    
    print(f"\nFound {len(coincidences)} coincidence events")
    
    if coincidences:
        # Calculate statistics
        time_diffs = [abs(t1 - t2) for t1, t2 in coincidences]
        mean_diff = sum(time_diffs) / len(time_diffs)
        min_diff = min(time_diffs)
        max_diff = max(time_diffs)
        
        print(f"\nTiming statistics:")
        print(f"  - Mean time difference: {mean_diff:.3f} ns ({mean_diff*1000:.1f} ps)")
        print(f"  - Min time difference: {min_diff:.3f} ns ({min_diff*1000:.1f} ps)")
        print(f"  - Max time difference: {max_diff:.3f} ns ({max_diff*1000:.1f} ps)")
        
        # Show first few coincidences
        print(f"\nFirst 5 coincidence events:")
        for i, (t1, t2) in enumerate(coincidences[:5]):
            diff = abs(t1 - t2)
            print(f"  Event {i+1}: Ch0={t1:.3f} ns, Ch1={t2:.3f} ns, Diff={diff:.3f} ns ({diff*1000:.1f} ps)")


def example_3_count_rate():
    """
    Example 3: Count rate measurement
    Measure photon count rate on multiple channels
    """
    print_separator()
    print("Example 3: Count Rate Measurement")
    print_separator()
    
    # Initialize FPGA
    print("Initializing FPGA...")
    fpga = FPGA()
    
    print("\nMeasuring count rates on all channels...")
    print("Integration time: 1.0 seconds")
    
    # Get count rates for all channels
    for channel in range(8):
        try:
            tags = fpga.get_time_tags(channel=channel, max_events=10000)
            
            if len(tags) >= 2:
                # Calculate rate from time span
                time_span_ns = tags[-1] - tags[0]
                time_span_s = time_span_ns / 1e9
                
                if time_span_s > 0:
                    rate_hz = len(tags) / time_span_s
                    print(f"  Channel {channel}: {rate_hz:.1f} Hz ({len(tags)} events in {time_span_s:.3f} s)")
                else:
                    print(f"  Channel {channel}: N/A (insufficient time span)")
            else:
                print(f"  Channel {channel}: N/A (insufficient events)")
                
        except Exception as e:
            print(f"  Channel {channel}: Error - {e}")


def example_4_time_histogram():
    """
    Example 4: Create timing histogram
    Analyze time difference distribution
    """
    print_separator()
    print("Example 4: Timing Histogram")
    print_separator()
    
    try:
        from time_tagger import TimeTaggerHistogram
    except ImportError:
        print("Error: TimeTaggerHistogram not available")
        return
    
    # Initialize FPGA
    print("Initializing FPGA...")
    fpga = FPGA()
    
    # Get coincidences
    print("\nCollecting coincidence data...")
    coincidences = fpga.get_coincidence_tags(
        channel1=0,
        channel2=1,
        window_ns=5.0,
        max_events=1000
    )
    
    if not coincidences:
        print("No coincidences found")
        return
    
    print(f"Found {len(coincidences)} coincidence events")
    
    # Calculate time differences
    time_diffs = [abs(t1 - t2) for t1, t2 in coincidences]
    
    # Create histogram
    histogram = TimeTaggerHistogram(bin_width_ps=50.0)
    bin_edges, counts = histogram.build_histogram(time_diffs, max_time_ns=5.0)
    
    print(f"\nHistogram created with {len(counts)} bins")
    print(f"Bin width: {histogram.bin_width_ps} ps")
    
    # Show first few histogram bins
    print("\nFirst 10 histogram bins:")
    for i in range(min(10, len(counts))):
        print(f"  Bin {i}: {bin_edges[i]:.1f} ps - {bin_edges[i+1]:.1f} ps: {counts[i]} events")


def example_5_channel_calibration():
    """
    Example 5: Channel-to-channel calibration
    Measure timing offsets between channels
    """
    print_separator()
    print("Example 5: Channel Calibration")
    print_separator()
    
    print("Connect the same signal source to channels 0 and 1")
    print("Press Enter when ready...")
    input()
    
    # Initialize FPGA
    print("\nInitializing FPGA...")
    fpga = FPGA()
    
    print("Measuring timing offset between channels 0 and 1...")
    
    # Get coincidences
    coincidences = fpga.get_coincidence_tags(
        channel1=0,
        channel2=1,
        window_ns=10.0,
        max_events=100
    )
    
    if not coincidences:
        print("No coincidences found - check signal source")
        return
    
    # Calculate timing offset
    time_diffs = [t1 - t2 for t1, t2 in coincidences]  # Note: not absolute value
    mean_offset = sum(time_diffs) / len(time_diffs)
    
    print(f"\nFound {len(coincidences)} coincidence events")
    print(f"Mean timing offset: {mean_offset:.3f} ns ({mean_offset*1000:.1f} ps)")
    print(f"(Positive means Channel 0 is later than Channel 1)")
    
    # Calculate correction
    correction_steps = int(mean_offset / 4.0)  # 4 ns per delay step
    print(f"\nSuggested delay correction: {correction_steps} steps")
    
    if abs(mean_offset) > 0.5:
        print(f"Apply delay of {abs(correction_steps)} steps to channel {'0' if mean_offset > 0 else '1'}")


def main():
    """Main function - run all examples."""
    print("\n")
    print("=" * 70)
    print(" Time Tagger Examples for EBAZ4205 Photon Coincidence Counter")
    print("=" * 70)
    print("\nThese examples demonstrate high-resolution time tagging capabilities")
    print("with ~50-100 ps timing accuracy.")
    print("\n")
    
    examples = [
        ("Basic Timing Measurement", example_1_basic_timing),
        ("Coincidence Measurement", example_2_coincidence_measurement),
        ("Count Rate Measurement", example_3_count_rate),
        ("Timing Histogram", example_4_time_histogram),
        ("Channel Calibration", example_5_channel_calibration),
    ]
    
    while True:
        print("\nAvailable examples:")
        for i, (name, _) in enumerate(examples):
            print(f"  {i+1}. {name}")
        print("  0. Exit")
        
        try:
            choice = input("\nSelect example (0-5): ").strip()
            
            if choice == '0':
                print("\nExiting...")
                break
            
            idx = int(choice) - 1
            if 0 <= idx < len(examples):
                print("\n")
                examples[idx][1]()
                print("\n")
            else:
                print("Invalid choice")
                
        except ValueError:
            print("Invalid input")
        except KeyboardInterrupt:
            print("\n\nInterrupted by user")
            break
        except Exception as e:
            print(f"\nError: {e}")
            import traceback
            traceback.print_exc()


if __name__ == "__main__":
    main()
