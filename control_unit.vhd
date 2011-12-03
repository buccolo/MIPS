library ieee; 
use ieee.std_logic_1164.all;

entity control_unit is
	port(
		Op			: std_logic_vector(5 downto 0);
		Funct		: std_logic_vector(5 downto 0);
		RegWrite	: std_logic;
		MemtoReg	: std_logic;
		MemWrite	: std_logic;
		ALUControl	: std_logic_vector(2 downto 0);
		ALUSrc		: std_logic;
		RegDst		: std_logic;
		Branch		: std_logic;
		Jump		: std_logic;
		Jal			: std_logic
	);
end control_unit;

architecture control_unit_arc of control_unit is

begin

	case Op is
		-- R-type instruction
		when "000000" =>
		
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
		
		when others => null;

	end case;

end;