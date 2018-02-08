import numpy as np
import pandas as pd
import os
import glob
import datetime
from matplotlib import pyplot as plt

current_Path = "C:/Users/masoudg/Dropbox/EyeTracker/Plots_Based_On_Farzad_Data_2Jan2018/"
save_PDF_Path = current_Path
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

position_Tick = list(np.round(np.unique(this_Subject_Data[this_Subject_Data.columns[4]])).astype(int))
position_Tickn = [-position_Tickn for position_Tickn in position_Tick[:0:-1]]
position_Tick = sum( [position_Tickn , [position_Tick[0]], position_Tick[1::1]], [])
print(position_Tick)

# Visualization
print('*** Start the Visualization ***')

MARKER_SIZE = 5
LINE_WIDTH = 1
AXIS_LINE_WIDTH = 1
LINE_COLOR = plt.get_cmap('gist_rainbow')
TICK_LENGTH = 5
X_AXIS_LIM = [-4.2, 4.2]
Y_AXIS_LIM = [0.48, 1]
Y_AXIS_1ST_TICK = 0.5
Y_AXIS_LABEL_NUM_STEPS = 3
SAVE_PDF = True  # do you want to save PDF file of the paper
WANT_LEGEND = True  # do you want legend
SAME_MARKER_FACECOLOR = False  # TRUE, same as line color, FALSE, white
sEM_AS_ERRORBAR = True  # FALSE std, TRUE sem
FIGURE_DIMENSION = [[5, 8],[3.5, 8]]  # dimension of the printed figure
PDF_RESOLUTION = 300

params = {'legend.fontsize': 8,
         'axes.labelsize': 10,
         'axes.titlesize':8,
         'xtick.labelsize':10,
         'ytick.labelsize':10,
         'font.family':'arial'}
plt.rcParams.update(params)



fig, axs = plt.subplots(nrows=3, ncols=1)
axs = axs.ravel()
index_Subplot = 0

for iCategory_Level in Results.keys():
    all_Legends = ()
    NUM_COLORS = len(Results[iCategory_Level].keys())
    # axs[index_Subplot].set_color_cycle([LINE_COLOR(1. * index_Color / NUM_COLORS) for index_Color in range(NUM_COLORS)])
    LINE_COLOR_LIST = [LINE_COLOR(1. * index_Color / NUM_COLORS) for index_Color in range(NUM_COLORS)]
    index_Color = 0
    for iExperiment_InCategory in Results[iCategory_Level].keys():

        mean_Accuracy_Matrix = np.mean(Results[iCategory_Level][iExperiment_InCategory]['PerformanceAll'], axis=0)
        if sEM_AS_ERRORBAR == True:
            errorbar_Matrix = np.std(Results[iCategory_Level][iExperiment_InCategory]['PerformanceAll'], axis=0)\
                              /np.sqrt(len(Results[iCategory_Level][iExperiment_InCategory]['PerformanceAll']))
        elif sEM_AS_ERRORBAR == False:
            errorbar_Matrix = np.std(Results[iCategory_Level][iExperiment_InCategory]['PerformanceAll'], axis=0)

        if SAME_MARKER_FACECOLOR == True:
            axs[index_Subplot].errorbar(x=np.arange(-4, 5), y=mean_Accuracy_Matrix, yerr=errorbar_Matrix, color=LINE_COLOR_LIST[index_Color], marker='o',
                                        markerfacecolor=LINE_COLOR_LIST[index_Color], markeredgecolor=LINE_COLOR_LIST[index_Color], linewidth=LINE_WIDTH,
                                        markersize=MARKER_SIZE, label=iExperiment_InCategory)
        elif SAME_MARKER_FACECOLOR == False:
            axs[index_Subplot].errorbar(x=np.arange(-4, 5), y=mean_Accuracy_Matrix, yerr=errorbar_Matrix, color=LINE_COLOR_LIST[index_Color], marker='o',
                                        markerfacecolor='white', markeredgecolor=LINE_COLOR_LIST[index_Color], linewidth=LINE_WIDTH,
                                        markersize=MARKER_SIZE, label=iExperiment_InCategory)


        axs[index_Subplot].set_xlim(X_AXIS_LIM)
        axs[index_Subplot].set_ylim(Y_AXIS_LIM)
        axs[index_Subplot].tick_params(length=TICK_LENGTH)
        axs[index_Subplot].set_yticks(np.linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM[1], num=Y_AXIS_LABEL_NUM_STEPS,
                                                       endpoint=True))
        axs[index_Subplot].set_yticklabels(np.linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM[1], num=Y_AXIS_LABEL_NUM_STEPS,
                                                       endpoint=True))
        axs[index_Subplot].set_xticks(np.linspace(-4,4,9,endpoint=True))
        axs[index_Subplot].set_xticklabels(position_Tick)

        for my_Axis in ['top', 'bottom', 'left', 'right']:
            if my_Axis == 'bottom' or my_Axis == 'left':
                axs[index_Subplot].spines[my_Axis].set_linewidth(AXIS_LINE_WIDTH)
            else:
                axs[index_Subplot].spines[my_Axis].set_linewidth(0)
        if index_Subplot == 2:
            axs[index_Subplot].set_xlabel('Eccentricity ($^o$)')
            axs[index_Subplot].set_ylabel('Accuracy')

        all_Legends = all_Legends + (iExperiment_InCategory.replace('_', ' vs. '), )
        index_Color += 1
    if WANT_LEGEND == True:
        # Shrink current axis by 20%
        plot_Box = axs[index_Subplot].get_position()
        axs[index_Subplot].set_position([plot_Box.x0, plot_Box.y0, plot_Box.width * 0.65, plot_Box.height])
        # Put a legend to the right of the current axis
        axs[index_Subplot].legend(all_Legends, loc='center left', bbox_to_anchor=(1, 0.5), frameon=False)
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION[0][:]
    elif WANT_LEGEND == False:
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION[1][:]

    index_Subplot += 1

if SAVE_PDF == True:
    if WANT_LEGEND == True:
        fig.set_size_inches(SELECTED_FIGURE_DIMENSION[0], SELECTED_FIGURE_DIMENSION[1])
        fig.savefig(save_PDF_Path + 'Accuracy_FullScreen_All_Category_Levels_All_Tasks_Legend_' + str(datetime.datetime.today().date()) + '.pdf',
                    dpi=PDF_RESOLUTION, bbox_inches="tight")
    elif WANT_LEGEND==False:
        fig.set_size_inches(SELECTED_FIGURE_DIMENSION[0], SELECTED_FIGURE_DIMENSION[1])
        fig.savefig(save_PDF_Path + 'Accuracy_FullScreen_All_Category_Levels_All_Tasks_' + str(datetime.datetime.today().date()) + '.pdf',
                    dpi=PDF_RESOLUTION, bbox_inches="tight")

plt.show()