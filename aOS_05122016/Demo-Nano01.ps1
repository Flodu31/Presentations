#region Demo01: Deploy an IIS Server
#Check the hostname/ipconfig
docker run -d -p 8080:80 --name iis microsoft/iis
docker ps
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" iis
#endregion

#region Demo02: Deploy a custom website
docker build -t floappwebsite C:\Users\fappointaire\Desktop\floappwebsite
docker images
docker run -d -p 8000:8080 --name floappwebsite floappwebsite
docker ps
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" floappwebsite
#endregion

#region Demo03: Hyper-V Containers
#Container ephemeral with following parameters
docker run -it --rm images
#On the host, check th vm vmwp process
powershell Get-Process -Name vmwp
docker run --rm -it --name nanohpv --isolation=hyperv microsoft/nanoserver:latest
#On the host, check th vm vmwp process
powershell Get-Process -Name vmwp
docker run --rm -it --name nanohpv2 microsoft/nanoserver:latest
#On the host, check th vm vmwp process
powershell Get-Process -Name vmwp
#endregion

#region Demo04: Hyper-V Containers Isolation
#Same PID for the ping process
docker run -d --name pid1 microsoft/nanoserver:latest ping localhost -t
docker top pid1
powershell get-process -Name ping
#Due to isolation, impossible to get the process
docker stop pid1
docker run -d --name pid2 --isolation=hyperv microsoft/nanoserver:latest ping localhost -t
docker top pid2
powershell get-process -Name ping
powershell Get-Process -Name vmwp
docker stop pid2
powershell Get-Process -Name vmwp
#endregion

#region Demo05: Test from another VM and from localhost (It works)
$password = Read-Host -Prompt "Enter password" -AsSecureString
$UserName = "flodu31"
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $password 
docker login -u $Credentials.GetNetworkCredential().UserName -p $Credentials.GetNetworkCredential().Password
#Change the name of the image
docker build -t flodu31/orchardcms:latest C:\Users\fappointaire\Desktop\orchad
docker images
docker push flodu31/orchardcms:latest
docker run -d -p 1433:1433 -v C:/temp/:C:/temp/ --env attach_dbs="[{'dbName':'Orchard','dbFiles':['C:\\Temp\\Orchard.mdf','C:\\Temp\\Orchard_log.ldf']}]" -e sa_password=Florentdu31! -e ACCEPT_EULA=Y --name sqlserver microsoft/mssql-server-windows-express:latest 
docker run -d -p 80:80 --name orchard --link sqlserver:sqlserver flodu31/orchardcms
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" orchard
#Data Source=sqlserver;Initial Catalog=Orchard;User ID=sa;Password=Florentdu31!;
docker exec -t -i orchard cmd.exe
#endregion

#region Demo06: Test a linux image (doesn't work)
docker run --name wordpress --link mysql:mysql -d wordpress -p 81:80 -e WORDPRESS_DB_PASSWORD=Test123!
#endregion
