# Time Tagger für EBAZ4205 Photonen-Koinzidenz-Detektor

## Übersicht

Dieses Dokument beschreibt die Implementierung eines hochauflösenden Time Taggers für den EBAZ4205 (Zynq-7010) basierten Photonen-Koinzidenz-Detektor mit einer Zeitauflösung von mindestens 50 ps.

## Spezifikationen

- **Ziel-Hardware**: EBAZ4205 (Xilinx Zynq-7010 FPGA)
- **Zeitauflösung**: ~50-100 ps
- **Anzahl Kanäle**: 8 Eingangskanäle
- **Referenztakt**: 250 MHz (4 ns Periode)
- **Zeitstempel-Format**: 54 Bit (48 Bit grob + 6 Bit fein)
- **Messbereich**: ~1100 Sekunden (kontinuierlich)

## Architektur

### Hardware-Komponenten

#### 1. Time Tagger Module

Es wurden mehrere Time-Tagger-Implementierungen erstellt:

##### a) `time_tagger.v` - Carry-Chain basiert
- Verwendet CARRY4-Primitives für Verzögerungsketten
- 64-stufige Verzögerungskette pro Kanal
- Theoretische Auflösung: ~62.5 ps pro Stufe
- Thermometer-zu-Binär-Konvertierung für Feinzeit

##### b) `time_tagger_iserdes.v` - ISERDES basiert
- Verwendet Überabtastung mit IOB-Registern
- 8-fache Überabtastung
- Interpolation für höhere Auflösung
- Robuster gegen Prozessvariationen

##### c) `time_tagger_simple.v` - Vereinfachte Version
- Einfachere Integration mit bestehendem Design
- LUT-basierte Verzögerungskette
- Direkte Integration möglich

#### 2. Time Tag FIFO (`time_tag_fifo.v`)
- Pufferspeicher für Zeitstempel von allen Kanälen
- 1024 Einträge tief
- Priority-Encoder für Multi-Channel-Schreiben
- AXI-Interface zum Auslesen durch PS

### Software-Komponenten

#### 1. TimeTagger Python-Klasse (`server/time_tagger.py`)
```python
from time_tagger import TimeTagger

# Initialisierung
tagger = TimeTagger(fpga_overlay)

# Zeitstempel auslesen
timestamps = tagger.get_time_tags(channel=0, max_events=1000)

# Koinzidenzen finden
coincidences = tagger.get_coincidences(
    channel1=0, 
    channel2=1, 
    window_ns=1.0
)

# Zeitauflösung abrufen
resolution = tagger.get_timing_resolution()
print(f"Auflösung: {resolution['total_resolution_ps']} ps")
```

#### 2. Zeitstempel-Format

```
54 Bit Gesamtzeitstempel:
[53:6]  - Grobzeit (48 Bit): 4 ns Auflösung, Zählt in Nanosekunden
[5:0]   - Feinzeit (6 Bit): ~62.5 ps Auflösung pro LSB
```

Zeitberechnung:
```python
def decode_timestamp(raw_tag):
    fine_time = raw_tag & 0x3F  # Unterste 6 Bits
    coarse_time = (raw_tag >> 6) & 0xFFFFFFFFFFFF  # Obere 48 Bits
    
    time_ns = coarse_time + (fine_time * 0.0625)
    return time_ns
```

## Integration mit bestehendem Design

### FPGA-Integration

Der Time Tagger kann in das bestehende Design integriert werden, indem man:

1. **Time Tagger Instanz hinzufügen** in `start.v`:
```verilog
// Time tagger instance für jeden Kanal
time_tagger_simple #(
    .COARSE_BITS(48),
    .FINE_BITS(6),
    .TAG_BITS(54)
) time_tagger_ch1 (
    .clk_250mhz(clk_250mhz),
    .reset(reset),
    .ch_in(ch1),
    .time_tag(time_tag_ch1),
    .time_tag_valid(time_tag_valid_ch1),
    .coarse_time(ns)  // Bestehendes ns-Signal verwenden
);
```

2. **FIFO hinzufügen** für Pufferung:
```verilog
time_tag_fifo #(
    .CHANNELS(8),
    .TAG_BITS(54),
    .FIFO_DEPTH(1024)
) tag_fifo (
    .clk(clk_250mhz),
    .reset(reset),
    .time_tags({time_tag_ch8, ..., time_tag_ch1}),
    .time_tag_valid({time_tag_valid_ch8, ..., time_tag_valid_ch1}),
    // AXI-Interface für PS-Zugriff
    .read_enable(fifo_read_en),
    .read_time_tag(fifo_read_data),
    .read_channel(fifo_read_channel),
    .read_valid(fifo_read_valid)
);
```

### Python-API-Integration

Erweitern Sie `fpga.py` um Time-Tagger-Funktionalität:

```python
from time_tagger import TimeTagger

class FPGA:
    def __init__(self):
        # Bestehender Code...
        self.time_tagger = TimeTagger(self.overlay)
    
    def get_time_tags(self, channel, count=100):
        """Zeitstempel von Kanal auslesen"""
        return self.time_tagger.get_time_tags(channel, count)
    
    def get_coincidence_tags(self, ch1, ch2, window_ns=1.0):
        """Koinzidente Ereignisse finden"""
        return self.time_tagger.get_coincidences(ch1, ch2, window_ns)
```

## Kalibration und Genauigkeit

### Kalibrationsprozess

1. **Verzögerungskette-Kalibrierung**:
   - Verwenden Sie bekannte Referenzverzögerungen
   - Messen Sie tatsächliche ps/Bin-Werte
   - Kalibrierungsfunktion in `time_tagger.py`:
   ```python
   measured_delay = tagger.calibrate_fine_time(reference_delay_ps=50.0)
   ```

