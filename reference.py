"""Dependency-free 63-tap, 1.8 kHz low-pass reference at 48 kHz.
Run python3 reference.py to test and generate RTL vectors.
Quantization: floor(x*32768 + .5), saturate int16; accumulator >> 15.
"""
import math, random
from pathlib import Path
N, FS, FC = 63, 48000, 1800

def quantize(x):
    return max(-32768, min(32767, math.floor(x*32768+.5)))

def coefficients():
    h=[]
    for i in range(N):
        k=i-(N-1)/2
        v=2*FC/FS if k==0 else math.sin(2*math.pi*FC*k/FS)/(math.pi*k)
        h.append(v*(.54-.46*math.cos(2*math.pi*i/(N-1))))
    return [v/sum(h) for v in h]

def fixed(x,h):
    return [max(-32768,min(32767,sum(x[i-k]*h[k] for k in range(min(i+1,len(h)))) >> 15)) for i in range(len(x))]

def main():
    h=coefficients(); qh=list(map(quantize,h))
    assert abs(sum(h)-1)<1e-12
    assert max(abs(h[i]-h[-1-i]) for i in range(N))<1e-12
    def response(freq):
        return abs(sum(v*complex(math.cos(2*math.pi*freq*i/FS),-math.sin(2*math.pi*freq*i/FS)) for i,v in enumerate(h)))
    assert response(220)>.95
    assert response(6500)<.01
    assert fixed([0]*128,qh)==[0]*128
    assert fixed([32767],[32767])==[32766]
    assert fixed([-32768],[32767])==[-32767]
    assert fixed([32767]*3,[32767]*3)[-1]==32767
    assert fixed([-32768]*3,[32767]*3)[-1]==-32768
    rng=random.Random(42)
    x=[32767]+[0]*100+[quantize(.22*(math.sin(2*math.pi*220*i/FS)+math.sin(2*math.pi*6500*i/FS))) for i in range(512)]+[rng.randint(-32768,32767) for _ in range(512)]
    y=fixed(x,qh)
    p=Path(__file__).parent
    for name,vals in [('coeffs.hex',qh),('input.hex',x),('expected.hex',y)]:
        (p/name).write_text(''.join(f'{v & 65535:04x}\n' for v in vals))
    print(f'PASS: DC gain, symmetry, passband, stopband, zero, signed arithmetic and saturation. Generated {len(x)} RTL vectors.')
if __name__=='__main__':main()
