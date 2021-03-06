#*****************************************************************************
# makeFw.sh
#
# Change History:
#  VER.   Author         DATE              Change Description
#  1.0    Qiwei Wu       May. 4, 2019      Initial Release
#  1.1    Qiwei Wu       Mar.30, 2020      Improvement
#  1.2    Qiwei Wu       OCT.07, 2020      Improvement
#*****************************************************************************
#!/bin/bash

BuildDir='.buildFw'
BitFileDir='impl_1/'
CopyBitRoute='../../../..'

PrjName=$1
ChipType=$2
BuildTclDir=$3
CopyBitFileDir=$4
CopyHdf=$5
echo "Info: Project Name is $PrjName, ChipType is $ChipType"

#make dir
if [ -d $BuildDir ]; then
   echo "Warning: Building Directory $BuildDir Exist"
   rm -r $BuildDir
   echo "Info: Old Building Directory $BuildDir Removing"
fi
mkdir $BuildDir
echo "Info: Building Directory $BuildDir Establish"

#copy source files
cp * $BuildDir -r
cp .depend $BuildDir -r

#building
cd $BuildDir/build
if [ ! -f run.tcl ]; then
   cp ../$BuildTclDir/run.tcl ./
fi
echo "Run $PrjName $ChipType 0" >> run.tcl
echo "Info: $PrjName $ChipType is building"
vivado -mode batch -source run.tcl

#finish building
echo "Info: $PrjName Project finish building"

#copy the bit file
cd $PrjName.runs/$BitFileDir
if [ -f $PrjName.bit ]; then
   cp $PrjName.bit $CopyBitRoute/$CopyBitFileDir
   echo "Info: $PrjName bit file moved to $CopyBitFileDir"
   if [ $CopyHdf -eq 1 ]; then
      cp $CopyBitRoute/$BuildDir/build/$PrjName.sdk/$PrjName.hdf $CopyBitRoute/$CopyBitFileDir
      echo "Info: $PrjName hdf file moved to $CopyBitFileDir"
   fi
   cp $PrjName\_timing_summary_routed.rpt $CopyBitRoute/$CopyBitFileDir
   cp $PrjName\_utilization_placed.rpt $CopyBitRoute/$CopyBitFileDir
   cp runme.log $CopyBitRoute/$CopyBitFileDir/$PrjName\_runme.log
   echo "Info: $PrjName build log files moved to $CopyBitFileDir"
   #clean
   cd $CopyBitRoute
   #rm -rf $BuildDir
   echo "Info: $PrjName finish building"
   echo -e "\n   Success \n"
else
   echo "Error: $PrjName Project built failed"
   echo "Error: $PrjName Project make failed"
   echo -e "\n   Failure \n"
fi
