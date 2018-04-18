----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:32:51 04/10/2018 
-- Design Name: 
-- Module Name:    FSM - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM is
    Port ( rowRead : in  STD_LOGIC_VECTOR (7 downto 0);
           btn : in  STD_LOGIC;
           updateClk : in  STD_LOGIC;
           Val : out  STD_LOGIC_VECTOR (2 downto 0);
           rowWrite : out  STD_LOGIC;
           writeStrobe : out  STD_LOGIC;
           level : out  STD_LOGIC);
end FSM;

architecture Behavioral of FSM is

begin


end Behavioral;

