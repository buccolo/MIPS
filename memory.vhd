library ieee; 
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity memory is
	generic(
		nbits	: positive	:= 32
	);
	port(
		clk			: in std_logic;

		-- Control Unit
		RegWriteE	: in std_logic;
		MemtoRegE	: in std_logic;
		MemWriteE	: in std_logic;
		MemWriteM	: out std_logic;
		RegWriteM	: out std_logic;
		MemtoRegM	: out std_logic;

		-- ALU
		ZeroE		: in std_logic;
		AluOutE		: in std_logic_vector(31 downto 0);
		AluOutM		: out std_logic_vector(31 downto 0);

		-- RegFile 
		WriteDataE	: in std_logic_vector(31 downto 0);
		WriteRegE	: in std_logic_vector(4 downto 0);
		WriteRegM	: out std_logic_vector(4 downto 0);

		-- Memory
		ReadDataM	: out std_logic_vector(31 downto 0);

		-- Migué de receber a memory direto da entrada do MIPS
		Data		: in std_logic_vector(31 downto 0);

		-- Saída da escrita
		WriteDataM	: out std_logic_vector(31 downto 0);
		
		-- Reset
		reset		: in std_logic
		
	);
end memory;

architecture memory_arc of memory is

begin

	-- Sinais que passam direto
	AluOutM 	<= AluOutE;
	WriteRegM	<= WriteRegE;
	RegWriteM	<= RegWriteE;
	MemtoRegM	<= MemtoRegE;
	ReadDataM	<= Data;
	WriteDataM	<= WriteDataE;
	MemWriteM 	<= MemWriteE;

end;
