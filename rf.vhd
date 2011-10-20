library ieee; 
--use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity RF is generic(W : natural := 32); 
	port(
		A1	: in std_logic_vector(4 downto 0);
		A2	: in std_logic_vector(4 downto 0); 
		A3	: in std_logic_vector(4 downto 0); 
		WD3	: in std_logic_vector(W-1 downto 0); 
		clk	: in std_logic;
		We3	: in std_logic; 
		RD1	: out std_logic_vector(W-1 downto 0); 
		RD2	: out std_logic_vector(W-1 downto 0)
	);

	type RegisterFile is array(W-1 downto 0) of std_logic_vector(W-1 downto 0);

	signal RegFile: RegisterFile;

end RF;

architecture arc of RF is begin

	process(A1, A2)
	begin 

		-- READ 
		-- Em RD1 colocamos o conteudo de A1, o mesmo com RD2 e A2
		-- Por definicao do lab, a primeira posicao deve ser sempre 000...
		if (conv_integer(A1) = 0) then
			RD1 <= conv_std_logic_vector(0, W); -- 000..
		else 
			RD1 <= RegFile(conv_integer(A1));
		end if;
		
		if (conv_integer(A2) = 0) then
			RD2 <= conv_std_logic_vector(0, W); -- 000..
		else 
			RD2 <= RegFile(conv_integer(A2));
		end if;

	end process;

	process(clk, We3, A3, WD3)
	begin 
		-- WRITE
		-- O conteudo de WD3 escrevemos em A3, se estivermos com We3 (Enable) e rising clock
		if clk'EVENT and clk = '1' and We3 = '1' then
			RegFile(conv_integer(A3)) <= WD3;
		end if;
	end process;

end;
