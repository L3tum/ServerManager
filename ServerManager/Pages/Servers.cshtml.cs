#region usings

using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using ServerManager.Models;

#endregion

namespace ServerManager.Pages
{
	public class ServersModel : PageModel
	{
		private readonly ServerManager.Models.ServerManager _context;

		public ServersModel(ServerManager.Models.ServerManager context)
		{
			_context = context;
		}

		public IList<Server> Servers { get; set; }
		public string Layout { get; set; }

		public async Task OnGetAsync([FromQuery(Name = "layout")] string layout)
		{
			Layout = layout;
			Servers = await _context.Servers.ToListAsync();
		}
	}
}