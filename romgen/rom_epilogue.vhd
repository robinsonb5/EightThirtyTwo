		others => (others => x"00")
	);
	signal q1_local : word_t;
	signal q2_local : word_t;  

	-- Xilinx XST attributes
	attribute ram_style: string;
	attribute ram_style of ram: signal is "no_rw_check";

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(from_soc.memAAddr(maxAddrBitBRAM downto 2)));
	addr2 <= to_integer(unsigned(from_soc.memBAddr(maxAddrBitBRAM downto 2)));

	-- Reorganize the read data from the RAM to match the output
	unpack: for i in 0 to BYTES - 1 generate    
		data_out1(BYTE_WIDTH*(i+1) - 1 downto BYTE_WIDTH*i) <= q1_local((BYTES-1)-i);
		data_out2(BYTE_WIDTH*(i+1) - 1 downto BYTE_WIDTH*i) <= q2_local((BYTES-1)-i);    
	end generate unpack;
        
	process(clk)
	begin
		if(falling_edge(clk)) then 
			if(we1 = '1') then
				-- edit this code if using other than four bytes per word
				if(be1(3) = '1') then
					ram(addr1)(3) <= data_in1(7 downto 0);
				end if;
				if be1(2) = '1' then
					ram(addr1)(2) <= data_in1(15 downto 8);
				end if;
				if be1(1) = '1' then
					ram(addr1)(1) <= data_in1(23 downto 16);
				end if;
				if be1(0) = '1' then
					ram(addr1)(0) <= data_in1(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;

	process(clk)
	begin
		if(falling_edge(clk)) then 
			if(we2 = '1') then
				-- edit this code if using other than four bytes per word
				if(be2(3) = '1') then
					ram(addr2)(3) <= data_in2(7 downto 0);
				end if;
				if be2(2) = '1' then
					ram(addr2)(2) <= data_in2(15 downto 8);
				end if;
				if be2(1) = '1' then
					ram(addr2)(1) <= data_in2(23 downto 16);
				end if;
				if be2(0) = '1' then
					ram(addr2)(0) <= data_in2(31 downto 24);
				end if;
			end if;
			q2_local <= ram(addr2);
		end if;
	end process;  
  
end rtl;
