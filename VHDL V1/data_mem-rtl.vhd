architecture rtl of data_mem is

  signal DMem : DMem_array := work.gasm_data.data;
  signal read_ack : std_logic;

begin

  data_mem : process (clk_i) is
  begin
    if rising_edge(clk_i) then
      if to_X01(cyc_i) = '1' and to_X01(stb_i) = '1' then
        if to_X01(we_i) = '1' then
          DMem(to_integer(adr_i)) <= unsigned(dat_i);
          dat_o <= dat_i;
          read_ack <= '0';
        else
          dat_o <= std_logic_vector(DMem(to_integer(adr_i)));
          read_ack <= '1';
        end if;
      else
        read_ack <= '0';
      end if;
    end if;
  end process data_mem;

  ack_o <= cyc_i and stb_i and (we_i or read_ack);

end architecture rtl;
