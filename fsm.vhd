-------------------------------------------------------------------------------
-- Entity: fsm
-- Author: Felder Mario
-- Date  : 29. April 2014
-------------------------------------------------------------------------------
-- Description: (ECS Testat 1)
-- Calculator mit FSM 
-------------------------------------------------------------------------------
-- Total # of FFs: 88 + 8 + 3 = 99
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
   generic(
		CLK_FRQ : integer := 50_000_000 -- 50 MHz = 0x2FAF080 (26 bits)
		);
	port(
		rst 		: in  std_logic;
      clk 		: in  std_logic;
		enter		: in	std_logic;
		add		: in	std_logic;
		sub		: in	std_logic;
		mul		: in	std_logic;
		sw			: in	std_logic_vector (3 downto 0);
		
		go_add	: out std_logic;
		go_sub	: out std_logic;
		go_mul	: out std_logic;
		wa_done	: out std_logic;
		wb_done	: out std_logic;
		wa			: out std_logic_vector (7 downto 0);
		wb			: out std_logic_vector (7 downto 0));
end fsm;

architecture RTL of fsm is


	-- Sync-Array
	type t_sync_ar is array (0 to 1) of std_logic_vector(7 downto 0);
	signal in_sync	:	t_sync_ar;
	signal sync_sw	:	std_logic_vector(3 downto 0);
	signal sync_enter	: std_logic;
	signal sync_add	: std_logic;
	signal sync_sub	: std_logic;
	signal sync_mul	: std_logic;

	-- Debouncing
	signal debounced	: std_logic_vector(3 downto 0);
	
	-- FSM-State
	type state is (s_init, s_op_a, s_op_b, s_done);
	signal c_st, n_st : state;
  
begin

	p_sync: process (rst, clk)
	begin
		if rst = '1' then
			in_sync <= (others => (others => '0'));
		elsif rising_edge(clk) then
			--first stage sync FFs
			in_sync(0)(3 downto 0) <= debounced;
			in_sync(0)(7 downto 4) <= sw;
			--second stage sync FFs
			in_sync(1) <= in_sync(0);
		end if;
	end process;
	
	
	-----------------------------------------------------------------------------
	-- FSM: Mealy-type
	-- Inputs : db_enter, db_sub, db_add, db_mul
	-- Outputs: wa, wa_done, wb, wb_done, go_add, go_sub, go_mul
	-----------------------------------------------------------------------------
	-- memoryless process
	p_fsm_com: process (c_st, sync_enter, sync_sub, sync_add, sync_mul, sync_sw)
	begin
		-- default assignments
		n_st <= c_st; -- remain in current state
		go_add  <= '0'; 
		go_sub  <= '0'; 
		go_mul 	<= '0'; 
		wa_done <= '0'; 
		wb_done <= '0'; 
		wa	<= (others => '0');
		wa	<= (others => '0');

		-- specific assignments
		case c_st is
			when s_init =>
				if sync_enter = '1' then
					wa <= sync_sw(3) & sync_sw & "000";
					wa_done <= '1';
					n_st <= s_op_a;
				end if;
			when s_op_a =>
				if sync_enter = '1' then
					wb <= sync_sw(3) & sync_sw(3) & sync_sw(3) & sync_sw & '0';
					wb_done <= '1';
					n_st <= s_op_b;
				end if;
			when s_op_b =>
				if sync_add = '1' then
					go_add <= '1';
					n_st <= s_done;
				elsif sync_sub = '1' then
					go_sub <= '1';
					n_st <= s_done;
				elsif sync_mul = '1' then
					go_mul <= '1';
					n_st <= s_done;
				end if;			
			when s_done =>
			  null;           -- need reset to leave this state
			when others =>
			  n_st <= s_done; -- handle parasitic states
		end case;
	end process;
	----------------------------------------------------------------------------- 

	----------------------------------------------------------------------------- 
	-- sequential process
	-- # of FFs: 2 (assuming binary state encoding)
	p_fsm_seq: process(rst, clk)
	begin
	 if rst = '1' then
		c_st <= s_init;
	 elsif rising_edge(clk) then
		c_st <= n_st;
	 end if;
	end process;
	
	
	p_blank_cnt: process(rst, clk)
	begin
		if rst = '1' then
			blnk_cnt <= '0';
		elsif rising_edge(clk) then
			if blnk_cnt < BLNK_TIME then
				blnk_cnt <= blnk_cnt + 1;
			else
				blnk_cnt <= '0';
				debounced(0) <= enter;
				debounced(1) <= add;
				debounced(2) <= sub;
				debounced(3) <= mul;				
		end if
	end process;

end RTL;

