-------------------------------------------------------------------------------
-- Entity: clc
-- Author: Felder Mario
-- Date  : 29. April 2014
-------------------------------------------------------------------------------
-- Description: (ECS Testat 1)
-- Calculator mit FSM 
-------------------------------------------------------------------------------
-- Total # of FFs: 9
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clc is
	port(
		rst		: in	std_logic;
		clk		: in	std_logic;
		add		: in	std_logic;
		sub		: in	std_logic;
		mul		: in	std_logic;
		wa_done	: in 	std_logic;
		wb_done	: in	std_logic;
		op		: in 	std_logic_vector (3 downto 0);
		
		clc_done: out	std_logic;
		result	: out std_logic_vector (7 downto 0));
end clc;

architecture RTL of clc is

	signal wa	: std_logic_vector (3 downto 0);
	signal wb	: std_logic_vector (3 downto 0);
	

begin
	
	-----------------------------------------------------------------------------
	-- sequential process: Get operand
	p_get_op: process(clk, op)
	begin
		if rising_edge(clk) then
			if wb_done = '1' then
				wb <= op;
			elsif wa_done = '1' then
				wa <= op;
			end if;	
		end if;
	end process;

	-----------------------------------------------------------------------------
	-- sequential process: Calculation
	p_clc: process(rst, clk)
		variable op_a :	signed(7 downto 0);
		variable op_b :	signed(7 downto 0);
		variable res  : signed(15 downto 0);
	begin
	 if rst = '1' then
		result <= (others => '0');
		clc_done <= '0';
	 elsif rising_edge(clk) then
		op_a := signed(wa(3) & wa & "000");
		op_b := signed(wb(3) & wb(3) & wb(3) & wb & '0');
		if add = '1' then
		  result <= std_logic_vector(op_a + op_b);
		  clc_done <= '1';
		elsif sub = '1' then
		  result <= std_logic_vector(op_a - op_b);
		  clc_done <= '1';
		elsif mul = '1' then
		  res := op_a * op_b;
		  result <= std_logic_vector(res(11 downto 4));
		  clc_done <= '1';
		end if;
	 end if;
	end process;
	-----------------------------------------------------------------------------
end RTL;