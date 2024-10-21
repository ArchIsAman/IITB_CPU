--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--entity Testbench is
--end entity;
--
--architecture tb_arch of Testbench is
--    signal clk,reset: std_logic := '0';
--begin
--    uut: entity work.CPU
--        port map (
--            clk => clk,
--				reset => reset
--        );
--		  
--    process
--    begin
--        while now < 1000 ns loop
--            clk <= not clk;
--            wait for 5 ns; 	
--        end loop;
--        wait;
--    end process;
--	 
--	     process
--    begin
--        while now < 1000 ns loop
--            wait for 400ns;
--				reset <= '1';
--				wait for 100ns;
--				reset <= '0';
--        end loop;
--        wait;
--    end process;
--
--end architecture tb_arch;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Testbench is
end entity;

architecture tb_arch of Testbench is
    signal clk,reset: std_logic := '0';
	 signal led, switch : std_logic_vector(7 downto 0) := (others=>'0');
	 signal button : std_logic_vector(3 downto 0) := (others=>'0');
	 
	 component Board is 
    port(clk: in std_logic;
	 switch: in std_logic_vector(7 downto 0);
	 button: in std_logic_vector(3 downto 0);
	 led: out std_logic_vector(7 downto 0)
	 );
end component;

	
begin
    uut: Board
	port map(clk => clk,
		 switch => switch,
		 button => button,
		 led => led
		 );
 
	 button(3) <= reset;
	 switch <= "01000111";
	 
	 
	
	 buttongen: process
    begin
        while now < 1000 ns loop
				--Outputs first 8 bits of register 
				switch(7 downto 6) <= "01";
				wait for 100 ns;
				switch(7 downto 6) <= "01";
				wait for 100 ns;
				switch(7 downto 6) <= "10";
				wait for 100 ns;
				switch(7 downto 6) <= "11";
				wait for 100 ns;		
        end loop;
        wait;
    end process;
	 	
    
	 clkgen: process
    begin
        while now < 1000 ns loop
            clk <= not clk;
            wait for 5 ns; 	
        end loop;
        wait;
    end process;
	 
	 resetgen: process
    begin
        while now < 1000 ns loop
--            wait for 400ns;
				reset <= '1';
				wait for 40ns;
				reset <= '0';
				wait for 980ns;
        end loop;
        wait;
    end process;

end architecture tb_arch;

