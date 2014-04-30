-------------------------------------------------------------------------------
-- Entity: led_cntrl
-- Author: Felder Mario
-- Date  : 29. April 2014
-------------------------------------------------------------------------------
-- Description: (ECS Testat 1)
-- Calculator mit FSM 
-------------------------------------------------------------------------------
-- Total # of FFs: 8
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_ctrl is
	port(
		rst 		: in  std_logic;
		clk 		: in  std_logic;
		wa_done 	: in  std_logic;
		wb_done		: in  std_logic;
		clc_done 	: in  std_logic;
		op 			: in  std_logic_vector (3 downto 0);
		result 		: in  std_logic_vector (7 downto 0);
		
		led_out 	: out  std_logic_vector (7 downto 0));
end led_ctrl;

architecture RTL of led_ctrl is

begin
	-----------------------------------------------------------------------------
	-- sequential process: LED Control
	-- # of FFs: 8
	p_led_ctrl: process(rst, clk)
	begin
		if rst = '1' then
			led_out <= (others => '0');
		elsif rising_edge(clk) then
			if clc_done = '1' then
				led_out <= result;
			elsif wb_done = '1' then
				led_out <= op(3) & op(3) & op(3) & op & '0';
			elsif wa_done = '1' then
				led_out <= op(3) & op & "000";
			end if;
		end if;
	end process;
	-----------------------------------------------------------------------------
end RTL;