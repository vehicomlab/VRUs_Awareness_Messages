import serial
import numpy as np
import os
import time
from time import perf_counter


Directory = os.getcwd()
txtFolder = "\\24_07_2024"
MeasurementName = "\\acquisition_1Hz_test_2.txt"

timestamp_value = 0.0
timestamp = []
timestamps_vector = []
samples_vector = []
RB_voltage = []
RB_current = []

ser = serial.Serial(port='COM3', baudrate=115200)
start_time = perf_counter()
print("\ncode is running ...")
while (perf_counter() - start_time) <= 960: #660
    count = 0
    while count < 2:
        while True:
            try:
                value = ser.readline()
                valueInString = str(value,'ISO-8859-1')
                voltage = float(valueInString)
                #print(voltage)
                samples_vector.append(voltage)
                count +=1
                break
            except ValueError:
                value = ser.readline()
                break
    timestamps_vector.append(perf_counter())

samples_vector = np.array(samples_vector) * 6.144 / 32768.0
RB_voltage = samples_vector[samples_vector > 4.0]
RB_current = samples_vector[samples_vector < 4.0]

print(max(timestamps_vector)-min(timestamps_vector))

print(len(timestamps_vector))
print(len(RB_voltage))
print(len(RB_current))

In3Columns = [timestamps_vector,RB_voltage,RB_current]
FilePath = str(Directory) + str(txtFolder) + str(MeasurementName)
File_txt = open(FilePath,'w')
File_txt.write('timestampReal,voltage,current\n')
for i in zip(*In3Columns):
    File_txt.write("{0},{1},{2}\n".format(*i))
File_txt.close()