"""Streams the laptop webcam to the FPGA over a USB-to-UART adapter.

Protocol (matches uart_reciever.v):
    Pixels are 9 bits (RRRGGGBBB), in raster order, packed back to back MSB first,
    so 8 pixels take 9 bytes. No markers: the FPGA counts pixels, so reset the FPGA
    before starting this script.

Setup: pip install pyserial opencv-python numpy
"""

import cv2
import numpy as np
import serial

PORT, BAUD = "COM5", 2_000_000  # must match BAUD_RATE in uart_reciever.v
W, H = 640, 480                 # must match RESOLUTION

ser = serial.Serial(PORT, BAUD)
cam = cv2.VideoCapture(0)       # laptop webcam

while True:
    ok, frame = cam.read()
    if not ok:
        break
    frame = cv2.resize(frame, (W, H), interpolation=cv2.INTER_AREA)
    b, g, r = (frame >> 5).astype(np.uint16).transpose(2, 0, 1)  # OpenCV is BGR; keep 3 bits each
    px = ((r << 6) | (g << 3) | b).ravel()                        # RRRGGGBBB, raster order
    bits = (px[:, None] >> np.arange(8, -1, -1)) & 1              # 9 bits per pixel, MSB first
    ser.write(np.packbits(bits.astype(np.uint8)).tobytes())       # back to back into bytes
