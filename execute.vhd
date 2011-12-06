library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity execute is
	generic(
		nbits	: positive	:= 32
	);
	port(
		clk		: in std_logic;

		-- Control Unit: Entradas
		RegWriteD	: in std_logic;
		MemtoRegD	: in std_logic;
		MemWriteD	: in std_logic;
		ALUControlD	: in std_logic_vector(3 downto 0);
		ALUSrcD		: in std_logic;
		RegDstD		: in std_logic_vector(1 downto 0);

		-- Control Unit: Saidas
		RegWriteE	: out std_logic;
		MemtoRegE	: out std_logic;
		MemWriteE	: out std_logic;

		-- ALU
		ZeroE		: out std_logic;
		AluOutE		: out std_logic_vector(31 downto 0);

		-- RegisterFile
		RD1D		: in std_logic_vector(31 downto 0);
		RD2D		: in std_logic_vector(31 downto 0);

		-- RegFile
		RtD			: in std_logic_vector(4 downto 0);
		RdD			: in std_logic_vector(4 downto 0);
		WriteDataE	: out std_logic_vector(31 downto 0);

		-- Sign Extend
		SignImmD	: in std_logic_vector(nbits-1 downto 0);
		WriteRegE	: out std_logic_vector(4 downto 0);
		
		-- Reset
		reset		: in std_logic;
		
	);
end execute;

architecture execute_arc of execute is
	
	-- ALU --
	signal SrcAE		: std_logic_vector(31 downto 0);
	signal SrcBE		: std_logic_vector(31 downto 0);
	signal AluControlE	: std_logic_vector(2 downto 0); 
	signal IGNORE		: std_logic;

	component ALU is
		generic(
			W	: natural := 32; 
			Cw	: natural := 6 -- TODO: Nossa ALU usa opcodes menores! Precisamos refatorar a bagaca!
		);
		port(
			SrcA		: in std_logic_vector(W-1 downto 0);
			SrcB		: in std_logic_vector(W-1 downto 0);
			AluControl	: in std_logic_vector(3 downto 0);
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
	SrcBE <= RD2D when ALUSrcD = '0' else SignImmD; -- Isso podia ser um Mux, mas eu sou rebelde.

	-- Ignorando os ultimos dois sinais: Overflow e CarryOut
	alu_0: ALU port map (SrcAE,SrcBE,AluControlD,AluOutE,ZeroE,IGNORE,IGNORE);

	-- RegFile
	WriteDataE	<= RD2D;
	WriteRegE 	<= RtD when RegDstD = "00" else RdD; -- outro mux

end;
