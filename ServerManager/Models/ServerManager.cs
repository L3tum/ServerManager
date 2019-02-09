#region usings

using Microsoft.EntityFrameworkCore;

#endregion

namespace ServerManager.Models
{
	public class ServerManager : DbContext
	{
		public ServerManager(DbContextOptions options) : base(options)
		{
		}

		public DbSet<Server> Servers { get; set; }
	}
}