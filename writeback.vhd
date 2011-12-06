library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity writeback is
	generic(
		nbits	: positive	:= 32
	);
	port(
		clk			: in std_logic;

		-- Control Unit
		RegWriteM	: in std_logic;
		MemtoRegM	: in std_logic;
		RegWriteW	: out std_logic;

		-- ALU
		AluOutM		: in std_logic_vector(31 downto 0);
		ResultW		: out std_logic_vector(31 downto 0);

		-- RegFile
		WriteRegM	: in std_logic_vector(4 downto 0);
		WriteRegW	: out std_logic_vector(4 downto 0);

		-- Memory
		ReadDataM	: in std_logic_vector(31 downto 0);
		
		-- Reset
		reset		: in std_logic
	);
end writeback;

architecture writeback_arc of writeback is

begin
	RegWriteW	<= RegWriteM;
	WriteRegW	<= WriteRegM; 

	ResultW 	<= AluOutM when MemtoRegM = '0' else ReadDataM; -- outro mux
end;
