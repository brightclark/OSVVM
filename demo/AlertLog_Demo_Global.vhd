--
--  File Name:         AlertLog_Demo_Global.vhd
--  Design Unit Name:  AlertLog_Demo_Global
--  Revision:          STANDARD VERSION,  2015.01
--
--  Copyright (c) 2015 by SynthWorks Design Inc.  All rights reserved.
--
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      email:  jim@synthworks.com
--
--  Description:
--    Demo showing use of the global counter in AlertLogPkg
--
--  Developed for:
--		SynthWorks Design Inc.
--		Training Courses
--		11898 SW 128th Ave.
--		Tigard, Or  97223
--		http://www.SynthWorks.com
--
--
--  Revision History:
--    Date      Version    Description
--    01/2015   2015.01    Refining tests
--    02/2016   Try 4      Dev Cadence 
--                         Changed wait for 0 ns before SetLogEnable in TbP1 to wait for 1 ns 
--    02/2016   Try 5      Changed concurrent call to SetLogEnble in block Uart_1 to
--                         be in a process and have a wait for 1 ns before it.
--    02/2016   Try 9      Added wait for 1 ns before call to SetAlertLogName.  
--                         To allow time for data structure to be created.
--
--
--  Copyright (c) 2015 by SynthWorks Design Inc.  All rights reserved.
--
--  Verbatim copies of this source file may be used and
--  distributed without restriction.
--
--  This source file is free software; you can redistribute it
--  and/or modify it under the terms of the ARTISTIC License
--  as published by The Perl Foundation; either version 2.0 of
--  the License, or (at your option) any later version.
--
--  This source is distributed in the hope that it will be
--  useful, but WITHOUT ANY WARRANTY; without even the implied
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
--  PURPOSE. See the Artistic License for details.
--
--  You should have received a copy of the license with this source.
--  If not download it from,
--     http://www.perlfoundation.org/artistic_license_2_0
--

library IEEE ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

  use std.textio.all ;
  use ieee.std_logic_textio.all ;

library osvvm ;
  use osvvm.OsvvmGlobalPkg.all ;
  use osvvm.TranscriptPkg.all ;
  use osvvm.AlertLogPkg.all ;

entity AlertLog_Demo_Global is
end AlertLog_Demo_Global ;
architecture hierarchy of AlertLog_Demo_Global is
  signal Clk : std_logic := '0'; 
  
begin

  Clk <= not Clk after 10 ns ; 
  
  
  -- /////////////////////////////////////////////////////////////
  -- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  Testbench_1 : block 
  begin
  
    TbP0 : process
      variable ClkNum : integer := 0 ; 
    begin
      wait until Clk = '1' ; 
      ClkNum := ClkNum + 1 ; 
      print(LF & "Clock Number " & to_string(ClkNum)) ; 
    end process TbP0 ; 
  
    ------------------------------------------------------------
    TbP1 : process
    begin
-- Uncomment this line for Dev Cadence Try 6
      -- InitializeAlertLogStruct ; 
-- Uncomment this line to use a log file rather than OUTPUT
      -- TranscriptOpen("./Demo_Global.txt") ;   
-- Uncomment this line and the simulation will stop after 15 errors  
      -- SetAlertStopCount(ERROR, 15) ; 
      wait for 1 ns ;   -- make sure all processes have elaborated
      SetAlertLogName("AlertLog_Demo_Global") ; 
      wait for 1 ns ;   -- make sure all processes have elaborated
      SetLogEnable(DEBUG, TRUE) ;  -- Enable DEBUG Messages for all levels of the hierarchy
      
