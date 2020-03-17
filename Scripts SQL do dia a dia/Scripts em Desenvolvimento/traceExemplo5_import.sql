use MonitoramentoDBA
SELECT * INTO Profiler_GEDM20150514
FROM::fn_trace_gettable('\\10.1.114.30\sql$\Trace3semana.trc', default)