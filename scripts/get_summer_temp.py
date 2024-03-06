import math
import os
import csv
import netCDF4 as nc

# function to extract list from csv file
def get_node_list(fileName):
    nodeList = []
    with open(fileName,'r') as read_obj:
        f = csv.reader(read_obj)
        for row in f:
            print(row[0])
            nodeList.append(int(row[0]))
    return nodeList

def main():

    # define file paths
    folder = r"C:\Users\graym\Documents\Salish Sea Model 2014 Hydro\2014-Hydrodynamics-UploadFolder\HYD_SSM_2014__DFO_mc_0.65alb_tsobc200m"
    fileList = os.listdir(folder)
    nodeList = get_node_list("PugetNodeList.csv") #only nodes within Puget Sound
    resultFileName = r"C:\Users\graym\Desktop\avgMaxDailyTemp.csv"

    # define variables
    numNodes = len(nodeList)
    numFiles = 365
    badFile = 287 # day 287 file is missing variables
    numHours = 24
    siglay = 0 # surface temp only
    FirstSummerDay = 152 # summer days from June 1 to Sep 1 2014
    LastSummerDay = 272

    # create a list which contains an empty list for every node
    TempDailyMaxList = []
    for i in range(numNodes):
        TempDailyMaxList.append([])

    # iterate through every file (day) and calculate
    # the maximum daily temperature at each node
    for iFile in range (numFiles):
        if iFile >= FirstSummerDay and iFile <= LastSummerDay:

            # open the nc file
            fn=folder+"\\"+fileList[iFile]
            print(fn)
            ds = nc.Dataset(fn)

            # iterate through nodes of interest
            for iNode in range(numNodes):
                nodeID = nodeList[iNode]

                # find the maximum temperature and put it in the matrix
                TempDailyMax = 0
                for iTime in range(numHours):
                    temp = ds['temp'][iTime,siglay, nodeID]
                    if temp>TempDailyMax:
                        TempDailyMax = temp
                TempDailyMaxList[iNode].append(TempDailyMax)

    # write the results to a csv file
    fResult = open(resultFileName,'w')
    fResult.write("nodeID,avgDailyMaxTemp\n")
    for iNode in range(numNodes):
        nodeID = nodeList[iNode]
        dailyMaxTemp = sum(TempDailyMaxList[iNode])/len(TempDailyMaxList[iNode])
        fResult.write(str(nodeID)+","+str(dailyMaxTemp)+"\n")

main()
