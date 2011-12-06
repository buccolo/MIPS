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


component ALU is 
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

end component;


component fetch is
	generic(
		nbits	: positive	:= 32
	);
	port(
	
		-- Control Unit
		Jump		: in std_logic;
		
		-- Decode
		PCBranchD	: in std_logic_vector(nbits-1 downto 0);	-- Endereço da instrução para pular caso haja BRANCH
		PCJump28D	: in std_logic_vector(nbits-5 downto 0); 	-- 28bits do endereço para pular caso haja JUMP
		PCSrcD		: in std_logic;								-- Indica se deve ocorrer o BRANCH
		FPCPlus4	: out std_logic_vector(nbits-1 downto 0);	-- PC+4 que é passado para o Decode
		PCFF		: out std_logic_vector(nbits-1 downto 0);	-- saída na especificação do MIPS (endereço da instrução atual)
		
		-- Aux
		clk			: in std_logic;
		reset		: in std_logic
		
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
		RegDstD		: out std_logic_vector(1 downto 0);;
		JumpD		: out std_logic;
		JalD		: out std_logic;

		-- PC
		PCSrcD		: out std_logic;
		PCBranchD	: out std_logic

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
		RegDstD		: in std_logic_vector(1 downto 0);;

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
		WriteRegE	: out std_logic_vector(4 downto 0)
		
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
		Data		: in std_logic_vector(31 downto 0)
		
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
		ReadDataM	: in std_logic_vector(31 downto 0)
	);
end component;

begin

end;
