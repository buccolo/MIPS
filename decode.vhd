library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity decode is
	generic(
		nbits	: positive	:= 32;
	);
	port(
		clk				: in std_logic;

		-- Preciosa instrucao
		InstrD			: in std_logic_vector(nbits-1 downto 0);

		-- Repassando o PCPlus4
		PCPlus4F		: in std_logic_vector(nbits-1 downto 0);
		PCPlus4D		: out std_logic_vector(nbits-1 downto 0);

		-- RegFile: sinal de enable, vem do Writeback		
		RegWriteW		: in std_logic;

		-- RegFile: sinal de WD3
		ResultW			: in std_logic_vector(nbits-1 downto 0);

		-- RegFile: saidas
		RD1D			: out std_logic_vector(nbits-1 downto 0)		
		RD2D			: out std_logic_vector(nbits-1 downto 0)

		-- Saidas extras
		RtED			: out std_logic_vector(4 downto 0);
		RdED			: out std_logic_vector(4 downto 0);

		-- Saida do Sign Extend
		SignImmD		: out std_logic_vector(nbits-1 downto 0)

	);
end decode;	
	
architecture decode_arc of decode is

	-- Sinais necessarios para ligar o RegisterFile!
	signal A1	: std_logic_vector(4 downto 0);
	signal A2	: std_logic_vector(4 downto 0);
	signal A3	: std_logic_vector(4 downto 0);
	signal WD3	: std_logic_vector(nbits-1 downto 0); 
	signal We3	: std_logic;

	component RF is
		generic(
			W : natural := 32
		);
		port(
			A1	: in std_logic_vector(4 downto 0);
			A2	: in std_logic_vector(4 downto 0); 
			A3	: in std_logic_vector(4 downto 0); 
			WD3	: in std_logic_vector(nbits-1 downto 0); 
			clk	: in std_logic;
			We3	: in std_logic; 
			RD1	: out std_logic_vector(nbits-1 downto 0); 
			RD2	: out std_logic_vector(nbits-1 downto 0)
		);
	end component;

begin
	-- TODO: precisa por um process(clk ao inves disso tudo?)
	--		 dizendo isso por conta do clk do regfile...
	
	-- Control Unit
	Op		<= InstrD(31 downto 26);
	Funct	<= InstrD(5 downto 0);
	
	cu_0: CU port map

	-- Register File
	A1	<= InstrD(25 downto 21);
	A2	<= InstrD(20 downto 16);
	A3	<= WriteRegW;
	WD3	<= ResultW;
	We3	<= RegWriteW;

	rf_0: RF port map (A1,A2,A3,WD3,clk,We3,RD1,RD2);

	RD1D <= RD1;
	RD2D <= RD2;

	-- TODO: Extender o sinal, eh algo assim
	SignImmD <= "0000" & InstrD(15 downto 0);

	-- Saidas extras
	RtED <= InstrD(20 downto 16);
	RdED <= InstrD(15 downto 11);

	-- Repassa o PCPlus4 
	PCPlus4D <= PCPlus4F;

end;








