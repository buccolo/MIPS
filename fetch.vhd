library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity fetch is
	generic(
		nbits	: positive	:= 32
	);
	port(
	
		-- Control Unit
		Jump		: in std_logic;
		
		-- Instruction
		Instruction	: in std_logic_vector(nbits-1 downto 0);
		InstructionF: out std_logic_vector(nbits-1 downto 0);
		
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
end fetch;	
	
architecture fetch_arc of fetch is

component reg is 
	generic(
		nbits : positive := 32
	);
	port(
		clk, reset	: in STD_LOGIC;
		d			: in STD_LOGIC_VECTOR(nbits-1 downto 0);
		q			: out STD_LOGIC_VECTOR(nbits-1 downto 0)
	);
end component;

component mux2 is
	generic(
		nbits	: positive := 32
	);
	port(
		d0, d1	: in STD_LOGIC_VECTOR(nbits-1 downto 0);
		s		: in STD_LOGIC;
		y		: out STD_LOGIC_VECTOR(nbits-1 downto 0)
	);
end component;


-- Sinais auxiliares.
signal PC			: std_logic_vector(nbits-1 downto 0);
signal PCLinha		: std_logic_vector(nbits-1 downto 0);
signal PCPlus4		: std_logic_vector(nbits-1 downto 0);
signal PCAux		: std_logic_vector(nbits-1 downto 0);
signal PCJump32		: std_logic_vector(nbits-1 downto 0);

begin

	PCJump32	<= PCPlus4(31 downto 28) & PCJump28D; -- Completa o endereço alvo do Jump 

	pcreg	: reg port map(clk, reset, PCLinha, PC);	-- Registrador que passa do PC' para o PCF na subida do relógio
	beq		: mux2 port map(PCPlus4, PCBranchD, PCSrcD, PCAux);	-- Mux que decide se é branch
	jumpMux	: mux2 port map(PCAux, PCJump32, Jump, PCLinha);		-- Mux que decide se é Jump
	
	PCFF <= PC;
	
	InstructionF	<= Instruction;	-- Passa a instrução para frente
	
	PCPlus4 <= PC + 4; -- Calcula a próxima instrução caso não seja beq nem jump
	FPCPlus4 <= PCPlus4;
	
	DataF <= Data;
	
	process(clk) begin
	
	if (clk'event and clk = '1') then
		if reset = '1' then	-- Caso seja reset, coloca 0 no PCSrcD e no Jump (não é branch e nem Jump).
			PCSrcDAux	<= '0';
			JumpAux		<= '0';
		end if;
	end if;
	
	end process;
	
end;