-- Uncomment this line to justify alert and log reports  
      -- SetAlertLogJustify ; 
      for i in 1 to 5 loop 
        wait until Clk = '1' ; 
        if i = 4 then  SetLogEnable(DEBUG, FALSE) ;  end if ;  -- DEBUG Mode OFF
        wait for 1 ns ; 
        Alert("Tb.P1.E alert " & to_string(i) & " of 5") ; -- ERROR by default
        Log  ("Tb.P1.D log   " & to_string(i) & " of 5", DEBUG) ; 
      end loop ;
      wait until Clk = '1' ; 
      wait until Clk = '1' ; 
      wait for 1 ns ; 
      ReportAlerts ;   
      print("") ; 
      -- Report Alerts with expected errors expressed as a negative ExternalErrors value
      ReportAlerts(Name => "AlertLog_Demo_Hierarchy with expected errors", ExternalErrors => -(FAILURE => 0, ERROR => 20, WARNING => 15)) ; 
      TranscriptClose ; 
      print(LF & "The following is brought to you by std.env.stop(0):") ; 
      std.env.stop(0) ; 
      wait ; 
    end process TbP1 ; 

    ------------------------------------------------------------
    TbP2 : process
    begin
      for i in 1 to 5 loop 
        wait until Clk = '1' ; 
        wait for 2 ns ; 
        Alert("Tb.P2.E alert " & to_string(i) & " of 5", ERROR) ; 
        -- example of a log that is not enabled, so it does not print
        Log  ("Tb.P2.I log   " & to_string(i) & " of 5", INFO) ; 
      end loop ;
      wait until Clk = '1' ; 
      wait for 2 ns ; 
-- Uncomment this line to and the simulation will stop here
      -- Alert("Tb.P2.F Message 1 of 1", FAILURE) ; 
      wait ; 
    end process TbP2 ;

    ------------------------------------------------------------
    TbP3 : process
    begin
      for i in 1 to 5 loop 
        wait until Clk = '1' ; 
        wait for 3 ns ; 
        Alert("Tb.P3.W alert " & to_string(i) & " of 5", WARNING) ; 
      end loop ;
      wait ; 
    end process TbP3 ; 
  end block Testbench_1 ; 

  
  -- /////////////////////////////////////////////////////////////
  -- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  Cpu_1 : block 
  begin
  
    ------------------------------------------------------------
    CpuP1 : process
    begin
      for i in 1 to 5 loop 
        wait until Clk = '1' ; 
        wait for 5 ns ; 
        Alert("Cpu.P1.E Message " & to_string(i) & " of 5", ERROR) ; 
        Log  ("Cpu.P1.D log   " & to_string(i) & " of 5", DEBUG) ; 
        Log  ("Cpu.P1.F log   " & to_string(i) & " of 5", FINAL) ;   -- enabled by Uart_1      
      end loop ;
      wait ; 
    end process CpuP1 ; 

    ------------------------------------------------------------
    CpuP2 : process
    begin
      for i in 1 to 5 loop 
        wait until Clk = '1' ; 
        wait for 6 ns ; 
        Alert("Cpu.P2.W Message " & to_string(i) & " of 5", WARNING) ; 
        Log  ("Cpu.P2.I log   " & to_string(i) & " of 5", INFO) ; 
      end loop ;
      wait ; 
    end process CpuP2 ;
  end block Cpu_1 ;     
  

  -- /////////////////////////////////////////////////////////////
  -- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  Uart_1 : block 
  begin
    -- Enable FINAL logs for every level
    -- Note it is expected that most control of alerts will occur only in the testbench block
    -- Note that this also turns on FINAL messages for CPU - see hierarchy for better control
    UartInit : process 
    begin 
      wait for 5 ns ; -- make it so we don't debug this path first.
      SetLogEnable(FINAL, TRUE) ;   -- Runs once at initialization time
      wait ; 
    end process ; 
  
    ------------------------------------------------------------
    UartP1 : process
    begin
      for i in 1 to 5 loop 
        wait until Clk = '1' ; 
        wait for 10 ns ; 
        Alert("Uart.P1.E alert " & to_string(i) & " of 5") ; -- ERROR by default
        Log  ("UART.P1.D log   " & to_string(i) & " of 5", DEBUG) ; 
      end loop ;
      wait ; 
    end process UartP1 ; 

    ------------------------------------------------------------
    UartP2 : process
    begin
      for i in 1 to 5 loop 
        wait until Clk = '1' ; 
        wait for 11 ns ; 
        Alert("Uart.P2.W alert " & to_string(i) & " of 5", WARNING) ;
        -- Info not enabled
        Log  ("UART.P2.I log   " & to_string(i) & " of 5", INFO) ; 
        Log  ("UART.P2.F log   " & to_string(i) & " of 5", FINAL) ; 
      end loop ;
      wait ; 
    end process UartP2 ;
  end block Uart_1 ;     

end hierarchy ;