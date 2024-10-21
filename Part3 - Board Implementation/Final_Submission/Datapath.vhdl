library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Components.all;

entity DataPath is
	port(clk: in std_logic;  
		  reset: in std_logic;
		  switch: in std_logic_vector(7 downto 0);
		  mem_dp_out: out std_logic_vector(15 downto 0);
		  reg_dp_out: out std_logic_vector(15 downto 0);
		  z_dp_out: out std_logic
		  );
end entity Datapath;

architecture trivial of DataPath is

	signal alu_a, alu_b, alu_out,ir_in, t1_in,t1_out,t2_in,t2_out,t3_in,t3_out,t5_in,t5_out,rf_d1,
		rf_d2, rf_d3, se_combined_out, shifter_in,shifter_out, mem_add, mem_in, mem_out, mem_dp_temp_out,
		state2_ir_11_9_out,state2_ir_8_6_out,state2_ir_5_3_out: std_logic_vector(15 downto 0);
	signal rf_a1, rf_a2, rf_a3, t4_in, t4_out, ir_11_9, ir_8_6, ir_5_3,alu_ctrl: std_logic_vector(2 downto 0);
	signal ir_8_0,se_combined_in_9: std_logic_vector(8 downto 0);
	signal ir_5_0,se_combined_in_6: std_logic_vector(5 downto 0);
	signal ir_15_12:std_logic_vector(3 downto 0);
	signal shift_signal,SE_signal:std_logic_vector(1 downto 0);
	signal t1_wr, t2_wr, t3_wr, t4_wr, t5_wr, ir_wr, m_rd, m_wr, rf_wr,c_out: std_logic;
	signal state: std_logic_vector(3 downto 0);
	signal opcode: std_logic_vector(3 downto 0);
	signal z_out: std_logic:='0'; 

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
   constant state13 : std_logic_vector(3 downto 0):= "1101";
	constant state_reset : std_logic_vector(3 downto 0):= "0000";
	
--	constant state1 : std_logic_vector(3 downto 0):= "0001";
--	constant state2 : std_logic_vector(3 downto 0):= "0010";
--	constant state3 : std_logic_vector(3 downto 0):= "0011";
--	constant state4 : std_logic_vector(3 downto 0):= "0100";
--	constant state5 : std_logic_vector(3 downto 0):= "0101";
--	constant state6 : std_logic_vector(3 downto 0):= "0110";
--	constant state7 : std_logic_vector(3 downto 0):= "0111";
--	constant state8 : std_logic_vector(3 downto 0):= "1000";
--	constant state9 : std_logic_vector(3 downto 0):= "1001";
--	constant state10 : std_logic_vector(3 downto 0):= "1010";
--	constant state11 : std_logic_vector(3 downto 0):= "1011";
--	constant state12 : std_logic_vector(3 downto 0):= "1100";
--	constant state13 : std_logic_vector(3 downto 0):= "1101";
	
	signal s_present : std_logic_vector(3 downto 0) := state13;
	signal s_next : std_logic_vector(3 downto 0) := state13;
	
--	component FSM is 
--	port (opcode: in std_logic_vector(3 downto 0);
--			z : in std_logic;
--			reset : in std_logic;
--			clk : in std_logic;
--			output_state : out std_logic_vector(3 downto 0)
--			);
--end component;
	
	begin
		
		z_dp_out <= z_out;
		
		instr_reg: component instruction_register
			port map(ir_in, ir_wr, clk,reset, ir_15_12, ir_11_9, ir_8_6, ir_5_3, ir_5_0,ir_8_0);
			
		T1: component bit16_register
			port map(t1_in,"0000000000000000" ,t1_wr, clk,reset, t1_out);
			
		T2: component bit16_register
			port map(t2_in,"0000000000000000",t2_wr, clk,reset, t2_out);
			
		T3: component bit16_register
			port map(t3_in,"0000000000000000",t3_wr, clk,reset, t3_out);
			
		T5: component bit16_register
			port map(t5_in,"0000000000000000" ,t5_wr, clk,reset, t5_out);

		T4: component bit3_register
			port map(t4_in,"000", t4_wr, clk,reset, t4_out);
		
		reg_file: component register_file
			port map(rf_a1,rf_a2,rf_a3,rf_d1,rf_d2,rf_d3,clk,reset,'1',rf_wr);

		ext: component SE_combined
			port map(se_combined_in_6,se_combined_in_9,SE_signal,se_combined_out);
		
		shift: component SHIFTER
			port map(shifter_in,shift_signal(1),shift_signal(0),shifter_out);
						
		mem: component Memory
			port map(clk,'0', m_wr, m_rd, mem_add, mem_in, mem_out);
			
		alu_comp: component ALU
			port map(alu_a, alu_b, alu_ctrl, alu_out, z_out, c_out);
			
		state2_ir_5_3	: component Multiplexer2to1
			port map(rf_d2,t5_out,ir_5_3,state2_ir_5_3_out);
		
		state2_ir_11_9	: component Multiplexer2to1
			port map(rf_d2,t5_out,ir_11_9,state2_ir_11_9_out);
