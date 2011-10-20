#!/bin/sh
echo Compilando as dependencias no dep.sh
./dep.sh
echo Compilando mips.vhd e executando o tb_mips.vhd
echo ghdl -a mips.vhd
ghdl -a --ieee=synopsys -fexplicit mips.vhd
echo ghdl -a tb_mips.vhd
ghdl -a --ieee=synopsys -fexplicit tb_mips.vhd
echo ghdl -e tb_mips
ghdl -e --ieee=synopsys -fexplicit tb_mips
echo ghdl -r tb_mips --wave=mips.ghw
ghdl -r tb_mips --wave=mips.ghw
