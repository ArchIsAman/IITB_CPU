library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FSM is 
	port (opcode: in std_logic_vector(3 downto 0);
			z : in std_logic;
			clk : in std_logic;
			output_state : out std_logic_vector(3 downto 0)
			);
end entity FSM;

architecture BH_FSM of FSM is
constant s1 : std_logic_vector(3 downto 0):= "0001";
constant s2 : std_logic_vector(3 downto 0):= "0010";
constant s3 : std_logic_vector(3 downto 0):= "0011";
constant s4 : std_logic_vector(3 downto 0):= "0100";
constant s5 : std_logic_vector(3 downto 0):= "0101";
constant s6 : std_logic_vector(3 downto 0):= "0110";
constant s7 : std_logic_vector(3 downto 0):= "0111";
constant s8 : std_logic_vector(3 downto 0):= "1000";
constant s9 : std_logic_vector(3 downto 0):= "1001";
constant s10 : std_logic_vector(3 downto 0):= "1010";
constant s11 : std_logic_vector(3 downto 0):= "1011";
constant s12 : std_logic_vector(3 downto 0):= "1100";


signal s_present : std_logic_vector(3 downto 0) := s1;
signal s_next : std_logic_vector(3 downto 0) := s1;


begin
   output_state <= s_present;
	state_change: process (clk)
	
	begin
		if (clk = '1' and clk'event) then
			s_present <= s_next;
		end if;
	
	end process state_change;

	state_transition: process (s_present, opcode,z)
	
	begin
	
	case s_present is
		
		when s1 =>
			case opcode is
				
				when "0000" | "0010" | "0011" | "0100" | "0101" | "0110" | "1100" =>
					s_next <= s2;
					
				when "1000" | "1001" =>
					s_next <= s5;
				
				when "0001" =>
					s_next <= s6;
				
				when "1011" | "1010" =>
					s_next <= s7;
				
				when "1101" =>
					s_next <= s10;
				
				when "1111" =>
					s_next <= s11;
				
				when others =>
					s_next <= s1;
		
				
			end case;
			
		when s2=>
				s_next <= s3;
				
		when s3 =>
			
			if (opcode = "1100") then
				if (z = '1') then 
					s_next <= S10;
				else
					s_next <= S1;
				end if;
			elsif (opcode(3) = '0') then
				s_next <= s4;
			else
				s_next <= S1;
			end if;
		
		when S4 =>
			s_next <= s1;
			
		when S5 =>
			s_next <= s4;
		
		when S6 =>
			s_next <= s3;
		
		when s7 => 
			
			case opcode is
				
				when "1010" =>
					s_next <= s8;
				
				when "1011" =>
					s_next <= s9;
				
				when others =>
					s_next <= s1;
			
			end case;
		
		when S8 =>
			s_next <= s4;
		
		when S9 =>
			s_next <= s1;
		
		when s10 => 
			
			case opcode is
				
				when "1100" =>
					s_next <= s1;
				
				when "1101" =>
					s_next <= s11;
				
				when others =>
					s_next <= s1;
		
			end case;
		
		when s11 => 
			
			case opcode is
				
				when "1101" =>
					s_next <= s1;
				
				when "1111" =>
					s_next <= s12;
				
				when others =>
					s_next <= s1;
		
			end case;
		
		when S12 =>
			s_next <= s1;
		
		when others =>
			s_next <= s1;
			
	end case;
	
	end process state_transition;
	
end BH_FSM;