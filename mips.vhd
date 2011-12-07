library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity mips is 
	generic(
		nbits : positive := 32
	);
	port(
		-- A simulacao ira funcionar da seguinte maneira
		-- 1. O sinal reset serah ligado, para colocar o datapath no estado
		--    inicial. Isso inclui resetar o RegFile e colocar o PC = 0.
		-- 2. Agora podemos executar normalmente.

		-- Instruction Memory: Leitura
		Instruction : in std_logic_vector(nbits -1 downto 0);

		-- Data Memory: Leitura	
		Data		: in std_logic_vector(nbits -1 downto 0);

		clk 		: in std_logic;
		reset		: in std_logic;

		-- PCF: Fizemos os jumps / branches corretamente?
		PCF			: out std_logic_vector(nbits -1 downto 0);
		
		-- ALU: A ALU esta funcionando? 
		ALUOutM		: out std_logic_vector(nbits -1 downto 0);

		--  Data Memory: Escrita
		WriteDataM	: out std_logic_vector(nbits -1 downto 0);
		MemWriteM	: out std_logic
	);
end mips;
  
architecture arc_mips of mips is

component fetch is
	generic(
		nbits	: positive	:= 32
	);
	port(
	
		-- Control Unit
		Jump		: in std_logic;

		-- Instruction
		Instruction  : in std_logic_vector(nbits-1 downto 0);
		InstructionF : out std_logic_vector(nbits-1 downto 0);
		
		-- Decode
		PCBranchD	: in std_logic_vector(nbits-1 downto 0);	-- Endereço da instrução para pular caso haja BRANCH
		PCJump28D	: in std_logic_vector(nbits-5 downto 0); 	-- 28bits do endereço para pular caso haja JUMP
		PCSrcD		: in std_logic;								-- Indica se deve ocorrer o BRANCH
		FPCPlus4	: out std_logic_vector(nbits-1 downto 0);	-- PC+4 que é passado para o Decode
		PCFF		: out std_logic_vector(nbits-1 downto 0);	-- saída na especificação do MIPS (endereço da instrução atual)
		
		-- Aux
		clk			: in std_logic;
		reset		: in std_logic;

		Data		: in std_logic_vector(nbits-1 downto 0);	-- Data de entrada
		DataF		: out std_logic_vector(nbits-1 downto 0)	-- Data de saída
		
	);
end component;	


component decode is
	generic(
		nbits	: positive	:= 32
	);
	port(
		clk			: in std_logic;

		-- Preciosa instrucao
		InstrD		: in std_logic_vector(nbits-1 downto 0);

		-- Repassando o PCPlus4
		PCPlus4F	: in std_logic_vector(nbits-1 downto 0);

		-- RegFile: sinal de enable, vem do Writeback		
		RegWriteW	: in std_logic;
		WriteRegW	: in std_logic_vector(4 downto 0); 

		-- RegFile: sinal de WD3
		ResultW		: in std_logic_vector(nbits-1 downto 0);

		-- RegFile: saidas
		RD1D		: out std_logic_vector(nbits-1 downto 0);
		RD2D		: out std_logic_vector(nbits-1 downto 0);
		RtD			: out std_logic_vector(4 downto 0);
		RdD			: out std_logic_vector(4 downto 0);

		-- SignExtender
		SignImmD	: out std_logic_vector(nbits-1 downto 0);

		-- ControlUnit: Saidas
		RegWriteD	: out std_logic;
		MemtoRegD	: out std_logic;
		MemWriteD	: out std_logic;
		ALUControlD	: out std_logic_vector (3 downto 0);
		ALUSrcD		: out std_logic;
		RegDstD		: out std_logic_vector(1 downto 0);
		JumpD		: out std_logic;
		JalD		: out std_logic;

		-- PC
		PCSrcD		: out std_logic;
		PCBranchD	: out std_logic_vector(nbits-1 downto 0);
		PCJump28D 	: out std_logic_vector(nbits-5 downto 0);
		
		-- Reset
		reset		: in std_logic;

		DataF		: in std_logic_vector(nbits-1 downto 0);	-- Data de entrada
		DataD		: out std_logic_vector(nbits-1 downto 0)	-- Data de saída

	);
end component;	

component execute is
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

		DataD		: in std_logic_vector(nbits-1 downto 0);	-- Data de entrada
		DataE		: out std_logic_vector(nbits-1 downto 0)	-- Data de saída
		
	);
end component;


component memory is
	generic(
		nbits	: positive	:= 32
	);
	port(
		clk			: in std_logic;

		-- Control Unit
		RegWriteE	: in std_logic;
		MemtoRegE	: in std_logic;
		MemWriteE	: in std_logic;
		RegWriteM	: out std_logic;
		MemtoRegM	: out std_logic;

		-- ALU
		ZeroE		: in std_logic;
		AluOutE		: in std_logic_vector(31 downto 0);
		AluOutM		: out std_logic_vector(31 downto 0);

		-- RegFile 
		WriteDataE	: in std_logic_vector(31 downto 0);
		WriteRegE	: in std_logic_vector(4 downto 0);
		WriteRegM	: out std_logic_vector(4 downto 0);

		-- Memory
		ReadDataM	: out std_logic_vector(31 downto 0);

		-- Migué de receber a memory direto da entrada do MIPS
		Data		: in std_logic_vector(31 downto 0);
		
		-- Saída da escrita
		WriteDataM	: out std_logic_vector(31 downto 0);
		
		-- Reset
		reset		: in std_logic
		
	);
