library ieee; 
use ieee.std_logic_1164.all;

entity CU is
	port(
		Op			: in std_logic_vector(5 downto 0);
		Funct		: in std_logic_vector(5 downto 0);
		RegWrite	: out std_logic;
		MemtoReg	: out std_logic;
		MemWrite	: out std_logic;
		ALUControl	: out std_logic_vector(2 downto 0);
		ALUSrc		: out std_logic;
		RegDst		: out std_logic;
		Branch		: out std_logic;
		Jump		: out std_logic;
		Jal			: out std_logic
	);
end CU;

architecture CU_arc of CU is

begin

	case Op is
		-- R-type instruction
		when "000000" =>
			case Funct is
				-- add
				when "100000"=>

				-- addu
				when "100001"=>

				-- sub
				when "100010"=>

				-- subu
				when "100011"=>

				-- and
				when "100100"=>

				-- or
				when "100101"=>

				-- xor
				when "100110"=>

				-- slt
				when "101010"=>

				-- sltu
				when "101011"=>

				when others => null;
			end case;
		
		-- lw
		when "100011" =>
		
		-- sw
		when "101011" =>
		
		-- addi
		when "001000" =>
		
		-- j
		when "000010" =>
		
		-- jal
		when "000100" =>
		
		-- beq
		when "000100" =>

		-- TODO: faltou o subi, essa porra existe mesmo??
		
		when others => null;

	end case;

end;
