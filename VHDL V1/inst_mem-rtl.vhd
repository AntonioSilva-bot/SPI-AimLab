architecture rtl of inst_mem is

  constant IMem : IMem_array := work.gasm_text.program;

begin

  dat_o <= std_logic_vector(IMem(to_integer(adr_i)));

  ack_o <= cyc_i and stb_i;

end architecture rtl;
