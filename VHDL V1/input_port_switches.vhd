---
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity input_port_switches is
    Port ( 
				CLK : in  STD_LOGIC;
				RST : in  STD_LOGIC;
				
				-- I/O port bus
				PORT_CYC_I : in 	std_logic;
				PORT_STB_I : in 	std_logic;
				PORT_WE_I  : in 	std_logic;
				PORT_ACK_O : out 	std_logic;
				PORT_ADR_I : in	unsigned(7 downto 0);
				PORT_DAT_I : in 	std_logic_vector(7 downto 0);
				PORT_DAT_O : out 	std_logic_vector(7 downto 0);
				-- Interrupts
				INT_REQ : out std_logic;
				INT_ACK : in std_logic;
				--SW
				SW_IN   : in std_logic_vector(7 downto 0)
				
				);
end input_port_switches;

architecture behavioral of input_port_switches is

constant ID_SWITCHES : unsigned(7 downto 0) := X"01";

signal reg_pres, reg_next, sw_next, sw_pres : std_logic_vector(7 downto 0);
signal int_ack_s : std_logic;
signal int_req_pres, int_req_next : std_logic;
signal compare_flag : std_logic;
signal compare : std_logic_vector(7 downto 0);


begin
		--manejo de FFD y registros
		sequential : process(CLK, RST)
						 begin
							if(RST = '1') then
													reg_pres  <= (others => '0');
													sw_pres <= (others => '0');
													int_req_pres <= '0';
							elsif(CLK'event and CLK = '1') then
													reg_pres  <= reg_next;
													sw_pres <= sw_next;
													int_req_pres <= int_req_next;
							end if;
						 end process sequential;
		
		sw_next <= reg_pres when (PORT_ADR_I = ID_SWITCHES and PORT_CYC_I = '1' and PORT_STB_I = '1' and PORT_WE_I = '0') else 
		           sw_pres;
		
		--pipe in
		reg_next <= SW_IN;
		
		--se escribe dato a bus
		PORT_DAT_O <= sw_pres;
		
		--conexion del acknowledge de interrupcion
		int_ack_s <= INT_ACK;
		
		--se generan interrupciones
		INT_REQ <= int_req_pres;
		
		int_req_next <= '1' when (compare_flag = '1') else
							 '0' when (int_ack_s = '1') else
							 int_req_pres;
		
		compare <= SW_IN xor sw_pres;
		compare_flag <= compare(0) or compare(1) or compare(2) or compare(3) or
							 compare(4) or compare(5) or compare(6) or compare(7);
		
		
		PORT_ACK_O <= PORT_CYC_I and PORT_STB_I;
		--PORT_ACK_O <= '1';
		
end behavioral;

