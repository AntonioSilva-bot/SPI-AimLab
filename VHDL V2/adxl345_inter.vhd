---
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adxl345_inter is
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
end adxl345_inter;

architecture behavioral of adxl345_inter is
--ID ACCELEROMETER
constant ID_ACC_X1 : std_logic_vector(7 downto 0) := X"D1";
constant ID_ACC_X2 : std_logic_vector(7 downto 0) := X"D2";
constant ID_ACC_Y1 : std_logic_vector(7 downto 0) := X"D3";
constant ID_ACC_Y2 : std_logic_vector(7 downto 0) := X"D4";
constant ID_ACC_Z1 : std_logic_vector(7 downto 0) := X"D5";
constant ID_ACC_Z2 : std_logic_vector(7 downto 0) := X"D6";
--ID FOR FLAG
constant ID_FLAG : std_logic_vector(7 downto 0) := X"13";

signal data_x_pres,data_x_next : std_logic_vector(15 downto 0);
signal data_y_pres,data_y_next : std_logic_vector(15 downto 0);
signal data_z_pres,data_z_next : std_logic_vector(15 downto 0);

signal tmp : std_logic_vector(7 downto 0);

--flip-flops type p
signal ffp_flag_pres, ffp_flag_next : std_logic;


begin
		--manejo de FFD y registros
		sequential : process(CLK, RST_n)
						 begin
							if(RST_n = '1') then
													data_x_pres <= (others => '0');
													data_y_pres <= (others => '0');
													data_z_pres <= (others => '0');
													ffp_flag_pres <= '0';
													--reg_pres  <= (others => '0');
												
							elsif(CLK'event and CLK = '1') then
													data_x_pres <= data_x_next;
													data_y_pres <= data_y_next;
													data_z_pres <= data_z_next;
													ffp_flag_pres <= ffp_flag_next;
													--reg_pres  <= reg_next;

							end if;
						 end process sequential;
						 
		--interrupcion				 
		INT_REQ <= ffp_flag_pres;
		ffp_flag_next <= '1' when (flag ='1') else
						 '0' when (INT_ACK = '1') else
						 ffp_flag_pres;
		
		tmp <= "0000000" & flag;
		
		--lectura de datos del sensor
		data_x_next <= acceleration_x when (flag = '1') else data_x_pres;
		data_y_next <= acceleration_y when (flag = '1') else data_y_pres;
		data_z_next <= acceleration_z when (flag = '1') else data_z_pres;
		
		--acceso de lectura para ejes x & y
		PORT_DAT_O <= tmp when (PORT_ADR_I = ID_FLAG and PORT_CYC_I = '1' and PORT_STB_I = '1' and PORT_WE_I = '0') else
					  data_x_pres(15 DOWNTO 8) when (PORT_ADR_I = ID_ACC_X1 and PORT_CYC_I = '1' and PORT_STB_I = '1' and PORT_WE_I = '0') else 
		           data_x_pres(7 DOWNTO 0) when (PORT_ADR_I = ID_ACC_X2 and PORT_CYC_I = '1' and PORT_STB_I = '1' and PORT_WE_I = '0') else
					  data_y_pres(15 DOWNTO 8) when (PORT_ADR_I = ID_ACC_Y1 and PORT_CYC_I = '1' and PORT_STB_I = '1' and PORT_WE_I = '0') else
					  data_y_pres(7 DOWNTO 0) when (PORT_ADR_I = ID_ACC_Y2 and PORT_CYC_I = '1' and PORT_STB_I = '1' and PORT_WE_I = '0') else  
					  (others => '0');
				   
		--asignacion de acknowledge
		PORT_ACK_O <= PORT_CYC_I and PORT_STB_I;
		
end behavioral;