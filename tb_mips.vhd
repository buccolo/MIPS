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
		Data		: in std_logic_vector(nbits -1 downto 0);
		clk 		: in std_logic;
		reset		: in std_logic;
		PCF			: out std_logic_vector(nbits -1 downto 0);
		ALUOutM		: out std_logic_vector(nbits -1 downto 0);
		WriteDataM	: out std_logic_vector(nbits -1 downto 0);
		MemWriteM	: out std_logic
	);
end component;

for mips_0: mips use entity work.mips;

-- Sinais de Debug --
signal erro : boolean := false;

-- Sinais do MIPS -- 
signal Instruction 	: std_logic_vector(31 downto 0);
signal Data			: std_logic_vector(31 downto 0);
signal clk 			: std_logic := '1';
signal reset		: std_logic;
signal PCF			: std_logic_vector(31 downto 0);
signal ALUOutM		: std_logic_vector(31 downto 0);
signal WriteDataM	: std_logic_vector(31 downto 0);
signal MemWriteM	: std_logic;

-- RTYPE  RD, RS, RT --------------------+
-- --------------------------------------|
-- OP     RS    RT    RD    SHIFT FUNCT  |
-- 000000 SSSSS TTTTT DDDDD 00000 000000 |
-----------------------------------------+

-- LW RT, IMEDIATE(RS) -------------------+
-- ---------------------------------------|
-- OP     RS    RT    IMEDIATE            |
-- 100011 00000 01010 0000 0000 0010 0000 |
------------------------------------------+

-- SW RT, IMEDIATE(RS) -------------------+
-- ---------------------------------------|
-- OP     RS    RT    IMEDIATE            |
-- 101011 00000 01010 0000 0000 0010 0000 |
------------------------------------------+

-- BEQ RS, RT, IMEDIATE ------------------+
-- ---------------------------------------|
-- OP     RS    RT    IMEDIATE            |
-- 000100 00000 01010 0000 0000 0010 0000 |
------------------------------------------+

-- J 26-BIT-IMEDIATE ----------------+
-- ----------------------------------|
-- OP     26 BIT IMEDIATE            |
-- 000010 00000000000000000000000000 |
-------------------------------------+

-- JAL 26-BIT-IMEDIATE --------------+
-- ----------------------------------|
-- OP     26 BIT IMEDIATE            |
-- 000011 00000000000000000000000000 |
-------------------------------------+

begin
	mips_0: mips port map (Instruction, Data, clk, reset, PCF, AluOutM, WriteDataM, MemWriteM);

	clk <= not clk after 50 ns;

	process begin
		reset <= '1';
		wait for 50 ns;

		-- lw $1, 1($0) >>> $0, $1, imediate
		Instruction <= "100011"&"00000"&"00001"&"0000000000000001";
		Data <= "10000000000000000000000000000000";
		assert PCF = "00000000000000000000000000000100" report "PC NAO FUNCIONA";
		wait for 50 ns;

		-- lw $2, 2($0) 
		Instruction <= "100011"&"00000"&"00010"&"0000000000000010";
		Data <= "01111111111111111111111111111111";
		assert PCF = "00000000000000000000000000001000" report "PC NAO FUNCIONA";
		wait for 50 ns;

		-- lw $3, 3($0) 
		Instruction <= "100011"&"00000"&"00011"&"0000000000000011";
		Data <= "00000000000000001111111111111111";
		assert PCF = "00000000000000000000000000001100" report "PC NAO FUNCIONA";
		wait for 50 ns;

		-- add $4, $1, $2
		Instruction <= "000000"&"00001"&"00010"&"00100"&"00000"&"100000";
		assert PCF = "00000000000000000000000000010000" report "PC NAO FUNCIONA";
		wait for 50 ns;

		-- and $5, $3, $2 >>> $3, $2, $5
		Instruction <= "000000"&"00011"&"00010"&"00110"&"00000"&"100100";
		assert PCF = "00000000000000000000000000010100" report "PC NAO FUNCIONA";
		wait for 50 ns;

	end process;
	

	process 
		begin
		wait for 600 ns;      -- Define o tempo de simulacao
		erro <= true;
	end process;

	assert not erro report "End of Simulation" severity failure;

end behav;
