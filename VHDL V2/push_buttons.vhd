
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity push_buttons is
    Port (	
				CLK : in  STD_LOGIC;
				RST : in  STD_LOGIC;
				
				-- I/O port bus
				PORT_CYC_I : in 	std_logic;
				PORT_STB_I : in 	std_logic;
				PORT_WE_I  : in 	std_logic;
				PORT_ACK_O : out 	std_logic;
				PORT_ADR_I : in	std_logic_vector(7 downto 0);
				PORT_DAT_I : in 	std_logic_vector(7 downto 0);
				PORT_DAT_O : out 	std_logic_vector(7 downto 0);
				-- Interrupts
				INT_REQ 	  : out std_logic;
				INT_ACK 	  : in std_logic;
	 
				--Game keys
				KEY_FIRE		  : in std_logic; 
				KEY_STR		  : in std_logic 
				
				);
end push_buttons;

architecture behavioral of push_buttons is

--ID FOR PUSH BUTTONS
constant ID_BUTTONS: std_logic_vector(7 downto 0) := X"14";

signal buttons_pres, buttons_next, reg_pres ,reg_next: std_logic_vector(7 downto 0);
signal int_ack_s : std_logic;

begin
		--manejo de FFD y registros
		sequential : process(CLK, RST)
						 begin
							if(RST = '1') then
													buttons_pres <= (others => '0');
													reg_pres  <= (others => '0');
							elsif(CLK'event and CLK = '1') then
													buttons_pres <= buttons_next;
													reg_pres  <= reg_next;
							end if;
						 end process sequential;
						 
		buttons_next <= reg_pres when (PORT_ADR_I = ID_BUTTONS and PORT_CYC_I = '1' and PORT_STB_I = '1' and PORT_WE_I = '0') else 
		           buttons_pres;
		
		--pipe in 
		reg_next <= "000000" & KEY_STR & KEY_FIRE;
		
		--writes the data at bus		
		PORT_DAT_O <= buttons_pres;
						  
		--conexion del acknowledge de interrupcion
		int_ack_s <= INT_ACK;
		
		--Never creates an interruption for gumnut
		INT_REQ <= '0';
		
		--asignacion de acknowledge
		PORT_ACK_O <= PORT_CYC_I and PORT_STB_I;  

end behavioral;