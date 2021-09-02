using System;
using Topshelf;
using WinNUT_client;

namespace WinNUT_service
{
    class Program
    {
        static void Main(string[] args)
        {
            WinNUT_Globals.Init_Globals();
            WinNUT_Params.Init_Params();
            WinNUT_Params.Load_Params();

            var logger = new Logger(true, LogLvl.LOG_DEBUG);
            logger.WriteLog = bool.Parse("" + WinNUT_Params.Arr_Reg_Key["UseLogFile"]);
            logger.LogLevel = (LogLvl)Enum.Parse(typeof(LogLvl), "" + WinNUT_Params.Arr_Reg_Key["Log Level"]);

            HostFactory.Run(configure =>
            {
                configure.Service<WatcherService>(service =>
                {
                    service.ConstructUsing(s => new WatcherService(logger));
                    service.WhenStarted(s => { s.Start(); });
                    service.WhenStopped(s => { s.Stop(); });
                });

                configure.OnException(ex => { logger.LogTracing(ex.Message, (int)LogLvl.LOG_ERROR, configure); });
                configure.SetServiceName("WinNut-service");
                configure.SetDisplayName("WinNut-service");
                configure.SetDescription("WinNUT - Service for manager UPS based shutdown");
            });
        }
    }
}
