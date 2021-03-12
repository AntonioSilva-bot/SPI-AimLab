library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Reto01 is
	Port (
				CLK : in  STD_LOGIC;
				RST : in  STD_LOGIC;
				
				--SPI PINS
				GSENSOR_SDI : in STD_LOGIC; --miso
				GSENSOR_SCLK: buffer STD_LOGIC; --spi serial clk
				GSENSOR_CS_n: buffer STD_LOGIC_VECTOR(0 downto 0); --slave select
				GSENSOR_SDO : out STD_LOGIC; --mosi
				
				--Push buttons
				KEY : in STD_LOGIC_VECTOR(1 downto 0);
				
				--For recive and transmite data
				GPIO_1	  :  OUT	STD_LOGIC; --TX
				GPIO_0	  :  IN	STD_LOGIC   --RX
	);
end Reto01;


architecture behavioral of Reto01 is

component adxl345_top_lvl
    Port ( 
				CLK : in  STD_LOGIC;
				RST_n : in  STD_LOGIC;
				
				-- I/O port buses
				PORT_CYC_I : in 	std_logic;
				PORT_STB_I : in 	std_logic;
				PORT_WE_I  : in 	std_logic;
				PORT_ACK_O : out 	std_logic;
				PORT_ADR_I : in	std_logic_vector(7 downto 0);
				PORT_DAT_I : in 	std_logic_vector(7 downto 0);
				PORT_DAT_O : out 	std_logic_vector(7 downto 0);
				-- Interrupt ports
				INT_REQ : out std_logic;
				INT_ACK : in std_logic;
				
				--SPI Ports
				MISO :  IN      STD_LOGIC;                      --SPI bus: master in, slave out
				SCLK :  BUFFER  STD_LOGIC;                      --SPI bus: serial clock
				SS_n :  BUFFER  STD_LOGIC_VECTOR(0 DOWNTO 0);   --SPI bus: slave select
				MOSI :  OUT     STD_LOGIC                       --SPI bus: master out, slave in
				
				);
end component adxl345_top_lvl;

component push_buttons is
    Port ( 
				CLK : in  STD_LOGIC;
				RST : in  STD_LOGIC;
				
				-- I/O port buses
				PORT_CYC_I : in 	std_logic;
				PORT_STB_I : in 	std_logic;
				PORT_WE_I  : in 	std_logic;
				PORT_ACK_O : out 	std_logic;
				PORT_ADR_I : in	std_logic_vector(7 downto 0);
				PORT_DAT_I : in 	std_logic_vector(7 downto 0);
				PORT_DAT_O : out 	std_logic_vector(7 downto 0);
				-- Interrupt ports
				INT_REQ : out std_logic;
				INT_ACK : in std_logic;
				
				--Game keys
				KEY_FIRE		  : in std_logic; 
				KEY_STR		  : in std_logic 
			);
end component push_buttons;

component gumnut_with_mem is
  generic ( IMem_file_name : string := "gasm_text.dat";
            DMem_file_name : string := "gasm_data.dat";
            debug : boolean := false );
  port ( clk_i : in std_logic;
         rst_i : in std_logic;
         -- I/O port bus
         port_cyc_o : out std_logic;
         port_stb_o : out std_logic;
         port_we_o : out std_logic;
         port_ack_i : in std_logic;
         port_adr_o : out std_logic_vector(7 downto 0);
         port_dat_o : out std_logic_vector(7 downto 0);
         port_dat_i : in std_logic_vector(7 downto 0);
         -- Interrupts
         int_req : in std_logic;
         int_ack : out std_logic );
end component gumnut_with_mem;


