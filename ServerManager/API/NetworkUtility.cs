#region usings

using System.Diagnostics;
using System.Net;
using System.Net.NetworkInformation;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

#endregion

namespace ServerManager.API
{
	public class NetworkUtility
	{
		/// <summary>
		/// Gets the mac.
		/// </summary>
		/// <param name="ip">The ip.</param>
		/// <returns></returns>
		public async Task<string> GetMac(string ip)
		{
			var reachable = await IsReachable(ip);

			if (!reachable)
			{
				return string.Empty;
			}

			string command = $"arp -a {ip}";
			string mac;

			if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
			{
				var process = new Process
				{
					StartInfo = new ProcessStartInfo
					{
						FileName = "cmd.exe",
						Arguments = $@"/c {command}",
						RedirectStandardOutput = true,
						UseShellExecute = false,
						CreateNoWindow = true
					}
				};
				process.Start();

				string result = process.StandardOutput.ReadToEnd();

				process.WaitForExit();

				StringBuilder sb = new StringBuilder();
				string pattern = @"(([a-f0-9]{2}-?){6})";
				int i = 0;

				foreach (Match m in Regex.Matches(result, pattern, RegexOptions.IgnoreCase))
				{
					if (i > 0)
						sb.Append(";");
					sb.Append(m);
					i++;
				}

				mac = sb.ToString();
			}
			else
			{
				var escapedArgs = command.Replace("\"", "\\\"");

				var process = new Process
				{
					StartInfo = new ProcessStartInfo
					{
						FileName = "/bin/bash",
						Arguments = $"-c \"{escapedArgs}\"",
						RedirectStandardOutput = true,
						UseShellExecute = false,
						CreateNoWindow = true
					}
				};
				process.Start();

				string result = process.StandardOutput.ReadToEnd();

				process.WaitForExit();

				StringBuilder sb = new StringBuilder();
				string pattern = @"(([a-f0-9]{2}:?){6})";
				int i = 0;

				foreach (Match m in Regex.Matches(result, pattern, RegexOptions.IgnoreCase))
				{
					if (i > 0)
						sb.Append(";");
					sb.Append(m);
					i++;
				}

				mac = sb.ToString();
			}

			return mac;
		}

		/// <summary>
		/// Determines whether the specified ip is reachable.
		/// </summary>
		/// <param name="ip">The ip.</param>
		/// <returns></returns>
		public async Task<bool> IsReachable(string ip)
		{
			using (Ping ping = new Ping())
			{
				for (var i = 0; i < 10; i++)
				{
					var reply = await ping.SendPingAsync(ip, 100);

					if (reply.Status == IPStatus.Success)
					{
						return true;
					}
				}
			}

			return false;
		}

		/// <summary>
		/// Gets the broadcast address.
		/// </summary>
		/// <param name="ip">The ip.</param>
		/// <param name="subnet">The subnet.</param>
		/// <returns></returns>
		public string GetBroadcast(string ip, string subnet)
		{
			byte[] ipAdressBytes = IPAddress.Parse(ip).GetAddressBytes();
			byte[] subnetMaskBytes = IPAddress.Parse(subnet).GetAddressBytes();

			if (ipAdressBytes.Length != subnetMaskBytes.Length)
				return string.Empty;

			byte[] broadcastAddress = new byte[ipAdressBytes.Length];
			for (int i = 0; i < broadcastAddress.Length; i++)
			{
				broadcastAddress[i] = (byte) (ipAdressBytes[i] | (subnetMaskBytes[i] ^ 255));
			}

			return new IPAddress(broadcastAddress).ToString();
		}

		/// <summary>
		/// Determines whether [is valid ip] [the specified ip].
		/// </summary>
		/// <param name="ip">The ip.</param>
		/// <returns></returns>
		public bool IsValidIP(string ip)
		{
			return IPAddress.TryParse(ip, out IPAddress ipa);
		}
	}
}