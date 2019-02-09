#region usings

using System.Collections.Generic;
using System.Net.Sockets;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ServerManager.Models;

#endregion

namespace ServerManager.API
{
	[Produces("application/json")]
	[Route("api/[controller]")]
	[ApiController]
	public class ServerController : ControllerBase
	{
		private readonly Models.ServerManager context;
		private readonly NetworkUtility network;

		public ServerController(Models.ServerManager context, NetworkUtility network)
		{
			this.context = context;
			this.network = network;
		}

		// GET: api/Server
		/// <summary>
		/// Gets a specific server
		/// </summary>
		/// <param name="id"></param>
		/// <returns>A Server</returns>
		/// <response code="200">Returns the Server</response>
		/// <response code="404">If the Server does not exist.</response>
		[HttpGet("{id}")]
		[ProducesResponseType(typeof(Server), 200)]
		[ProducesResponseType(typeof(int), 404)]
		public async Task<IActionResult> GetServer([FromRoute] int id)
		{
			var server = await context.Servers.FindAsync(id);

			if (server == null)
			{
				return NotFound(id);
			}

			return Ok(server);
		}

		/// <summary>
		/// Gets all servers
		/// </summary>
		/// <returns>The Servers</returns>
		/// <response code="200">Returns the Servers</response>
		[HttpGet("all")]
		[ProducesResponseType(typeof(List<Server>), 200)]
		public async Task<IActionResult> GetAllServers()
		{
			return Ok(await context.Servers.ToListAsync());
		}

		// POST: api/Server
		/// <summary>
		/// Add a new Server
		/// </summary>
		/// <param name="server"></param>
		/// <returns>The new Server</returns>
		/// <response code="201">Returns the newly created server</response>
		/// <response code="400">If the IP or Subnet are invalid.</response>
		[HttpPost]
		[ProducesResponseType(typeof(Server), 201)]
		[ProducesResponseType(typeof(Server), 400)]
		public async Task<IActionResult> AddServer([FromBody] Server server)
		{
			if (!network.IsValidIP(server.IP) || !network.IsValidIP(server.Subnet))
			{
				return BadRequest(server);
			}

			server.Online = await network.IsReachable(server.IP);
			await context.Servers.AddAsync(server);
			await context.SaveChangesAsync();

			return CreatedAtAction("GetServer", new {id = server.ID}, server);
		}

		// DELETE: api/Server/5
		/// <summary>
		/// Deletes the Server
		/// </summary>
		/// <param name="id"></param>
		/// <returns>A Server</returns>
		/// <response code="200">Returns the Server</response>
		/// <response code="404">If the Server does not exist.</response>
		[HttpDelete("{id}")]
		[ProducesResponseType(typeof(Server), 200)]
		[ProducesResponseType(typeof(int), 404)]
		public async Task<IActionResult> DeleteServer([FromRoute] int id)
		{
			var server = await context.Servers.FindAsync(id);

			if (server == null)
			{
				return NotFound(id);
			}

			context.Servers.Remove(server);
			await context.SaveChangesAsync();

			return Ok(server);
		}

		// PUT: api/Server/5
		/// <summary>
		/// Modify an existing Server
		/// </summary>
		/// <param name="id"></param>
		/// <param name="server"></param>
		/// <returns>The Server</returns>
		/// <response code="200">Returns the Server</response>
		/// <response code="400">If the Server and id do not match.</response>
		[HttpPut("{id}")]
		[ProducesResponseType(typeof(Server), 200)]
		[ProducesResponseType(400)]
		public async Task<IActionResult> PutServer([FromRoute] int id, [FromBody] Server server)
		{
			if (id != server.ID)
			{
				return BadRequest();
			}

			context.Entry(server).State = EntityState.Modified;

			await context.SaveChangesAsync();

			return Ok(server);
		}

		// GET: api/Server
		/// <summary>
		/// Gets the MAC address for a specific IP.
		/// </summary>
		/// <param name="ip"></param>
		/// <returns>A MAC as string</returns>
		/// <response code="200">Returns the Mac</response>
		/// <response code="400">If the Server does not respond.</response>
		[HttpGet("mac/{ip}")]
		[ProducesResponseType(typeof(string), 200)]
		[ProducesResponseType(typeof(string), 400)]
		public async Task<IActionResult> GetMAC([FromRoute] string ip)
		{
			var mac = await network.GetMac(ip);

			if (string.IsNullOrEmpty(mac))
			{
				return BadRequest(mac);
			}

			return Ok(mac);
		}

		// GET: api/Server/wake/{id}
		/// <summary>
		/// Wakes up the server.
		/// </summary>
		/// <param name="id">The identifier.</param>
		/// <returns>The server</returns>
		/// <response code="200">Returns the Server</response>
		/// <response code="400">If the Server does not respond.</response>
		/// <response code="404">If the Server does not exist.</response>
		[HttpGet("wake/{id}")]
		[ProducesResponseType(typeof(Server), 200)]
		[ProducesResponseType(typeof(Server), 400)]
		[ProducesResponseType(typeof(string), 404)]
		public async Task<IActionResult> WakeUp([FromRoute] int id)
		{
			var server = await context.Servers.FindAsync(id);

			if (server == null)
			{
				return NotFound(id);
			}

			var broadcast = network.GetBroadcast(server.IP, server.Subnet);

			// WOL packet is sent over UDP 255.255.255.0:9.
			using (UdpClient client = new UdpClient())
			{
				client.Connect(broadcast, 9);

				// WOL packet contains a 6-bytes trailer and 16 times a 6-bytes sequence containing the MAC address.
				byte[] packet = new byte[17 * 6];

				// Trailer of 6 times 0xFF.
				for (int i = 0; i < 6; i++)
					packet[i] = 0xFF;

				// Body of magic packet contains 16 times the MAC address.
				for (int i = 1; i <= 16; i++)
				for (int j = 0; j < 6; j++)
					packet[i * 6 + j] = (byte) server.MAC[j];

				// Send WOL packet.
				client.Send(packet, packet.Length);
			}

			var reachable = await network.IsReachable(server.IP);

			if (reachable)
			{
				return Ok(server);
			}

			return BadRequest(server);
		}
	}
}