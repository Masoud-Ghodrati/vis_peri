import numpy as np
import pandas as pd
import os
import glob
import datetime
from matplotlib import pyplot as plt

current_Path = "C:/Users/masoudg/Dropbox/EyeTracker/Plots_Based_On_Farzad_Data_2Jan2018/"
save_PDF_Path = current_Path + 'PyFigures/'
data_Path = current_Path + "Dataset/"
dir_Category_Levels = os.listdir(data_Path)
Results = {}  # an empty dictionary to store the results of analysis. probably not the best way to store the data

for iCategory_Level in dir_Category_Levels:  # loop over different category levels

    print(f'{iCategory_Level:25s}: ')

    current_Category = os.listdir(data_Path + iCategory_Level + "/")  # get what's inside this directory
    This_category_Results = {}  # an empty dictionary to store the results of analysis for this category

    for iExperiment_InCategory in current_Category:  # loop over the experiments in this particular category
                                                     # (e.g, animal/non-animal)

        print(f'{iExperiment_InCategory:25s}: ', end="")
        this_this_Experiment = os.listdir(data_Path + iCategory_Level + "/" + iExperiment_InCategory + "/") # get what's inside this directory

        This_Experiment_Result = {} # an empty dictionary to store the results of analysis for this experiment
                                    # (e.g, animal/non-animal)

        # making some empty arrays storing subject's performance
        this_subject_Accuracy = np.zeros((len(this_this_Experiment), 9))
        this_subject_Accuracy_Class1 = np.zeros((len(this_this_Experiment), 9))
        this_subject_Accuracy_Class2 = np.zeros((len(this_this_Experiment), 9))
        subject_Index = 0

        for iSubject in this_this_Experiment:  # loop over subjects in this experiment

            print(iSubject + ", ", end="")

            this_Subject = os.listdir(data_Path + iCategory_Level + "/" + iExperiment_InCategory + "/" + iSubject + "/" )  # get what's inside this directory
            this_Subject_DataFile = glob.glob(data_Path + iCategory_Level + "/" + iExperiment_InCategory + "/" +
                                              iSubject + "/" + "*.xlsx")  # find all .xlsx files, there're might be
                                                                          # multiple files but we only need one
            this_Subject_Data = pd.read_excel(this_Subject_DataFile[0])  # get the first xlsx file

            # extract the different arrays from excel files
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

                #  calculate accuracy (% correct)
                this_subject_Accuracy[subject_Index, iPosition-1] = np.mean(subject_Response_Array[stimulus_Position_Array == iPosition])  # mean accuarcy of this subject on this position
                this_subject_Accuracy_Class1[subject_Index, iPosition-1] = np.mean( subject_Response_Array[[stimulus_Position_Array == iPosition] and idx_Class1])  # mean accuracy in class 1
                this_subject_Accuracy_Class2[subject_Index, iPosition-1] = np.mean( subject_Response_Array[[stimulus_Position_Array == iPosition] and idx_Class2])  # mean accuracy in class 2

            subject_Index += 1

        This_Experiment_Result['PerformanceAll'] = np.array(this_subject_Accuracy)
        This_Experiment_Result['PerformanceClass_1'] = np.array(this_subject_Accuracy_Class1)
        This_Experiment_Result['PerformanceClass_2'] = np.array(this_subject_Accuracy_Class2)

        This_category_Results[iExperiment_InCategory] = This_Experiment_Result

        print("*** Done ***", end="")
        print("")

    Results[iCategory_Level] = This_category_Results

print('*** Data loading and analysis done ! ***')

# just to make some position ticks
position_Tick = list(np.round(np.unique(this_Subject_Data[this_Subject_Data.columns[4]])).astype(int))
position_Tickn = [-position_Tickn for position_Tickn in position_Tick[:0:-1]]
position_Tick = sum( [position_Tickn , [position_Tick[0]], position_Tick[1::1]], [])

# ****** Visualization ******
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

# set global font properties, this is going to apply to all plots, cool isn't it?
params = {'legend.fontsize': 8,
         'axes.labelsize': 10,
         'axes.titlesize':8,
         'xtick.labelsize':10,
         'ytick.labelsize':10,
         'font.family':'arial'}
plt.rcParams.update(params)

# plotting accuracy for all categorical levels and all experiments individually
fig, axs = plt.subplots(nrows=3, ncols=1)  # make a subplot structure
axs = axs.ravel()
index_Subplot = 0

