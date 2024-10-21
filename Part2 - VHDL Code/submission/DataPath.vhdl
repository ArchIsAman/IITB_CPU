library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Components.all;

entity DataPath is
	port(clk: in std_logic; 
	     state: in std_logic_vector(3 downto 0); 
		  z_out: out std_logic;
		  opcode: out std_logic_vector(3 downto 0));
end entity Datapath;

architecture trivial of DataPath is

	signal alu_a, alu_b, alu_out,ir_in, t1_in,t1_out,t2_in,t2_out,t3_in,t3_out,t5_in,t5_out,rf_d1, rf_d2, rf_d3, se_combined_out, shifter_in,shifter_out, mem_add, mem_in, mem_out: std_logic_vector(15 downto 0):=(others=>'0');
	signal rf_a1, rf_a2, rf_a3, t4_in, t4_out, ir_11_9, ir_8_6, ir_5_3,alu_ctrl: std_logic_vector(2 downto 0):=(others=>'0');
	signal ir_8_0,se_combined_in_9: std_logic_vector(8 downto 0);
	signal ir_5_0,se_combined_in_6: std_logic_vector(5 downto 0);
	signal ir_15_12:std_logic_vector(3 downto 0):=(others=>'0');
	signal shift_signal,SE_signal:std_logic_vector(1 downto 0):=(others=>'0');
	signal t1_wr, t2_wr, t3_wr, t4_wr, t5_wr, ir_wr, m_rd, m_wr, rf_wr,c_in: std_logic;

	constant state1  : std_logic_vector(3 downto 0):= "0001";  
	constant state2  : std_logic_vector(3 downto 0):= "0010";
	constant state3  : std_logic_vector(3 downto 0):= "0011";
	constant state4  : std_logic_vector(3 downto 0):= "0100";
	constant state5  : std_logic_vector(3 downto 0):= "0101";
	constant state6  : std_logic_vector(3 downto 0):= "0110";
	constant state7  : std_logic_vector(3 downto 0):= "0111";
	constant state8  : std_logic_vector(3 downto 0):= "1000";
	constant state9  : std_logic_vector(3 downto 0):= "1001";  
	constant state10 : std_logic_vector(3 downto 0):= "1010";
	constant state11 : std_logic_vector(3 downto 0):= "1011";
	constant state12 : std_logic_vector(3 downto 0):= "1100";

	constant state_reset : std_logic_vector(3 downto 0):= "0000";
	
	begin

		instr_reg: component instruction_register
			port map(ir_in, ir_wr, clk, ir_15_12, ir_11_9, ir_8_6, ir_5_3, ir_5_0,ir_8_0);
			
		T1: component bit16_register
			port map(t1_in,"0000000000000000" ,t1_wr, clk, t1_out);
			
		T2: component bit16_register
			port map(t2_in,"0000000000000000",t2_wr, clk, t2_out);
			
		T3: component bit16_register
			port map(t3_in,"0000000000000000",t3_wr, clk, t3_out);
			
		T5: component bit16_register
			port map(t5_in,"0000000000000000" ,t5_wr, clk, t5_out);

		T4: component bit3_register
			port map(t4_in,"000", t4_wr, clk, t4_out);
		
		reg_file: component register_file
			port map(rf_a1,rf_a2,rf_a3,rf_d1,rf_d2,rf_d3,clk,'1',rf_wr);

		ext: component SE_combined
			port map(se_combined_in_6,se_combined_in_9,SE_signal,se_combined_out);
		
		shift: component SHIFTER
			port map(shifter_in,shift_signal(1),shift_signal(0),shifter_out);
						
		mem: component Memory
			port map(clk,'0', m_wr, m_rd, mem_add, mem_in, mem_out);
			
		alu_comp: component ALU
			port map(alu_a, alu_b, alu_ctrl, alu_out, z_out, c_in);
			
only_process: process(state, rf_d1, mem_out, alu_out, t5_out, t4_out, rf_d2, shifter_out,se_combined_out,t3_out,t2_out,t1_out,ir_11_9,ir_8_6,ir_5_3,ir_15_12,ir_8_0,ir_5_0)
		begin