end component;


component writeback is
	generic(
		nbits	: positive	:= 32
	);
	port(
		clk			: in std_logic;

		-- Control Unit
		RegWriteM	: in std_logic;
		MemtoRegM	: in std_logic;
		RegWriteW	: out std_logic;

		-- ALU
		AluOutM		: in std_logic_vector(31 downto 0);
		ResultW		: out std_logic_vector(31 downto 0);

		-- RegFile
		WriteRegM	: in std_logic_vector(4 downto 0);
		WriteRegW	: out std_logic_vector(4 downto 0);

		-- Memory
		ReadDataM	: in std_logic_vector(31 downto 0);
		
		-- Reset
		reset		: in std_logic
	);
end component;

-----------------------------------------------------------

-----------------------------------------------------------


--- FETCH ---
-- Entradas do Fetch
signal F_InstructionF	: std_logic_vector(nbits-1 downto 0);
signal Jump_F			: std_logic;
signal PCBranchD_F		: std_logic_vector(nbits-1 downto 0);
signal PCJump28D_F		: std_logic_vector(nbits-5 downto 0);
signal PCSrcD_F			: std_logic;
-- Saidas do Fetch
signal F_FPCPlus4		: std_logic_vector(nbits-1 downto 0);
signal F_PCFF			: std_logic_vector(nbits-1 downto 0);
signal F_DataF			: std_logic_vector(nbits-1 downto 0);
	
--- DECODE ---
-- Entradas do Decode
signal InstructionF_D 	: std_logic_vector(nbits-1 downto 0);
signal PCPlus4F_D		: std_logic_vector(nbits-1 downto 0);
signal RegWriteW_D		: std_logic;
signal WriteRegW_D		: std_logic_vector(4 downto 0);
signal ResultW_D		: std_logic_vector(nbits-1 downto 0);
signal DataF_D			: std_logic_vector(nbits-1 downto 0);
-- Saídas do Decode
signal D_RD1D			: std_logic_vector(nbits-1 downto 0);
signal D_RD2D			: std_logic_vector(nbits-1 downto 0);
signal D_RtD			: std_logic_vector(4 downto 0);
signal D_RdD			: std_logic_vector(4 downto 0);
signal D_SignImmD		: std_logic_vector(nbits-1 downto 0);
signal D_RegWriteD		: std_logic;
signal D_MemtoRegD		: std_logic;
signal D_MemWriteD		: std_logic;
signal D_ALUControlD	: std_logic_vector (3 downto 0);
signal D_ALUSrcD		: std_logic;
signal D_RegDstD		: std_logic_vector(1 downto 0);
signal D_JumpD			: std_logic;
signal D_JalD			: std_logic;
signal D_PCSrcD			: std_logic;
signal D_PCBranchD		: std_logic_vector(nbits-1 downto 0);
signal D_PCJump28D		: std_logic_vector(nbits-5 downto 0);
signal D_DataD			: std_logic_vector(nbits-1 downto 0);

--- EXECUTE ----
-- Entradas do Execute
signal RegWriteD_E		: std_logic;
signal MemtoRegD_E		: std_logic;
signal MemWriteD_E		: std_logic;
signal ALUControlD_E	: std_logic_vector(3 downto 0);
signal ALUSrcD_E		: std_logic;
signal RegDstD_E		: std_logic_vector(1 downto 0);
signal RD1D_E			: std_logic_vector(31 downto 0);
signal RD2D_E			: std_logic_vector(31 downto 0);
signal RtD_E			: std_logic_vector(4 downto 0);
signal RdD_E			: std_logic_vector(4 downto 0);
signal SignImmD_E		: std_logic_vector(nbits-1 downto 0);
signal DataD_E			: std_logic_vector(nbits-1 downto 0);

-- Saídas do Execute
signal E_RegWriteE		: std_logic;
signal E_MemtoRegE		: std_logic;
signal E_MemWriteE		: std_logic;
signal E_ZeroE			: std_logic;
signal E_AluOutE		: std_logic_vector(31 downto 0);
signal E_WriteDataE		: std_logic_vector(31 downto 0);
signal E_WriteRegE		: std_logic_vector(4 downto 0);
signal E_DataE			: std_logic_vector(nbits-1 downto 0);

