library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

package Components is

component Multiplexer2to1 is
  Port ( A : in STD_LOGIC_VECTOR(15 downto 0);
         B : in STD_LOGIC_VECTOR(15 downto 0);
          S : in STD_LOGIC_VECTOR(2 downto 0);
         Y : out STD_LOGIC_VECTOR(15 downto 0));
end component;

component bit3_register is
port(D3_in,init_state: in std_logic_vector(2 downto 0); W_enable, clk,reset: in std_logic; D3_out: out std_logic_vector(2 downto 0));
end component;

component bit16_register is
port(D16_in,init_state: in std_logic_vector(15 downto 0); W_enable, clk,reset: in std_logic; D16_out: out std_logic_vector(15 downto 0));
end component;

component instruction_register is
port(IR_in: in std_logic_vector(15 downto 0); W_enable, clk,reset: in std_logic;
 IR15_12: out std_logic_vector(3 downto 0);
 IR11_9: out std_logic_vector(2 downto 0);
 IR8_6: out std_logic_vector(2 downto 0);
 IR5_3: out std_logic_vector(2 downto 0);
 IR5_0: out std_logic_vector(5 downto 0);
 IR8_0: out std_logic_vector(8 downto 0)
 );
end component;

component register_file is
port (sel_D_out_1, sel_D_out_2: in std_logic_vector(2 downto 0);
      sel_D_in: in std_logic_vector(2 downto 0);
		D_out_1, D_out_2: out std_logic_vector(15 downto 0);
      D_in: in std_logic_vector(15 downto 0); 
		
		clk,reset: in std_logic;
		R_enable, W_enable: in std_logic
		
		);
end component;

component ALU is
    Port (
        num_in_1, num_in_2: in std_logic_vector(15 downto 0);
        OP_code: in std_logic_vector(2 downto 0);
        num_out: out std_logic_vector(15 downto 0);
        zero_flag, carry_flag: out std_logic
    );
end component;
component SHIFTER is 

	port (INPUT: in std_logic_vector(15 downto 0);DIR_RIGHT, SHIFT_ONE: in std_logic; OUTPUT: out std_logic_vector(15 downto 0));
	
end component;

component SE_combined is
    port (
        input_6bit: in std_logic_vector(5 downto 0);
        input_9bit: in std_logic_vector(8 downto 0);
        condition: in std_logic_vector(1 downto 0);
        output_bit: out std_logic_vector(15 downto 0)
    );
end component;

component Memory is
    Port ( clk_in , reset , write_enable , read_enable : in STD_LOGIC;
           address_in : in STD_LOGIC_VECTOR (15 downto 0);
           data_in : in STD_LOGIC_VECTOR (15 downto 0);
           data_out : out STD_LOGIC_VECTOR (15 downto 0));
end component;
end package Components;
--------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Multiplexer2to1 is
  Port ( A : in STD_LOGIC_VECTOR(15 downto 0);
         B : in STD_LOGIC_VECTOR(15 downto 0);
         S : in STD_LOGIC_VECTOR(2 downto 0);
         Y : out STD_LOGIC_VECTOR(15 downto 0));
end Multiplexer2to1;

architecture Behavioral of Multiplexer2to1 is
begin
  process (A, B, S)
  begin
    if (S = "111") then
      Y <= B;
    else
      Y <= A;
    end if;
  end process;
end Behavioral;

----twotoonemux--------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.Gates.all;

entity TwoToOneMultiplexer is
	port (I1,I0, S: in std_logic; Y: out std_logic);
end entity TwoToOneMultiplexer;

architecture Structure of TwoToOneMultiplexer is

	signal I1_AND_S, I2_AND_S_BAR, S_BAR: std_logic;

