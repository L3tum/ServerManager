#region usings

using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

#endregion

namespace ServerManager.Models
{
	public class Server
	{
		public int ID { get; set; }

		[Required] public string Name { get; set; }

		[DefaultValue(false)] public bool Online { get; set; }

		[Required] public string IP { get; set; }

		[Required] public string Subnet { get; set; }

		[Required] public string MAC { get; set; }
	}
}