for iCategory_Level in Results.keys():

    all_Legends = ()  # just to store the legend
    #  we are making some color list to be used in plots
    NUM_COLORS = len(Results[iCategory_Level].keys())
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

        #  setting some axis properties
        axs[index_Subplot].set_xlim(X_AXIS_LIM)
        axs[index_Subplot].set_ylim(Y_AXIS_LIM)
        axs[index_Subplot].tick_params(length=TICK_LENGTH)
        axs[index_Subplot].set_yticks(np.linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM[1], num=Y_AXIS_LABEL_NUM_STEPS,
                                                       endpoint=True))
        axs[index_Subplot].set_yticklabels(np.linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM[1], num=Y_AXIS_LABEL_NUM_STEPS,
                                                       endpoint=True))
        axs[index_Subplot].set_xticks(np.linspace(-4,4,9,endpoint=True))
        axs[index_Subplot].set_xticklabels(position_Tick)

        # setting the axes line width, here we remove the right and top axes by setting the line width to zero
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

# saving the PDF files with a proper name
if SAVE_PDF == True:
    if WANT_LEGEND == True:
        fig.set_size_inches(SELECTED_FIGURE_DIMENSION[0], SELECTED_FIGURE_DIMENSION[1])
        fig.savefig(save_PDF_Path + 'Accuracy_FullScreen_All_Category_Levels_All_Tasks_Legend_' + str(datetime.datetime.today().date()) + '.pdf',
                    dpi=PDF_RESOLUTION, bbox_inches="tight")
    elif WANT_LEGEND==False:
        fig.set_size_inches(SELECTED_FIGURE_DIMENSION[0], SELECTED_FIGURE_DIMENSION[1])
        fig.savefig(save_PDF_Path + 'Accuracy_FullScreen_All_Category_Levels_All_Tasks_' + str(datetime.datetime.today().date()) + '.pdf',
                    dpi=PDF_RESOLUTION, bbox_inches="tight")


# plotting accuracy for the average of categorical levels
fig, axs = plt.subplots(nrows=1, ncols=1)  # make a subplot structure
FIGURE_DIMENSION = [[5, 3],[3.5, 3]]  # dimension of the printed figure
index_Subplot = 0

all_Legends = ()  # just to store the legend
#  we are making some color list to be used in plots
NUM_COLORS = len(Results.keys())
LINE_COLOR_LIST = [LINE_COLOR(1. * index_Color / NUM_COLORS) for index_Color in range(NUM_COLORS)]
index_Color = 0

for iCategory_Level in Results.keys():

    Accuray_Matrix = []
    for iExperiment_InCategory in Results[iCategory_Level].keys():

        Accuray_Matrix.append(Results[iCategory_Level][iExperiment_InCategory]['PerformanceAll'])

    Accuray_Matrix = np.reshape(Accuray_Matrix, (-1, len(position_Tick)))
    mean_Accuracy_Matrix = np.mean(Accuray_Matrix, axis=0)
    if sEM_AS_ERRORBAR == True:
        errorbar_Matrix = np.std(Accuray_Matrix, axis=0)/np.sqrt(len(Accuray_Matrix))
    elif sEM_AS_ERRORBAR == False:
        errorbar_Matrix = np.std(Accuray_Matrix, axis=0)

    if SAME_MARKER_FACECOLOR == True:
        axs.errorbar(x=np.arange(-4, 5), y=mean_Accuracy_Matrix, yerr=errorbar_Matrix, color=LINE_COLOR_LIST[index_Color], marker='o',
                                    markerfacecolor=LINE_COLOR_LIST[index_Color], markeredgecolor=LINE_COLOR_LIST[index_Color], linewidth=LINE_WIDTH,
                                    markersize=MARKER_SIZE, label=iExperiment_InCategory)
    elif SAME_MARKER_FACECOLOR == False:
        axs.errorbar(x=np.arange(-4, 5), y=mean_Accuracy_Matrix, yerr=errorbar_Matrix, color=LINE_COLOR_LIST[index_Color], marker='o',
                                    markerfacecolor='white', markeredgecolor=LINE_COLOR_LIST[index_Color], linewidth=LINE_WIDTH,
                                    markersize=MARKER_SIZE, label=iExperiment_InCategory)
    all_Legends = all_Legends + (iCategory_Level,)
    index_Color += 1

