-- entidad top-level
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_controller is
    Port (
				CLK :   in  STD_LOGIC;
				RST_n : in  STD_LOGIC;
				
            -- I/O port bus
            PORT_CYC_I : in     std_logic;
            PORT_STB_I : in     std_logic;
            PORT_WE_I : in      std_logic;
            PORT_ACK_O : out    std_logic;
            PORT_ADR_I : in     STD_LOGIC_VECTOR(7 downto 0);
            PORT_DAT_I : in     std_logic_vector(7 downto 0);
            PORT_DAT_O : out    std_logic_vector(7 downto 0);
            -- Interrupts
            INT_REQ : out std_logic;
            INT_ACK : in std_logic;	
				
				TX	  :  OUT	STD_LOGIC;
				RX	  :  IN	STD_LOGIC

				);
end uart_controller;

architecture behavioral of uart_controller is

component uart IS
	GENERIC(
		clk_freq		:	INTEGER		:= 50_000_000;	--frequency of system clock in Hertz
		baud_rate	:	INTEGER		:= 19_200;		--data link baud rate in bits/second
		os_rate		:	INTEGER		:= 16;			--oversampling rate to find center of receive bits (in samples per baud period)
		d_width		:	INTEGER		:= 8; 			--data bus width
		parity		:	INTEGER		:= 1;				--0 for no parity, 1 for parity
		parity_eo	:	STD_LOGIC	:= '0');			--'0' for even, '1' for odd parity
	PORT(
		clk		:	IN		STD_LOGIC;										--system clock
		reset_n	:	IN	STD_LOGIC;										--ascynchronous reset
		tx_ena	:	IN	STD_LOGIC;										--initiate transmission
		tx_data	:	IN	STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data to transmit
		rx			:	IN	STD_LOGIC;										--receive pin
		rx_busy	:	OUT	STD_LOGIC;										--data reception in progress
		rx_error	:	OUT	STD_LOGIC;										--start, parity, or stop bit error detected
		rx_data	:	OUT	STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);	--data received
		tx_busy	:	OUT	STD_LOGIC;  									--transmission in progress
		tx			:	OUT	STD_LOGIC);										--transmit pin
END component uart;

component uart_periferico_out is
Port (
                CLK : in STD_LOGIC;
                RST_n : in STD_LOGIC;

                -- I/O port bus
                PORT_CYC_I : in     std_logic;
                PORT_STB_I : in     std_logic;
                PORT_WE_I : in      std_logic;
                PORT_ACK_O : out    std_logic;
                PORT_ADR_I : in     STD_LOGIC_VECTOR(7 downto 0);
                PORT_DAT_I : in     std_logic_vector(7 downto 0);
                PORT_DAT_O : out    std_logic_vector(7 downto 0);
                -- Interrupts
                INT_REQ : out std_logic;
                INT_ACK : in std_logic;

--              -- tx interface
                TX_ENABLE : out std_logic;
                TX_BUSY   : in     std_logic;
                TX_DATA   : out std_logic_vector(7 downto 0);

                -- rx interface
                RX_BUSY : in     std_logic;
					 RX_ERROR : in     std_logic;
                RX_DATA : in     std_logic_vector(7 downto 0)

                );

end component uart_periferico_out;

-- signal para UART
signal tx_enable_s, tx_busy_s : std_logic;
signal tx_data_s, rx_data_s   : std_logic_vector(7 downto 0);
signal rx_busy_s, rx_error_s  : std_logic;

--signal para Gumnut
signal port_cyc_i_s, port_stb_i_s, port_we_i_s, port_ack_o_s  : std_logic;
signal int_req_s, int_ack_s : std_logic;
signal port_adr_i_s, port_data_o_s, port_data_i : std_logic_vector(7 downto 0);

begin

		uart_0 : uart generic map (10_000_000, 9_600, 16, 8, 1, '0')
						      port map (CLK, RST_n, tx_enable_s, tx_data_s, RX, rx_busy_s, rx_error_s, rx_data_s, tx_busy_s, TX);

		control :  uart_periferico_out port map(CLK, RST_n,port_cyc_i_s,port_stb_i_s,port_we_i_s,port_ack_o_s,port_adr_i_s,port_data_o_s,
											port_data_i,int_req_s,int_ack_s,tx_enable_s,tx_busy_s,tx_data_s,rx_busy_s, rx_error_s, rx_data_s);

end behavioral;
