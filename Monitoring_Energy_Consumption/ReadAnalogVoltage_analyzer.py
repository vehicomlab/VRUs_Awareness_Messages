import serial
import numpy as np
import os
import time
from datetime import datetime, timezone


Directory = os.getcwd()
Folder = "\\results"
FileNumber = 10
MeasurementName = ["\\no_load_test", "\\acquisition_1Hz_test","\\acquisition_10Hz_test"]

mon_time_load_free = []
samp_freq_load_free = []
en_cons_load_free = []

mon_time_1_Hz = []
samp_freq_1_Hz = []
en_cons_1_Hz = []

mon_time_10_Hz = []
samp_freq_10_Hz = []
en_cons_10_Hz = []

for index in range (1,FileNumber+1,1):
    for index_file in range (0,3,1):
        timestamps_vector = []
        RB_voltage = []
        RB_current = []
        power_consumption = 0
        energy_consumption = 0

        FilePath_short =  str(Directory) + str(Folder) + str(MeasurementName[index_file]) + "_" + str(index) + ".txt"
        File_txt = open(FilePath_short,'r')
        for line in File_txt.readlines()[1:]:
            currentline = line.split(",")
            timestamps_vector.append(float(str.strip(currentline[0])))
            RB_voltage.append(float(str.strip(currentline[1]))-float(str.strip(currentline[2])))
            RB_current.append(float(str.strip(currentline[2]))/0.24)
        File_txt.close()

        min_timestamp = min(timestamps_vector)
        for i in range (0,len(timestamps_vector),1):
            if timestamps_vector[i] - min_timestamp > 30:
                break
        del timestamps_vector[:i]
        del RB_voltage[:i]
        del RB_current[:i]

        min_timestamp = min(timestamps_vector)
        for i in range (0,len(timestamps_vector),1):
            if timestamps_vector[i] - min_timestamp > 900:
                break
        del timestamps_vector[:len(timestamps_vector)-i]
        del RB_voltage[:len(timestamps_vector)-i]
        del RB_current[:len(timestamps_vector)-i]

        l = min(len(timestamps_vector),len(RB_voltage),len(RB_current))

        for i in range (0,l,1):
            power_consumption = power_consumption + (RB_voltage[i]*RB_current[i])

        sampling_interval = (max(timestamps_vector)-min(timestamps_vector))/len(timestamps_vector)

        for i in range (0,l,1):
            energy_consumption = energy_consumption + (RB_voltage[i]*RB_current[i])*sampling_interval

        if index_file == 0:
            mon_time_load_free.append(max(timestamps_vector)-min(timestamps_vector))
            samp_freq_load_free.append(1/sampling_interval)
            en_cons_load_free.append(energy_consumption)
        if index_file == 1:
            mon_time_1_Hz.append(max(timestamps_vector)-min(timestamps_vector))
            samp_freq_1_Hz.append(1/sampling_interval)
            en_cons_1_Hz.append(energy_consumption)
        if index_file == 2:
            mon_time_10_Hz.append(max(timestamps_vector)-min(timestamps_vector))
            samp_freq_10_Hz.append(1/sampling_interval)
            en_cons_10_Hz.append(energy_consumption)

print("\nNumber of measurements done: " + str(FileNumber))
print("Test type name: no_load, acquisition_1Hz, acquisition_10Hz")
print("Monitoring time: " + str(sum(mon_time_load_free)/FileNumber) + " s, " + str(sum(mon_time_1_Hz)/FileNumber) + " s, " + str(sum(mon_time_10_Hz)/FileNumber) + " s")
print("Sampling frequency: " + str(sum(samp_freq_load_free)/FileNumber) + " Hz, " + str(sum(samp_freq_1_Hz)/FileNumber) + " Hz, " + str(sum(samp_freq_10_Hz)/FileNumber) + " Hz")
print("Total energy consumed: " + str(sum(en_cons_load_free)/FileNumber) + " J, " + str(sum(en_cons_1_Hz)/FileNumber) + " J, " + str(sum(en_cons_10_Hz)/FileNumber) + " J")

print("\nMean energy consumed load free: " + str(sum(en_cons_load_free)/FileNumber) + " J")
print("Mean energy consumed acquisition 1Hz: " + str(sum(en_cons_1_Hz)/FileNumber) + " J")
print("Mean energy consumed acquisition 10Hz: " + str(sum(en_cons_10_Hz)/FileNumber) + " J")

delta_en = (sum(en_cons_10_Hz)/FileNumber-sum(en_cons_1_Hz)/FileNumber) / (sum(en_cons_10_Hz)/FileNumber-sum(en_cons_load_free)/FileNumber) * 100

print("\nEnergy saved when reducing sampling frequency at 1 Hz: " + str(delta_en) + " %\n")