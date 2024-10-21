library ieee;
use ieee.std_logic_1164.all;

library Work;
use work.Components.all;

entity Board is 
    port(clk: in std_logic;
	 switch: in std_logic_vector(7 downto 0);
	 button: in std_logic;
	 led: out std_logic_vector(7 downto 0)
	 );
end entity;

architecture complete of Board is

    component DataPath is
	     port(clk: in std_logic;  
		  reset: in std_logic;
		  switch: in std_logic_vector(7 downto 0);
		  mem_dp_out: out std_logic_vector(15 downto 0);
		  reg_dp_out: out std_logic_vector(15 downto 0);
		  z_dp_out: out std_logic
		  );
	end component;
	 
    signal z_out: std_logic := '0';
	 
	 signal mem_dp_out, reg_dp_out: std_logic_vector(15 downto 0);

begin
    Main_Data: Datapath
        port map(clk,button,switch,mem_dp_out, reg_dp_out,z_out);	  
 cpu_var: process(button,clk)
		begin
			if (clk = '1' and clk'event) then
				
				case switch(7 downto 6) is
					when "00"=>
						if switch(3 downto 0) = "1000" then
						led <= (others=>z_out);
						else
						led <= reg_dp_out(15 downto 8);
						end if;
					when "01"=>
						led <= reg_dp_out(7 downto 0);
					when "10" =>
						led <= mem_dp_out(15 downto 8);
					when "11" =>
						led <= mem_dp_out(7 downto 0);
					when others =>
						null;
				end case;
				
			end if;
				
		end process cpu_var;
end architecture;