--- MEMORY ---
signal RegWriteE_M	: std_logic;
signal MemtoRegE_M	: std_logic;
signal MemWriteE_M	: std_logic;
signal M_RegWriteM	: std_logic;
signal M_MemtoRegM	: std_logic;
signal ZeroE_M		: std_logic;
signal AluOutE_M	: std_logic_vector(31 downto 0);
signal M_AluOutM	: std_logic_vector(31 downto 0);
signal WriteDataE_M	: std_logic_vector(31 downto 0);
signal WriteRegE_M	: std_logic_vector(4 downto 0);
signal M_WriteRegM	: std_logic_vector(4 downto 0);
signal M_ReadDataM	: std_logic_vector(31 downto 0);
signal Data_M		: std_logic_vector(31 downto 0);
signal M_WriteDataM	: std_logic_vector(31 downto 0);
signal DataE_M		: std_logic_vector(31 downto 0);

-- WRITEBACK ---
-- Control Unit
signal RegWriteM_W	: std_logic;
signal MemtoRegM_W	: std_logic;
signal W_RegWriteW	: std_logic;
signal AluOutM_W	: std_logic_vector(31 downto 0);
signal W_ResultW	: std_logic_vector(31 downto 0);
signal WriteRegM_W	: std_logic_vector(4 downto 0);
signal W_WriteRegW	: std_logic_vector(4 downto 0);
signal ReadDataM_W	: std_logic_vector(31 downto 0);


begin
	
fetch_0: Fetch port map(Jump_F, Instruction, F_InstructionF, PCBranchD_F, PCJump28D_F, PCSrcD_F, F_FPCPlus4, F_PCFF, clk, reset, Data, F_DataF);

decode_0: Decode port map(clk, InstructionF_D, PCPlus4F_D, RegWriteW_D, WriteRegW_D, ResultW_D, D_RD1D, D_RD2D, D_RtD, D_RdD, D_SignImmD, D_RegWriteD, D_MemtoRegD, D_MemWriteD, D_ALUControlD, D_ALUSrcD, D_RegDstD, D_JumpD, D_JalD, D_PCSrcD, D_PCBranchD, D_PCJump28D, reset, DataF_D, D_DataD);

execute_0: Execute port map(clk, RegWriteD_E, MemtoRegD_E, MemWriteD_E, ALUControlD_E, ALUSrcD_E, RegDstD_E, E_RegWriteE, E_MemtoRegE, E_MemWriteE, E_ZeroE, E_AluOutE, RD1D_E, RD2D_E, RtD_E, RdD_E, E_WriteDataE, SignImmD_E, E_WriteRegE, reset, DataD_E, E_DataE);

memory_0: Memory port map(clk, RegWriteE_M, MemtoRegE_M, MemWriteE_M, M_RegWriteM, M_MemtoRegM, ZeroE_M, AluOutE_M, M_AluOutM, WriteDataE_M, WriteRegE_M, M_WriteRegM, M_ReadDataM, DataE_M, M_WriteDataM, reset);

writeback_0: Writeback port map(clk, RegWriteM_W, MemtoRegM_W, W_RegWriteW, AluOutM_W, W_ResultW, WriteRegM_W, W_WriteRegW, ReadDataM_W, reset);


process(clk)
begin 
	WriteDataM		<= M_WriteDataM;

	if clk'EVENT and clk = '1' then
	
		-- TO FETCH
		PCBranchD_F <= D_PCBranchD;
		PCJump28D_F <= D_PCJump28D;
		PCSrcD_F 	<= D_PCSrcD;
		Jump_F 		<= D_JumpD;

		-- TO DECODE
		InstructionF_D	<= F_InstructionF;
		PCPlus4F_D		<= F_FPCPlus4;
		RegWriteW_D		<= W_RegWriteW;
		WriteRegW_D		<= W_WriteRegW;
		ResultW_D		<= W_ResultW;
		DataF_D			<= F_DataF;
		
		-- TO EXECUTE
		RegWriteD_E		<= D_RegWriteD;
		MemtoRegD_E		<= D_MemtoRegD;
		MemWriteD_E		<= D_MemWriteD;
		ALUControlD_E	<= D_ALUControlD;
		ALUSrcD_E		<= D_ALUSrcD;
		RegDstD_E		<= D_RegDstD;
		RD1D_E			<= D_RD1D;
		RD2D_E			<= D_RD2D;
		RtD_E			<= D_RtD;
		RdD_E			<= D_RdD;
		SignImmD_E		<= D_SignImmD;
		DataD_E			<= D_DataD;
		
		-- TO MEMORY
		RegWriteE_M		<= E_RegWriteE; 
		MemtoRegE_M		<= E_MemtoRegE;
		MemWriteE_M		<= E_MemWriteE;
		ZeroE_M			<= E_ZeroE;
		AluOutE_M		<= E_AluOutE;
		WriteDataE_M	<= E_WriteDataE;
		WriteRegE_M		<= E_WriteRegE;
		DataE_M			<= E_DataE;
		

		-- TO WRITEBACK
		RegWriteM_W 	<= M_RegWriteM;
		MemtoRegM_W		<= M_MemtoRegM;
		AluOutM_W 		<= M_AluOutM;
		WriteRegM_W		<= M_WriteRegM;
		ReadDataM_W		<= M_ReadDataM;




	end if;
end process;

end;