case state is
				when state1 =>
					--Data Flow
					rf_a1<="111";
					if to_integer(unsigned(rf_d1)) < 512 then --to avoid problems caused by LW
					mem_add<=rf_d1;
					else
					mem_add<="0000000000000000";
					end if;
					alu_a<=rf_d1;
					ir_in<=mem_out;
					alu_b<="0000000000000010";
					rf_d3<=alu_out;
					rf_a3<="111";
					t5_in<=alu_out;
					opcode<=mem_out(15 downto 12);
					
					--Control Signals
					rf_wr<='1';
					m_wr<='0';
					m_rd<='1';
					t1_wr<='0';
					t2_wr<='0';
					t3_wr<='0';
					t4_wr<='0';
					t5_wr<='1';
					ir_wr<='1';
					alu_ctrl<="000";
               shift_signal<="XX";
					SE_signal<="00";
					
				when state2 =>
					--Data Flow
					rf_a1<=ir_11_9;
					rf_a2<=ir_8_6;
					t1_in<=rf_d1;
					t2_in<=rf_d2;
					t4_in<=ir_5_3;
					opcode<=ir_15_12;
					
					--Control Signals
					rf_wr<='0';
					m_wr<='0';
					m_rd<='0';
					t1_wr<='1';
					t2_wr<='1';
					t3_wr<='0';
					t4_wr<='1';
					t5_wr<='0';
					ir_wr<='0';
					alu_ctrl<="XXX";
               shift_signal<="XX";
					SE_signal<="00";
					
				when state3 =>
					--Data Flow
					alu_a<=t1_out;
					alu_b<=t2_out;
					t3_in<=alu_out;
					opcode<=ir_15_12;
					
					--Control Signal
					rf_wr<='0';
					m_wr<='0';
					m_rd<='0';
					t1_wr<='0';
					t2_wr<='0';
					t3_wr<='1';
					t4_wr<='0';
					t5_wr<='0';
					ir_wr<='0';
					alu_ctrl<=(2=> ir_15_12(2) and (ir_15_12(0) or ir_15_12(1)),1=>(ir_15_12(0) and ir_15_12(1)) or ((not ir_15_12(3)) and ir_15_12(2) and (not ir_15_12(1)) and (not ir_15_12(0))),0=>(not ir_15_12(0)) and (ir_15_12(1) or ir_15_12(2)));--add operation
               shift_signal<="XX";
					SE_signal<="00";
					
				when state4 =>
					--Data Flow
					rf_d3<=t3_out;
					rf_a3<=t4_out;
					opcode<=ir_15_12;
					
					--Control Signals
					rf_wr<='1';
					m_wr<='0';
					m_rd<='0';
					t1_wr<='0';
					t2_wr<='0';
					t3_wr<='0';
					t4_wr<='0';
					t5_wr<='0';
					ir_wr<='0';
					alu_ctrl<="XXX";
               shift_signal<="XX";
					SE_signal<="00";
					
				when state5 =>
					--Data Flow
					shifter_in<= "0000000" & ir_8_0;
					t3_in<=shifter_out;
				   t4_in<=ir_11_9;
					opcode<=ir_15_12;
					
					--Control Signals
					rf_wr<='0';
					m_wr<='0';
					m_rd<='0';
					t1_wr<='0';
					t2_wr<='0';
					t3_wr<='1';
					t4_wr<='1';
					t5_wr<='0';
					ir_wr<='0';
					alu_ctrl<="XXX";
               shift_signal<=(1=>ir_15_12(0),0=>ir_15_12(0));
					SE_signal<="00";
					
				when state6 =>
					--Data Flow
					rf_a1<=ir_11_9;
					t1_in<=rf_d1;
					t4_in<=ir_8_6;
					se_combined_in_6<=ir_5_0;
					t2_in<=se_combined_out;
					opcode<=ir_15_12;
					
					--Control Signals
               rf_wr<='0';
					m_wr<='0';
					m_rd<='0';
					t1_wr<='1';
					t2_wr<='1';
					t3_wr<='0';
					t4_wr<='1';
					t5_wr<='0';
					ir_wr<='0';
					alu_ctrl<="XXX";
               shift_signal<="XX";
					SE_signal<="01";
					
				when state7 =>
					--Data Flow
					t4_in<=ir_11_9;
					se_combined_in_6<=ir_5_0;
					alu_a<=se_combined_out;
					rf_a2<=ir_8_6;
					alu_b<=rf_d2;
					t3_in<=alu_out;
					rf_a1<=ir_11_9;
					t1_in<=rf_d1;
					opcode<=ir_15_12;

					--Control Signals
               rf_wr<='0';
					m_wr<='0';
					m_rd<='0';
					t1_wr<='1';
					t2_wr<='0';
					t3_wr<='1';
					t4_wr<='1';
					t5_wr<='0';
					ir_wr<='0';
					alu_ctrl<="000";
               shift_signal<="XX";
					SE_signal<="01";
					
				when state8 =>
					--Data Flow
					mem_add<=t3_out;
					t3_in<=mem_out;
					opcode<=ir_15_12;
					
					--Control Signals
               rf_wr<='0';
					m_wr<='0';
					m_rd<='1';
					t1_wr<='0';
					t2_wr<='0';
					t3_wr<='1';
					t4_wr<='0';
					t5_wr<='0';
					ir_wr<='0';
					alu_ctrl<="XXX";
               shift_signal<="XX";
					SE_signal<="00";
					
				when state9 =>
					--Data Flow
					mem_in<=t1_out;
					mem_add<=t3_out;
					opcode<=ir_15_12;
					
					--Control Signals
               rf_wr<='0';
					m_wr<='1';
					m_rd<='0';
					t1_wr<='0';
					t2_wr<='0';
					t3_wr<='0';
					t4_wr<='0';
					t5_wr<='0';
					ir_wr<='0';
					alu_ctrl<="XXX";
               shift_signal<="XX";
					SE_signal<="00";
					
				when state10 =>
					--Data Flow
					alu_a<=t5_out;
					se_combined_in_6<=ir_5_0;
					se_combined_in_9<=ir_8_0;
					shifter_in<=se_combined_out;
					alu_b<=shifter_out;
					rf_d3<=alu_out;
					rf_a3<="111";
					opcode<=ir_15_12;
					
					--Control Signals
               rf_wr<='1';
					m_wr<='0';
					m_rd<='0';
					t1_wr<='0';
					t2_wr<='0';
					t3_wr<='0';
					t4_wr<='0';
					t5_wr<='0';
					ir_wr<='0';
					alu_ctrl<="000";
               shift_signal<="01";
					SE_signal<=(1=>ir_15_12(0),0=>ir_15_12(2));
					
				when state11 =>
					--Data Flow
					rf_a3<=ir_11_9;
					rf_d3<=t5_out;
					opcode<=ir_15_12;

					--Control Signals
               rf_wr<='1';
					m_wr<='0';
					m_rd<='0';
					t1_wr<='0';
					t2_wr<='0';
					t3_wr<='0';
					t4_wr<='0';
					t5_wr<='0';
					ir_wr<='0';
					alu_ctrl<="XXX";
               shift_signal<="XX";
					SE_signal<="00";
					
				when state12 =>
					--Data Flow
					rf_a2<=ir_8_6;
					rf_d3<=rf_d2;
					rf_a3<="111";
					opcode<=ir_15_12;

					--Control Signals
               rf_wr<='1';
					m_wr<='0';
					m_rd<='0';
					t1_wr<='0';
					t2_wr<='0';
					t3_wr<='0';
					t4_wr<='0';
					t5_wr<='0';
					ir_wr<='0';
					alu_ctrl<="XXX";
               shift_signal<="XX";
					SE_signal<="00";
					
				when others =>
					opcode<=ir_15_12;
					--Control Signals
					rf_wr<='0';
					m_wr<='0';
					m_rd<='0';
					t1_wr<='0';
					t2_wr<='0';
					t3_wr<='0';
					t4_wr<='0';
					t5_wr<='0';
					ir_wr<='0';
					alu_ctrl<="XXX";
               shift_signal<="XX";
					SE_signal<="00";
			end case;
		end process;
		end architecture trivial;