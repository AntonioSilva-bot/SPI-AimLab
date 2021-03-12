library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity output_port_leds is
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
				--LEDs
				LEDS_OUT   : out std_logic_vector(7 downto 0)

				);
end output_port_leds;

architecture behavioral of output_port_leds is
signal leds_next, leds_pres : std_logic_vector(7 downto 0);
constant ID_LEDS : unsigned(7 downto 0) := X"02";
signal int_ack_s : std_logic;

begin
		--manejo de FFD y registros
		sequential : process(CLK, RST)
						 begin
							if(RST = '1') then

													leds_pres <= (others => '0');
							elsif(CLK'event and CLK = '1') then

													leds_pres <= leds_next;
							end if;
						 end process sequential;

		leds_next <= PORT_DAT_I when (PORT_ADR_I = ID_LEDS and PORT_CYC_I = '1' and PORT_STB_I = '1' and PORT_WE_I = '1') else
		             leds_pres;

		LEDS_OUT <= leds_pres;

		PORT_DAT_O <= (others =>'0');

		--conexion del acknowledge de interrupcion
		int_ack_s <= INT_ACK;

		--no se generan interrupciones
		INT_REQ <= '0';

		PORT_ACK_O <= PORT_CYC_I and PORT_STB_I;

end behavioral;
