LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity reg is
	generic (
		data_width : natural := 8
	);
	port (
		reset    : in  std_logic;
		clock    : in  std_logic;
		load     : in  std_logic;
		data_in  : in  std_logic_vector(data_width-1 downto 0);
		data_out : out std_logic_vector(data_width-1 downto 0)
	);
end entity;

architecture behavioral of reg is
begin
	process (clock, reset)
	begin
		if rising_edge(clock) and load = '1' then
			data_out <= data_in;
		end if;
		if reset = '0' then
			data_out <= (others => '0');
		end if;
	end process;
end architecture;
