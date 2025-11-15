#!/usr/bin/env python3
"""
Time Tagger Interface for EBAZ4205 Photon Coincidence Counter

This module provides Python interface to the high-resolution time tagger
hardware implemented in the FPGA. The time tagger achieves ~50-100 ps
timing resolution using TDC (Time-to-Digital Converter) techniques.

Author: Auto-generated
Date: 2025-10-24
"""

import numpy as np
from typing import List, Tuple, Dict
import struct


class TimeTagger:
    """
    Interface class for the FPGA-based time tagger.
    
    The time tagger captures precise timestamps of photon detection events
    on multiple input channels with sub-nanosecond resolution.
    
    Timestamp format:
    - Total bits: 54 bits
    - Coarse time: 48 bits (4 ns resolution, counts in nanoseconds)
    - Fine time: 6 bits (~62.5 ps resolution per LSB)
    
    Effective timing resolution: ~50-100 ps (depends on FPGA routing)
    """
    
    def __init__(self, fpga_overlay):
        """
        Initialize the time tagger interface.
        
        Args:
            fpga_overlay: PYNQ Overlay object with time tagger loaded
        """
        self.overlay = fpga_overlay
        self.channels = 8
        self.tag_bits = 54
        self.coarse_bits = 48
        self.fine_bits = 6
        
        # Time conversion factors
        self.coarse_resolution_ns = 4.0  # 250 MHz clock = 4 ns
        self.fine_resolution_ps = 62.5   # Approximately 62.5 ps per fine bin
        
        # FIFO interface (if available in design)
        self.fifo_depth = 1024
        
    def get_time_tags(self, channel: int, max_events: int = 100) -> List[float]:
        """
        Read time tags from specified channel.
        
        Args:
            channel: Channel number (0-7)
            max_events: Maximum number of events to read
            
        Returns:
            List of timestamps in nanoseconds
        """
        if channel < 0 or channel >= self.channels:
            raise ValueError(f"Channel must be between 0 and {self.channels-1}")
        
        timestamps = []
        
        # Read from FIFO (implementation depends on actual hardware interface)
        # This is a placeholder - actual implementation would read from AXI GPIO
        # or DMA depending on the hardware design
        
        return timestamps
    
    def decode_timestamp(self, raw_tag: int) -> float:
        """
        Decode raw timestamp value to nanoseconds.
        
        Args:
            raw_tag: 54-bit raw timestamp value
            
        Returns:
            Time in nanoseconds (float)
        """
        # Extract coarse and fine parts
        fine_time = raw_tag & ((1 << self.fine_bits) - 1)
        coarse_time = (raw_tag >> self.fine_bits) & ((1 << self.coarse_bits) - 1)
        
        # Convert to nanoseconds
        coarse_ns = float(coarse_time)
        fine_ns = (fine_time * self.fine_resolution_ps) / 1000.0
        
        total_time_ns = coarse_ns + fine_ns
        
        return total_time_ns
    
    def get_timing_resolution(self) -> Dict[str, float]:
        """
        Get timing resolution specifications.
        
        Returns:
            Dictionary with resolution information
        """
        return {
            'coarse_resolution_ns': self.coarse_resolution_ns,
            'fine_resolution_ps': self.fine_resolution_ps,
            'total_resolution_ps': self.fine_resolution_ps,
            'max_time_range_s': (2 ** self.coarse_bits) * self.coarse_resolution_ns / 1e9
        }
    
    def calculate_time_difference(self, tag1: int, tag2: int) -> float:
        """
        Calculate time difference between two timestamps.
        
        Args:
            tag1: First timestamp (raw)
            tag2: Second timestamp (raw)
            
        Returns:
            Time difference in nanoseconds
        """
        time1 = self.decode_timestamp(tag1)
        time2 = self.decode_timestamp(tag2)
        
        return abs(time1 - time2)
    
    def get_coincidences(self, 
                        channel1: int, 
                        channel2: int,
                        window_ns: float = 1.0,
                        max_events: int = 1000) -> List[Tuple[float, float]]:
        """
        Find coincidence events between two channels.
        
        Args:
            channel1: First channel number
            channel2: Second channel number
            window_ns: Coincidence window in nanoseconds
            max_events: Maximum number of events to process
            
        Returns:
            List of (time1, time2) tuples for coincident events
        """
        tags1 = self.get_time_tags(channel1, max_events)
        tags2 = self.get_time_tags(channel2, max_events)
        
        coincidences = []
        
        # Simple coincidence finding algorithm
        # This should be optimized for production use
        for t1 in tags1:
            for t2 in tags2:
                if abs(t1 - t2) <= window_ns:
                    coincidences.append((t1, t2))
        
        return coincidences
    
    def get_count_rate(self, channel: int, integration_time_s: float = 1.0) -> float:
        """
        Get photon count rate on specified channel.
        
        Args:
            channel: Channel number (0-7)
            integration_time_s: Integration time in seconds
            
        Returns:
            Count rate in Hz
        """
        tags = self.get_time_tags(channel, max_events=10000)
        
        if len(tags) < 2:
            return 0.0
        
        # Calculate rate from time span
        time_span_ns = tags[-1] - tags[0]
        time_span_s = time_span_ns / 1e9
        
        if time_span_s > 0:
            return len(tags) / time_span_s
        else:
            return 0.0
    
    def calibrate_fine_time(self, reference_delay_ps: float = 50.0) -> float:
        """
        Calibrate the fine time measurement against a known delay.
        
        This function can be used with a precision delay generator to
        calibrate the actual ps/bin value of the fine time measurement.
        
        Args:
            reference_delay_ps: Known delay in picoseconds
            
        Returns:
            Measured delay in picoseconds
        """
        # Placeholder for calibration routine
        # Actual implementation would use test pattern generator
        return self.fine_resolution_ps
    
    def reset_tagger(self):
        """
        Reset the time tagger hardware.
        """
        # Implementation depends on hardware interface
        pass
    
    def get_status(self) -> Dict:
        """
        Get time tagger status information.
        
        Returns:
            Dictionary with status information
        """
        return {
            'channels': self.channels,
            'resolution_ps': self.fine_resolution_ps,
            'fifo_depth': self.fifo_depth,
            'tag_bits': self.tag_bits
        }


