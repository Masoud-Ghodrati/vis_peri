import numpy as np
import pandas as pd
import os
import glob
from matplotlib import pyplot as plt

current_Path = "C:/Users/masoudg/Dropbox/EyeTracker/Plots_Based_On_Farzad_Data_2Jan2018/"
data_Path = current_Path + "Dataset/"
dir_Category_Levels = os.listdir(data_Path)
Results = {}
for iCategory_Level in dir_Category_Levels:
    print(f'{iCategory_Level:25s}: ')

    current_Category = os.listdir(data_Path + iCategory_Level + "/")
    This_category_Results = {}

    for iExperiment_InCategory in current_Category:

        print(f'{iExperiment_InCategory:25s}: ', end="")
        this_this_Experiment = os.listdir(data_Path + iCategory_Level + "/" + iExperiment_InCategory + "/")

        This_Experiment_Result = {}
        this_subject_Accuracy = np.zeros((len(this_this_Experiment), 9))
        this_subject_Accuracy_Class1 = np.zeros((len(this_this_Experiment), 9))
        this_subject_Accuracy_Class2 = np.zeros((len(this_this_Experiment), 9))
        subject_Index = 0
        for iSubject in this_this_Experiment:

            print(iSubject + ", ", end="")
            this_Subject = os.listdir(data_Path + iCategory_Level + "/" + iExperiment_InCategory + "/" + iSubject + "/" )
            this_Subject_DataFile = glob.glob(data_Path + iCategory_Level + "/" + iExperiment_InCategory + "/" + iSubject + "/" + "*.xlsx")
            this_Subject_Data = pd.read_excel(this_Subject_DataFile[0])

            stimulus_Position_Array = np.array(this_Subject_Data[this_Subject_Data.columns[3]])
            subject_Response_Array = np.array(this_Subject_Data[this_Subject_Data.columns[10]])
            task_Label_Array = np.array(this_Subject_Data[this_Subject_Data.columns[2]])
            unique_Task = this_Subject_Data[this_Subject_Data.columns[2]].unique()
            if len(unique_Task[0]) >= 2 or len(unique_Task[1]) >= 2:
                if not( len(unique_Task[0]) == 1 and len(unique_Task[1]) == 2):
                    unique_Task = [unique_Task[1], unique_Task[0]]

            idx_Class1 = task_Label_Array == unique_Task[0]
            idx_Class2 = task_Label_Array == unique_Task[1]

            for iPosition in np.unique(stimulus_Position_Array):  # loop over  positions

                this_subject_Accuracy[subject_Index, iPosition-1] = np.mean(subject_Response_Array[stimulus_Position_Array == iPosition])  # mean accuarcy of this subject on this position
                this_subject_Accuracy_Class1[subject_Index, iPosition-1] = np.mean( subject_Response_Array[[stimulus_Position_Array == iPosition] and idx_Class1])  # mean accuracy in class 1
                this_subject_Accuracy_Class2[subject_Index, iPosition-1] = np.mean( subject_Response_Array[[stimulus_Position_Array == iPosition] and idx_Class2])  # mean accuracy in class 2

            subject_Index += 1

        This_Experiment_Result['PerformanceAll'] = np.array(this_subject_Accuracy)
        This_Experiment_Result['PerformanceClass_1'] = np.array(this_subject_Accuracy_Class1)
        This_Experiment_Result['PerformanceClass_2'] = np.array(this_subject_Accuracy_Class2)

        This_category_Results[iExperiment_InCategory] = This_Experiment_Result
        # print(This_Experiment_Result)

        print("*** Done ***", end="")
        print("")

    Results[iCategory_Level] = This_category_Results

print('*** Data loading and analysis done ! ***')

unique_Position = np.unique(stimulus_Position_Array)

# Visualization
print('*** Start the Visualization ***')

MARKER_SIZE = 5
LINE_WIDTH = 1
AXIS_LINE_WIDTH = 1
LINE_COLOR = colormap(brewermap([],'*YlGnBu'))
TICK_LENGTH = 3;
X_AXIS_LIM = [-4.2 4]
Y_AXIS_LIM = [0.48 1]
Y_AXIS_1ST_TICK = 0.5
Y_AXIS_LABEL_NUM_STEPS = 3
SAVE_PDF = True # do you want to save PDF file of the paper
WANT_LEGEND = False #  % do you want legend
SAME_MARKER_FACECOLOR = False # TRUE, same as line color, FALSE, white
sEM_AS_ERRORBAR = True # FALSE std, TRUE sem
FONT_SIZE = 10
FIGURE_DIMENSION = [[0, 0, 600, 800][0, 0, 300, 800]]  # dimesion of the printed figure
PRINTED_FIGURE_SIZE = [20, 20]# the size of printed PDF file, cm
PDF_RESOLUTION = '-r300'

fig, axs = plt.subplots(nrows=3, ncols=1)
axs = axs.ravel()
index_Subplot = 0
for iCategory_Level in Results.keys():

    for iExperiment_InCategory in Results[iCategory_Level].keys():

        mean_Accuracy_Matrix = np.mean(Results[iCategory_Level][iExperiment_InCategory]['PerformanceAll'], axis=0)
        sTD_Matrix = np.std(Results[iCategory_Level][iExperiment_InCategory]['PerformanceAll'], axis=0)

        axs[index_Subplot].errorbar(x = np.arange(-4, 5), y = mean_Accuracy_Matrix, yerr=sTD_Matrix, marker='o',
                                    markerfacecolor='red', markeredgecolor='black', linewidth=0.5)

        axs[index_Subplot].set_xlabel('dd')
        axs[index_Subplot].set_ylabel('dd')

    index_Subplot += 1

plt.show()