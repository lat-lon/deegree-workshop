# Tutorial "INSPIRE Network Services with deegree on Docker"

## Agenda

1. [Setup the Docker infrastructure](#part-1---)

2. [Configure INSPIRE Direct Access Download Services based on deegree WFS 2.0](#part-2---configure-wfs-20-)

3. [Import test data using deegree WFS-T interface](#part-3---import-test-data--)

4. [Retrieve data with different clients](#part-4---retrieve-data-)

5. [Validate service and data](#part-5---validate-deegree-webservice-)

## Online Document

SELF-LINK: **[https://github.com/lat-lon/deegree-workshop/blob/master/README.md](https://github.com/lat-lon/deegree-workshop/blob/master/README.md)**  

**[Link to all slides at the end of the document!](#slides)**


# Part 1 - ![image alt text](resources/image_0.png)

## Install docker

[https://docs.docker.com/engine/installation/](https://docs.docker.com/engine/installation/) 

On Ubuntu:

    sudo apt-get install docker-engine

## Start docker daemon

    sudo service docker start

## Verify that docker is installed correctly

    docker run hello-world

_**Attention:** On LINUX the docker daemon binds on a UNIX socket which is owned by the user root and other users can access it with sudo. For this reason, docker daemon always runs as the root user._

### Basic docker commands

General structure of the docker CLI:

    docker <command> [options] [arguments]

Display help per docker command:

* `docker <command> --help` 	- Show help per docker command

Commands and options used within this tutorial:

* `docker info` 		- Display system-wide information

* `docker images`		- List images

* `docker pull`		- Pull an image or a repository from a registry (e.g. [hub.docker.com](https://hub.docker.com/))

* `docker ps`		- List containers

    * -a 		- Show all containers, incl. **stopped** containers

* `docker network ls`	- List all networks

* `docker run`		- Run a command in a **new** container

    * -d, --detach      	Run container in background and print container ID

    * -e, --env value           	Set environment variables (default [])

    * -i, --interactive           	Keep STDIN open even if not attached
 
    * --link value                  Add link to another container (default [] / )

    * -m, --memory string  	Memory limit (format: <number><unit>, where unit = b, k, m or g)

    * --name string            	Assign a name to the container

    * --network string      	Connect a container to a network (default "default" / [host, bridge]

    * -p, --publish value      	Publish a container's port(s) to the host (default [] / host:container)

    * --rm                          	Automatically remove the container when it exits

    * -t, --tty                 	Allocate a pseudo-TTY

    * -v, --volume value   	Bind mount a volume (default [] / host_dir:container_dir)

* `docker exec`		- Run a command in a **running** container

* `docker logs`		- Fetch the logs of a container

    * -f, --follow    	- Follow log output

* `docker start`		- Start one or more stopped containers

* `docker stop`		- Stop one or more running containers

* `docker load`		- Load a docker image from a tar archive file

* `docker save`		- Save a docker image into a tar archive file

* `docker rm` 		- Remove one or more containers

* `docker rmi`		- Remove one or more images

## Get docker images and run docker infrastructure

![image alt text](resources/image_1.png)

### Spatial Database 

![image alt text](resources/image_2.png) ![image alt text](resources/image_3.png)

Docker Hub: [https://hub.docker.com/r/mdillon/postgis/](https://hub.docker.com/r/mdillon/postgis/)

To download the docker image from the docker registry hub.docker.com run:

    docker pull mdillon/postgis

In case no Internet connection is available you can import a Docker image from a tar archive:

    docker load -i <PATH_TO_USB_DRIVE>/**Docker/postgis.tar**

To run the Docker container execute:

    docker run -d --name postgis -p 5432:5432 mdillon/postgis

![image alt text](resources/image_4.png)

Docker Hub: [https://hub.docker.com/r/zfil/pgadmin3/](https://hub.docker.com/r/zfil/pgadmin3/)

_**Hint**: This docker container requires X windows running on the host (LINUX or macOS are required!)_

    docker pull zfil/pgadmin3
    xhost +
    docker run -d -t -v /tmp/.X11-unix:/tmp/.X11-unix -v  ~/.pgadmin:/home/pgadmin -e DISPLAY=unix:0 --name pgadmin3 --link postgis:postgres zfil/pgadmin3

#### pgAdmin4 web console

Docker Hub: [https://hub.docker.com/r/fenglc/pgadmin4/](https://hub.docker.com/r/fenglc/pgadmin4/)

    docker pull fenglc/pgadmin4
    docker run -d --name pgadmin4 -p 5050:5050 --link postgis:postgres fenglc/pgadmin4

Open in browser: [http://localhost:5050/browser/](http://localhost:5050/browser/)

Use the following credential to login:

User: 		pgadmin4@pgadmin.org

Password: 	admin

_**Hint**: On Windows and macOS when running Docker with Docker Toolbox (using VirtualBox) you have to use the IP of the Docker Machine, such as 192.168.99.100 as the  container IP instead of localhost!_

#### Connection parameters for DBA

Hostname: 	postgres

Port: 		5432

User:		postgres

#### Database setup

Add a technical user for deegree with password ‘deegree’:

    CREATE ROLE deegree LOGIN

     ENCRYPTED PASSWORD 'md5b73ce574b23cf58ac77c8ca9ea0d2b5f'

     NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

    COMMENT ON ROLE deegree IS 'technical user for deegree FeatureStore config';

_**Hint**: Use persistent [data volume container](https://docs.docker.com/engine/tutorials/dockervolumes/) for productive systems, otherwise you may lose your data when removing the container!_

## ![image alt text](resources/image_5.png)eegree Webservices 

Docker Hub: [https://hub.docker.com/r/tfr42/deegree/](https://hub.docker.com/r/tfr42/deegree/)

Dockerfile: [https://github.com/tfr42/deegree-docker](https://github.com/tfr42/deegree-docker)

    docker pull tfr42/deegree

    docker run --name deegree -p 8080:8080 tfr42/deegree

To link the deegree with the postgis container and run the container attached to the deegree log execute:

    docker run --name deegree -p 8080:8080 --link postgis:db tfr42/deegree

Open in browser: [http://localhost:8080/deegree-webservices](http://localhost:8080/deegree-webservices)

Navigate to "connections > databases" and create a new connection of type “DataSource” with config template “PostgreSQL (minimal)”.

Change the JDBC URL to `jdbc:postgresql://db:5432/postgres` using the link name of the docker container running the PostgreSQL/PostGIS database.

Complete configuration file (saved inside the container in directory `/root/.deegree/`):

    <DataSourceConnectionProvider configVersion="3.4.0"
            xmlns="http://www.deegree.org/connectionprovider/datasource" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.deegree.org/connectionprovider/datasource http://schemas.deegree.org/jdbc/datasource/3.4.0/datasource.xsd">
        <!-- Creation / lookup of javax.sql.DataSource instance -->
        <DataSource javaClass="org.apache.commons.dbcp.BasicDataSource" />

        <!-- Configuration of DataSource properties -->
        <Property name="driverClassName" value="org.postgresql.Driver" />
        <Property name="url" value="jdbc:postgresql://db:5432/postgres" />
        <Property name="username" value="deegree" />
        <Property name="password" value="deegree" />
        <Property name="poolPreparedStatements" value="true" />
        <Property name="maxActive" value="10" />
        <Property name="maxIdle" value="10" />
    </DataSourceConnectionProvider>

After you have successfully tested the database connection you can stop the docker container with CTRL+c.

### Build deegree docker container based on a Dockerfile (optional)

Readme: [https://github.com/tfr42/deegree-docker/tree/master/deegree-webapp-tomcat](https://github.com/tfr42/deegree-docker/tree/master/deegree-webapp-tomcat)

[Dockerfile](https://github.com/tfr42/deegree-docker/blob/master/deegree-webapp-tomcat/Dockerfile)

    git clone [https://github.com/tfr42/deegree-docker.git](https://github.com/tfr42/deegree-docker.git)
    cd deegree-docker/deegree-webapp-tomcat/
    docker build -t deegree/deegree-tomcat .

Use the branch "feature/deegree3_4" to build the container with deegree 3.4-RC3

### Useful commands to monitor the docker container

* `docker logs -f deegree`	- follow the deegree console output

* `docker attach deegree`	- attach to the deegree container
    * You can detach from the container and leave it running with CTRL-p CTRL-q. Requires to pass `-it` option to the docker run command!
    * You can stop the container with CTRL+c.	

* `docker exec -it deegree '/bin/bash'` - opens a shell in the running deegree container. 
    * Use command `exit` to disconnect from the container.

* `docker stats deegree` 	- This will present the CPU utilization for the container, the memory used and total memory available to the container.

* `docker network inspect bridge` 	- lists the IP for each container.

# Part 2 - configure WFS 2.0 ![image alt text](resources/image_6.png)

## Start deegree docker container with local deegree workspace directory

Download one of the deegree workspace bundle for INSPIRE data themes 

* Protected Sites:  	[deegree3-workspace-ps](https://github.com/lat-lon/deegree-workshop/tree/master/deegree3-workspace-ps)

* Cadastral Parcels: 	[deegree3-workspace-cp](https://github.com/lat-lon/deegree-workshop/tree/master/deegree3-workspace-cp)

Create a new directory `.deegree` in the user home directory and copy all files into the `~/.deegree` directory. 

Stop and delete the docker container deegree before you continue with:

    docker stop deegree
    docker rm deegree

Start a **new** container with mounted directory `~/.deegree`:

    docker run -d --name deegree -v ~/.deegree:/root/.deegree -p 8080:8080 --link postgis:db tfr42/deegree

Open the deegree services console: [http://localhost:8080/deegree-webservices](http://localhost:8080/deegree-webservices) 

## Create WFS serving INSPIRE data theme Protected Sites

To configure a INSPIRE direct-access download service based on deegree WFS 2.0 serving harmonized data the following steps are needed:

1. Create the database and schema 

2. Add the GML application schema to the deegree workspace

3. Create the database connection configuration file

4. Create the SQLFeatureStore configuration file

5. Create the WFS service configuration file

The workspace bundle contains the following resources:

<table>
  <tr>
    <td>Directory</td>
    <td>Content</td>
    <td>Documentation</td>
  </tr>
  <tr>
    <td>ddl</td>
    <td>SQL DDL scripts for canonical and blob mapping</td>
    <td>PostgreSQL
PostGIS</td>
  </tr>
  <tr>
    <td>scripts</td>
    <td>Shell scripts to execute all SQL scripts using psql CLI (Linux/Unix only)</td>
    <td></td>
  </tr>
  <tr>
    <td>test</td>
    <td>SoapUI project for testing</td>
    <td>Getting started with SoapUI</td>
  </tr>
  <tr>
    <td>workspace-ps</td>
    <td>Complete deegree workspace with WFS and WMS configuration including a configuration set for BLOB and canonical mapping</td>
    <td>Configuration basics with deegree</td>
  </tr>
</table>


### Database schema and deegree SQLFeatureStore configuration derived from GML application schema using relational/canonical mode

To derive the SQL DDL script and the deegree SQLFeatureStore configuration file from the GML application schema you can use the deegree CLI utility tool (see [Supporting tools](#supporting-tools) for more information).

The deegree workspace bundle contains all required files. Follow the step-by-step description to setup the deegree WFS:

1. Create the database

    1. As user postgres - `~/.deegree/ddl/ps-canonical/02_create_ps_canonical_db.sql`

    2. As user deegree connected to ps_canonical database - `~/.deegree/ddl/ps-canonical/04_create_ps_canonical_schema.sql`

2. Add the GML application schema to workspace ([source of XSD](http://inspire.ec.europa.eu/schemas/ps/4.0/ProtectedSites.xsd))

    3. `~/.deegree/workspace-ps/appschemas/ProtectedSites.xsd`

3. Create the database connection configuration file

    4. `~/.deegree/workspace-ps/jdbc/postgresDS_canonical.xml`

4. Create the SQLFeatureStore configuration file

    5. `~/.deegree/workspace-ps/datasources/feature/ps_canonical.xml`

5. Create the WFS service configuration file

    6. `~/.deegree/workspace-ps/services/wfs_ps_canonical.xml`

6. Reload the workspace to activate the changes!

_**Attention:** As of deegree Version 3.4-RC3 the FeatureStore wizard may skip complex element types while generating the SQL DDL scripts and the deegree FeatureStore configuration file. For the GML application schema ProtectedSites (v.4.0) the element legalFoundationDocument is missing in the generated DDL and in the SQLFeatureStore configuration file (see issue [#742](https://github.com/deegree/deegree3/issues/742)). More information how to generate the mapping and SQL DDL files read further in paragraph [Supporting tools](#supporting-tools)._

#### Service Address

WFS Endpoint: [http://localhost:8080/deegree-webservices/services/wfs_ps_canonical](http://localhost:8080/deegree-webservices/services/wfs_ps_canonical)

WFS Capabilities:

[http://localhost:8080/deegree-webservices/services/wfs_ps_canonical?service=WFS&request=GetCapabilities](http://localhost:8080/deegree-webservices/services/wfs_ps_canonical?service=WFS&request=GetCapabilities)

### Database schema and deegree SQLFeatureStore configuration based on BLOB-mode GML application mapping

1. Create the database

    1. As user postgres - `~/.deegree/ddl/ps-blob/create_ps_blob_db.sql`

    2. As user deegree connected to ps_blob database - `~/.deegree/ddl/ps-blob/create_ps_blob_schema.sql`

2. GML application schema should be present already

    3. `~/.deegree/workspace-ps/appschemas/ProtectedSites.xsd`

3. Create the database connection configuration file

    4. `~/.deegree/workspace-ps/jdbc/postgresDS_blob.xml`

4. Create the SQLFeatureStore configuration file

    5. `~/.deegree/workspace-ps/datasources/feature/ps_blob.xml`

5. Create the WFS service configuration file

    6. `~/.deegree/workspace-ps/services/wfs_ps_blob.xml`

6. Reload the workspace to activate the changes!

#### Service Address

WFS Endpoint: [http://localhost:8080/deegree-webservices/services/wfs_ps_blob](http://localhost:8080/deegree-webservices/services/wfs_ps_blob)

WFS Capabilities:

[http://localhost:8080/deegree-webservices/services/wfs_ps_blob?service=WFS&request=GetCapabilities](http://localhost:8080/deegree-webservices/services/wfs_ps_blob?service=WFS&request=GetCapabilities)

### Supporting tools

Tools to create the SQL DDL and the deegree SQLFeatureStore configuration files:

* deegree services console - [http://localhost:8080/deegree-webservices/](http://localhost:8080/deegree-webservices/) 

    * in 3.4-RC3 the wizard is broken (see [issue #471](https://github.com/deegree/deegree3/issues/471) and related issues) 

    * deegree 3.3.20 (limited support for complex GML application schema)

* [deegree CLI utility tool](https://github.com/lat-lon/deegree-cli-utility/tree/deegree-3.4) 

# Part 3 - Import test data  ![image alt text](resources/image_7.png) 

Docker hub: [https://hub.docker.com/r/tfr42/docker-soapui/](https://hub.docker.com/r/tfr42/docker-soapui/)

Dockerfile: -

_**Hint**: This docker container requires X windows running on the host (LINUX or macOS are required!). For Windows download SoapUI here: [https://www.soapui.org/downloads/soapui.html](https://www.soapui.org/downloads/soapui.html)_

    docker pull tfr42/docker-soapui
    xhost +
    docker run --name soapui --rm -t -i -e DISPLAY=:0.0 -v /tmp/.X11-unix:/tmp/.X11-unix -v ${HOME}/.deegree:/var/opt --link deegree:deegree tfr42/docker-soapui '/opt/SoapUI/bin/soapui.sh'

## Setting custom properties

Open the file `/var/opt/test/wfs200-soapui-project.xml` with SoapUI and select the project root node. 

![image alt text](resources/image_8.png)

Switch to "Custom Properties" tab and set for property “wfsEndpoint”:

* To import data into the SQLFeatureStore in BLOB modus use:
[http://deegree:8080/deegree-webservices/services/wfs_ps_blob](http://deegree:8080/deegree-webservices/services/wfs_ps_blob)

* The WFS configured with the SQLFeatureStore in relational/canonical modus use:
[http://deegree:8080/deegree-webservices/services/wfs_ps_canonical](http://deegree:8080/deegree-webservices/services/wfs_ps_canonical)

## Import sample test data over WFS-T Insert operation

To send a WFS-T Insert action submit the test step "INSPIRE ProtectedSite > Transaction > INSERT-POST-FeatureCollection":

![image alt text](resources/image_9.png)

Switch the "wfsEndpoint" property to the other endpoint and re-submit the WFS-T Insert request to insert the data also in the other database.

## Import data with HALE

1. Download and install HALE [http://www.esdi-community.eu/projects/hale](http://www.esdi-community.eu/projects/hale) 

2. Download and unzip [http://grillmayer.eu/wp-content/uploads/2014/12/Protected_Sites_DS_Version_4_Example-1.zip](http://grillmayer.eu/wp-content/uploads/2014/12/Protected_Sites_DS_Version_4_Example-1.zip) 

3. Import project "Protected_Sites_DS_Version_4_Example.hale" into HALE workbench

4. Start the "Export transformed data" function and select “WFS-T” as destination using one of the WFS endpoints configured.

# Part 4 - Retrieve data ![image alt text](resources/image_10.png)

Docker hub: [https://hub.docker.com/r/kartoza/qgis-desktop/](https://hub.docker.com/r/kartoza/qgis-desktop/)

Dockerfile: [https://github.com/kartoza/docker-qgis-desktop](https://github.com/kartoza/docker-qgis-desktop)

_**Hint**: This docker container requires X windows running on the host (LINUX or macOS are required!). For Windows download QGIS here: [http://download.qgis.org](http://download.qgis.org)_ 

    docker pull kartoza/qgis-desktop

QGIS 2.18:

    xhost +
    docker run --name gqis-desktop_2_18 -i -t -v /tmp/.X11-unix:/tmp/.X11-unix -v ${HOME}:/home/${USER} -e DISPLAY=unix:0 --link deegree:deegree --rm kartoza/qgis-desktop:2.18.12 '/usr/bin/qgis'

QGIS 2.18 (latest DEV):

    xhost +
    docker run --name gqis-desktop_master -i -t  -v /tmp/.X11-unix:/tmp/.X11-unix -v ${HOME}:/home/${USER} -e DISPLAY=unix:0 --link deegree:deegree --rm kartoza/qgis-desktop:latest '/usr/bin/qgis'

WMS Endpoint for PS: [http://localhost:8080/deegree-webservices/services/wms_ps](http://localhost:8080/deegree-webservices/services/wms_ps) 

WMS Capabilities: [http://localhost:8080/deegree-webservices/services/wms_ps?service=WMS&request=GetCapabilities](http://localhost:8080/deegree-webservices/services/wms_ps?service=WMS&request=GetCapabilities) 

# Part 5 - Validate deegree Webservice ![image alt text](resources/image_11.png)

Docker hub: [https://hub.docker.com/r/tfr42/teamengine/](https://hub.docker.com/r/tfr42/teamengine/)

Dockerfile: [https://github.com/tfr42/teamengine/tree/feature/addDockerConfig/teamengine-docker](https://github.com/tfr42/teamengine/tree/feature/addDockerConfig/teamengine-docker)

## TEAM Engine 4.6 with WFS ETS 1.22:

    docker pull tfr42/teamengine
    docker run -d --name teamengine -p 8088:8080 --link deegree:deegree tfr42/teamengine

## TEAM Engine 4.10 with WFS ETS 1.26:

    docker pull dstenger/teamengine-ets-all
    docker run -d --name teamengine -p 8088:8080 --link deegree:deegree dstenger/teamengine-ets-all

Open in browser: [http://localhost:8088/teamengine](http://localhost:8088/teamengine)

Use either

* [http://deegree:8080/deegree-webservices/services/wfs_ps_canonical?service=WFS&request=GetCapabilities](http://deegree:8080/deegree-webservices/services/wfs_ps_canonical?service=WFS&request=GetCapabilities)

* [http://deegree:8080/deegree-webservices/services/wfs_ps_blob?service=WFS&request=GetCapabilities](http://deegree:8080/deegree-webservices/services/wfs_ps_blob?service=WFS&request=GetCapabilities)

to run the validation against.

### deegree WFS 2.0 Reference Implementation online:

[http://ogctestbed12.lat-lon.de/deegree/services/wfs?service=WFS&request=GetCapabilities](http://ogctestbed12.lat-lon.de/deegree/services/wfs?service=WFS&request=GetCapabilities)

## Further testing with the INSPIRE Reference Validator

Docker hub: [https://hub.docker.com/r/iide/etf-webapp/](https://hub.docker.com/r/iide/etf-webapp/)

Dockerfile: [https://github.com/interactive-instruments/etf-webapp](https://github.com/interactive-instruments/etf-webapp) 

    docker pull iide/etf-webapp
    docker run --name etf -d -p 8188:8080 -v ~/etf:/etf --link deegree:deegree iide/etf-webapp:latest

Open in browser: [http://localhost:8188/etf-webapp](http://localhost:8088/etf-webapp)

To allow access to the local Docker Container running deegree you need to change the configuration file `~/etf/config/etf-config.properties` and set the property:

    etf.testobject.allow.privatenet.access = true

More information how to configure the etf-web application under [http://docs.etf-validator.net/](http://docs.etf-validator.net/) and [https://github.com/inspire-eu-validation/ets-repository](https://github.com/inspire-eu-validation/ets-repository). 

# Troubleshooting

* Can’t access docker from the command line - 

    * check if the docker daemon is running and use `sudo`

* Error while starting docker container - 

    * check system resources if memory is still available

    * Remove the container with docker rm and re-run the container

* For more hints and tips check [https://docs.docker.com/toolbox/faqs/troubleshoot/](https://docs.docker.com/toolbox/faqs/troubleshoot/)

    * For Mac OS : [https://docs.docker.com/docker-for-mac/troubleshoot/](https://docs.docker.com/docker-for-mac/troubleshoot/)

    * For Windows:  [https://docs.docker.com/docker-for-windows/troubleshoot/](https://docs.docker.com/docker-for-windows/troubleshoot/)

* Can’t access the Docker container within Docker network then try the following

    * `docker network create -d bridge --subnet 192.168.0.0/24 --gateway 192.168.0.1 inspirenet`

    * `docker network connect inspirenet deegree`

    * `docker network connect inspirenet etf`

    * `docker network connect inspirenet postgis`

    * `docker network connect inspirenet teamengine`

    * And retry to access the Docker container

* Can’t insert data into the database

    * Check if the user deegree has all needed privileges

    * Grant user deegree all privileges with:

        * `GRANT ALL ON SCHEMA public TO deegree;`

        * `GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO deegree;`

        * `GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public to deegree;`

# Links for further reading

## Slides

[01_T_Introduction.pdf](https://drive.google.com/open?id=0B5kCqK1r1vn0YVZXYVRaVWFtYms)

[02_T_INSPIRE-Download-Services.pdf](https://drive.google.com/open?id=0B5kCqK1r1vn0NFpqZko3OWNmSFk)

[03_TP_Docker.pdf](https://drive.google.com/open?id=0B5kCqK1r1vn0b3ZkVDNkbHJKSG8)

[04_P_deegree-on-Docker.pdf](https://drive.google.com/open?id=0B5kCqK1r1vn0dTJoQnIwODRDLU0)

[05_TP_deegree.pdf](https://drive.google.com/open?id=0B5kCqK1r1vn0X2w1MG1Yc1JVaW8)

[06_P_Configuration-of-a-deegree-INSPIRE-Download-Service.pdf](https://drive.google.com/open?id=0B5kCqK1r1vn0MGRvazdfVzBTeU0)

[07_TP_Validation-of-service-and-data.pdf](https://drive.google.com/open?id=0B5kCqK1r1vn0cTFlUi1mU3l0dVk)

Archive:

[https://githu](https://github.com/tfr42/deegree-docker/tree/foss4g2016_workshop)[b.com/tfr42/deegree-docker/tree/foss4g2016_workshop](https://github.com/tfr42/deegree-docker/tree/foss4g2016_workshop)

## Docker

[https://www.docker.com](https://www.docker.com)

[https://docs.docker.com](https://docs.docker.com)

[https://hub.docker.com](https://hub.docker.com)

[http://linoxide.com/linux-how-to/run-gui-apps-docker-container/](http://linoxide.com/linux-how-to/run-gui-apps-docker-container/)

### Talks about Docker and GIS

Video (german) - [https://www.fossgis.de/konferenz/2015/programm/events/847.de.html](https://www.fossgis.de/konferenz/2015/programm/events/847.de.html)

Slides (english) - [https://2016.foss4g-na.org/session/spatial-data-processing-docker](https://2016.foss4g-na.org/session/spatial-data-processing-docker)

Video (german) - [FOSS4G 2016 - Docker Images for Geospatial](https://ftp.gwdg.de/pub/misc/openstreetmap/FOSS4G-2016/foss4g-2016-1146-an_overview_of_docker_images_for_geospatial_applications-hd.mp4)

[https://inspire.ec.europa.eu/events/conferences/inspire_2017/submissions/169.html](https://inspire.ec.europa.eu/events/conferences/inspire_2017/submissions/169.html)

## deegree

[https://github.com/deegree/deegree3](https://github.com/deegree/deegree3)

[http://www.deegree.org](http://www.deegree.org)

[http://osgeo.getinteractive.nl/projects/deegree/](http://osgeo.getinteractive.nl/projects/deegree/) 

[https://inspire-reference.jrc.ec.europa.eu/tools/deegree](https://inspire-reference.jrc.ec.europa.eu/tools/deegree)

Documentation 3.3.x - [http://download.deegree.org/documentation/3.3.20/html/](http://download.deegree.org/documentation/3.3.20/html/) 

Documentation 3.4.x - [http://download.deegree.org/documentation/3.4-RC3/html/](http://download.deegree.org/documentation/3.4-RC3/html/) 

### deegree on Docker Hub

[https://hub.docker.com/r/tfr42/deegree/](https://hub.docker.com/r/tfr42/deegree/)

### deegree workspace for INSPIRE

[https://github.com/de-bkg/deegree-workspace-dlm250-inspire](https://github.com/de-bkg/deegree-workspace-dlm250-inspire)

[https://github.com/DirkThalheim/deegree-elf](https://github.com/DirkThalheim/deegree-elf)

[https://github.com/eENVplus/deegree-workspace-eenvplus](https://github.com/eENVplus/deegree-workspace-eenvplus) 

## OGC CITE TEAM Engine

[https://github.com/opengeospatial/teamengine](https://github.com/opengeospatial/teamengine)

[http://opengeospatial.github.io/teamengine/](http://opengeospatial.github.io/teamengine/)

[http://cite.opengeospatial.org](http://cite.opengeospatial.org)

[http://cite.opengeospatial.org/teamengine/](http://cite.opengeospatial.org/teamengine/)

[https://github.com/opengeospatial/teamengine-docker](https://github.com/opengeospatial/teamengine-docker)

## INSPIRE

### General Information about INSPIRE

[http://inspire.ec.europa.eu/](http://inspire.ec.europa.eu/)

[http://www.slideshare.net/ChrisSchubert1/inspirehandsondatatransformation](http://www.slideshare.net/ChrisSchubert1/inspirehandsondatatransformation)

### Validation 

[http://inspire-geoportal.ec.europa.eu/validator2/](http://inspire-geoportal.ec.europa.eu/validator2/)

[http://inspire-sandbox.jrc.ec.europa.eu/validator/](http://inspire-sandbox.jrc.ec.europa.eu/validator/) 

[https://github.com/interactive-instruments/etf-test-projects-elf](https://github.com/interactive-instruments/etf-test-projects-elf) 

[https://github.com/Geonovum/etf-test-projects-inspire](https://github.com/Geonovum/etf-test-projects-inspire) 

### Data specifications

[http://inspire-regadmin.jrc.ec.europa.eu/dataspecification/](http://inspire-regadmin.jrc.ec.europa.eu/dataspecification/)
[http://inspire.ec.europa.eu/Themes/Data-Specifications/2892](http://inspire.ec.europa.eu/Themes/Data-Specifications/2892)

### INSPIRE Download Services

[http://inspire.ec.europa.eu/events/conferences/inspire_2012/presentations/69.pdf](http://inspire.ec.europa.eu/events/conferences/inspire_2012/presentations/69.pdf)

### INSPIRE Data Transformation with HALE

[http://inspire-extensions.wetransform.to/tutorial/tutorial.html](http://inspire-extensions.wetransform.to/tutorial/tutorial.html)

[http://grillmayer.eu/blog/#hale-projekt-inklusive-daten-protected-sites-austria](http://grillmayer.eu/blog/#hale-projekt-inklusive-daten-protected-sites-austria) 

### INSPIRE in Practice

[https://inspire-reference.jrc.ec.europa.eu/](https://inspire-reference.jrc.ec.europa.eu/)

## OSGeo

[https://live.osgeo.org/en/index.html](https://live.osgeo.org/en/index.html)

[http://live.osgeo.org/en/overview/deegree_overview.html](http://live.osgeo.org/en/overview/deegree_overview.html)

[http://geocontainers.org/](http://geocontainers.org/)

[https://wiki.osgeo.org/wiki/DockerImages](https://wiki.osgeo.org/wiki/DockerImages)

[https://wiki.osgeo.org/wiki/INSPIRE](https://wiki.osgeo.org/wiki/INSPIRE)

[https://wiki.osgeo.org/wiki/INSPIRE_tools_inventory](https://wiki.osgeo.org/wiki/INSPIRE_tools_inventory)

### Data and services

WMS with OSM data

[http://ows.terrestris.de/osm/service?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetCapabilities](http://ows.terrestris.de/osm/service?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetCapabilities)

# License

This document is published under creative commons license.

[Attribution - Non Commercial - Share Alike -  4.0 International (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en)

