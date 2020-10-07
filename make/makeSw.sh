#*****************************************************************************
# makeSw.sh
#
# Change History:
#  VER.   Author         DATE              Change Description
#  1.0    Qiwei Wu       Apr. 06, 2020     Initial Release
#  1.1    Qiwei Wu       Apr. 25, 2020     Add memfs generate process
#*****************************************************************************
#!/bin/bash

BuildDir='.build'
WorkspaceDir='workspace'
ElfDir='Debug'
CopyElfRoute='../../../../../'

PrjName=$1
TclFileDir=$2
SrcFileDir=$3
CopyFileDir=$4
MemfsGen=$5
echo "Info: Project Name is $PrjName"

#make dir
if [ -d $BuildDir ]; then
   echo "Warning: Building Directory $BuildDir Exist"
   rm -r $BuildDir
   echo "Info: Old Building Directory $BuildDir Removing"
fi
mkdir $BuildDir
echo "Info: Building Directory $FileSys/$BuildDir Establish"

#copy source files
cp * $BuildDir -r

#copy files
mkdir $BuildDir/$WorkspaceDir
cp $CopyFileDir/$PrjName.hdf $BuildDir/$WorkspaceDir
cp $TclFileDir/runsw.tcl $BuildDir/$WorkspaceDir

if [ $MemfsGen -eq 1 ]; then
   cp $SrcFileDir/memfs $BuildDir/$WorkspaceDir -r
fi

#building
cd $BuildDir/$WorkspaceDir
if [ $MemfsGen -eq 1 ]; then
   cd memfs
   mfsgen -cvbf ../image.mfs 2048 css images js yui generate-mfs index.html
   cd ../
fi
echo "Run $PrjName ../$SrcFileDir $WorkspaceDir" >> runsw.tcl
echo "Info: $PrjName Project is building"
xsdk -batch -source runsw.tcl

#finish building
sleep 2
echo "Info: $PrjName Project finish building"

#copy the elf file
cd $WorkspaceDir/$PrjName/$ElfDir
if [ -f $PrjName.elf ]; then
   cp $PrjName.elf $CopyElfRoute/$CopyFileDir
   echo "Info: $PrjName.elf file moved to $CopyFileDir"
   cd $CopyElfRoute
   #copy memfs
   if [ $MemfsGen -eq 1 ]; then
      cp $BuildDir/$WorkspaceDir/image.mfs $CopyFileDir
   fi
   #clean
   rm -rf $BuildDir
   echo "Info: $PrjName.elf file finish making"
   echo -e "\n   Success \n"
else
   echo "Error: $PrjName Project built failed"
   echo "Error: $PrjName Project make failed"
   echo -e "\n   Failure \n"
fi