component uart_controller IS
	PORT(
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
END component uart_controller;
--ID FOR ADXL345 DATA
constant ID_ACC_X1 : std_logic_vector(7 downto 0) := X"D1";
constant ID_ACC_X2 : std_logic_vector(7 downto 0) := X"D2";
constant ID_ACC_Y1 : std_logic_vector(7 downto 0) := X"D3";
constant ID_ACC_Y2 : std_logic_vector(7 downto 0) := X"D4";
--ID FOR FLAG
constant ID_FLAG : std_logic_vector(7 downto 0) := X"13";
--ID FOR PUSH BUTTONS
constant GUMNUT_KEYS: std_logic_vector(7 downto 0) := X"14";
--ID FOR Rx & Tx
constant ID_DATA_TRANSMITED : std_logic_vector(7 downto 0) := X"10";
constant ID_READ_TX_BUSY : std_logic_vector(7 downto 0) := X"11";
constant ID_TX_HABILITATED : std_logic_vector(7 downto 0) := X"12";

--Signal wires
signal tx_enable_s, tx_busy_s, rx_busy_s, rx_error_s : std_logic;
signal tx_data_s, rx_data_s : std_logic_vector(7 downto 0);
signal port_cyc_o_s, port_stb_o_s, port_we_o_s : std_logic;
signal port_ack_i_s,  port_ack_i_s_1, port_ack_i_s_2 ,port_ack_i_s_3: std_logic;
signal port_adr_o_s : std_logic_vector(7 downto 0); 
signal port_dat_o_s, port_dat_i_s : std_logic_vector(7 downto 0); 
signal port_dat_i_s_1, port_dat_i_s_2, port_dat_i_s_3 : std_logic_vector(7 downto 0);
signal int_req_s, int_ack_s : std_logic; 
signal int_req_s_1, int_req_s_2, int_req_s_3 : std_logic;  

begin

	spi_pmod_acc : adxl345_top_lvl port map(CLK,RST,port_cyc_o_s,port_stb_o_s, port_we_o_s,port_ack_i_s_1,port_adr_o_s,port_dat_o_s,
													port_dat_i_s_1,int_req_s_1,int_ack_s,GSENSOR_SDI,GSENSOR_SCLK,GSENSOR_CS_n,GSENSOR_SDO);
																
	buttons: push_buttons port map(CLK,RST,port_cyc_o_s, port_stb_o_s, port_we_o_s,port_ack_i_s_2,port_adr_o_s,port_dat_o_s,
											 port_dat_i_s_2,int_req_s_2,int_ack_s,KEY(0),KEY(1));
	
	gumnut_with_mem_0 : gumnut_with_mem   generic map("gasm_text.dat", "gasm_data.dat", false)
																port map(CLK, RST,port_cyc_o_s, port_stb_o_s, port_we_o_s, port_ack_i_s,
																			port_adr_o_s, port_dat_o_s, port_dat_i_s,int_req_s, int_ack_s);
	
	uart_controller_01 :uart_controller port map(CLK,RST,port_cyc_o_s, port_stb_o_s, port_we_o_s,port_ack_i_s_3,port_adr_o_s,
													port_dat_o_s, port_dat_i_s_3,int_req_s_3, int_ack_s,GPIO_1,GPIO_0); 

	
		--acknowledge for Gumnut
		port_ack_i_s <= port_ack_i_s_1 or port_ack_i_s_2 or port_ack_i_s_3;
		
		--input data for Gumnut
		port_dat_i_s <= port_dat_i_s_1 when (port_adr_o_s = ID_FLAG) else
							  port_dat_i_s_1 when (port_adr_o_s = ID_ACC_X1) else
							  port_dat_i_s_1 when (port_adr_o_s = ID_ACC_X2) else
							  port_dat_i_s_1 when (port_adr_o_s = ID_ACC_Y1) else
							  port_dat_i_s_1 when (port_adr_o_s = ID_ACC_Y2) else
		port_dat_i_s_2 when (port_adr_o_s = GUMNUT_KEYS) else
		port_dat_i_s_3 when (port_adr_o_s = ID_DATA_TRANSMITED) else
							  port_dat_i_s_3 when (port_adr_o_s = ID_READ_TX_BUSY ) else
							  port_dat_i_s_3 when (port_adr_o_s = ID_TX_HABILITATED ) else
		(others => '0');

		--request of interruption for Gumnut
		int_req_s <= int_req_s_1 or int_req_s_2 or int_req_s_3;	
	

end behavioral;
