library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;

use work.gumnut_defs.all;

entity inst_mem is
  generic ( IMem_file_name : string := "gasm_text.dat" );
  port ( clk_i : in std_logic;
         cyc_i : in std_logic;
         stb_i : in std_logic;
         ack_o : out std_logic;
         adr_i : in unsigned(11 downto 0);
         dat_o : out std_logic_vector(17 downto 0) );
end entity inst_mem;
