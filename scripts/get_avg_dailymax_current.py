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
            nodeList.append(int(row[0]))
    return nodeList

def main():

    # define file paths
    folder = r"C:\Users\vicor\Documents\Globus\HYD_SSM_2014__DFO_mc_0.65alb_tsobc200m"
    fileList = os.listdir(folder)
    nodeList = get_node_list("PugetNodeList.csv") #only nodes within Puget Sound
    resultFileName = r"C:\Users\vicor\Desktop\avgDailyMaxCurrentResult.csv"

    # define variables
    numNodes = len(nodeList)
    numFiles = 365
    badFile = 287 # day 287 file is missing variables
    numHours = 24
    siglay = 0 # surface velocity only

    # create a list which contains an empty list for every node
    curDailyMaxList = []
    for i in range(numNodes):
        curDailyMaxList.append([])

    # iterate through every file (day) and calculate
    # the maximum hourly current velocity at each node
    for iFile in range (numFiles):
        if iFile != badFile - 1:

            # open the nc file
            fn=folder+"\\"+fileList[iFile]
            print(fn)
            ds = nc.Dataset(fn)

            # iterate through nodes of interest
            for iNode in range(numNodes):
                nodeID = nodeList[iNode]

                # find the maximum hourly current velocity and put it in the matrix
                # note: calculating the current in three directions
                # makes no real difference.  If we run this script
                # again we should only use two directions (u and v).
                curDailyMax = 0
                for iTime in range(numHours):
                    u = ds['u'][iTime,siglay, nodeID]
                    v = ds['v'][iTime, siglay, nodeID]
                    w = ds['w'][iTime, siglay, nodeID]
                    cur = math.sqrt((u**2)+(v**2)+(w**2))
                    if cur>curDailyMax:
                        curDailyMax = cur
                curDailyMaxList[iNode].append(curDailyMax)

    # write the results to a csv file
    fResult = open(resultFileName,'w')
    fResult.write("nodeID,avgDailyMaxCurrent\n")
    for iNode in range(numNodes):
        nodeID = nodeList[iNode]
        dailyMaxCurrent = sum(curDailyMaxList[iNode])/len(curDailyMaxList[iNode])
        fResult.write(str(nodeID)+","+str(dailyMaxCurrent)+"\n")


main()
