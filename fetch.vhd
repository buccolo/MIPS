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
		reset		: in std_logic
		
		
		
	);
end fetch;	
	
architecture fetch_arc of fetch is
	-- Auxiliar para guardar o PC+4
	signal PCPlus4	: std_logic_vector(nbits-1 downto 0);
	
	-- Guarda o próximo PC
	signal PClinha	: std_logic_vector(nbits-1 downto 0);
	
	-- Caso o PC seja o próximo (+4) ou através de Branch
	signal PCNormal	: std_logic_vector(nbits-1 downto 0);
	
	-- Caso haja um Jump
	signal PCJump	: std_logic_vector(nbits-1 downto 0);
	
	-- PCF auxiliar
	signal PCF		: std_logic_vector(nbits-1 downto 0);
	
	component mux2
		port(
			d0, d1	: in STD_LOGIC_VECTOR(nbits downto 0);
			s		: in STD_LOGIC;
			y		: out STD_LOGIC_VECTOR(nbits downto 0)
		);
	end component;
	
begin
	
	-- calculando PC + 4 (na variavel auxiliar e já passando para a saída)
	PCPlus4 <= PCF + 4;
	FPCPlus4 <= PCPlus4;
	
	InstructionF <= Instruction;
	
	PCFF <= PCF;
	
	-- mux para decidir se o branch deve ser tomado
	pcnorm	: mux2 port map (PCPlus4, PCBranchD, PCSrcD, PCNormal);
	
	-- Calcula o endereço para o PC caso haja um Jump
	PCJump <= PCPlus4(nbits-1 downto nbits-5) & PCJump28D;
	
	-- Mux para decidir se é um Jump (a saída é o PC', que é o próximo endereço)
	pc		: mux2 port map (PCNormal, PCJump, Jump, PCLinha);
	
	
	process(clk) begin
	
		if(reset = '1') then
			PCLinha <= CONV_STD_LOGIC_VECTOR(0, nbits); 			-- TODO: pode estar errado..
		end if;
	
		-- Rising Edge of the clock
		if(clk'event and clk = '1') then
		
			-- Atualiza o próximo endereço em PCF com o que estava em PC' (registrador)
			PCF <= PClinha;
	
		end if;	
	
	end process;

end;
