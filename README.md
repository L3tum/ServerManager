# ServerManager (https://github.com/L3tum/ServerManager)

## Usage

It works out of the box using an in-memory database. 
If you want to change that you need to set the environment variable `DATABASE_TYPE` to an alternative database.
Currently supported are: `MYSQL`, `SQLITE`, `MSSQL` and `INMEMORY`(default).

Do note that using an in-memory database any data is lost on restart of the container/application. 
If you set SQLITE to an in-container path you should mount a volume at that path or otherwise any data is lost on restart of the container.

Additionally, for any database except in-memory, you'll need to set `DATABASE_URL`. This is a connection string according to the database type you chose. 

### Docker

ServerManager is available on Docker here https://hub.docker.com/r/l3tum/servermanager

For an easy in-memory database "test" setup you can use the following command:

`docker run -d -p 80:80 --name servermanager l3tum/servermanager`

The standard image is a multi-arch image, meaning it will pull the appropriate image itself based on your OS and Architecture.
Currently supported are: 

* `Windows 1703-1809`(and corresponding Windows Server versions)
* `Linux on AMD64`
* `Linux on Arm32v7`
* `Linux on Arm64v8`
* Windows on Arm32v7 and Arm64v8 is planned and may arrive soon.
	
	
### Hosted

ServerManager is an ASP.Net Core 2.1 Application, so it will run on any host where you have .Net Core >2.1 installed. 
You can download the ServerManager.zip file in the release tab and execute it as any other dotnet program.

With version 1.1.0 we also ship "pre-built" executables in their respective zip files for the following platforms:

* `Windows x86`
* `Windows x64`
* `Windows ARM`
* `Windows ARM64`
* `Linux Portable x64`
* `Debian x64`
* `Ubuntu x64`
* `OSX x64`


## Application

This program (for now) let's you wake up your servers/computers in an easy-to-use webinterface. 
Just add the Server to the list and click on wake-up and a WOL magic packet is sent to that PC. 
The interface will let you know which Servers are online (respond to a ping). It updates every 30 seconds automatically and without you noticing. 
If the Server is awake at the time of adding it into the interface, you may click on "Autofill MAC" after entering the IP Address. 
The application will automatically fetch the MAC Address of the target IP. 

## Roadmap

This program is mainly used in my personal raspberry pi cluster (which is why ARM support is important to me). 
After asking on /r/homelab about similar programs and not really finding anything satisfying I chose to write it myself. 

As such, features may be implemented pretty slowly. I work full-time as well as on other projects so my time is limited. 

Anyways, a basic roadmap would consist of the following:

- [ ] Upgrade to .Net Core 3.0 and with that also release Windows ARM Docker images
- [ ] Different interface, with a "block" (col-md-6 for bootstrappers) for each Server
- [ ] Support for sending basic commands to the Server
- [ ] Support for SSH in-browser
- [ ] "Basic" management tools, such as open-port-scan and similar
- [ ] MAYBE: RDP support. This is not planned. I do not own any Server or PC where I would need to use this.
