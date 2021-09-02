// WinNUT is a NUT windows client for monitoring your ups hooked up to your favorite linux server.
// Copyright (C) 2019-2021 Gawindx (Decaux Nicolas)
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY

using System;
using System.Management;
using System.Runtime.InteropServices;
using System.Timers;
using WinNUT_client;

namespace WinNUT_service
{
    public class WatcherService
    {
        private Timer _timer = new Timer(60000);
        private Logger _logger;
        private UPS_Network upsnet;

        public WatcherService(Logger logger)
        {
            _logger = logger;
            upsnet = new UPS_Network(ref _logger);
            upsnet.Stop_Shutdown += Upsnet_Stop_Shutdown;
            _timer.Elapsed += _timer_Elapsed;
        }

        private void _timer_Elapsed(object sender, ElapsedEventArgs e)
        {
            if (upsnet.IsConnected) { upsnet.Disconnect(); }
            WinNUT_Params.ReloadDataFromRegistry();

            _logger.WriteLog = bool.Parse("" + WinNUT_Params.Arr_Reg_Key["UseLogFile"]);
            _logger.LogLevel = (LogLvl)Enum.Parse(typeof(LogLvl), "" + WinNUT_Params.Arr_Reg_Key["Log Level"]);

            upsnet.NutHost = "" + WinNUT_Params.Arr_Reg_Key["ServerAddress"];
            upsnet.NutPort = int.Parse("" + WinNUT_Params.Arr_Reg_Key["Port"]);
            upsnet.NutUPS = "" + WinNUT_Params.Arr_Reg_Key["UPSName"];
            upsnet.NutDelay = int.Parse("" + WinNUT_Params.Arr_Reg_Key["Delay"]);
            upsnet.NutLogin = "" + WinNUT_Params.Arr_Reg_Key["NutLogin"];
            upsnet.NutPassword = "" + WinNUT_Params.Arr_Reg_Key["NutPassword"];
            upsnet.AutoReconnect = bool.Parse("" + WinNUT_Params.Arr_Reg_Key["AutoReconnect"]);
            upsnet.Battery_Limit = int.Parse("" + WinNUT_Params.Arr_Reg_Key["ShutdownLimitBatteryCharge"]);
            upsnet.Backup_Limit = int.Parse("" + WinNUT_Params.Arr_Reg_Key["ShutdownLimitUPSRemainTime"]);
            upsnet.UPS_Follow_FSD = bool.Parse("" + WinNUT_Params.Arr_Reg_Key["Follow_FSD"]);

            if (!upsnet.IsConnected) { upsnet.Connect(); }
        }

        public void Start()
        {
            _timer.Start();
            _timer_Elapsed(this, null);
            _logger.LogTracing("Service started", (int)LogLvl.LOG_NOTICE, this);
        }

        private void Upsnet_Stop_Shutdown()
        {
            var t = int.Parse("" + WinNUT_Params.Arr_Reg_Key["TypeOfStop"]);
            if (t == 0)
            {
                ManagementClass mcWin32 = new ManagementClass("Win32_OperatingSystem");
                mcWin32.Get();


                mcWin32.Scope.Options.EnablePrivileges = true; // You can't shutdown without security privileges
                ManagementBaseObject mboShutdownParams = mcWin32.GetMethodParameters("Win32Shutdown");

                mboShutdownParams["Flags"] = "1"; // Flag 1 means we want to shut down the system. Use "2" to reboot.
                mboShutdownParams["Reserved"] = "0";
                foreach (ManagementObject manObj in mcWin32.GetInstances()) { manObj.InvokeMethod("Win32Shutdown", mboShutdownParams, null); }
            }
            else if (t == 1) { SetSuspendState(false, true, true); } // sleep
            else if (t == 2) { SetSuspendState(true, true, true); } // hibernate
        }

        public void Stop() 
        {
            _logger.LogTracing("Service stopped", (int)LogLvl.LOG_NOTICE, this);
            _timer.Stop(); 
            if (upsnet.IsConnected) { upsnet.Disconnect(); }
        }

        [DllImport("Powrprof.dll", CharSet = CharSet.Auto, ExactSpelling = true)]
        public static extern bool SetSuspendState(bool hiberate, bool forceCritical, bool disableWakeEvent);
    }
}
