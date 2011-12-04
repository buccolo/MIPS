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
		BranchE		: in std_logic;
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

		-- PC
		PCBranchE	: in std_logic_vector(31 downto 0);
		PCBranchM	: out std_logic_vector(31 downto 0);
		PCSrcM		: out std_logic;

		-- Memory
		ReadDataM	: out std_logic_vector(31 downto 0);

		-- Migué de receber a memory direto da entrada do MIPS
		Data		: in std_logic_vector(31 downto 0)
		
	);
end memory;

architecture memory_arc of memory is

begin

	-- PC
	PCSrcM 		<= BranchE and ZeroE;

	-- Sinais que passam direto
	AluOutM 	<= AluOutE;
	WriteRegM	<= WriteRegE;
	PCBranchM	<= PCBranchE;
	RegWriteM	<= RegWriteE;
	MemtoRegM	<= MemtoRegE;

	-- Buccolo: MEMORIA: Nao lembro o migue que eh pra dar, ele diz que nao eh pra implementar
	-- TODO:  Richard: Done! Só precisa ver se a variável é a certa
	ReadDataM <= Data;
	-- MemoriaA 	<= AluOutE;
	-- MemoriaWD	<= WriteDataE;
	-- MemoriaWE	<= MemWriteE;
	-- ReadDataM 	<= null; -- ??? 

end;
