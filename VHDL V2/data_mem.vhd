library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;

use work.gumnut_defs.all;

entity data_mem is
  generic ( DMem_file_name : string := "gasm_data.dat" );
  port ( clk_i : in std_logic;
         cyc_i : in std_logic;
         stb_i : in std_logic;
         we_i : in std_logic;
         ack_o : out std_logic;
         adr_i : in unsigned(7 downto 0);
         dat_i : in std_logic_vector(7 downto 0);
         dat_o : out std_logic_vector(7 downto 0) );
end entity data_mem;
