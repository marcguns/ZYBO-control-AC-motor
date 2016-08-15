--Design: PWM_AC; control of AC motor with sinusoidal PWM
--Device: zynq

----- CELL COMPM16_HXILINX_PWM_AC -----  
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;

entity COMPM16_HXILINX_PWM_AC is
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A   : in std_logic_vector(15 downto 0);
    B   : in std_logic_vector(15 downto 0)
  );
end COMPM16_HXILINX_PWM_AC;

architecture COMPM16_HXILINX_PWM_AC_V of COMPM16_HXILINX_PWM_AC is
begin
     
  GT <= '1' when ( A > B ) else '0';
  LT <= '1' when ( A < B ) else '0';

end COMPM16_HXILINX_PWM_AC_V;

----- CELL CC16CLED_HXILINX_PWM_AC -----
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CC16CLED_HXILINX_PWM_AC is
port (
        CEO : out STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR(15 downto 0);
        TC  : out STD_LOGIC;
        C   : in STD_LOGIC;
        CE  : in STD_LOGIC;
        CLR : in STD_LOGIC;
        D   : in STD_LOGIC_VECTOR(15 downto 0);
        L   : in STD_LOGIC;
        UP  : in STD_LOGIC);
end CC16CLED_HXILINX_PWM_AC;

architecture Behavioral of CC16CLED_HXILINX_PWM_AC is

  signal COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

  constant TERMINAL_COUNT_UP : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');
  constant TERMINAL_COUNT_DOWN : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
    elsif (C'event and C = '1') then
      if (L = '1') then
        COUNT <= D;
      elsif (CE='1') then
        if (UP='1') then
          COUNT <= COUNT+1;
        elsif (UP='0') then
          COUNT <= COUNT-1;
        end if;
      end if;
  end if;
end process;

TC <=    '0' when (CLR = '1') else
         '1' when (((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or 
	((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0'))) else '0'; 

CEO <= '1' when (((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or 
	 ((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0')))  and CE='1' else '0';
Q <= COUNT;

end Behavioral;

----- CELL CB16CE_HXILINX_PWM_AC -----
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CB16CE_HXILINX_PWM_AC is
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end CB16CE_HXILINX_PWM_AC;

architecture Behavioral of CB16CE_HXILINX_PWM_AC is

  signal COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC  <= '1' when (COUNT = TERMINAL_COUNT) else '0';
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';
Q   <= COUNT;

end Behavioral;

----------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity PWM_AC is
   port ( Clk      : in    std_logic; 
          Periode32: in    std_logic_vector (31 downto 0);
          Gain32   : in    std_logic_vector (31 downto 0);
          PWM      : out   std_logic; 
          PWMcompl : out   std_logic);
end PWM_AC;

architecture BEHAVIORAL of PWM_AC is
   attribute HU_SET     : string ;
   attribute BOX_TYPE   : string ;
   signal Een      : std_logic;
   signal Nul      : std_logic;
   signal XLXN_54  : std_logic;
   signal Adr      : std_logic_vector (15 downto 0);
   signal Sinus    : std_logic_vector (15 downto 0);
   signal NewSinus : std_logic_vector (16 downto 0);
   signal Constante: std_logic_vector(15 downto 0);
   signal CompIn   : std_logic_vector(15 downto 0);   
   signal Laad     : std_logic;
   
   COMPONENT xbip_dsp48_macro_0
      PORT (
        CLK : IN STD_LOGIC;
        A : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        P : OUT STD_LOGIC_VECTOR(16 DOWNTO 0)
      );
   END COMPONENT;

    COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
       douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
    END COMPONENT;
  
   component CC16CLED_HXILINX_PWM_AC
      port ( C   : in    std_logic; 
             CE  : in    std_logic; 
             CLR : in    std_logic; 
             D   : in    std_logic_vector (15 downto 0); 
             L   : in    std_logic; 
             UP  : in    std_logic; 
             CEO : out   std_logic; 
             Q   : out   std_logic_vector (15 downto 0); 
             TC  : out   std_logic);
   end component;
   
   component CB16CE_HXILINX_PWM_AC
      port ( C   : in    std_logic; 
             CE  : in    std_logic; 
             CLR : in    std_logic; 
             CEO : out   std_logic; 
             Q   : out   std_logic_vector (15 downto 0); 
             TC  : out   std_logic);
   end component;
   
   component COMPM16_HXILINX_PWM_AC
      port ( A  : in    std_logic_vector (15 downto 0); 
             B  : in    std_logic_vector (15 downto 0); 
             GT : out   std_logic; 
             LT : out   std_logic);
   end component;
   
   component GND
      port ( G : out   std_logic);
   end component;
   attribute BOX_TYPE of GND : component is "BLACK_BOX";
   
   component VCC
      port ( P : out   std_logic);
   end component;
   attribute BOX_TYPE of VCC : component is "BLACK_BOX";
      
   attribute HU_SET of XLXI_3 : label is "XLXI_3_2";
   attribute HU_SET of XLXI_4 : label is "XLXI_4_1";
   attribute HU_SET of XLXI_6 : label is "XLXI_6_0";
   
begin

   Constante(15 downto 0) <= x"0C35";    

   Multiplier : xbip_dsp48_macro_0
      PORT MAP (
        CLK => Clk,
        A => Sinus(15 downto 0),
        B => Gain32(7 downto 0),
        P => NewSinus(16 downto 0));

   ROMSine : blk_mem_gen_0
     PORT MAP (
       clka => Clk,
       addra => Adr(10 downto 0),
       douta => Sinus(15 downto 0));

   Zaagtand : CC16CLED_HXILINX_PWM_AC
      port map (C=>Clk,
                CE=>Een,
                CLR=>Nul,
                D(15 downto 0)=>Constante(15 downto 0),
                L=>Laad,
                UP=>Nul,
                CEO=>Laad,
                Q=>CompIn(15 downto 0),
                TC=>open);
   
   XLXI_3 : CC16CLED_HXILINX_PWM_AC
      port map (C=>Clk,
                CE=>Een,
                CLR=>Nul,
                D(15 downto 0)=>Periode32(15 downto 0),
                L=>XLXN_54,
                UP=>Nul,
                CEO=>XLXN_54,
                Q=>open,
                TC=>open);
   
   XLXI_4 : CB16CE_HXILINX_PWM_AC
      port map (C=>Clk,
                CE=>XLXN_54,
                CLR=>Nul,
                CEO=>open,
                Q(15 downto 0)=>Adr(15 downto 0),
                TC=>open);
   
   XLXI_6 : COMPM16_HXILINX_PWM_AC
      port map (A(15 downto 0)=>CompIn(15 downto 0),
                B(15 downto 0)=>NewSinus(15 downto 0),
                GT=>PWM,
                LT=>PWMcompl);
   
   XLXI_14 : GND
      port map (G=>Nul);
   
   XLXI_15 : VCC
      port map (P=>Een);
   
end BEHAVIORAL;