#  setting some axis properties
axs.set_xlim(X_AXIS_LIM)
axs.set_ylim(Y_AXIS_LIM)
axs.tick_params(length=TICK_LENGTH)
axs.set_yticks(np.linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM[1], num=Y_AXIS_LABEL_NUM_STEPS,
                                               endpoint=True))
axs.set_yticklabels(np.linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM[1], num=Y_AXIS_LABEL_NUM_STEPS,
                                               endpoint=True))
axs.set_xticks(np.linspace(-4,4,9,endpoint=True))
axs.set_xticklabels(position_Tick)

# setting the axes line width, here we remove the right and top axes by setting the line width to zero
for my_Axis in ['top', 'bottom', 'left', 'right']:
    if my_Axis == 'bottom' or my_Axis == 'left':
        axs.spines[my_Axis].set_linewidth(AXIS_LINE_WIDTH)
    else:
        axs.spines[my_Axis].set_linewidth(0)

axs.set_xlabel('Eccentricity ($^o$)')
axs.set_ylabel('Accuracy')



if WANT_LEGEND == True:
    # Shrink current axis by 20%
    plot_Box = axs.get_position()
    axs.set_position([plot_Box.x0, plot_Box.y0, plot_Box.width * 0.65, plot_Box.height])
    # Put a legend to the right of the current axis
    axs.legend(all_Legends, loc='center left', bbox_to_anchor=(1, 0.5), frameon=False)
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION[0][:]
elif WANT_LEGEND == False:
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION[1][:]


# saving the PDF files with a proper name
if SAVE_PDF == True:
    if WANT_LEGEND == True:
        fig.set_size_inches(SELECTED_FIGURE_DIMENSION[0], SELECTED_FIGURE_DIMENSION[1])
        fig.savefig(save_PDF_Path + 'Accuracy_FullScreen_Aveareg_of_All_Category_Levels_All_Tasks_Legend_' + str(datetime.datetime.today().date()) + '.pdf',
                    dpi=PDF_RESOLUTION, bbox_inches="tight")
    elif WANT_LEGEND==False:
        fig.set_size_inches(SELECTED_FIGURE_DIMENSION[0], SELECTED_FIGURE_DIMENSION[1])
        fig.savefig(save_PDF_Path + 'Accuracy_FullScreen_Aveareg_of_All_Category_Levels_All_Tasks_' + str(datetime.datetime.today().date()) + '.pdf',
                    dpi=PDF_RESOLUTION, bbox_inches="tight")



# plotting accuracy for all categorical levels and all experiments individually, for half a screen
X_AXIS_LIM = [-.2, 4.2]
fig, axs = plt.subplots(nrows=3, ncols=1)  # make a subplot structure
axs = axs.ravel()
index_Subplot = 0
FIGURE_DIMENSION = [[5, 8],[3.5, 8]]  # dimension of the printed figure

