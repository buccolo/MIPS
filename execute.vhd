library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity execute is
	generic(
		nbits	: positive	:= 32;
	);
	port(
		clk		: in std_logic;

		-- Control Unit: Entradas
		RegWriteD	: in std_logic;
		MemtoRegD	: in std_logic;
		MemWriteD	: in std_logic;
		ALUControlD	: in std_logic;
		ALUSrcD		: in std_logic;
		RegDstD		: in std_logic;
		BranchD		: in std_logic;
		JumpD		: in std_logic;
		JalD		: in std_logic;

		-- Control Unit: Saidas
		RegWriteE	: out std_logic;
		MemtoRegE	: out std_logic;
		MemWriteE	: out std_logic;
		BranchE		: out std_logic;

		-- ALU
		ZeroE		: out std_logic;
		AluOutE		: out std_logic_vector(31 downto 0);

		-- RegisterFile
		RD1D		: in std_logic_vector(31 downto 0);
		RD2D		: in std_logic_vector(31 downto 0);

		-- Outras entradas
		RtD			: in std_logic_vector(4 downto 0);
		RdD			: in std_logic_vector(4 downto 0);
		SignImmD	: in std_logic_vector(31 downto 0);
		PCPlus4D	: in std_logic_vector(31 downto 0);

		-- Outras saidas
		WriteDataE	: out std_logic_vector(31 downto 0);
		WriteRegE	: out std_logic_vector(4 downto 0);
		PCBranchE	: out std_logic_vector(31 downto 0)
	);
end execute;

architecture execute_arc of execute is
	
	-- ALU --
	signal SrcAE		: std_logic_vector(31 downto 0);
	signal SrcBE		: std_logic_vector(31 downto 0);
	signal AluControlE	: std_logic_vector(2 downto 0); 	

	component ALU is
		generic(
			W	: natural := 32; 
			Cw	: natural := 6 -- TODO: Nossa ALU usa opcodes menores! Precisamos refatorar a bagaca!
		);
		port(
			SrcA		: in std_logic_vector(W-1 downto 0);
			SrcB		: in std_logic_vector(W-1 downto 0);
			AluControl	: in std_logic_vector(2 downto 0);
			AluResult	: out std_logic_vector(W-1 downto 0);
			Zero		: out std_logic;
			Overflow	: out std_logic;
			CarryOut	: out std_logic
		);
	end component;

begin

	---------
	-- ALU -- 
	---------
	SrcAE <= RD1D;
	SrcBE <= RD2D when ALUSrcE = '0' else SignImmD; -- Isso podia ser um Mux, mas eu sou rebelde.

	-- Nao precisamos dos ultimos sinais, era pra ser Overflow e CarryOut
	alu_0: ALU port map (SrcAE,SrcBE,AluControlD,AluOutE,ZeroE,null,null);

	-- Outros
	WriteDataE	<= R2D2;
	WriteRegE 	<= RtD when RegDstD = '0' else RdD; -- outro mux
	
	-- Shift Left Like a Boss: DDCA.pdf, pag 423
	PCBranchE <= (SignImmE(29 downto 0) & "00") + PCPlus4D;

end;