begin
	NOT1: INVERTER port map(A=> S, Y=> S_BAR);
	
	AND1: AND_2 port map (A=> I1, B=> S, Y=> I1_AND_S);
	
	AND2: AND_2 port map (A=> I0, B=> S_BAR, Y=> I2_AND_S_BAR);
	
	OR1: OR_2 port map (A=> I1_AND_S, B=> I2_AND_S_BAR, Y=> Y);

end Structure;
----fourtoonemux--------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

entity FourToOneMultiplexer is
	port (I3,I2,I1,I0,S1, S0: in std_logic; Y: out std_logic);
end entity FourToOneMultiplexer;

architecture Structure of FourToOneMultiplexer is

component TwoToOneMultiplexer is
	port (I1,I0, S: in std_logic; Y: out std_logic);
end component;

signal O1, O2: std_logic;
	
begin
	
	mux2x1_1: TwoToOneMultiplexer port map (I1=> I3, I0=> I2, S=> S0, Y=> O1);
	
	mux2x1_2: TwoToOneMultiplexer port map (I1=> I1, I0=> I0, S=>S0, Y=> O2);
	
	mux2x1_3: TwoToOneMultiplexer port map (I1=> O1, I0=> O2, S=> S1, Y=> Y);
	
end Structure;

------mux_8to1------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity mux_8to1 is
    
    port (
        I0: in std_logic_vector(15 downto 0);
        I1: in std_logic_vector(15 downto 0);
		  I2: in std_logic_vector(15 downto 0);
		  I3: in std_logic_vector(15 downto 0);
		  I4: in std_logic_vector(15 downto 0);
		  I5: in std_logic_vector(15 downto 0);
		  I6: in std_logic_vector(15 downto 0);
		  I7: in std_logic_vector(15 downto 0);
        Sel: in std_logic_vector(2 downto 0);
		  enable : in std_logic;
        O: out std_logic_vector(15 downto 0)
    ) ;
	 
end entity mux_8to1;

architecture inside of mux_8to1 is

begin
mux : process( I0, I1, I2, I3, I4, I5, I6, I7, sel)

begin

	if Enable = '1' then
		  if sel = "000" then
			 O <= I0;
		  elsif sel = "001" then
			 O <= I1;
		  elsif sel = "010" then
			 O <= I2;
		  elsif sel = "011" then
			 O <= I3;
		  elsif sel = "100" then
			 O <= I4;
		  elsif sel = "101" then
			 O <= I5;
		  elsif sel = "110" then
			 O <= I6;
		  else
			 O <= I7;
		  end if;
		  
	end if;
	
end process mux;

end architecture inside;

--demux_1to8----------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dmux_1to8 is
    Port ( I : in STD_LOGIC;
           sel : in STD_LOGIC_VECTOR (2 downto 0);
           O : out STD_LOGIC_VECTOR(7 downto 0));
end dmux_1to8;

architecture Behavioral of dmux_1to8 is
begin

    process (sel, I)
    begin
        O <= (others => '0');
        
        case sel is
            when "000" =>
                O(0) <= I;
            when "001" =>
                O(1) <= I;
            when "010" =>
                O(2) <= I;
            when "011" =>
                O(3) <= I;
            when "100" =>
                O(4) <= I;
            when "101" =>
                O(5) <= I;
            when "110" =>
                O(6) <= I;
            when others =>
                O(7) <= I;
        end case;

	  end process;

end Behavioral;

---bit1_register---------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bit1_register is
    Port (
        d_in      : in  STD_LOGIC;
        W_enable  : in  STD_LOGIC;
        clk       : in  STD_LOGIC;
		  reset: in std_logic;
		  init_state: in  STD_LOGIC;
        d_out     : out STD_LOGIC
    );
end bit1_register;

architecture Behavioral of bit1_register is
    signal internal_state : STD_LOGIC := init_state;
begin
    process (clk)
    begin
        if rising_edge(clk) then
	         if reset = '1' then 
				internal_state <= '0';
				else
            if W_enable = '1' then
                internal_state <= d_in;
            end if;
        end if;
		  end if;
    end process;

    d_out <= internal_state;  
