cmake_minimum_required(VERSION 3.2) # set version of CMake
# cmake_minimum_required(VERSION 2.8) # set version of CMake

# MESSAGE(STATUS "CMAKE_Fortran_COMPILER_ID = ${CMAKE_Fortran_COMPILER_ID}")
EXECUTE_PROCESS(COMMAND which mpiifort RESULT_VARIABLE MPIIFORT_RESULT)
EXECUTE_PROCESS(COMMAND which ifort    RESULT_VARIABLE IFORT_RESULT)
IF (${MPIIFORT_RESULT} EQUAL 0 AND ${IFORT_RESULT} EQUAL 0)
  MESSAGE(STATUS "GATE!9: Found Intel compiler and Intel MPI: building with Intel Compiler")
  SET (CMAKE_Fortran_COMPILER_ID Intel  ) 
  SET (CMAKE_Fortran_COMPILER mpiifort  )
  #SET (CMAKE_C_COMPILER       mpiicc    )
  #SET (CMAKE_CXX_COMPILER     mpiicpc   )
ELSE() # ... if intel compiler is not found, try Fujitsu Compiler
  MESSAGE(STATUS "GATE!14: Building with Fujitsu Compiler")
  SET (CMAKE_Fortran_COMPILER_ID Fujitsu  ) 
  SET (CMAKE_Fortran_COMPILER    mpifrtpx )
  SET (CMAKE_C_COMPILER          mpifccpx )
  SET (CMAKE_CXX_COMPILER        mpiFCCpx )
# ELSE()
#   MESSAGE(STATUS "GATE!14: Did not detect ifort or mpiifort: building with mpif90/mpicc/mpicxx")
#   SET (CMAKE_Fortran_COMPILER mpif90   CACHE FILEPATH "")
#   SET (CMAKE_C_COMPILER       mpicc    CACHE FILEPATH "")
#   SET (CMAKE_CXX_COMPILER     mpicxx   CACHE FILEPATH "")
ENDIF()

MESSAGE("GATE!10: CMAKE_Fortran_COMPILER_INIT = ${CMAKE_Fortran_COMPILER_INIT}")
MESSAGE("GATE!10: CMAKE_Fortran_COMPILER_FULLPATH = ${CMAKE_Fortran_COMPILER_FULLPATH}")
MESSAGE("GATE!10: CMAKE_Fortran_COMPILER = ${CMAKE_Fortran_COMPILER}")
MESSAGE("GATE!10: CMAKE_Fortran_FLAGS = ${CMAKE_Fortran_FLAGS}")
MESSAGE("GATE!10: CMAKE_Fortran_COMPILER_ID = ${CMAKE_Fortran_COMPILER_ID}")

enable_language(Fortran) # setup for fortran 

project(hello-V2) # set project name 

set(EXECUTABLE hello-V2.out) # set target name

# ********************************************************************
# option 
# - CMAKE_Fortran_FLAGS – Used for all builds.
# - CMAKE_Fortran_FLAGS_DEBUG – Used only for debugging builds.
# - CMAKE_Fortran_FLAGS_RELEASE – Used only for release builds.
# ********************************************************************
# we default to Release build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()

if( CMAKE_Fortran_COMPILER_ID MATCHES "PGI|NVHPC" )
    MESSAGE("GATE!14: under dev. ")

elseif( CMAKE_Fortran_COMPILER_ID MATCHES "GNU" )
    MESSAGE("GATE!16: under dev. ")
    set(CMAKE_Fortran_FLAGS         "${CMAKE_Fortran_FLAGS} -Wall")
    set(CMAKE_Fortran_FLAGS_DEBUG   "-O0 -g3")
    set(CMAKE_Fortran_FLAGS_RELEASE "-Ofast -march=native")

elseif( CMAKE_Fortran_COMPILER_ID MATCHES "Intel" )
    set(CMAKE_Fortran_FLAGS         "${CMAKE_Fortran_FLAGS} -r8")
    set(CMAKE_Fortran_FLAGS_DEBUG   "-g -O0 -traceback -CB -fpe0 -mcmodel=large" )
    set(CMAKE_Fortran_FLAGS_RELEASE "-g -xHOST -O3 -ipo -no-prec-div -mcmodel=large -heap-arrys -traceback ") # error case
    # set(CMAKE_Fortran_FLAGS_RELEASE "-fast -mcmodel=large -heap-arrys ")
    # MEMO
    # fpe0: NaN /0 
    # fast: -O3 + -ipo, -no-prec-div, -static, -fp-model fast=2, -xHost

elseif( CMAKE_Fortran_COMPILER_ID MATCHES "Fujitsu" )
    set(CMAKE_Fortran_FLAGS         "${CMAKE_Fortran_FLAGS} -Ad")
    set(CMAKE_Fortran_FLAGS_DEBUG   "-g  ")
    set(CMAKE_Fortran_FLAGS_RELEASE "-Kfast -Ad -mcmodel=large -Nalloc_assign")
    # set(CMAKE_Fortran_FLAGS_RELEASE "-O3 -Ad -mcmodel=large -Nalloc_assign")
    # MEMO
    # -Kfast:
    #   - O3
    #   - Keval!                    演算の評価方法を変更する最適化を行う
    #   - Kfp_contract!             Floating-Point Multiply-Add/Subtract演算命令を使用した最適化を行う
    #   - Kfp_relaxed!              単精度浮動小数点除算/倍精度浮動小数点除算/SQRT関数に対して、逆数近 似演算を利用する最適化を行う
    #   - Kfz!                      flush-to-zeroモード(演算結果またはソースオペランドが非正規化数の場合、それらを同符号の0で置き換える)を使用する
    #   - Kilfunc!                  組込み関数/演算をインライン展開する．つまり，sub. func. をその場に展開してくれるはず．
    #   - Kmfunc!                   組込み関数/演算をマルチ演算関数に変換する最適化を行う
    #   - Komitfp                   手続呼出しにおけるフレームポインタレジスタを保証しない最適化を行う。そのため、トレースバック情報は保証されない
    #   - Ksimd_packed_promotion!   単精度実数型/4バイト整数型の配列要素のインデックス計算が4バイトの範囲を超 えないと仮定して、packed-SIMD化を促進する。4バイトの範囲を超えていると、実行時異常終了や実行結果誤りが生じることがある
    #   !: 演算精度誤差が発生する可能性のある最適化オプション
endif()

add_executable(${EXECUTABLE} #
    # ... main 
    main.f90
    mod_glb_var.f90         # ... glb var 
    mod_prg_hello.f90       # ... main program 
    dir_A/mod_A_tool.f90    # ... dir_A
    dir_A/mod_A.f90 
    dir_B/mod_B_tool.f90    # ... dir_B 
    dir_B/mod_B.f90 
  )