--			port map(rf_d1,t5_out,ir_11_9,state2_ir_11_9_out);
			
		state2_ir_8_6	: component Multiplexer2to1
			port map(rf_d1,t5_out,ir_8_6,state2_ir_8_6_out);
--			port map(rf_d2,t5_out,ir_8_6,state2_ir_8_6_out);
		
		  state <= s_present;
		
	state_change: process (clk)
	
	begin
		if (clk = '1' and clk'event) then
			s_present <= s_next;
		end if;
	
	end process state_change;

	state_transition: process (s_present, opcode,z_out,reset)
	
	begin
	
	if reset = '1' then
	   s_next <= state13;
	else
		case s_present is
			
			when state1 =>
				case opcode is
					
					when "0000" | "0010" | "0011" | "0100" | "0101" | "0110" | "1100" =>
						s_next <= state2;
						
					when "1000" | "1001" =>
						s_next <= state5;
					
					when "0001" =>
						s_next <= state6;
					
					when "1011" | "1010" =>
						s_next <= state7;
					
					when "1101" =>
						s_next <= state10;
					
					when "1111" =>
						s_next <= state11;
					
					when others =>
						s_next <= state13;
			
					
				end case;
				
			when state2=>
					s_next <= state3;
					
			when state3 =>
				
				if (opcode = "1100") then
					if (z_out = '1') then 
						s_next <= state10;
					else
						s_next <= state13;
					end if;
				elsif (opcode(3) = '0') then
					s_next <= state4;
				else
					s_next <= state13;
				end if;
			
			when state4 =>
				s_next <= state13;
				
			when state5 =>
				s_next <= state4;
			
			when state6 =>
				s_next <= state3;
			
			when state7 => 
				
				case opcode is
					
					when "1010" =>
						s_next <= state8;
					
					when "1011" =>
						s_next <= state9;
					
					when others =>
						s_next <= state13;
				
				end case;
			
			when state8 =>
				s_next <= state4;
			
			when state9 =>
				s_next <= state13;
			
			when state10 => 
				
				case opcode is
					
					when "1100" =>
						s_next <= state13;
					
					when "1101" =>
						s_next <= state11;
					
					when others =>
						s_next <= state13;
			
				end case;
			
			when state11 => 
				
				case opcode is
					
					when "1101" =>
						s_next <= state13;
					
					when "1111" =>
						s_next <= state12;
					
					when others =>
						s_next <= state13;
			
				end case;
			
			when state12 =>
				s_next <= state13;
				
			when state13 =>
				s_next <= state1;
			
			when others =>
				s_next <= state13;
			
				
		end case;
		
	
	end if;
	
	end process state_transition;
		
	only_process: process(alu_b,alu_a,state,reset, rf_d1, mem_out, alu_out, t5_out, t4_out, rf_d2, shifter_out,se_combined_out,
								state2_ir_11_9_out,state2_ir_8_6_out,state2_ir_5_3_out,switch,t3_out,t2_out,t1_out,ir_11_9,ir_8_6,ir_5_3,ir_15_12,ir_8_0,ir_5_0)
		
		begin
		
			alu_a<=(others=>'0');
			alu_b<=(others=>'0');
--			PQR<=(others=>'0');
			t1_IN<=(others=>'0');
			t2_IN<=(others=>'0');
			t3_IN<=(others=>'0');
			t4_IN<=(others=>'0');
			t5_IN<=(others=>'0');
			t1_Wr <= '0';
			t2_Wr <= '0';
			t3_Wr <= '0';
			t4_Wr <= '0';
			t5_Wr <= '0';
			IR_IN<=(others=>'0');
			MEM_IN<=(others=>'0');
			m_wr<='0';
			IR_wr<='0';
			MEM_ADD<=(others=>'0');
			RF_A1<=(others=>'0');
			RF_A2<=(others=>'0');
			RF_A3<=(others=>'0');
			RF_D3<=(others=>'0');
--			IP_update <= (others => '0');
--			MEM_OUT <= (others=>'0');
			OPCODE <= (others=>'0');
			SE_signal<="00";
			Shift_signal<="XX";
			SHIFTER_IN<=(others=>'0');
			se_combined_in_6<=(others=>'0');
			se_combined_in_9<=(others=>'0');
			mem_dp_temp_out<=(others=>'0');
			
			if reset = '1' then
--			            Control signals
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
			
							--Data Flow
							rf_a1<="111";
							if to_integer(unsigned(rf_d1)) < 512 then 
							mem_add<=rf_d1;
							else
							mem_add<="0000000000000000";
							end if;
							alu_a<=rf_d1;
							ir_in<=mem_out;
							alu_b<="0000000000000000";
							rf_d3<=alu_out;
							rf_a3<="111";
							t5_in<=alu_out;
							opcode<=mem_out(15 downto 12);
		else 
			case state is
						when state1 =>
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
							--Data Flow
							rf_a1<="111";
							t5_in<=rf_d1;
							if to_integer(unsigned(rf_d1)) < 512 then 
							mem_add<=rf_d1;
							else
							mem_add<="0000000000000000";
							end if;
							alu_a<=rf_d1;
							ir_in<=mem_out;
							alu_b<="0000000000000001";
							rf_d3<=alu_out;
							rf_a3<="111";
							opcode<=mem_out(15 downto 12);
						when state2 =>
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
							--Data Flow
							rf_a1<=ir_8_6;
							rf_a2<=ir_5_3;
							t1_in<=state2_ir_8_6_out;
							t2_in<=state2_ir_5_3_out;
							t4_in<=ir_11_9;
							opcode<=ir_15_12;
						when state3 =>
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
							--Data Flow
							alu_a<=t1_out;
							alu_b<=t2_out;
							t3_in<=alu_out;
							opcode<=ir_15_12;
						when state4 =>
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
							--Data Flow
							rf_d3<=t3_out;
							rf_a3<=t4_out;
							opcode<=ir_15_12;
						when state5 =>
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
							--Data Flow
							shifter_in<= "0000000" & ir_8_0;
							t3_in<=shifter_out;
							t4_in<=ir_11_9;
							opcode<=ir_15_12;
						when state6 =>
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
							--Data Flow
							rf_a1<=ir_8_6;
							t1_in<=state2_ir_8_6_out;
							t4_in<=ir_11_9;
							se_combined_in_6<=ir_5_0;
							t2_in<=se_combined_out;
							opcode<=ir_15_12;
						when state7 =>
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
							--Data Flow
							t4_in<=ir_11_9;
							se_combined_in_6<=ir_5_0;
							alu_a<=se_combined_out;
							rf_a1<=ir_8_6;
							alu_b<=state2_ir_8_6_out;
							t3_in<=alu_out;
							rf_a2<=ir_11_9;
							t1_in<=state2_ir_11_9_out;
							opcode<=ir_15_12;
						when state8 =>
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
							--Data Flow
							mem_add<=t3_out;
							t3_in<=mem_out;
							opcode<=ir_15_12;
						when state9 =>
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
							--Data Flow
							mem_in<=t1_out;
							mem_add<=t3_out;
							opcode<=ir_15_12;
						when state10 =>
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
							--Data Flow
							alu_a<=t5_out;
							se_combined_in_6<=ir_5_0;
							se_combined_in_9<=ir_8_0;
							shifter_in<=se_combined_out;
							alu_b<=shifter_out;
							rf_d3<=alu_out;
							rf_a3<="111";
							opcode<=ir_15_12;
						when state11 =>
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
							--Data Flow
							rf_a3<=ir_11_9;
							rf_d3<=t5_out;
							opcode<=ir_15_12;

						when state12 =>
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
							--Data Flow
							rf_a1<=ir_8_6;
							rf_d3<=state2_ir_8_6_out;
							rf_a3<="111";
							opcode<=ir_15_12;

						when state13 =>
							--Control Signals
							rf_wr<='0';
							m_wr<='0';
							m_rd<='1';
							t1_wr<='0';
							t2_wr<='0';
							t3_wr<='0';
							t4_wr<='0';
							t5_wr<='0';
							ir_wr<='0';
							alu_ctrl<="XXX";
							shift_signal<="XX";
							SE_signal<="00";
							
							--Dataflow
						   mem_add(15 downto 6) <= (others =>'0');
							mem_add(5 downto 0) <= switch(5 downto 0);
							mem_dp_temp_out <= mem_out;
							rf_a2 <= switch(2 downto 0);
							reg_dp_out <= rf_d2;
						opcode<=ir_15_12;
						when others =>
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
							opcode<=ir_15_12;
					end case;
	end if;
end process;
	mem_dp_out <= mem_dp_temp_out;
--	reg_dp_out <= "0000000000000000";
--state_out <= state;
end architecture trivial;