library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity tb_mips is
end tb_mips;

architecture behav of tb_mips is
component mips is 
	generic(
		nbits : positive := 32
	);
	port(
		Instruction : in std_logic_vector(nbits -1 downto 0);
		Data				: in std_logic_vector(nbits -1 downto 0);
		clk 				: in std_logic;
		reset				: in std_logic;
		PCF					: out std_logic_vector(nbits -1 downto 0);
		ALUOutM			: out std_logic_vector(nbits -1 downto 0);
		WriteDataM	: out std_logic_vector(nbits -1 downto 0);
		MemWriteM		: out std_logic
	);
end component;

for mips_0: mips use entity work.mips;

-- Sinais de Debug --
signal erro : boolean := false;

-- Sinais do MIPS -- 
signal Instruction 	: std_logic_vector(31 downto 0);
signal Data					: std_logic_vector(31 downto 0);
signal clk 					: std_logic := '1';
signal reset				: std_logic;
signal PCF					: std_logic_vector(31 downto 0);
signal ALUOutM			: std_logic_vector(31 downto 0);
signal WriteDataM		: std_logic_vector(31 downto 0);
signal MemWriteM		: std_logic;

begin
	mips_0: mips port map (Instruction, Data, clk, reset, PCF, AluOutM, WriteDataM, MemWriteM);

	clk <= not clk after 50 ns;

	process 
		begin
		wait for 600 ns;      -- Define o tempo de simulacao
		erro <= true;
	end process;

	assert not erro report "End of Simulation" severity failure;

end behav;
