library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adxl345_top_lvl is
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
end adxl345_top_lvl;

architecture behavioral of adxl345_top_lvl is

component adxl345_inter is
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
				
				--ADXL345
				acceleration_x : in     STD_LOGIC_VECTOR(15 DOWNTO 0);  --x-axis acceleration data
				acceleration_y : in     STD_LOGIC_VECTOR(15 DOWNTO 0);  --y-axis acceleration data
				acceleration_z : in     STD_LOGIC_VECTOR(15 DOWNTO 0); --z-axis acceleration data
				flag		   	: in	 STD_LOGIC  --sensor data is avalible and updated
				
				);
end component adxl345_inter;

component pmod_accelerometer_adxl345 IS
  GENERIC(
    clk_freq   : INTEGER := 50;              --system clock frequency in MHz
    data_rate  : STD_LOGIC_VECTOR := "0100"; --data rate code to configure the accelerometer
    data_range : STD_LOGIC_VECTOR := "00");  --data range code to configure the accelerometer
  PORT(
    clk            : IN      STD_LOGIC;                      --system clock
    reset_n        : IN      STD_LOGIC;                      --active low asynchronous reset
    miso           : IN      STD_LOGIC;                      --SPI bus: master in, slave out
    sclk           : BUFFER  STD_LOGIC;                      --SPI bus: serial clock
    ss_n           : BUFFER  STD_LOGIC_VECTOR(0 DOWNTO 0);   --SPI bus: slave select
    mosi           : OUT     STD_LOGIC;                      --SPI bus: master out, slave in
    acceleration_x : OUT     STD_LOGIC_VECTOR(15 DOWNTO 0);  --x-axis acceleration data
    acceleration_y : OUT     STD_LOGIC_VECTOR(15 DOWNTO 0);  --y-axis acceleration data
    acceleration_z : OUT     STD_LOGIC_VECTOR(15 DOWNTO 0); --z-axis acceleration data
	 flag 			 : OUT      STD_LOGIC
	 );
end component pmod_accelerometer_adxl345;
--ID

--signals for wiring
signal port_cyc_o_s, port_stb_o_s, port_we_o_s,port_ack_i_s : std_logic;
signal port_adr_o_s, port_dat_o_s, port_dat_i_s : std_logic_vector(7 downto 0); 
signal int_req_s, int_ack_s,data_flag : std_logic; 
signal data_x, data_y, data_z : std_logic_vector(15 downto 0); 

begin
	
	gumnut_ports: adxl345_inter port map (CLK,RST_n,port_cyc_o_s, port_stb_o_s, port_we_o_s,port_ack_i_s,port_adr_o_s,port_dat_o_s,
													  port_dat_i_s,int_req_s, int_ack_s,data_x, data_y, data_z,data_flag);
	
	pmod_acc : pmod_accelerometer_adxl345 generic map (10_000_000,"0100","00")
													  port map (CLK,RST_n,MISO,SCLK,SS_n,MOSI,data_x, data_y, data_z, data_flag);

end behavioral;