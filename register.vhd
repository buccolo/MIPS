library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity reg is
	generic(
		nbits : positive := 32
	);
	port(
		clk, reset	: in STD_LOGIC;
		d			: in STD_LOGIC_VECTOR(nbits-1 downto 0);
		q			: out STD_LOGIC_VECTOR(nbits-1 downto 0)
	);
end reg;

architecture synth of reg is
begin
	process(clk) begin
		if clk'event and clk = '1' then
			if reset = '1' then
				q <= CONV_STD_LOGIC_VECTOR(0, nbits);
			else q <= d;
			end if;
		end if;
	end process;
end;
		