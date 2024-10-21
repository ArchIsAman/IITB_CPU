library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Testbench is
end entity;

architecture tb_arch of Testbench is
    signal clk: std_logic := '0';
begin
    uut: entity work.CPU
        port map (
            clk => clk
        );
		  
    process
    begin
        while now < 100 ns loop
            clk <= not clk;
            wait for 5 ns;  
        end loop;
        wait;
    end process;

end architecture tb_arch;