end Behavioral;


---bit3_register----------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity bit3_register is
port(D3_in,init_state: in std_logic_vector(2 downto 0);
 W_enable, clk: in std_logic;
 reset : in std_logic; 
 D3_out: out std_logic_vector(2 downto 0));
end entity bit3_register;

architecture inside of bit3_register is

component bit1_register is
    Port (
        d_in      : in  STD_LOGIC;
        W_enable  : in  STD_LOGIC;
        clk       : in  STD_LOGIC;
		   reset : in std_logic;
		  init_state: in  STD_LOGIC;
        d_out     : out STD_LOGIC
    );
end component bit1_register;

begin

bit3_r : for i in 0 to 2 generate
bit1_r : bit1_register port map (D3_in(i), W_enable, clk,reset,init_state(i), D3_out(i));
end generate bit3_r;

end architecture inside;

---bit16_register----------------------------------------------------------------------------------------------------------------------------------
--local imports
library ieee;
use ieee.std_logic_1164.all;

entity bit16_register is
port(D16_in,init_state: in std_logic_vector(15 downto 0); 
W_enable, clk: in std_logic;
 reset : in std_logic;
 D16_out: out std_logic_vector(15 downto 0));
end entity bit16_register;

architecture inside of bit16_register is

component bit1_register is
    Port (
        d_in      : in  STD_LOGIC;
        W_enable  : in  STD_LOGIC;
        clk       : in  STD_LOGIC;
		   reset : in std_logic;
		  init_state: in  STD_LOGIC;
        d_out     : out STD_LOGIC
    );
end component bit1_register;

begin

bit16_r : for i in 0 to 15 generate
bit1_r : bit1_register port map (D16_in(i), W_enable, clk,reset,init_state(i), D16_out(i));
end generate bit16_r;

end architecture inside;
---instruction-register------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library Work;
entity instruction_register is
port(IR_in: in std_logic_vector(15 downto 0); W_enable, clk,reset: in std_logic;
 IR15_12: out std_logic_vector(3 downto 0);
 IR11_9: out std_logic_vector(2 downto 0);
 IR8_6: out std_logic_vector(2 downto 0);
 IR5_3: out std_logic_vector(2 downto 0);
 IR5_0: out std_logic_vector(5 downto 0);
 IR8_0: out std_logic_vector(8 downto 0)
 );
end entity instruction_register;

