library ieee; 
use ieee.std_logic_1164.all;

entity CU is
	port(
		Op			: in std_logic_vector(5 downto 0);
		Funct		: in std_logic_vector(5 downto 0);
		RegWrite	: out std_logic;
		MemtoReg	: out std_logic;
		MemWrite	: out std_logic;
		ALUControl	: out std_logic_vector(3 downto 0);
		ALUSrc		: out std_logic;
		RegDst		: out std_logic_vector(1 downto 0);
		Branch		: out std_logic;
		Jump		: out std_logic;
		Jal			: out std_logic
	);
end CU;

architecture CU_arc of CU is 

begin

process
 
begin
	case Op is
		-- R-type instruction
		when "000000" =>
			RegWrite	<= '1';
			RegDst		<= "01";
			ALUSrc		<= '0';
			Branch 		<= '0';
			MemWrite	<= '0';
			MemtoReg	<= '0';
			Jump			<= '0';
			Jal				<= '0';

			case Funct is
				-- add
				when "100000"=>
					ALUControl <= "0010";
				-- addu
				when "100001"=>
					ALUControl <= "0010";
				-- sub
				when "100010"=>
					ALUControl <= "0110";
				-- subu
				when "100011"=>
					ALUControl <= "0110";
				-- and
				when "100100"=>
					ALUControl <= "0000";
				-- or
				when "100101"=>
					ALUControl <= "0001";
				-- xor
				when "100110"=>
					ALUControl <= "1000";
				-- slt
				when "101010"=>
					ALUControl <= "0111";
				-- sltu
				when "101011"=>
					ALUControl <= "0111"; -- TODO: fazer o sltu na ALU
				when others => null;
			end case;
		
		-- lw
		when "100011" =>
			RegWrite	<= '1';
			RegDst		<= "00";
			ALUSrc		<= '1';
			Branch 		<= '0';
			MemWrite	<= '0';
			MemtoReg	<= '1';
			Jump			<= '0';
			Jal				<= '0';
			ALUControl <= "0010"; --soma imediato
		-- sw
		when "101011" =>
			RegWrite	<= '0';
			RegDst		<= "00";--xx
			ALUSrc		<= '1';
			Branch 		<= '0';
			MemWrite	<= '1';
			MemtoReg	<= '0';--x
			Jump			<= '0';
			Jal				<= '0';
			ALUControl <= "0010"; --soma imediato
		-- addi
		when "001000" =>
			RegWrite	<= '1';
			RegDst		<= "00";
			ALUSrc		<= '1';
			Branch 		<= '0';
			MemWrite	<= '0';
			MemtoReg	<= '0';
			Jump			<= '0';
			Jal				<= '0';
			ALUControl <= "0010"; --soma imediato
		-- j
		when "000010" =>
			RegWrite	<= '0';
			RegDst		<= "00"; --xx
			ALUSrc		<= '0'; --x
			Branch 		<= '0'; --x
			MemWrite	<= '0'; 
			MemtoReg	<= '0';	--x
			Jump			<= '1';
			Jal				<= '0';
			ALUControl <= "0010";  --xxxx
		-- jal
		when "000011" =>
			RegWrite	<= '1';
			RegDst		<= "10"; --10 WriteReg4:0 11111 (31)
			ALUSrc		<= '0';--x
			Branch 		<= '0';
			MemWrite	<= '0';
			MemtoReg	<= '0';--x
			Jump			<= '1';
			Jal				<= '1';
		-- beq
		when "000100" =>
			RegWrite	<= '0';
			RegDst		<= "00";--xx
			ALUSrc		<= '0';
			Branch 		<= '1';
			MemWrite	<= '0';
			MemtoReg	<= '0';--x
			Jump			<= '0';
			Jal				<= '0';
			ALUControl <= "0110"; --subtrai

		-- TODO: faltou o subi
		-- ALHO: segundo o livro, o MIPS não tem subi porque é a mesma coisa que addi com negativo, nem opcode tem
		
		when others => null;

	end case;

end process;

end;
