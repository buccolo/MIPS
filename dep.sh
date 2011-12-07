#!/bin/sh
# Lista de Dependencias
ghdl -a --ieee=synopsys -fexplicit rf.vhd
ghdl -a --ieee=synopsys -fexplicit register.vhd
ghdl -a --ieee=synopsys -fexplicit mux.vhd
ghdl -a --ieee=synopsys -fexplicit mux2.vhd
ghdl -a --ieee=synopsys -fexplicit alu.vhd
ghdl -a --ieee=synopsys -fexplicit fetch.vhd
ghdl -a --ieee=synopsys -fexplicit decode.vhd
ghdl -a --ieee=synopsys -fexplicit execute.vhd
ghdl -a --ieee=synopsys -fexplicit memory.vhd
ghdl -a --ieee=synopsys -fexplicit writeback.vhd
ghdl -a --ieee=synopsys -fexplicit cu.vhd