architecture bhv of instruction_register is
	
	signal s, storage: std_logic_vector(15 downto 0):="0000000000000000";
	
	begin
		s(15 downto 0)<= storage(15 downto 0);
		
		edit_process: process(clk)
		begin
		
			if(clk='1' and clk'event) then
				if reset = '1' then
						storage(15 downto 0)<= "0000000000000000";
				else
					if  W_enable='1'then
						storage(15 downto 0)<=IR_in(15 downto 0);
					else
						storage(15 downto 0)<=storage(15 downto 0);
					end if;
				end if;
			end if;
		end process;
			
		IR8_0<= s(8 downto 0);
		IR5_0<= s(5 downto 0);
		IR15_12<= s(15 downto 12);
		IR11_9<= s(11 downto 9);
		IR8_6<= s(8 downto 6);
		IR5_3<= s(5 downto 3);
end architecture bhv;




---REGISTER FILE---------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity register_file is
port (D_in: in std_logic_vector(15 downto 0); 
		sel_D_in: in std_logic_vector(2 downto 0);
		sel_D_out_1, sel_D_out_2: in std_logic_vector(2 downto 0);
		R_enable, W_enable, clk: in std_logic;
		 reset : in std_logic;
		D_out_1, D_out_2: out std_logic_vector(15 downto 0));
end entity register_file;

architecture inside of register_file is

component bit16_register is
port(D16_in,init_state: in std_logic_vector(15 downto 0);
 W_enable, clk: in std_logic;
 reset : in std_logic;
 D16_out: out std_logic_vector(15 downto 0));
end component bit16_register;

component dmux_1to8 is
    Port ( I : in STD_LOGIC;
           sel : in STD_LOGIC_VECTOR (2 downto 0);
           O : out STD_LOGIC_VECTOR(7 downto 0));
end component dmux_1to8;

component mux_8to1 is
    
    port (
        I0: in std_logic_vector(15 downto 0);
        I1: in std_logic_vector(15 downto 0);
		  I2: in std_logic_vector(15 downto 0);
		  I3: in std_logic_vector(15 downto 0);
		  I4: in std_logic_vector(15 downto 0);
		  I5: in std_logic_vector(15 downto 0);
		  I6: in std_logic_vector(15 downto 0);
		  I7: in std_logic_vector(15 downto 0);
        Sel: in std_logic_vector(2 downto 0);
		  enable : in std_logic;
        O: out std_logic_vector(15 downto 0)
    ) ;
	 
end component mux_8to1;


type reg_array is array (0 to 7) of std_logic_vector(15 downto 0);


signal reg_out: reg_array;
signal d_mux_sel_out: std_logic_vector(7 downto 0);
signal init_states: reg_array := (0=>"1111111111111111",
										    1=>"0000000000000001",
										    2=>"0000000000000010",
										    3=>"0000000000000011",
										    4=>"0000000000000100",
										    5=>"0000000000000101",
										    6=>"0000000000000110",
									others => "0000000000000000");
begin

d_mux_sel: dmux_1to8
port map(W_enable, sel_D_in, d_mux_sel_out);

r_file: for i in 0 to 7 generate
	reg: bit16_register port map(D_in,init_states(i),d_mux_sel_out(i), clk,reset, reg_out(i));
end generate r_file;

mux_8to1_inst: mux_8to1
        port map(
            reg_out(0),
            reg_out(1),
            reg_out(2),
            reg_out(3),
            reg_out(4),
            reg_out(5),
            reg_out(6),
            reg_out(7),
            sel_D_out_1,
            clk,
            D_out_1
        );
		  
mux_8to1_inst_2: mux_8to1
        port map(
            reg_out(0),
            reg_out(1),
            reg_out(2),
            reg_out(3),
            reg_out(4),
            reg_out(5),
            reg_out(6),
            reg_out(7),
            sel_D_out_2,
            clk,
            D_out_2
        );

end architecture inside;
--ALU-----------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
entity ALU is
    Port (
        num_in_1, num_in_2: in std_logic_vector(15 downto 0);
        OP_code: in std_logic_vector(2 downto 0);
        num_out: out std_logic_vector(15 downto 0);
        zero_flag, carry_flag: out std_logic
    );
end entity ALU;

architecture inside of ALU is

    function add_sub(
        num_in_1, num_in_2 : in STD_LOGIC_VECTOR(15 downto 0);
        add_or_sub : in STD_LOGIC)
		  return std_logic_vector is
        variable temp_sum : STD_LOGIC_VECTOR(15 downto 0);
        variable sum : std_logic_vector(16 downto 0) := (others => '0');
		  variable carry : std_logic;
    begin
        carry := add_or_sub;
        for i in 0 to 15 loop
            if add_or_sub = '0' then
                temp_sum(i) := num_in_1(i) XOR num_in_2(i) XOR carry;
                carry := (num_in_1(i) AND num_in_2(i)) OR ((num_in_1(i) OR num_in_2(i)) AND carry);
            else
                temp_sum(i) := num_in_1(i) XOR (not num_in_2(i)) XOR carry;
                carry := (num_in_1(i) AND (not num_in_2(i))) OR ((num_in_1(i) OR (not num_in_2(i))) AND carry);
            end if;
        end loop;

        sum(15 downto 0) := temp_sum;
		  sum(16) := carry;
        return sum;
    end function add_sub;

    function multiplier(
        num_in_1, num_in_2: in STD_LOGIC_VECTOR(15 downto 0))
		  return std_logic_vector is
        variable lsb_product : integer;
        variable mul : std_logic_vector(15 downto 0) := (others => '0');
    begin
        lsb_product := to_integer(signed(num_in_1(3 downto 0))) * to_integer(signed(num_in_2(3 downto 0)));
        mul(15 downto 0) := std_logic_vector(to_signed(lsb_product, 16));
        return mul;
    end function multiplier;


begin
    ALU: process(num_in_1, num_in_2, OP_code)
	 variable temp: STD_LOGIC_VECTOR(16 downto 0);
    begin
        if (OP_code = "000" or OP_code = "001") then
            temp := add_sub(num_in_1, num_in_2, OP_code(0));
            carry_flag <= temp(16);
				
        elsif (OP_code = "010") then
            temp(15 downto 0) := multiplier(num_in_1, num_in_2);
            carry_flag <= '0';
        elsif (OP_code = "011") then
            temp(15 downto 0) := num_in_1 and num_in_2;
            carry_flag <= '0';
        elsif (OP_code = "100") then
            temp(15 downto 0) := num_in_1 or num_in_2;
            carry_flag <= '0';
        elsif (OP_code = "101") then
            temp(15 downto 0) := (not num_in_1) or num_in_2;
            carry_flag <= '0';
        else
            temp := (others => '0');
            carry_flag <= '0';
        end if;
		  num_out <= temp(15 downto 0);
		  if(temp(15 downto 0) = "0000000000000000") then
            zero_flag <= '1';
		  else 
				zero_flag <= '0';
		  end if;
    end process ALU;

end architecture inside;

----SHIFTER----------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
entity SHIFTER is 

	port (INPUT: in std_logic_vector(15 downto 0);DIR_RIGHT, SHIFT_ONE: in std_logic; OUTPUT: out std_logic_vector(15 downto 0));
	
end entity SHIFTER;

architecture BHV_SHIFTER of SHIFTER is 

component FourToOneMultiplexer is
		port (I3,I2,I1,I0,S1, S0: in std_logic; Y: out std_logic);
end component FourToOneMultiplexer;
begin

	MUX4x1_0: FourToOneMultiplexer port map(I3 => INPUT(0), I2 => INPUT(8), I1 => '0', I0 => '0', S1 => DIR_RIGHT, S0 => SHIFT_ONE, Y=>OUTPUT(0));
	
	GNN1: for i in 1 to 7 generate
		
		MUX4x1_1: FourToOneMultiplexer port map(I3 => INPUT(i), I2 => INPUT(i+8), I1 => INPUT(i-1), I0 => '0', S1 => DIR_RIGHT, S0 => SHIFT_ONE, Y=>OUTPUT(i));
		
	end generate GNN1;
	
	GNN2: for i in 8 to 14 generate
		
		MUX4x1_2: FourToOneMultiplexer port map(I3 => INPUT(i), I2 => '0', I1 => INPUT(i-1), I0 => INPUT(i-8), S1 => DIR_RIGHT, S0 => SHIFT_ONE, Y=>OUTPUT(i));
		
	end generate GNN2;
	
		MUX4x1_15: FourToOneMultiplexer port map(I3 => INPUT(15), I2 => '0', I1 => INPUT(14), I0 => INPUT(7), S1 => DIR_RIGHT, S0 => SHIFT_ONE, Y=>OUTPUT(15));
	
end BHV_SHIFTER;

--SE_combined----------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
entity SE_combined is
    port (
        input_6bit: in std_logic_vector(5 downto 0);
        input_9bit: in std_logic_vector(8 downto 0);
        condition: in std_logic_vector(1 downto 0);
        output_bit: out std_logic_vector(15 downto 0)
    );
end entity SE_combined;

architecture extender of SE_combined is
begin
    conv_process: process(condition,input_6bit,input_9bit)
    begin
        if condition = "01" then
            if (input_6bit(5) = '0') then
                output_bit <= "0000000000" & input_6bit;
            else 
                output_bit <= "1111111111" & input_6bit;
            end if;
        elsif condition = "11" then
            if (input_9bit(8) = '0') then
                output_bit <= "0000000" & input_9bit;
            else 
                output_bit <= "1111111" & input_9bit;
            end if;
        else
            output_bit <= (others => '0');
        end if;
    end process;
end extender;

--Memory--------------------------------------------------------------------------------------------------------------------------------------------
--Memory--------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
entity Memory is
    Port ( clk_in , reset , write_enable , read_enable : in STD_LOGIC;
           address_in : in STD_LOGIC_VECTOR (15 downto 0);
           data_in : in STD_LOGIC_VECTOR (15 downto 0);
           data_out : out STD_LOGIC_VECTOR (15 downto 0));
end Memory;

architecture Behavioral of Memory is
    type mem_array is array (0 to 63) of STD_LOGIC_VECTOR (15 downto 0); 
signal ram: mem_array := (	00 => "1001011000001010", --Load immed((8bit) ie 10) into least significant 8 bits of R3 and others as 0 
									01 => "1010000011001101", --Load data from memory address 23 (10 at r3 + 13 immediate) into R0
									02 => "1010001011001110", --Load data from memory address 24 (10 at r3 + 14 immediate) into R1
									03 => "0000001000100000", --Add R0 and R4 and store it in R1
									04 => "1011100011001111", --Store R4 at 25 (10 at R3 + 15 immediate)
									05 => "0010001000100000", --Subtract R0 and R4 and store it in R1
									06 => "1011100011010000", --Store R4 at 26 (10 at R3 + 16 immediate)
									07 => "0011001000100000", --Multiply R0 and R4 and store it in R1
									08 => "1011100011010001", --Store R4 at 27 (10 at R3 + 17 immediate)
									09 => "0100001000100000", --Logical AND R0 and R4 and store it in R1
									10 => "1011100011010010", --Store R4 at 28 (10 at R3 + 18 immediate)
									11 => "0101001000100000", --Logical OR R0 and R4 and store it in R1
									12 => "1011100011010011", --Store R4 at 29 (10 at R3 + 19 immediate)
									13 => "0110001000100000", --Logical IMP R0 and R4 and store it in R1
									14 => "1011100011010100", --Store R4 at 30(10 at R3 + 20 immediate)
									15 => "1000101010101001", --Load immed((8bit) ie 169) into higher significant 8 bits of R5 and others as 0
									16 => "0001010011010101", --Add content of R3 with 21 and stores it in R2
									17 => "1100000000000001", --Compares value in R0 and R0 and jumps to 19 (17 BEQ + 2 (2*immed))
									19 => "1101110000000001", --Saves PC in R6 and jumps to 21(19 PC and 2 (2*immed))
									21 => "1111001010000000", --Saves PC in R1 and jumps to 31(stored in R2)
									23 => "1010101010001011", --Load from mem into reg 5, mem address = imm + reg 2
									24 => "0010001100010100",-- Sub Reg 2 from Reg 4 and store in reg 1
						others =>    "0000001000100000");
	signal mem_data_out : STD_LOGIC_VECTOR (15 downto 0);
begin
    process(clk_in,read_enable,write_enable,address_in)
    begin
		mem_data_out <= (others=>'0');
		if(read_enable = '1') then
                mem_data_out(15 downto 0) <= ram(to_integer(unsigned(address_in)));
		end if;
	   if rising_edge(clk_in) then
            if(reset = '1') then
                ram <= (others => "0000000000000000");
            end if;
            if(write_enable = '1') then
                ram(to_integer(unsigned(address_in))) <= data_in(15 downto 0);
				end if;
		end if;
     end process;
		data_out <= mem_data_out;
end Behavioral;
