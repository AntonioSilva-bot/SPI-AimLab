-- Se describ el controlador para poner a prueba al uart
-- uart como periferico de salida
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_periferico_out is
    Port (
				CLK :   in  STD_LOGIC;
				RST_n : in  STD_LOGIC;

        -- I/O port bus
        PORT_CYC_I : in 	std_logic;
        PORT_STB_I : in 	std_logic;
        PORT_WE_I  : in 	std_logic;
        PORT_ACK_O : out 	std_logic;
        PORT_ADR_I : in		std_logic_vector(7 downto 0);
        PORT_DAT_I : in 	std_logic_vector(7 downto 0);
        PORT_DAT_O : out 	std_logic_vector(7 downto 0);
        -- Interrupts
        INT_REQ : out std_logic;
        INT_ACK : in std_logic;
        
			-- tx interface
			TX_ENABLE   : out std_logic;
			TX_BUSY     : in 	std_logic;
			TX_DATA     : out std_logic_vector(7 downto 0);

			-- rx interface
			RX_BUSY    : in 	std_logic;
			RX_ERROR   : in 	std_logic;
			RX_DATA    : in 	std_logic_vector(7 downto 0)

			);
end uart_periferico_out;

architecture behavioral of uart_periferico_out is
-- STM varibles and states
type fsm_state is (wait_for_tx, otro_estado, sig_estado);
signal next_state, pres_state : fsm_state;

--registers
signal reg_rx_next, reg_rx_pres : std_logic_vector(7 downto 0);
signal reg_tx_next, reg_tx_pres : std_logic_vector(7 downto 0);
signal enable_tx_next , enable_tx_pres : std_logic_vector(7 downto 0);

--directions
constant ID_DATA_TRANSMITED : std_logic_vector(7 downto 0) := X"10";
constant ID_READ_TX_BUSY : std_logic_vector(7 downto 0) := X"11";
constant ID_TX_HABILITATED : std_logic_vector(7 downto 0) := X"12";

--flip-flops type D
signal FFD_TX_BUSY_NEXT, FFD_TX_BUSY_PRES  : std_logic;

--support signals
signal tmp_1 : std_logic_vector(7 downto 0);


begin

    --data that gumnut want to transmit -> write access to gumnut
    reg_tx_next <= PORT_DAT_I when (PORT_ADR_I = ID_DATA_TRANSMITED and PORT_CYC_I = '1' and PORT_STB_I = '1' and PORT_WE_I = '1') else
                   reg_tx_pres;
						 
    --Activate acknowledge of the data recived
    PORT_ACK_O <= PORT_CYC_I and PORT_STB_I;

    --gumnut reads the transmisor state
    FFD_TX_BUSY_NEXT <= TX_BUSY;
    tmp_1 <= "0000000" & FFD_TX_BUSY_PRES;
    
	 PORT_DAT_O <= tmp_1 when (PORT_ADR_I = ID_READ_TX_BUSY and PORT_CYC_I = '1' and PORT_STB_I = '1' and PORT_WE_I = '0') else
                  (others => '0');

    --gumnut indicates that transmition begins
    enable_tx_next <= PORT_DAT_I when (PORT_ADR_I = ID_TX_HABILITATED and PORT_CYC_I = '1' and PORT_STB_I = '1' and PORT_WE_I = '1') else
                   enable_tx_pres;

		--inferfencia del registro interno de la interfaz
		sequential : process(CLK, RST_n)
						 begin
								if(RST_n = '1') then
													   pres_state <= wait_for_tx;
														reg_rx_pres <= (others => '0');
														reg_tx_pres <= (others => '0');
														FFD_TX_BUSY_PRES <= '0';
														enable_tx_pres <= (others => '0');
								elsif(CLK'event and CLK = '1') then
														pres_state <= next_state;
														reg_rx_pres <= reg_rx_next;
														reg_tx_pres <= reg_tx_next;
														FFD_TX_BUSY_PRES <= FFD_TX_BUSY_NEXT;
														enable_tx_pres <= enable_tx_next;
								end if;
						 end process sequential;

		--descripción del controlador
		fsm_controller : 	process(reg_rx_pres, reg_tx_pres, pres_state, RX_BUSY, TX_BUSY, RX_DATA)
								begin
										-- para prevenir latches
										reg_rx_next <= reg_rx_pres;
										--reg_tx_next <= reg_tx_pres;
										next_state <= pres_state;
										TX_DATA <= (others => '0');
										TX_ENABLE <= '0';

										case(pres_state) is
												when wait_for_tx  =>    --espera a que tx esté listo
                                                        if(TX_BUSY = '1') then
                                                                      next_state <= wait_for_tx;
                                                        else
                                                                                                        
                                                                      next_state <= otro_estado;               
                                                        end if;
                                                                                
                                    when otro_estado => if(enable_tx_pres(0) = '1') then
																							 next_state <= sig_estado;
                                                        else
																							 next_state <= otro_estado;
                                                        end if;                      
                                    when sig_estado =>  --envía dato y comienza de nuevo
                                                                                
                                                       TX_DATA <= reg_tx_pres;
                                                       TX_ENABLE <= '1';
                                                       next_state <= wait_for_tx;

										end case;

								end process fsm_controller;


end behavioral;
