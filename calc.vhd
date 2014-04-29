-------------------------------------------------------------------------------
-- Entity: calc
-- Author: Felder Mario
-- Date  : 29. April 2014
-------------------------------------------------------------------------------
-- Description: (ECS Testat 1)
-- Calculator mit FSM 
-------------------------------------------------------------------------------
-- Total # of FFs: 54 + 9 + 8 = 71
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calc is
   generic(
		CLK_FRQ : integer := 50_000_000 -- 50 MHz = 0x2FAF080 (26 bits)
		);
	port(
		rst 		: in  std_logic;
		clk 		: in  std_logic;
		ROT_C		: in  std_logic;
		BTN_NORTH	: in  std_logic;
		BTN_EAST 	: in  std_logic;
		BTN_WEST 	: in  std_logic;
		SW			: in 	std_logic_vector (3 downto 0);
		LED 		: out std_logic_vector (7 downto 0)
		);
end calc;

architecture struct of calc is

	component fsm is
	port(
		rst 	: in  std_logic;
		clk 	: in  std_logic;
		enter	: in	std_logic;
		add		: in	std_logic;
		sub		: in	std_logic;
		mul		: in	std_logic;
		sw		: in	std_logic_vector (3 downto 0);	

		go_add	: out std_logic;
		go_sub	: out std_logic;
		go_mul	: out std_logic;
		wa_done	: out std_logic;
		wb_done	: out std_logic;
		op		: out std_logic_vector (3 downto 0));
	end component fsm;
	
	component clc is
	port(
		rst		: in	std_logic;
		clk		: in	std_logic;
		add		: in	std_logic;
		sub		: in	std_logic;
		mul		: in	std_logic;
		wa_done	: in	std_logic;
		wb_done	: in	std_logic;
		op		: in 	std_logic_vector (3 downto 0);
		
		clc_done: out	std_logic;
		result	: out std_logic_vector (7 downto 0));
	end component clc;

	component led_ctrl is
	port(
		rst 	: in  std_logic;
		clk 	: in  std_logic;	
		wa_done : in  std_logic;
		wb_done	: in  std_logic;
		clc_done: in  std_logic;
		op 		: in  std_logic_vector (3 downto 0);
		result 	: in  std_logic_vector (7 downto 0);
		
		led_out 	: out  std_logic_vector (7 downto 0));
	end component led_ctrl;
	
	
	signal GO_ADD	: std_logic;
	signal GO_SUB	: std_logic;
	signal GO_MUL	: std_logic;
	signal WA_DONE 	: std_logic;
	signal WB_DONE 	: std_logic;
	signal CLC_DONE	: std_logic;
	signal OP		: std_logic_vector (3 downto 0);
	signal RESULT	: std_logic_vector (7 downto 0);

begin
	
	F1:fsm
	port map(
		--inputs
		rst		=>	rst,
		clk		=> clk,
		enter	=> ROT_C,
		add		=>	BTN_WEST,
		sub		=> BTN_EAST,
		mul		=> BTN_NORTH,
		sw		=> SW,
		--outputs
		go_add	=> GO_ADD,
		go_sub	=> GO_SUB,
		go_mul	=> GO_MUL,
		wa_done	=> WA_DONE,
		wb_done	=> WB_DONE,
		op			=> OP
	);
	
	C1:clc
	port map(
		--inputs
		rst		=> rst,
		clk		=> clk,
		add		=> GO_ADD,
		sub		=> GO_SUB,
		mul		=> GO_MUL,
		wa_done	=> WA_DONE,
		wb_done	=> WB_DONE,
		op		=> OP,
		--ouputs
		clc_done=> CLC_DONE,
		result	=> RESULT
	);
	
	LCTRL:led_ctrl
	port map(
		--inputs
		rst		=> rst,
		clk		=> clk,
		wa_done	=> WA_DONE,
		wb_done	=> WB_DONE,
		op 		=> OP,
		clc_done	=> CLC_DONE,
		result  	=> RESULT,
		--outputs
		led_out	=> LED
	);

end struct;

