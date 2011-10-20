#!/bin/sh
# Lista de Dependencias
ghdl -a --ieee=synopsys -fexplicit rf.vhd
ghdl -a --ieee=synopsys -fexplicit alu.vhd
