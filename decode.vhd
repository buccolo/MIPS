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

		-- SignExtender
		SignImmD		: out std_logic_vector(nbits-1 downto 0)

		-- ControlUnit: Saidas
		RegWriteD		: out std_logic;
		MemtoRegD		: out std_logic;
		MemWriteD		: out std_logic;
		ALUControlD		: out std_logic;
		ALUSrcD			: out std_logic;
		RegDstD			: out std_logic;
		BranchD			: out std_logic;
		JumpD			: out std_logic;
		JalD			: out std_logic;

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

	-- Sinais do ControlUnit
	signal Op		: std_logic_vector(5 downto 0);
	signal Funct	: std_logic_vector(5 downto 0);

	component CU is
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
	end component;

begin
	
	------------------	
	-- Control Unit -- 
	------------------
	Op 		<= InstrD(31 downto 26);
	Funct	<= InstrD(5 downto 0);

	-- TODO: Mapear as saidas aqui em cima eh suficiente? Mesmo para RegFile...	
	cu_0: CU port map(Op,Funct,RegWriteD,MemtoRegD,MemWriteD,ALUControlD,ALUSrcD,RegDstD,BranchD,JumpD,JalD);
	

	-- TODO: precisa por um process(clk envolta disso tudo?) dizendo isso por conta do clk do regfile...
	-------------------
	-- Register File --
	-------------------
	A1	<= InstrD(25 downto 21);
	A2	<= InstrD(20 downto 16);
	A3	<= WriteRegW;
	WD3	<= ResultW;
	We3	<= RegWriteW;

	rf_0: RF port map (A1,A2,A3,WD3,clk,We3,RD1D,RD2D);

	-- TODO: Verificar isso aqui, achei no DDCA.pdf pag 423.
	SignImmD <= "0000000000000000" & InstrD(15 downto 0) when InstrD(15) = '0' else "1111111111111111" & InstrD(15 downto 0);

	-- Saidas extras
	RtED <= InstrD(20 downto 16);
	RdED <= InstrD(15 downto 11);

	-- Repassa o PCPlus4 
	PCPlus4D <= PCPlus4F;

end;
