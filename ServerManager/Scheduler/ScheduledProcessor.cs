#region usings

using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using NCrontab;
using ServerManager.BackgroundService;

#endregion

namespace ServerManager.Scheduler
{
	public abstract class ScheduledProcessor : ScopedProcessor
	{
		private DateTime _nextRun;
		private readonly CrontabSchedule _schedule;

		public ScheduledProcessor(IServiceScopeFactory serviceScopeFactory) : base(serviceScopeFactory)
		{
			_schedule = CrontabSchedule.Parse(Schedule);
			_nextRun = _schedule.GetNextOccurrence(DateTime.Now);
		}

		protected abstract string Schedule { get; }

		protected override async Task ExecuteAsync(CancellationToken stoppingToken)
		{
			do
			{
				var now = DateTime.Now;
				var nextrun = _schedule.GetNextOccurrence(now);
				if (now > _nextRun)
				{
					await Process();
					_nextRun = _schedule.GetNextOccurrence(DateTime.Now);
				}

				await Task.Delay(5000, stoppingToken); //5 seconds delay
			} while (!stoppingToken.IsCancellationRequested);
		}
	}
}