2. **Kanal-zu-Kanal-Kalibrierung**:
   - Gleiche Quelle an mehrere Kanäle anschließen
   - Zeitoffsets zwischen Kanälen messen
   - In Software korrigieren

### Erwartete Genauigkeit

- **Beste Auflösung**: ~50 ps (mit Kalibrierung)
- **Typische Auflösung**: ~100 ps (ohne Kalibrierung)
- **Grobzeit-Auflösung**: 4 ns (250 MHz Takt)
- **Stabilität**: Abhängig von Temperatur und Versorgungsspannung

## Verwendungsbeispiele

### Beispiel 1: Einfache Zeitmessung
```python
from time_tagger import TimeTagger

# Initialisierung
tagger = TimeTagger(overlay)

# 100 Ereignisse von Kanal 0 erfassen
tags = tagger.get_time_tags(channel=0, max_events=100)

# Zeitstempel anzeigen
for i, tag_raw in enumerate(tags):
    time_ns = tagger.decode_timestamp(tag_raw)
    print(f"Event {i}: {time_ns:.3f} ns")
```

### Beispiel 2: Koinzidenzmessung
```python
# Koinzidenzen zwischen Kanal 0 und 1 finden
# mit 1 ns Zeitfenster
coincidences = tagger.get_coincidences(
    channel1=0,
    channel2=1,
    window_ns=1.0,
    max_events=1000
)

print(f"Gefundene Koinzidenzen: {len(coincidences)}")

# Zeitdifferenzen analysieren
time_diffs = [abs(t1 - t2) for t1, t2 in coincidences]
mean_diff = sum(time_diffs) / len(time_diffs)
print(f"Mittlere Zeitdifferenz: {mean_diff:.3f} ns")
```

### Beispiel 3: Histogramm erstellen
```python
from time_tagger import TimeTaggerHistogram

# Histogramm-Objekt erstellen mit 10 ps Bins
histogram = TimeTaggerHistogram(bin_width_ps=10.0)

# Zeitdifferenzen berechnen
time_diffs = [abs(coincidences[i][0] - coincidences[i][1]) 
              for i in range(len(coincidences))]

# Histogramm plotten
histogram.plot_histogram(
    time_diffs, 
    max_time_ns=10.0,
    title="Koinzidenz-Zeitdifferenz"
)
```

## API-Erweiterungen

Fügen Sie neue Endpunkte zu `APIServer.py` hinzu:

```python
@app.route('/api/time_tags/<int:channel>', methods=['GET'])
def get_time_tags(channel):
    count = request.args.get('count', default=100, type=int)
    tags = self.fpga.get_time_tags(channel, count)
    return jsonify({'channel': channel, 'tags': tags})

@app.route('/api/coincidences', methods=['POST'])
def get_coincidences():
    data = request.get_json()
    ch1 = data.get('channel1', 0)
    ch2 = data.get('channel2', 1)
    window = data.get('window_ns', 1.0)
    
    coincidences = self.fpga.get_coincidence_tags(ch1, ch2, window)
    return jsonify({
        'channel1': ch1,
        'channel2': ch2,
        'window_ns': window,
        'count': len(coincidences),
        'coincidences': coincidences
    })
```

## Leistung und Einschränkungen

### Vorteile
- ✓ Hohe Zeitauflösung (~50-100 ps)
- ✓ 8 parallele Kanäle
- ✓ Großer Messbereich (>1000 s)
- ✓ Hardware-basiert (keine CPU-Last)
- ✓ Deterministisch (kein Jitter durch Software)

### Einschränkungen
- ✗ Auflösung begrenzt durch FPGA-Routing-Verzögerungen
- ✗ Temperaturabhängigkeit der Verzögerungen
- ✗ Kalibrierung erforderlich für beste Genauigkeit
- ✗ FIFO-Überlauf bei sehr hohen Ereignisraten
- ✗ Maximale Ereignisrate: ~100 MHz pro Kanal

## Test und Verifikation

### Hardware-Tests

1. **Funktionstest**:
   - Signal-Generator an Eingang anschließen
   - Konstante Frequenz prüfen (z.B. 1 MHz)
   - Zeitstempel-Gleichmäßigkeit verifizieren

2. **Auflösungstest**:
   - Präzisionsverzögerungs-Generator verwenden
   - Bekannte Verzögerungen einstellen (100 ps, 200 ps, etc.)
   - Gemessene vs. erwartete Werte vergleichen

3. **Koinzidenztest**:
   - Gleiches Signal an zwei Kanäle
   - Zeitdifferenz sollte nahe 0 sein
   - Kabel-/Pfadverzögerungen messen

### Software-Tests

Siehe `tests/time_tagger_test.py` (zu erstellen) für Unit-Tests.

## Zukünftige Erweiterungen

- DMA-Integration für höheren Durchsatz
- Hardware-basierte Koinzidenzerkennung
- Mehrkanal-Kreuzkorrelation
- Echtzeit-Histogramm in FPGA
- Temperaturkompensation

## Referenzen

- Xilinx Zynq-7000 TRM
- "Time-to-Digital Converters" - Jiri Kovar
- "FPGA-based TDC Design" - Application Notes
- EBAZ4205 Schematic und Pinout

## Support

Bei Fragen oder Problemen:
- GitHub Issues erstellen
- Hardware-Spezifikationen prüfen
- Kalibrierung durchführen

---

**Version**: 1.0  
**Datum**: 2025-10-24  
**Autor**: Auto-generiert für EBAZ4205 Photon Coincidence Counter