for iCategory_Level in Results.keys():

    all_Legends = ()  # just to store the legend
    #  we are making some color list to be used in plots
    NUM_COLORS = len(Results[iCategory_Level].keys())
    LINE_COLOR_LIST = [LINE_COLOR(1. * index_Color / NUM_COLORS) for index_Color in range(NUM_COLORS)]
    index_Color = 0

    for iExperiment_InCategory in Results[iCategory_Level].keys():

        Accuray_Matrix = Results[iCategory_Level][iExperiment_InCategory]['PerformanceAll']

        mean_Accuracy_Matrix = [np.mean(Accuray_Matrix[:, 4]),      np.mean(Accuray_Matrix[:,[3, 5]]),
                                np.mean(Accuray_Matrix[:, [2, 6]]), np.mean(Accuray_Matrix[:, [1, 7]]),
                                np.mean(Accuray_Matrix[:, [0, 8]])]
        if sEM_AS_ERRORBAR == True:
            errorbar_Matrix = [np.std(Accuray_Matrix[:, 4]),       np.std(Accuray_Matrix[:,[3, 5]]),
                                np.std(Accuray_Matrix[:, [2, 6]]), np.std(Accuray_Matrix[:, [1, 7]]),
                                np.std(Accuray_Matrix[:, [0, 8]])]/np.sqrt(2*len(Accuray_Matrix))
        elif sEM_AS_ERRORBAR == False:
            errorbar_Matrix = [np.std(Accuray_Matrix[:, 4]),       np.std(Accuray_Matrix[:,[3, 5]]),
                                np.std(Accuray_Matrix[:, [2, 6]]), np.std(Accuray_Matrix[:, [1, 7]]),
                                np.std(Accuray_Matrix[:, [0, 8]])]

        if SAME_MARKER_FACECOLOR == True:
            axs[index_Subplot].errorbar(x=np.arange(0, 5), y=mean_Accuracy_Matrix, yerr=errorbar_Matrix, color=LINE_COLOR_LIST[index_Color], marker='o',
                                        markerfacecolor=LINE_COLOR_LIST[index_Color], markeredgecolor=LINE_COLOR_LIST[index_Color], linewidth=LINE_WIDTH,
                                        markersize=MARKER_SIZE, label=iExperiment_InCategory)
        elif SAME_MARKER_FACECOLOR == False:
            axs[index_Subplot].errorbar(x=np.arange(0, 5), y=mean_Accuracy_Matrix, yerr=errorbar_Matrix, color=LINE_COLOR_LIST[index_Color], marker='o',
                                        markerfacecolor='white', markeredgecolor=LINE_COLOR_LIST[index_Color], linewidth=LINE_WIDTH,
                                        markersize=MARKER_SIZE, label=iExperiment_InCategory)

        #  setting some axis properties
        axs[index_Subplot].set_xlim(X_AXIS_LIM)
        axs[index_Subplot].set_ylim(Y_AXIS_LIM)
        axs[index_Subplot].tick_params(length=TICK_LENGTH)
        axs[index_Subplot].set_yticks(np.linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM[1], num=Y_AXIS_LABEL_NUM_STEPS,
                                                       endpoint=True))
        axs[index_Subplot].set_yticklabels(np.linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM[1], num=Y_AXIS_LABEL_NUM_STEPS,
                                                       endpoint=True))
        axs[index_Subplot].set_xticks(np.linspace(0, 4, 5,endpoint=True))
        axs[index_Subplot].set_xticklabels(position_Tick[4::])

        # setting the axes line width, here we remove the right and top axes by setting the line width to zero
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

# saving the PDF files with a proper name
if SAVE_PDF == True:
    if WANT_LEGEND == True:
        fig.set_size_inches(SELECTED_FIGURE_DIMENSION[0], SELECTED_FIGURE_DIMENSION[1])
        fig.savefig(save_PDF_Path + 'Accuracy_HalfScreen_All_Category_Levels_All_Tasks_Legend_' + str(datetime.datetime.today().date()) + '.pdf',
                    dpi=PDF_RESOLUTION, bbox_inches="tight")
    elif WANT_LEGEND==False:
        fig.set_size_inches(SELECTED_FIGURE_DIMENSION[0], SELECTED_FIGURE_DIMENSION[1])
        fig.savefig(save_PDF_Path + 'Accuracy_HalfScreen_All_Category_Levels_All_Tasks_' + str(datetime.datetime.today().date()) + '.pdf',
                    dpi=PDF_RESOLUTION, bbox_inches="tight")


# plotting averaged accuracy for all categorical levels and all experiments individually, for half a screen
X_AXIS_LIM = [-.2, 4.2]
fig, axs = plt.subplots(nrows=1, ncols=1)  # make a subplot structure
FIGURE_DIMENSION = [[5, 3],[3.5, 3]]  # dimension of the printed figure

all_Legends = ()  # just to store the legend
#  we are making some color list to be used in plots
NUM_COLORS = len(Results.keys())
LINE_COLOR_LIST = [LINE_COLOR(1. * index_Color / NUM_COLORS) for index_Color in range(NUM_COLORS)]
index_Color = 0

