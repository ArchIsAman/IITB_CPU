library ieee;
use ieee.std_logic_1164.all;

library Work;
use work.Components.all;

entity CPU is 
    port(clk: in std_logic);
end entity;

architecture complete of CPU is

    component FSM is 
        port (opcode: in std_logic_vector(3 downto 0);
              z : in std_logic;
              clk : in std_logic;
              output_state : out std_logic_vector(3 downto 0)
              );
    end component;
    
    component Datapath is
        port(clk: in std_logic; state: in std_logic_vector(3 downto 0); 
              z_out: out std_logic;
				  opcode: out std_logic_vector(3 downto 0));
    end component;
    
    signal state, opcode: std_logic_vector(3 downto 0);
    signal z_i: std_logic := '0';
    
begin
    Main_Data: Datapath
        port map(clk, state, z_i,opcode);
        
    Main_FSM: FSM
        port map(opcode, z_i, clk, state);

end architecture;
