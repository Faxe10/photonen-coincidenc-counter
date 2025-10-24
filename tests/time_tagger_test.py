#!/usr/bin/env python3
"""
Unit tests for Time Tagger module

Tests the time tagger interface and data processing functions.
"""

import unittest
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'server'))

try:
    from time_tagger import TimeTagger, TimeTaggerHistogram
    import numpy as np
except ImportError as e:
    print(f"Warning: Could not import required modules: {e}")
    print("Some tests may be skipped.")


class MockOverlay:
    """Mock FPGA overlay for testing without hardware."""
    pass


class TestTimeTagger(unittest.TestCase):
    """Test cases for TimeTagger class."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.mock_overlay = MockOverlay()
        self.tagger = TimeTagger(self.mock_overlay)
    
    def test_initialization(self):
        """Test time tagger initialization."""
        self.assertEqual(self.tagger.channels, 8)
        self.assertEqual(self.tagger.tag_bits, 54)
        self.assertEqual(self.tagger.coarse_bits, 48)
        self.assertEqual(self.tagger.fine_bits, 6)
        self.assertAlmostEqual(self.tagger.coarse_resolution_ns, 4.0)
        self.assertAlmostEqual(self.tagger.fine_resolution_ps, 62.5)
    
    def test_decode_timestamp(self):
        """Test timestamp decoding."""
        # Test case 1: Only coarse time
        raw_tag = 1000 << 6  # 1000 in coarse bits
        time_ns = self.tagger.decode_timestamp(raw_tag)
        self.assertAlmostEqual(time_ns, 1000.0, places=2)
        
        # Test case 2: Coarse + fine time
        fine = 16  # 16 * 62.5 ps = 1000 ps = 1 ns
        coarse = 1000
        raw_tag = (coarse << 6) | fine
        time_ns = self.tagger.decode_timestamp(raw_tag)
        expected = 1000.0 + (16 * 62.5 / 1000.0)
        self.assertAlmostEqual(time_ns, expected, places=2)
        
        # Test case 3: Maximum fine time
        fine = 63  # Maximum 6-bit value
        coarse = 0
        raw_tag = fine
        time_ns = self.tagger.decode_timestamp(raw_tag)
        expected = 63 * 62.5 / 1000.0  # ~3.94 ns
        self.assertAlmostEqual(time_ns, expected, places=2)
    
    def test_calculate_time_difference(self):
        """Test time difference calculation."""
        # Create two timestamps
        tag1 = 1000 << 6  # 1000 ns
        tag2 = 1010 << 6  # 1010 ns
        
        diff = self.tagger.calculate_time_difference(tag1, tag2)
        self.assertAlmostEqual(diff, 10.0, places=2)
        
        # Test with fine time
        tag1 = (1000 << 6) | 10
        tag2 = (1000 << 6) | 30
        diff = self.tagger.calculate_time_difference(tag1, tag2)
        expected_diff = (30 - 10) * 62.5 / 1000.0
        self.assertAlmostEqual(diff, expected_diff, places=2)
    
    def test_get_timing_resolution(self):
        """Test timing resolution reporting."""
        resolution = self.tagger.get_timing_resolution()
        
        self.assertIn('coarse_resolution_ns', resolution)
        self.assertIn('fine_resolution_ps', resolution)
        self.assertIn('total_resolution_ps', resolution)
        self.assertIn('max_time_range_s', resolution)
        
        self.assertEqual(resolution['coarse_resolution_ns'], 4.0)
        self.assertEqual(resolution['fine_resolution_ps'], 62.5)
        self.assertEqual(resolution['total_resolution_ps'], 62.5)
    
    def test_get_status(self):
        """Test status information."""
        status = self.tagger.get_status()
        
        self.assertEqual(status['channels'], 8)
        self.assertEqual(status['resolution_ps'], 62.5)
        self.assertEqual(status['fifo_depth'], 1024)
        self.assertEqual(status['tag_bits'], 54)


class TestTimeTaggerHistogram(unittest.TestCase):
    """Test cases for TimeTaggerHistogram class."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.histogram = TimeTaggerHistogram(bin_width_ps=10.0)
    
    def test_initialization(self):
        """Test histogram initialization."""
        self.assertEqual(self.histogram.bin_width_ps, 10.0)
    
    def test_build_histogram(self):
        """Test histogram building."""
        # Create test data: time differences in nanoseconds
        time_diffs = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]
        
        bin_edges, counts = self.histogram.build_histogram(
            time_diffs, 
            max_time_ns=5.0
        )
        
        # Check output format
        self.assertIsInstance(bin_edges, np.ndarray)
        self.assertIsInstance(counts, np.ndarray)
        self.assertEqual(len(counts), len(bin_edges) - 1)
        
        # Check that all counts sum to number of events
        self.assertEqual(counts.sum(), len(time_diffs))
    
    def test_build_histogram_with_different_bin_width(self):
        """Test histogram with different bin widths."""
        histogram_fine = TimeTaggerHistogram(bin_width_ps=5.0)
        histogram_coarse = TimeTaggerHistogram(bin_width_ps=50.0)
        
        time_diffs = [0.5, 1.0, 1.5, 2.0]
        
        _, counts_fine = histogram_fine.build_histogram(time_diffs, 5.0)
        _, counts_coarse = histogram_coarse.build_histogram(time_diffs, 5.0)
        
        # Fine histogram should have more bins
        self.assertGreater(len(counts_fine), len(counts_coarse))


