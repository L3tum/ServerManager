#region usings

using System;
using System.IO;
using System.Reflection;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using ServerManager.API;
using ServerManager.Scheduler;
using Swashbuckle.AspNetCore.Swagger;
using IHostingEnvironment = Microsoft.AspNetCore.Hosting.IHostingEnvironment;

#endregion

namespace ServerManager
{
	public class Startup
	{
		private readonly IHostingEnvironment _env;

		public Startup(IConfiguration configuration, IHostingEnvironment env)
		{
			Configuration = configuration;
			_env = env;
		}

		public IConfiguration Configuration { get; }

		// This method gets called by the runtime. Use this method to add services to the container.
		public void ConfigureServices(IServiceCollection services)
		{
			services.AddSingleton<IHostedService, ScheduleTask>();
			services.AddSingleton<NetworkUtility>();

			services.Configure<CookiePolicyOptions>(options =>
			{
				// This lambda determines whether user consent for non-essential cookies is needed for a given request.
				options.CheckConsentNeeded = context => true;
				options.MinimumSameSitePolicy = SameSiteMode.None;
			});


			services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_1);
			services.AddResponseCaching();
			services.AddResponseCompression();
			services.AddMemoryCache();

			services.AddSwaggerGen(setup =>
			{
				setup.SwaggerDoc("v1", new Info {Title = "ServerManager API", Version = "v1"});
				setup.DescribeAllEnumsAsStrings();
				// Set the comments path for the Swagger JSON and UI.
				var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
				var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
				setup.IncludeXmlComments(xmlPath);
			});

			var connectionString = Configuration.GetValue<string>("DATABASE_URL");
			var dbType = Configuration.GetValue<string>("DATABASE_TYPE");

			switch (dbType)
			{
				case "SQLITE":
				{
					services.AddDbContext<Models.ServerManager>(options => options.UseSqlite(connectionString));
					break;
				}

				case "MYSQL":
				{
					services.AddDbContext<Models.ServerManager>(options => options.UseMySql(connectionString));
					break;
				}

				case "MSSQL":
				{
					services.AddDbContext<Models.ServerManager>(options => options.UseSqlServer(connectionString));
					break;
				}
				case "INMEMORY":
				{
					services.AddDbContext<Models.ServerManager>(options => options.UseInMemoryDatabase("ServerName"));
					break;
				}
			}
		}

		// This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
		public void Configure(IApplicationBuilder app, IHostingEnvironment env)
		{
			if (Configuration.GetValue<string>("DATABASE_TYPE") != "INMEMORY")
			{
				UpdateDatabase(app);
			}

			app.UseSwagger();
			app.UseSwaggerUI(setup =>
			{
				setup.SwaggerEndpoint("/swagger/v1/swagger.json", "ServerManager APIv1");
				setup.RoutePrefix = "api";
			});

			if (env.IsDevelopment())
			{
				app.UseDeveloperExceptionPage();
			}
			else
			{
				app.UseExceptionHandler("/Error");
				app.UseHsts();
				app.UseResponseCaching();
				app.UseResponseCompression();
			}

			app.UseHttpsRedirection();
			app.UseStaticFiles();
			app.UseCookiePolicy();
			app.UseMvc();
			app.UseDefaultFiles();
		}

		private void UpdateDatabase(IApplicationBuilder app)
		{
			using (var serviceScope = app.ApplicationServices
				.GetRequiredService<IServiceScopeFactory>()
				.CreateScope())
			{
				using (var context = serviceScope.ServiceProvider.GetService<Models.ServerManager>())
				{
					context.Database.Migrate();
				}
			}
		}
	}
}