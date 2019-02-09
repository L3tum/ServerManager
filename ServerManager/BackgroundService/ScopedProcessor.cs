#region usings

using System;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;

#endregion

namespace ServerManager.BackgroundService
{
	public abstract class ScopedProcessor : BackgroundService
	{
		private readonly IServiceScopeFactory _serviceScopeFactory;

		public ScopedProcessor(IServiceScopeFactory serviceScopeFactory)
		{
			_serviceScopeFactory = serviceScopeFactory;
		}

		protected override async Task Process()
		{
			using (var scope = _serviceScopeFactory.CreateScope())
			{
				await ProcessInScope(scope.ServiceProvider);
			}
		}

		public abstract Task ProcessInScope(IServiceProvider serviceProvider);
	}
}