class TestTimestampFormatting(unittest.TestCase):
    """Test timestamp format and conversion."""
    
    def test_timestamp_format(self):
        """Test that timestamp format is correct."""
        # Create a timestamp with known values
        coarse = 0x123456789ABC  # 48-bit value
        fine = 0x3F  # 6-bit value (maximum)
        
        # Combine into 54-bit timestamp
        raw_tag = (coarse << 6) | fine
        
        # Extract values
        extracted_fine = raw_tag & 0x3F
        extracted_coarse = (raw_tag >> 6) & 0xFFFFFFFFFFFF
        
        self.assertEqual(extracted_fine, fine)
        self.assertEqual(extracted_coarse, coarse)
    
    def test_timestamp_range(self):
        """Test timestamp range calculations."""
        # Maximum coarse time
        max_coarse = (1 << 48) - 1
        max_time_ns = max_coarse  # Direct mapping to nanoseconds
        max_time_s = max_time_ns / 1e9
        
        # Should be able to measure for >1000 seconds
        self.assertGreater(max_time_s, 1000.0)
        
        # Should be less than ~8 years (reasonable range)
        self.assertLess(max_time_s, 8 * 365 * 24 * 3600)


class TestCoincidenceDetection(unittest.TestCase):
    """Test coincidence detection algorithms."""
    
    def test_simple_coincidence(self):
        """Test basic coincidence detection."""
        # Create mock timestamps with known coincidences
        tags1 = [100.0, 200.0, 300.0]  # ns
        tags2 = [100.5, 250.0, 300.2]  # ns
        
        coincidences = []
        window_ns = 1.0
        
        for t1 in tags1:
            for t2 in tags2:
                if abs(t1 - t2) <= window_ns:
                    coincidences.append((t1, t2))
        
        # Should find 2 coincidences (100-100.5 and 300-300.2)
        self.assertEqual(len(coincidences), 2)
        
        # Check first coincidence
        self.assertAlmostEqual(coincidences[0][0], 100.0)
        self.assertAlmostEqual(coincidences[0][1], 100.5)
    
    def test_no_coincidence(self):
        """Test case with no coincidences."""
        tags1 = [100.0, 200.0, 300.0]
        tags2 = [150.0, 250.0, 350.0]
        
        coincidences = []
        window_ns = 1.0
        
        for t1 in tags1:
            for t2 in tags2:
                if abs(t1 - t2) <= window_ns:
                    coincidences.append((t1, t2))
        
        # Should find no coincidences
        self.assertEqual(len(coincidences), 0)


def run_tests():
    """Run all tests."""
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # Add test classes
    suite.addTests(loader.loadTestsFromTestCase(TestTimeTagger))
    suite.addTests(loader.loadTestsFromTestCase(TestTimeTaggerHistogram))
    suite.addTests(loader.loadTestsFromTestCase(TestTimestampFormatting))
    suite.addTests(loader.loadTestsFromTestCase(TestCoincidenceDetection))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    return result.wasSuccessful()


if __name__ == '__main__':
    success = run_tests()
    sys.exit(0 if success else 1)
