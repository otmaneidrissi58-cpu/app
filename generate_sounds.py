import os
import math
import random
import wave
import struct

os.makedirs('/Users/macbookpro/focus_flow/assets/sounds', exist_ok=True)

sample_rate = 22050
duration = 8  # seconds
num_samples = sample_rate * duration

def save_wav(filename, samples):
    filepath = os.path.join('/Users/macbookpro/focus_flow/assets/sounds', filename)
    with wave.open(filepath, 'w') as f:
        f.setnchannels(1)  # Mono
        f.setsampwidth(2)  # 16-bit
        f.setframerate(sample_rate)
        # Normalize
        max_val = max(abs(s) for s in samples) or 1.0
        scaled = [int((s / max_val) * 30000) for s in samples]
        raw_bytes = bytearray()
        for s in scaled:
            raw_bytes.extend(struct.pack('<h', s))
        f.writeframes(raw_bytes)
    print(f"Generated {filename} ({len(raw_bytes)} bytes)")

# 1. White Noise
samples_white = [random.uniform(-1, 1) for _ in range(num_samples)]
save_wav('white_noise.wav', samples_white)

# 2. Rain
samples_rain = []
b0, b1, b2 = 0, 0, 0
for _ in range(num_samples):
    # Soft filtered noise + occasional drops
    white = random.uniform(-1, 1)
    b0 = 0.95 * b0 + 0.05 * white
    drop = 2.0 if random.random() < 0.002 else 0.0
    samples_rain.append(b0 + drop * (random.random() - 0.5))
save_wav('rain.wav', samples_rain)

# 3. Ocean Waves
samples_ocean = []
b0 = 0
for i in range(num_samples):
    t = i / sample_rate
    # Modulate frequency envelope over 4-second cycles
    wave_env = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(2 * math.pi * t / 4.0))
    white = random.uniform(-1, 1)
    b0 = 0.96 * b0 + 0.04 * white
    samples_ocean.append(b0 * wave_env)
save_wav('ocean.wav', samples_ocean)

# 4. Crackling Fire
samples_fire = []
b0 = 0
for _ in range(num_samples):
    white = random.uniform(-1, 1)
    b0 = 0.90 * b0 + 0.10 * white
    crackle = (random.random() ** 15) * random.choice([-3, 3])
    samples_fire.append(b0 * 0.4 + crackle)
save_wav('fire.wav', samples_fire)

# 5. Cafe Ambience
samples_cafe = []
b0 = 0
for i in range(num_samples):
    t = i / sample_rate
    white = random.uniform(-1, 1)
    b0 = 0.92 * b0 + 0.08 * white
    clink = math.sin(2 * math.pi * 1200 * t) * math.exp(-((t * 10) % 3) * 5) if random.random() < 0.0005 else 0
    samples_cafe.append(b0 + clink)
save_wav('cafe.wav', samples_cafe)

# 6. Forest (Premium)
samples_forest = []
b0 = 0
for i in range(num_samples):
    t = i / sample_rate
    white = random.uniform(-1, 1)
    b0 = 0.97 * b0 + 0.03 * white  # gentle leaf rustle
    # bird chirp
    chirp = 0
    if (int(t * 1.5) % 3 == 0) and (t % 0.6 < 0.15):
        chirp = math.sin(2 * math.pi * (2500 + 500 * math.sin(2 * math.pi * t * 20)) * t) * 0.3
    samples_forest.append(b0 * 0.5 + chirp)
save_wav('forest.wav', samples_forest)

# 7. Thunderstorm (Premium)
samples_thunder = []
b0 = 0
for i in range(num_samples):
    t = i / sample_rate
    white = random.uniform(-1, 1)
    b0 = 0.94 * b0 + 0.06 * white  # rain
    thunder = 0
    if 2.0 < t < 4.5:
        thunder_env = math.exp(-(t - 2.0) * 1.2) * (random.uniform(-1, 1))
        thunder = thunder_env * 1.5
    samples_thunder.append(b0 * 0.5 + thunder)
save_wav('thunderstorm.wav', samples_thunder)

# 8. Night Wind (Premium)
samples_wind = []
b0 = 0
for i in range(num_samples):
    t = i / sample_rate
    wind_mod = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(2 * math.pi * t / 3.5))
    white = random.uniform(-1, 1)
    b0 = 0.98 * b0 + 0.02 * white
    samples_wind.append(b0 * wind_mod)
save_wav('night_wind.wav', samples_wind)

print("All sound assets generated successfully!")