class TimeTaggerHistogram:
    """
    Helper class for creating timing histograms from time tag data.
    """
    
    def __init__(self, bin_width_ps: float = 10.0):
        """
        Initialize histogram builder.
        
        Args:
            bin_width_ps: Histogram bin width in picoseconds
        """
        self.bin_width_ps = bin_width_ps
        
    def build_histogram(self, time_differences: List[float], 
                       max_time_ns: float = 10.0) -> Tuple[np.ndarray, np.ndarray]:
        """
        Build histogram from time difference data.
        
        Args:
            time_differences: List of time differences in nanoseconds
            max_time_ns: Maximum time range for histogram
            
        Returns:
            Tuple of (bin_edges, counts)
        """
        # Convert to picoseconds
        time_diffs_ps = [t * 1000.0 for t in time_differences]
        
        # Calculate number of bins
        n_bins = int(max_time_ns * 1000.0 / self.bin_width_ps)
        
        # Create histogram
        counts, bin_edges = np.histogram(time_diffs_ps, 
                                         bins=n_bins, 
                                         range=(0, max_time_ns * 1000.0))
        
        return bin_edges, counts
    
    def plot_histogram(self, time_differences: List[float], 
                      max_time_ns: float = 10.0,
                      title: str = "Time Difference Histogram"):
        """
        Plot timing histogram.
        
        Args:
            time_differences: List of time differences in nanoseconds
            max_time_ns: Maximum time range for histogram
            title: Plot title
        """
        try:
            import matplotlib.pyplot as plt
            
            bin_edges, counts = self.build_histogram(time_differences, max_time_ns)
            
            plt.figure(figsize=(10, 6))
            plt.bar(bin_edges[:-1], counts, width=self.bin_width_ps)
            plt.xlabel('Time Difference (ps)')
            plt.ylabel('Counts')
            plt.title(title)
            plt.grid(True, alpha=0.3)
            plt.show()
            
        except ImportError:
            print("matplotlib not available for plotting")


# Example usage
if __name__ == "__main__":
    print("Time Tagger Module for EBAZ4205")
    print("=" * 50)
    print()
    print("Features:")
    print("- 8 input channels")
    print("- ~50-100 ps timing resolution")
    print("- 54-bit timestamp (48-bit coarse + 6-bit fine)")
    print("- Coincidence detection")
    print("- Histogram analysis")
    print()
    print("This module requires PYNQ overlay with time tagger loaded.")
