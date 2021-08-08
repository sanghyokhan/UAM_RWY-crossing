import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import warnings
from datetime import datetime, timedelta
import re
import math
import seaborn as sns

# options
pd.set_option('max_columns',100)
warnings.simplefilter('ignore')
plt.style.use('fivethirtyeight')
save_dir = '../result/'





def entire_distribution(arr_df_north, arr_df_south, dep_df_north, dep_df_south):

    global labels1, labels2, kwargs_hist, kwargs_avline

    base_map = plt.imread('../data/map.png')
    BBox = (126.3940, 126.4743, 37.4414, 37.4856)

    # North flow wheel on/off
    fig, ax = plt.subplots(figsize = (25,20))
    ax.scatter(dep_df_north['Lon'], dep_df_north['Lat'], alpha= 0.6, c='b', s=30, marker = 'o', label = 'Departure')
    ax.scatter(arr_df_north['Lon'], arr_df_north['Lat'], alpha= 0.6, c='r', s=30, marker = 'x', label = 'Arrival')
    ax.set_xlim(BBox[0],BBox[1])
    ax.set_ylim(BBox[2],BBox[3])
    ax.legend(fontsize=20)
    ax.imshow(base_map, zorder = 0, extent = BBox, aspect= 'equal')
    plt.savefig(save_dir + 'northflow.png', bbox_inches='tight', pad_inches=1)


    # South flow wheel on/off
    fig, ax = plt.subplots(figsize = (25,20))
    ax.scatter(dep_df_south['Lon'], dep_df_south['Lat'], alpha= 0.6, c='b', s=30, marker = 'o', label = 'Departure')
    ax.scatter(arr_df_south['Lon'], arr_df_south['Lat'], alpha= 0.6, c='r', s=30, marker = 'x', label = 'Arrival')
    ax.set_xlim(BBox[0],BBox[1])
    ax.set_ylim(BBox[2],BBox[3])
    ax.legend(fontsize=20)
    ax.imshow(base_map, zorder = 0, extent = BBox, aspect= 'equal')
    plt.savefig(save_dir + 'southflow.png', bbox_inches='tight', pad_inches=1)


    # distribution
    plt.figure(figsize=(15, 15))

    plt.subplot(2,2,1)
    plt.axvline(np.mean(arr_df_north['DIST']), **kwargs_avline)
    sns.histplot(data = arr_df_north, **kwargs_hist)
    plt.annotate(round(np.mean(arr_df_north['DIST'])), 
                xy = (np.mean(arr_df_north['DIST']), 10),
                xytext = (np.mean(arr_df_north['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('North Arrival')

    plt.subplot(2,2,2)
    plt.axvline(np.mean(dep_df_south['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south['DIST'])), 
                xy = (np.mean(dep_df_south['DIST']), 10),
                xytext = (np.mean(dep_df_south['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('North Departure')

    plt.subplot(2,2,3)
    plt.axvline(np.mean(arr_df_south['DIST']), **kwargs_avline)
    sns.histplot(data = arr_df_south, **kwargs_hist)
    plt.annotate(round(np.mean(arr_df_south['DIST'])), 
                xy = (np.mean(arr_df_south['DIST']), 10),
                xytext = (np.mean(arr_df_south['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('South Arrival')

    plt.subplot(2,2,4)
    plt.axvline(np.mean(dep_df_south['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south['DIST'])), 
                xy = (np.mean(dep_df_south['DIST']), 10),
                xytext = (np.mean(dep_df_south['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('South Departure')

    plt.savefig(save_dir + 'entire_dist.png', bbox_inches='tight', pad_inches=1)





def aircraft_type_distribution(arr_df_north, arr_df_south, dep_df_north, dep_df_south):

    global labels1, labels2, kwargs_hist, kwargs_avline

    dep_df_south_A = dep_df_south[dep_df_south['AC'] == 'A']
    dep_df_south_B = dep_df_south[dep_df_south['AC'] == 'B']
    dep_df_south_C = dep_df_south[dep_df_south['AC'] == 'C']
    dep_df_south_G = dep_df_south[dep_df_south['AC'] == 'G']
    dep_df_south_NOWGT = dep_df_south[dep_df_south['AC'] == 'NOWGT']

    dep_df_north_A = dep_df_north[dep_df_north['AC'] == 'A']
    dep_df_north_B = dep_df_north[dep_df_north['AC'] == 'B']
    dep_df_north_C = dep_df_north[dep_df_north['AC'] == 'C']
    dep_df_north_G = dep_df_north[dep_df_north['AC'] == 'G']
    dep_df_north_NOWGT = dep_df_north[dep_df_north['AC'] == 'NOWGT']

    # South
    plt.figure(figsize=(15, 15))

    plt.subplot(3,2,1)
    plt.axvline(np.mean(dep_df_south_A['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south_A, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south_A['DIST'])), 
                xy = (np.mean(dep_df_south_A['DIST']), 10),
                xytext = (np.mean(dep_df_south_A['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('dep_df_south_A')

    plt.subplot(3,2,2)
    plt.axvline(np.mean(dep_df_south_B['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south_B, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south_B['DIST'])), 
                xy = (np.mean(dep_df_south_B['DIST']), 1),
                xytext = (np.mean(dep_df_south_B['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('dep_df_south_B')

    plt.subplot(3,2,3)
    plt.axvline(np.mean(dep_df_south_C['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south_C, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south_C['DIST'])), 
                xy = (np.mean(dep_df_south_C['DIST']), 10),
                xytext = (np.mean(dep_df_south_C['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('dep_df_south_C')

    plt.subplot(3,2,4)
    plt.axvline(np.mean(dep_df_south_G['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south_G, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south_G['DIST'])), 
                xy = (np.mean(dep_df_south_G['DIST']), 1),
                xytext = (np.mean(dep_df_south_G['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('dep_df_south_G')

    plt.subplot(3,2,5)
    plt.axvline(np.mean(dep_df_south_NOWGT['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south_NOWGT, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south_NOWGT['DIST'])), 
                xy = (np.mean(dep_df_south_NOWGT['DIST']), 1),
                xytext = (np.mean(dep_df_south_NOWGT['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('dep_df_south_NOWGT')

    plt.savefig(save_dir + 'weight_dist_south.png', bbox_inches='tight', pad_inches=1)


    # North
    plt.figure(figsize=(15, 15))

    plt.subplot(3,2,1)
    plt.axvline(np.mean(dep_df_north_A['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_north_A, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_north_A['DIST'])), 
                xy = (np.mean(dep_df_north_A['DIST']), 10),
                xytext = (np.mean(dep_df_north_A['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('dep_df_north_A')

    plt.subplot(3,2,2)
    plt.axvline(np.mean(dep_df_north_B['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_north_B, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_north_B['DIST'])), 
                xy = (np.mean(dep_df_north_B['DIST']), 1),
                xytext = (np.mean(dep_df_north_B['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('dep_df_north_B')

    plt.subplot(3,2,3)
    plt.axvline(np.mean(dep_df_north_C['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_north_C, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_north_C['DIST'])), 
                xy = (np.mean(dep_df_north_C['DIST']), 10),
                xytext = (np.mean(dep_df_north_C['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('dep_df_north_C')

    plt.subplot(3,2,4)
    plt.axvline(np.mean(dep_df_north_G['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_north_G, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_north_G['DIST'])), 
                xy = (np.mean(dep_df_north_G['DIST']), 1),
                xytext = (np.mean(dep_df_north_G['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('dep_df_north_G')

    plt.subplot(3,2,5)
    plt.axvline(np.mean(dep_df_north_NOWGT['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_north_NOWGT, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_north_NOWGT['DIST'])), 
                xy = (np.mean(dep_df_north_NOWGT['DIST']), 1),
                xytext = (np.mean(dep_df_north_NOWGT['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('dep_df_north_NOWGT')

    plt.savefig(save_dir + 'weight_dist_north.png', bbox_inches='tight', pad_inches=1)





def density_altitude_distribution(arr_df_north, arr_df_south, dep_df_north, dep_df_south, da):

    global labels1, labels2, kwargs_hist, kwargs_avline

    dep_df_north_highDA = dep_df_north[dep_df_north['DensityAltitude'] >= da]    
    dep_df_north_lowDA = dep_df_north[dep_df_north['DensityAltitude'] < da]
    dep_df_south_highDA = dep_df_south[dep_df_south['DensityAltitude'] >= da]
    dep_df_south_lowDA = dep_df_south[dep_df_south['DensityAltitude'] < da]

    plt.figure(figsize=(15, 15))

    plt.subplot(2,2,1)
    plt.axvline(np.mean(dep_df_north_highDA['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_north_highDA, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_north_highDA['DIST'])), 
                xy = (np.mean(dep_df_north_highDA['DIST']), 10),
                xytext = (np.mean(dep_df_north_highDA['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('dep_df_north_highDA')

    plt.subplot(2,2,2)
    plt.axvline(np.mean(dep_df_north_lowDA['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_north_lowDA, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_north_lowDA['DIST'])), 
                xy = (np.mean(dep_df_north_lowDA['DIST']), 10),
                xytext = (np.mean(dep_df_north_lowDA['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('dep_df_north_lowDA')

    plt.subplot(2,2,3)
    plt.axvline(np.mean(dep_df_south_highDA['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south_highDA, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south_highDA['DIST'])), 
                xy = (np.mean(dep_df_south_highDA['DIST']), 10),
                xytext = (np.mean(dep_df_south_highDA['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('dep_df_south_highDA')

    plt.subplot(2,2,4)
    plt.axvline(np.mean(dep_df_south_lowDA['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south_lowDA, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south_lowDA['DIST'])), 
                xy = (np.mean(dep_df_south_lowDA['DIST']), 10),
                xytext = (np.mean(dep_df_south_lowDA['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('dep_df_south_lowDA')

    plt.savefig(save_dir + 'densityaltitude_dist.png', bbox_inches='tight', pad_inches=1)





def headwind_distribution(arr_df_north, arr_df_south, dep_df_north, dep_df_south, headwind):

    global labels1, labels2, kwargs_hist, kwargs_avline

    dep_df_north_highHW = dep_df_north[dep_df_north['Headwind'] >= headwind]
    dep_df_north_lowHW = dep_df_north[dep_df_north['Headwind'] < headwind]
    dep_df_south_highHW = dep_df_south[dep_df_south['Headwind'] >= headwind]
    dep_df_south_lowHW = dep_df_south[dep_df_south['Headwind'] < headwind]

    plt.figure(figsize=(15, 15))

    plt.subplot(2,2,1)
    plt.axvline(np.mean(dep_df_north_highHW['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_north_highHW, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_north_highHW['DIST'])), 
                xy = (np.mean(dep_df_north_highHW['DIST']), 10),
                xytext = (np.mean(dep_df_north_highHW['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('dep_df_north_highHW')

    plt.subplot(2,2,2)
    plt.axvline(np.mean(dep_df_north_lowHW['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_north_lowHW, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_north_lowHW['DIST'])), 
                xy = (np.mean(dep_df_north_lowHW['DIST']), 10),
                xytext = (np.mean(dep_df_north_lowHW['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('dep_df_north_lowHW')

    plt.subplot(2,2,3)
    plt.axvline(np.mean(dep_df_south_highHW['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south_highHW, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south_highHW['DIST'])), 
                xy = (np.mean(dep_df_south_highHW['DIST']), 10),
                xytext = (np.mean(dep_df_south_highHW['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('dep_df_south_highHW')

    plt.subplot(2,2,4)
    plt.axvline(np.mean(dep_df_south_lowHW['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south_lowHW, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south_lowHW['DIST'])), 
                xy = (np.mean(dep_df_south_lowHW['DIST']), 10),
                xytext = (np.mean(dep_df_south_lowHW['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('dep_df_south_lowHW')

    plt.savefig(save_dir + 'headwind_dist.png', bbox_inches='tight', pad_inches=1)




# 왜 mean값 안나오냐?????????
def runway_condition_distribution(arr_df_north, arr_df_south, dep_df_north, dep_df_south):

    global labels1, labels2, kwargs_hist, kwargs_avline

    dep_df_north_Wet= dep_df_north[dep_df_north['Wet'] == 1]
    dep_df_north_notWet = dep_df_north[dep_df_north['Wet'] == 0]
    dep_df_south_Wet = dep_df_south[dep_df_south['Wet'] == 1]
    dep_df_south_notWet = dep_df_south[dep_df_south['Wet'] == 0]

    plt.figure(figsize=(15, 15))

    plt.subplot(2,2,1)
    plt.axvline(np.mean(dep_df_north_Wet['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_north_Wet, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_north_Wet['DIST'])), 
                xy = (np.mean(dep_df_north_Wet['DIST']), 10),
                xytext = (np.mean(dep_df_north_Wet['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('dep_df_north_Wet')

    plt.subplot(2,2,2)
    plt.axvline(np.mean(dep_df_north_notWet['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_north_notWet, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_north_notWet['DIST'])), 
                xy = (np.mean(dep_df_north_notWet['DIST']), 10),
                xytext = (np.mean(dep_df_north_notWet['DIST']), 0))
    plt.legend(labels = labels1)
    plt.title('dep_df_north_notWet')

    plt.subplot(2,2,3)
    plt.axvline(np.mean(dep_df_south_Wet['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south_Wet, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south_Wet['DIST'])), 
                xy = (np.mean(dep_df_south_Wet['DIST']), 10),
                xytext = (np.mean(dep_df_south_Wet['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('dep_df_south_Wet')

    plt.subplot(2,2,4)
    plt.axvline(np.mean(dep_df_south_notWet['DIST']), **kwargs_avline)
    sns.histplot(data = dep_df_south_notWet, **kwargs_hist)
    plt.annotate(round(np.mean(dep_df_south_notWet['DIST'])), 
                xy = (np.mean(dep_df_south_notWet['DIST']), 10),
                xytext = (np.mean(dep_df_south_notWet['DIST']), 0))
    plt.legend(labels = labels2)
    plt.title('dep_df_south_Wet')

    plt.savefig(save_dir + 'rwycondition_dist.png', bbox_inches='tight', pad_inches=1)










# RWY : '33L', '33R', 34, '15R', '15L', 16  -->>  1-3 : Northflow / 4-6 : Southflow
columns = ['Time', 'Callsign', 'AC', 'Lat', 'Lon', 'RWY', 'DIST']
labels1 = [ 'mean', '33L', '33R', '34']
labels2 = [ 'mean', '15R', '15L', '16']

# load data
arr_df = pd.read_csv(f'../input/arr_data.csv', index_col=False, header = 0)
dep_df = pd.read_csv(f'../input/dep_data.csv', index_col=False, header = 0)
metar_df = pd.read_csv(f'../input/metar_20191222-20191228.csv', index_col=False, header = 0)

# modify data
arr_df.columns = columns
dep_df.columns = columns
arr_df['Time']= pd.to_datetime(arr_df['Time'])
dep_df['Time']= pd.to_datetime(dep_df['Time'])
metar_df['IssueTime'] = pd.to_datetime(metar_df['IssueTime'])

# dep only
dep_df['DensityAltitude'] = 0
dep_df['Headwind'] = 0
dep_df['Wet'] = 0
for i in range(len(metar_df)-1):
    dep_df.loc[dep_df['Time'] >= metar_df['IssueTime'][i], 'DensityAltitude'] = metar_df['DensityAltitude'][i]
    dep_df.loc[dep_df['Time'] >= metar_df['IssueTime'][i], 'Headwind'] = metar_df['Headwind'][i]
    dep_df.loc[dep_df['Time'] >= metar_df['IssueTime'][i], 'Wet'] = metar_df['Wet'][i]

# dep / arr
arr_df_north = arr_df[arr_df['RWY'] <= 3]
dep_df_north = dep_df[dep_df['RWY'] <= 3]
arr_df_south = arr_df[arr_df['RWY'] > 3]
dep_df_south = dep_df[dep_df['RWY'] > 3]

# aircraft type mapping
mapping = {'B738':'C', 'A321':'C', 'A333':'A', 'A320':'C', 'B772':'A', 'B77W':'A', 'B744':'A',
           'B748':'A', 'A359':'A', 'B739':'C', 'A332':'A', 'B789':'A', 'A21N':'C', 'B763':'B',
           'B773':'A', 'B77L':'A', 'B737':'C', 'B788':'A', 'A20N':'C', 'A319':'C', 'B787':'A',
           'A339':'G', 'B767':'B', 'MD11':'B', 'B78X':'G', 'A306':'C', 'B747':'A', 'A330':'A', 
           'B752':'C', 'B777':'A', 'A124':'G', 'A388':'NOWGT', 'A380':'NOWGT'}
dep_df_north.loc[:,'AC'] = dep_df_north['AC'].map(mapping)
dep_df_south.loc[:,'AC'] = dep_df_south['AC'].map(mapping)










# plot keyward augment
kwargs_hist = {'x' : "DIST",
               'kde' : True, 
               'hue' : "RWY", 
               'multiple' : 'layer', 
               'bins' : 50
               }

kwargs_avline = {'color':'crimson',
                 'linestyle' : '--',
                  'linewidth' : 2
                  }

# parameters
da = -1866.010659
headwind = 10





if __name__ =='__main__':
    print('RKSI Wheel On/Off Distribution')
    entire_distribution(arr_df_north, arr_df_south, dep_df_north, dep_df_south)

    ##################################################################################################################
    # departure only now
    aircraft_type_distribution(arr_df_north, arr_df_south, dep_df_north, dep_df_south)
    density_altitude_distribution(arr_df_north, arr_df_south, dep_df_north, dep_df_south, da)
    headwind_distribution(arr_df_north, arr_df_south, dep_df_north, dep_df_south, headwind)
    runway_condition_distribution(arr_df_north, arr_df_south, dep_df_north, dep_df_south)
    ##################################################################################################################