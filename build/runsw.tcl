#******************************************************************************
# runsw.tcl
#
# This module is the tcl script of building software.
#
# Change History:
#  VER.   Author         DATE              Change Description
#  1.0    Qiwei Wu       Feb. 05, 2020     Initial Release
#  1.1    Qiwei Wu       Arl. 19, 2020     Add libary configure
#******************************************************************************

proc RunSw { buildName srcCode workSpace } {
   set proc ps7_cortexa9_0
   set os standalone

   sdk set_workspace $workSpace
   sdk create_hw_project -name hw_$buildName -hwspec ./$buildName.hdf
   sdk create_bsp_project -name bspbase_$buildName -hwproject hw_$buildName -proc $proc -os $os

   # add libary
   exec echo "BEGIN LIBRARY"                            >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER LIBRARY_NAME = xilffs"          >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER LIBRARY_VER = 3.1"              >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER PROC_INSTANCE = ps7_cortexa9_0" >> $workSpace/bspbase_$buildName/system.mss
   exec echo "END"                                      >> $workSpace/bspbase_$buildName/system.mss

   exec echo "BEGIN LIBRARY"                            >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER LIBRARY_NAME = xilmfs"          >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER LIBRARY_VER = 2.0"              >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER PROC_INSTANCE = ps7_cortexa9_0" >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER base_address = 0x7200000"       >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER init_type = MFSINIT_IMAGE"      >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER need_utils = true"              >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER numbytes = 0xA00000"            >> $workSpace/bspbase_$buildName/system.mss
   exec echo "END"                                      >> $workSpace/bspbase_$buildName/system.mss

   exec echo "BEGIN LIBRARY"                            >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER LIBRARY_NAME = lwip141"         >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER LIBRARY_VER = 1.3"              >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER PROC_INSTANCE = ps7_cortexa9_0" >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER lwip_dhcp = true"               >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER mem_size = 524288"              >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER memp_n_pbuf = 2048"             >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER memp_n_tcp_pcb = 1024"          >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER memp_n_tcp_seg = 1024"          >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER n_rx_descriptors = 256"         >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER n_tx_descriptors = 256"         >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER pbuf_pool_size = 4096"          >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER tcp_snd_buf = 65535"            >> $workSpace/bspbase_$buildName/system.mss
   exec echo "PARAMETER tcp_wnd = 65535"                >> $workSpace/bspbase_$buildName/system.mss
   exec echo "END"                                      >> $workSpace/bspbase_$buildName/system.mss

   # create BSP based on mss
   sdk create_bsp_project -name bsp_$buildName -hwproject hw_$buildName -proc $proc -os $os -mss $workSpace/bspbase_$buildName/system.mss

   # creat app project and fsbl project
   sdk create_app_project -name $buildName -hwproject hw_$buildName -proc $proc -os $os -lang C -bsp bsp_$buildName -app {Empty Application}
   #sdk create_app_project -name $buildName\_fsbl -hwproject hw_$buildName -proc $proc -os $os -lang C -app {Zynq FSBL}

   # build project
   eval file copy -force [glob $srcCode/*] ./workspace/$buildName/src/
   sdk build_project -type bsp -name bsp_$buildName
   sdk build_project -type app -name $buildName

   exit
}

#RunSw qwi01_gpioled ../software ./workspace
