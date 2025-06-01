  others => ( others => '0')
);

-- Xilinx Vivado attributes
attribute ram_style: string;
attribute ram_style of ram: signal is "block";

signal q_local : std_logic_vector(7 downto 0);

signal wea : std_logic;

begin

	output:
	q<=q_local;
    
    wea <= sel and we;

    process(clk)
    begin
        if rising_edge(clk) then
            q_local <= ram(to_integer(unsigned(addr)));
            if (wea = '1') then
                ram(to_integer(unsigned(addr))) <= d;
            end if;
        end if;
    end process;

end architecture;

