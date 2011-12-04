library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity mips is 
	generic(
		nbits : positive := 32
	);
	port(
		-- A simulacao ira funcionar da seguinte maneira
		-- 1. O sinal reset serah ligado, para colocar o datapath no estado
		--    inicial. Isso inclui resetar o RegFile e colocar o PC = 0.
		-- 2. Agora podemos executar normalmente.

		-- Instruction Memory: Leitura
		Instruction : in std_logic_vector(nbits -1 downto 0);

		-- Data Memory: Leitura	
		Data		: in std_logic_vector(nbits -1 downto 0);

		clk 		: in std_logic;
		reset		: in std_logic;

		-- PCF: Fizemos os jumps / branches corretamente?
		PCF			: out std_logic_vector(nbits -1 downto 0);
		
		-- ALU: A ALU esta funcionando? 
		ALUOutM		: out std_logic_vector(nbits -1 downto 0);

		--  Data Memory: Escrita
		WriteDataM	: out std_logic_vector(nbits -1 downto 0);
		MemWriteM	: out std_logic
	);
end mips;
  
architecture arc_mips of mips is

	
begin

end;
