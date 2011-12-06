library ieee; 
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ALU is 
	generic(
		W : natural := 32; 
		Cw	: natural := 3
	);
	port(
		SrcA				: in std_logic_vector(W-1 downto 0);
		SrcB				: in std_logic_vector(W-1 downto 0);
		AluControl	: in std_logic_vector(3 downto 0);
		AluResult		: out std_logic_vector(W-1 downto 0);
		Zero				: out std_logic;
		Overflow		: out std_logic;
		CarryOut		: out std_logic
	);	

end ALU;
    
-- +------------------------+
-- |	Lista de Operacoes		|
-- +------------------------+
-- |	0000 	|			A & B			|
-- |	0001 	|			A | B			|
-- |	0010 	|			A + B			|
-- |	0011 	|		Not used		|
-- |	0100 	|		A & not B		|
-- |	0101 	|		A | not B		|
-- |	0110 	|			A - B			|
-- |	0111 	|			SLT				|
-- |	1000 	|		A XOR	B			|
-- |	1001 	|		A SLTU B		|
-- +------------------------+

architecture arc_alu of ALU is begin

process (AluControl, SrcA, SrcB)

	variable Big: std_logic_vector(32 downto 0);
	variable TempLogic: std_logic_vector(31 downto 0);
	variable SrcBNeg: std_logic_vector(31 downto 0);

	begin
		
		-- A AND B --------------------------------------------------------------------------------------
		if(AluControl = "0000") then
			TempLogic := SrcA AND SrcB;
			AluResult <= TempLogic;

			if (TempLogic = "00000000000000000000000000000000") then
				Zero <= '1';
			else
				Zero <= '0';
			end if;
		
		-- A OR B	--------------------------------------------------------------------------------------
		elsif (AluControl = "0001") then 
			TempLogic := SrcA OR SrcB;
			AluResult <= TempLogic;

			if (TempLogic = "00000000000000000000000000000000") then
				Zero <= '1';
			else
				Zero <= '0';
			end if;

		-- A + B --------------------------------------------------------------------------------------
		elsif (AluControl = "0010") then

			Big := ( '0' & SrcA ) + ( '0' & SrcB );
			CarryOut <= Big(32);
			Overflow <= Big(32) xor SrcA(31) xor SrcB(31) xor Big(31);
			--Overflow <= ( SrcA(31) xnor SrcB(31) ) and ( SrcA(31) xor Big(31) );

			AluResult <= Big(31 downto 0);	

			if (Big(31 downto 0) = "00000000000000000000000000000000") then
				Zero <= '1';
			else
				Zero <= '0';
			end if;	
		
		-- A AND NOT B --------------------------------------------------------------------------------------
		elsif (AluControl = "0100") then
			TempLogic := SrcA AND NOT SrcB;
			AluResult <= TempLogic;

			if (TempLogic = "00000000000000000000000000000000") then
				Zero <= '1';
			else
				Zero <= '0';
			end if;

		-- A OR NOT B --------------------------------------------------------------------------------------
		elsif (AluControl = "0101") then
			TempLogic := SrcA OR NOT SrcB;
			AluResult <= TempLogic;

			if (TempLogic = "00000000000000000000000000000000") then
				Zero <= '1';
			else
				Zero <= '0';
			end if;

		-- A - B --------------------------------------------------------------------------------------
		elsif (AluControl = "0110") then

			-- Transforma o B em C2
			SrcBNeg := ("11111111111111111111111111111111" - SrcB) + "00000000000000000000000000000001";
			
			-- Faz a soma normalmente :)
			Big := ( '0' & SrcA ) + ( '0' & SrcBNeg );

			CarryOut <= Big(32);
			Overflow <= Big(32) xor SrcA(31) xor SrcBNeg(31) xor Big(31);			
			--Overflow <= ( SrcA(31) xnor SrcBNeg(31) ) and ( SrcA(31) xor Big(31) );

			AluResult <= Big(31 downto 0);

			if (Big(31 downto 0) = "00000000000000000000000000000000") then
				Zero <= '1';
			else
				Zero <= '0';
			end if;	

		-- A SLT B --------------------------------------------------------------------------------------
		elsif (AluControl = "0111") then 
			if (SrcA < SrcB) then
				AluResult <= SrcA;
				if (SrcA = "00000000000000000000000000000000") then
					Zero <= '1';
				else
					Zero <= '0';
				end if;	
			else
				AluResult <= SrcB;
				if (SrcB = "00000000000000000000000000000000") then
					Zero <= '1';
				else
					Zero <= '0';
				end if;
			end if;
		-- A XOR B --------------------------------------------------------------------------------------
		elsif (AluControl = "1000") then
			AluResult <= SrcA XOR SrcB;
		end if;

end process;

end;
