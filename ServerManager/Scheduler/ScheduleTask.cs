#region usings

using System;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using ServerManager.API;
using ServerManager.Models;

#endregion

namespace ServerManager.Scheduler
{
	public class ScheduleTask : ScheduledProcessor
	{
		public ScheduleTask(IServiceScopeFactory serviceScopeFactory) : base(serviceScopeFactory)
		{
		}

		protected override string Schedule => "*/1 * * * *"; // every minute

		public override async Task ProcessInScope(IServiceProvider serviceProvider)
		{
			Models.ServerManager manager =
				serviceProvider.GetService(typeof(Models.ServerManager)) as Models.ServerManager;
			NetworkUtility network = serviceProvider.GetService(typeof(NetworkUtility)) as NetworkUtility;

			foreach (Server server in manager.Servers)
			{
				var reachable = await network.IsReachable(server.IP);

				if (reachable)
				{
					server.Online = true;
				}
				else
				{
					server.Online = false;
				}
			}

			await manager.SaveChangesAsync();
		}
	}
}