for iCategory_Level in Results.keys():

    Accuray_Matrix = []
    for iExperiment_InCategory in Results[iCategory_Level].keys():
        Accuray_Matrix.append(Results[iCategory_Level][iExperiment_InCategory]['PerformanceAll'])

    Accuray_Matrix = np.reshape(Accuray_Matrix, (-1, len(position_Tick)))

    mean_Accuracy_Matrix = [np.mean(Accuray_Matrix[:, 4]),      np.mean(Accuray_Matrix[:,[3, 5]]),
                            np.mean(Accuray_Matrix[:, [2, 6]]), np.mean(Accuray_Matrix[:, [1, 7]]),
                            np.mean(Accuray_Matrix[:, [0, 8]])]
    if sEM_AS_ERRORBAR == True:
        errorbar_Matrix = [np.std(Accuray_Matrix[:, 4]),       np.std(Accuray_Matrix[:,[3, 5]]),
                            np.std(Accuray_Matrix[:, [2, 6]]), np.std(Accuray_Matrix[:, [1, 7]]),
                            np.std(Accuray_Matrix[:, [0, 8]])]/np.sqrt(2*len(Accuray_Matrix))
    elif sEM_AS_ERRORBAR == False:
        errorbar_Matrix = [np.std(Accuray_Matrix[:, 4]),       np.std(Accuray_Matrix[:,[3, 5]]),
                            np.std(Accuray_Matrix[:, [2, 6]]), np.std(Accuray_Matrix[:, [1, 7]]),
                            np.std(Accuray_Matrix[:, [0, 8]])]

    if SAME_MARKER_FACECOLOR == True:
        axs.errorbar(x=np.arange(0, 5), y=mean_Accuracy_Matrix, yerr=errorbar_Matrix, color=LINE_COLOR_LIST[index_Color], marker='o',
                                    markerfacecolor=LINE_COLOR_LIST[index_Color], markeredgecolor=LINE_COLOR_LIST[index_Color], linewidth=LINE_WIDTH,
                                    markersize=MARKER_SIZE, label=iExperiment_InCategory)
    elif SAME_MARKER_FACECOLOR == False:
        axs.errorbar(x=np.arange(0, 5), y=mean_Accuracy_Matrix, yerr=errorbar_Matrix, color=LINE_COLOR_LIST[index_Color], marker='o',
                                    markerfacecolor='white', markeredgecolor=LINE_COLOR_LIST[index_Color], linewidth=LINE_WIDTH,
                                    markersize=MARKER_SIZE, label=iExperiment_InCategory)
    all_Legends = all_Legends + (iCategory_Level,)
    index_Color += 1

#  setting some axis properties
axs.set_xlim(X_AXIS_LIM)
axs.set_ylim(Y_AXIS_LIM)
axs.tick_params(length=TICK_LENGTH)
axs.set_yticks(np.linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM[1], num=Y_AXIS_LABEL_NUM_STEPS, endpoint=True))
axs.set_yticklabels(np.linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM[1], num=Y_AXIS_LABEL_NUM_STEPS, endpoint=True))
axs.set_xticks(np.linspace(0, 4, 5,endpoint=True))
axs.set_xticklabels(position_Tick[4::])

# setting the axes line width, here we remove the right and top axes by setting the line width to zero
for my_Axis in ['top', 'bottom', 'left', 'right']:
    if my_Axis == 'bottom' or my_Axis == 'left':
        axs.spines[my_Axis].set_linewidth(AXIS_LINE_WIDTH)
    else:
        axs.spines[my_Axis].set_linewidth(0)

axs.set_xlabel('Eccentricity ($^o$)')
axs.set_ylabel('Accuracy')



if WANT_LEGEND == True:
    # Shrink current axis by 20%
    plot_Box = axs.get_position()
    axs.set_position([plot_Box.x0, plot_Box.y0, plot_Box.width * 0.65, plot_Box.height])
    # Put a legend to the right of the current axis
    axs.legend(all_Legends, loc='center left', bbox_to_anchor=(1, 0.5), frameon=False)
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION[0][:]
elif WANT_LEGEND == False:
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION[1][:]

# saving the PDF files with a proper name
if SAVE_PDF == True:
    if WANT_LEGEND == True:
        fig.set_size_inches(SELECTED_FIGURE_DIMENSION[0], SELECTED_FIGURE_DIMENSION[1])
        fig.savefig(save_PDF_Path + 'Accuracy_HalfScreen_Average_of_All_Category_Levels_All_Tasks_Legend_' + str(datetime.datetime.today().date()) + '.pdf',
                    dpi=PDF_RESOLUTION, bbox_inches="tight")
    elif WANT_LEGEND==False:
        fig.set_size_inches(SELECTED_FIGURE_DIMENSION[0], SELECTED_FIGURE_DIMENSION[1])
        fig.savefig(save_PDF_Path + 'Accuracy_HalfScreen_Average_of_All_Category_Levels_All_Tasks_' + str(datetime.datetime.today().date()) + '.pdf',
                    dpi=PDF_RESOLUTION, bbox_inches="tight")



plt.show()