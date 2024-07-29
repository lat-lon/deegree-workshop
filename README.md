# Quickstart Tutorial "INSPIRE Network Services with deegree 3.5 on Docker" (90 minutes)

[Online-Version (GitHub)](https://github.com/lat-lon/deegree-workshop/blob/main/README.md)

## Agenda   

1. [Setup the Docker Compose infrastructure](#setlink)

2. [Configure INSPIRE Direct Access Download Services based on deegree WFS 2.0](#setlink)

3. [Import test data using deegree WFS-T interface](#setlink)

4. [Retrieve data with different clients](#setlink)

5. [Validate service and data](#setlink)

---

## 1. Setup the Docker infrastructure

![image alt text](resources/docker-logo-blue.svg)

### 1.1 Install Docker

> **Info**: "Docker Desktop provides a user-friendly graphical interface that simplifies the management of containers and services. It includes Docker Engine as this is the core technology that powers Docker containers. Docker Desktop for Linux also comes with additional features like Docker Scout and Docker Extensions" [(Docker Inc. 2024)](https://docs.docker.com/desktop/install/linux-install/).

#### Docker Desktop
 
* [Linux](https://docs.docker.com/desktop/install/linux-install/) (recommended)
* [Windows](https://docs.docker.com/desktop/install/windows-install/)
* [Mac](https://docs.docker.com/desktop/install/mac-install/)

#### Docker Engine

* [Linux](https://docs.docker.com/engine/install/) (advanced)

### 1.2 Pull the desired Docker Image versions of deegree, PostgreSQL/PostGIS and pgAdmin4

#### PostgreSQL/PostGIS Database
![image alt text](resources/postgresql-horizontal.svg) ![image alt text](resources/image_3.png)

Docker Hub: [https://hub.docker.com/r/postgis/postgis/](https://hub.docker.com/r/postgis/postgis/)

To download the Docker image from the docker registry hub.docker.com run:

    docker pull postgis/postgis:16-3.4

#### pgAdmin4 Web Console

Docker Hub: [https://hub.docker.com/r/dpage/pgadmin4/](https://hub.docker.com/r/dpage/pgadmin4/)

    docker pull dpage/pgadmin4:8.9

#### deegree Webservices
![image alt text](resources/deegree_logo.svg)

Docker Hub: [https://hub.docker.com/r/deegree/deegree3-docker/](https://hub.docker.com/r/deegree/deegree3-docker/)
Dockerfile: [https://github.com/deegree/deegree3-docker](https://github.com/deegree/deegree3-docker)

    docker pull deegree/deegree3-docker:3.5.8

## 1.3 Configure the Docker Compose file

For this tutorial, a ready-to-use Docker Compose file is provided. Additionally, all the needed configurations for setting up an INSPIRE deegree workspace are available for Download in form of a [ZIP-File](https://github.com/lat-lon/deegree-workshop/archive/refs/heads/main.zip).

The contents of [ZIP-File](https://github.com/lat-lon/deegree-workshop/archive/refs/heads/main.zip) and in particular its containing folder `deegree-workshop-bundle` are as followed:

| Directory       | Content     | Documentation |
| :-------------- | :---------- | :------------ |   
| `/deegree-workspace/ps-sl`          | Complete deegree workspace with data and configuration files (WFS, WMS, layers, styles and database) for the INSPIRE Annex 1 data theme ProtectedSites from the federal state of Saarland | [What is a deegree workspace?](https://download.deegree.org/documentation/current/html/#_the_deegree_workspace) |
| `/sql`      |  SQL scripts for setting up the PostgreSQL database | [PostgreSQL](https://www.postgresql.org/docs/current/tutorial.html), [PostGIS](https://postgis.net/workshops/postgis-intro/) |
| `docker-compose.yaml`         | Docker Compose file for defining and running multi-container applications, in this case including deegree, PostgreSQL and pgAdmin4  | [How does Docker Compose work?](https://docs.docker.com/compose/compose-application-model/) | 
| `.env` | Used to set the necessery environment variables | [How to use the `.env`?](https://docs.docker.com/compose/environment-variables/set-environment-variables/) |

The provided Docker Compose file contains the following configuration:

```
version: '3.8'

services:
  deegree:
    image: deegree/deegree3-docker:${DEEGREE_VERSION}
    container_name: deegree_${DEEGREE_VERSION}
    ports:
      - 8080:8080
    links:
      - postgres
    volumes:
      - ./deegree-workspace:/root/.deegree:rw
    depends_on:
      postgres:
        condition: service_started
    networks:
      - network

  postgres:
    image: postgis/postgis:${POSTGRES_POSTGIS_VERSION}
    container_name: postgres_database
    ports:
      - 5432:5432
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    volumes:
      - ./sql:/docker-entrypoint-initdb.d/
    networks:
      - network

  pgadmin:
    image: dpage/pgadmin4:${PGADMIN_VERSION}
    container_name: pgadmin_${PGADMIN_VERSION}
    ports:
      - 5080:80
    environment:
      - PGADMIN_DEFAULT_EMAIL=pgadmin4@pgadmin.org
      - PGADMIN_DEFAULT_PASSWORD=admin
    networks:
      - network

networks:
  network:
    name: deegree_workshop
```
[comment]: <> (... Addmore info to configuration details!)

>**Info:** You can find an overview of basic Docker Compose commands at the end of this tutorial under: [Overview of basic Docker Compose commands](#overview-of-basic-docker-commands). 

# Part 2 - configure WFS 2.0

### X.X Use the pgAdmin Web Console 
Open in browser: [http://localhost:5080/](http://localhost:5080/)

Use the following credential to login into pgAdmin:

* **User**: pgadmin4@pgadmin.org
* **Password**: admin

##### Connection parameters for pgAdmin4 > Register > Server... > Connection

* **Host name**: postgres
* **Port**: 5432
* **User**:	postgres
* **Password**: postgres

>**Info**: The password is 'postgres', since the previously set docker environment variable for the container postgis is `POSTGRES_PASSWORD=postgres`!

## Start deegree docker container with local deegree workspace directory

Download the deegree demo workspace bundle (as ZIP file) for the INSPIRE data theme protected sites:

* Protected Sites:  	[deegree3-workspace-ps](https://github.com/lat-lon/deegree-workshop/tree/master/deegree3-workspace-ps)

* Download the ZIP file from https://github.com/lat-lon/deegree-workshop

* Unzip the file _deegree-workshop-X.zip_ to your local drive

* Create a new directory `.deegree` in the user's home directory and move the sub-directory `workspace-ps/` into the `~/.deegree` directory. 

Start now a **new** container with mounted user home directory `~/.deegree`:

    docker run -d --name deegree -v ~/.deegree:/root/.deegree -p 8080:8080 --link postgis:db deegree/deegree3-docker

Open the deegree services console: [http://localhost:8080/deegree-webservices](http://localhost:8080/deegree-webservices) 

* Then select under "workspaces > available workspaces" the workspace _workspace_ps_ and start the workspace with "Start".

## Start deegree WFS serving INSPIRE data theme Protected Sites

To configure a INSPIRE direct-access download service based on deegree WFS 2.0 serving harmonized data the following steps are needed:

1. Create the database and schema with the provided SQL scripts using pgAdmin or use the shell script `scripts/setupDB.sh`

2. Select and reload the workspace for Protected Sites in the deegree service console (now all warnings should be gone!)

Each workspace bundle (deegree3-workspace-cp and deegree3-workspace-ps) contains the following resources:

| Directory       | Content     | Documentation |
| :-------------- | :---------- | :------------ |   
| `/ddl`          | SQL DDL scripts for canonical and blob mapping | [PostgreSQL](https://www.postgresql.org/docs/current/static/tutorial.html), [PostGIS](http://workshops.boundlessgeo.com/postgis-intro/) |
| `/scripts`      | Shell scripts to execute all SQL scripts using psql CLI (Linux/Unix only) |  |
| `/test`         | SoapUI project for testing | [Getting started with SoapUI](https://www.soapui.org/getting-started/your-first-soapui-project.html) | 
| `/workspace-cp` | Complete deegree workspace with WFS and WMS configuration for INSPIRE Annex 1 data theme Cadastral Parcels including a configuration set for BLOB and canonical mapping | [Configuration basics with deegree](http://download.deegree.org/documentation/3.4.0/html/lightly.html#example-workspace-1-inspire-network-services) |
| `/workspace-ps` | Complete deegree workspace with WFS and WMS configuration for INSPIRE Annex 1 data theme Protected Sites including a configuration set for BLOB and canonical mapping   | [Configuration basics with deegree](http://download.deegree.org/documentation/3.4.0/html/lightly.html#example-workspace-1-inspire-network-services) |

### Detailed description for Protected Sites with manual database setup

The shell script `setupDB.sh` creates both, the canonical and BLOB database schema! In case you can't run the shell script execute the following scripts in pgAdmin:

1. Connect to the database server and open Query Tool in pgAdmin

    1. As user postgres create user and database with:
        
        - `~/.deegree/ddl/01_create_deegree_user.sql`
        - `~/.deegree/ddl/ps-canonical/02_create_ps_canonical_db.sql`
        
    2. As user deegree connect to _ps_canonical_ database and create the schema with 

        - `~/.deegree/ddl/03_create_extension_postgis.sql`
        - `~/.deegree/ddl/ps-canonical/04_create_ps_canonical_schema.sql`

2. Now open the deegree service console and reload the workspace:

    1. The WFS service configuration is located in `/services/wfs_ps_canonical.xml`

#### Service Address

WFS Endpoint: [http://localhost:8080/deegree-webservices/services/wfs_ps_canonical](http://localhost:8080/deegree-webservices/services/wfs_ps_canonical)

WFS Capabilities:

[http://localhost:8080/deegree-webservices/services/wfs_ps_canonical?service=WFS&request=GetCapabilities](http://localhost:8080/deegree-webservices/services/wfs_ps_canonical?service=WFS&request=GetCapabilities)

### Database schema and deegree SQLFeatureStore configuration based on BLOB-mode GML application mapping

1. Create the database using pgAdmin

    1. As user postgres create the database

        - `~/.deegree/ddl/ps-blob/create_ps_blob_db.sql`

    2. As user deegree connect to ps_blob database and create the schema with 

        - `~/.deegree/ddl/03_create_extension_postgis.sql`
        - `~/.deegree/ddl/ps-blob/04_create_ps_blob_schema.sql`

2. Reload the workspace to activate the changes!

#### Service Address

WFS Endpoint: [http://localhost:8080/deegree-webservices/services/wfs_ps_blob](http://localhost:8080/deegree-webservices/services/wfs_ps_blob)

WFS Capabilities:

[http://localhost:8080/deegree-webservices/services/wfs_ps_blob?service=WFS&request=GetCapabilities](http://localhost:8080/deegree-webservices/services/wfs_ps_blob?service=WFS&request=GetCapabilities)

# Part 3 - Import test data  ![image alt text](resources/image_7.png) 

Dockerfile: -

_**Hint**: Download SoapUI here: [https://www.soapui.org/downloads/soapui.html](https://www.soapui.org/downloads/soapui.html)_, and unzip the package. Then start SoapUI using the start scripts or the links created by the installer. For a short intro use the [Getting Starting Guide](https://www.soapui.org/getting-started/).

## Setting custom properties

Open the file `deegree3-workspace-ps/test/wfs200-soapui-project.xml` with SoapUI and select the project root node. 

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

# Part 4 - Retrieve data ![image alt text](resources/image_10.png)

Docker hub: [https://hub.docker.com/r/qgis/qgis/](https://hub.docker.com/r/qgis/qgis/)

Dockerfile: -

_**Hint**: Download QGIS for your operating system from [http://download.qgis.org](http://download.qgis.org) and install as documented._ 

Create a new project and add the WMS 1.3.0 Endpoint with URL [http://localhost:8080/deegree-webservices/services/wms_ps](http://localhost:8080/deegree-webservices/services/wms_ps) and the WFS 2.0.0 Endpoint with URL [http://localhost:8080/deegree-webservices/services/wfs_ps_canonical](http://localhost:8080/deegree-webservices/services/wfs_ps_canonical). 

# Part 5 - Validate deegree Webservice ![image alt text](resources/image_11.png)

Docker hub: [https://hub.docker.com/r/ogccite/teamengine-production/](https://hub.docker.com/r/ogccite/teamengine-production/)

Dockerfile: https://github.com/opengeospatial/teamengine-docker/

## TEAM Engine 5.x with WFS ETS 1.x:

    docker pull ogccite/teamengine-production
    docker run -d --name teamengine -p 8088:8080 --link deegree:deegree ogccite/teamengine-production

Open in browser: [http://localhost:8088/teamengine](http://localhost:8088/teamengine)

Use either

* [http://deegree:8080/deegree-webservices/services/wfs_ps_canonical?service=WFS&request=GetCapabilities](http://deegree:8080/deegree-webservices/services/wfs_ps_canonical?service=WFS&request=GetCapabilities)

* [http://deegree:8080/deegree-webservices/services/wfs_ps_blob?service=WFS&request=GetCapabilities](http://deegree:8080/deegree-webservices/services/wfs_ps_blob?service=WFS&request=GetCapabilities)

to run the validation against.

### deegree WFS 2.0 Reference Implementation online:

[http://cite.deegree.org/deegree-webservices-3.4.12/services/wfs200?service=WFS&request=GetCapabilities](http://cite.deegree.org/deegree-webservices-3.4.12/services/wfs200?service=WFS&request=GetCapabilities)

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

* Can't pull docker image in case no Internet connection is available you can import a Docker image from a tar archive:

    * `docker load -i <PATH_TO_USB_DRIVE>/Docker/postgis.tar`

* Error while starting docker container - 

    * check system resources if memory is still available
    * `docker stats deegree` 	- This will present the CPU utilization for the container, the memory used and total memory available to the container.
    * Stop and remove the container with `docker stop deegree && docker rm deegree` and re-run the container

* Check the deegree console output in case of errors -

    * `docker logs -f deegree`

* Attach to the deegree container when starting the container to execute commands inside of the container -
 
    * `docker attach deegree`
    * You can detach from the container and leave it running with `CTRL-p CTRL-q`. Requires to pass the `-it` option to the docker run command!
    * You can stop the container with `CTRL+c`.	

* To run commands inside of the container open a shell in the running deegree container - 
    
    * `docker exec -it deegree '/bin/bash'`
    * Use command `exit` to disconnect from the container.

* For more hints and tips check [https://docs.docker.com/toolbox/faqs/troubleshoot/](https://docs.docker.com/toolbox/faqs/troubleshoot/)

    * For Mac OS : [https://docs.docker.com/docker-for-mac/troubleshoot/](https://docs.docker.com/docker-for-mac/troubleshoot/)

    * For Windows:  [https://docs.docker.com/docker-for-windows/troubleshoot/](https://docs.docker.com/docker-for-windows/troubleshoot/)

* Can’t access the Docker container within Docker network then try the following

    * `docker network inspect bridge` 	- lists the IP for each container.

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
        
# Overview of basic docker commands
 
 General structure of the docker CLI:
 
     docker <command> [options] [arguments]
 
 Display help per docker command:
 
 * `docker <command> --help` 	- Show help per docker command
 
 Commands and options used within this tutorial:
 
 * `docker info` 		- Display system-wide information
 
 * `docker images`		- List images
 
 * `docker pull`		- Pull an image or a repository from a registry (e.g. [hub.docker.com](https://hub.docker.com/))
 
 * `docker ps`		    - List containers
 
     * -a 		        - Show all containers, incl. **stopped** containers
 
 * `docker network ls`	- List all networks
 
 * `docker run`		    - Run a command in a **new** container
 
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
 
 * `docker rm` 		    - Remove one or more containers
 
 * `docker rmi`		    - Remove one or more images
        
# Links for further reading and resources

## Tutorial resources and slides 

- slides/01_T_Introduction.pdf
- slides/02_T_INSPIRE-Download-Services.pdf
- slides/03_TP_Docker.pdf
- slides/04_P_deegree-on-Docker.pdf
- slides/05_TP_deegree.pdf
- slides/06_P_Configuration-of-a-deegree-INSPIRE-Download-Service.pdf
- slides/07_TP_Validation-of-service-and-data.pdf

### Archive:

* [FOSS4G 2016 Workshop](https://github.com/tfr42/deegree-docker/tree/foss4g2016_workshop)

## Docker

* [https://www.docker.com](https://www.docker.com)
* [https://docs.docker.com](https://docs.docker.com)
* [https://hub.docker.com](https://hub.docker.com)

### Talks about Docker and GIS

Video (german) - [FOSS4G 2016 - Docker Images for Geospatial](https://ftp.gwdg.de/pub/misc/openstreetmap/FOSS4G-2016/foss4g-2016-1146-an_overview_of_docker_images_for_geospatial_applications-hd.mp4)

[comment]: <> (... generell mehr adden, vor allem zu Docker Compose)
## deegree resources

* [https://github.com/deegree/deegree3](https://github.com/deegree/deegree3)
* [https://www.deegree.org](https://www.deegree.org)
* [https://www.osgeo.org/projects/deegree/](https://www.osgeo.org/projects/deegree/)
* [https://www.fossgis.de/aktivit%c3%a4ten/langzeitf%c3%b6rderungen/deegree/](https://www.fossgis.de/aktivit%c3%a4ten/langzeitf%c3%b6rderungen/deegree/)

### Documentation 3.5.x (current))

* [https://download.deegree.org/documentation/current/html/](https://download.deegree.org/documentation/current/html/) 

### Documentation 3.4.x

* [https://download.deegree.org/documentation/3.4.35/html/](https://download.deegree.org/documentation/3.4.35/html/)

### deegree on Docker Hub

* [https://hub.docker.com/r/deegree/deegree3-docker/](https://hub.docker.com/r/deegree/deegree3-docker/)

### deegree End of Life (EOL) and Support Matrix

* [https://github.com/deegree/deegree3/wiki/End-of-Life-and-Support-Matrix](https://github.com/deegree/deegree3/wiki/End-of-Life-and-Support-Matrix)

## OGC CITE TEAM Engine

### TEAM Engine on Docker Image Testsuite

* [https://cite.opengeospatial.org/teamengine/](https://cite.opengeospatial.org/teamengine/)

### TEAM Engine Documentation and Info

* [https://github.com/opengeospatial/teamengine](https://github.com/opengeospatial/teamengine)
* [https://opengeospatial.github.io/teamengine/](http://opengeospatial.github.io/teamengine/)
* [https://github.com/opengeospatial/cite/wiki](https://github.com/opengeospatial/cite/wiki)

### TEAM Engine Docker Image

* [https://github.com/opengeospatial/teamengine-docker](https://github.com/opengeospatial/teamengine-docker)

## INSPIRE resources

### General Information about INSPIRE

* [https://knowledge-base.inspire.ec.europa.eu/index_en](https://knowledge-base.inspire.ec.europa.eu/index_en)

### INSPIRE Reference Validator

[https://inspire.ec.europa.eu/validator/home/index.html](https://inspire.ec.europa.eu/validator/home/index.html)

#### Slides and Videos for the INSPIRE Reference Validator

* [https://www.youtube.com/watch?v=BVWxWuo9X5g&list=PLtvJPnZpinhfv3HXkjAOEbTTCSSEE5d7E](https://www.youtube.com/watch?v=BVWxWuo9X5g&list=PLtvJPnZpinhfv3HXkjAOEbTTCSSEE5d7E)
* [https://github.com/INSPIRE-MIF/helpdesk-validator/tree/master/training%20material/2024-05-31%20JRC%20Training](https://github.com/INSPIRE-MIF/helpdesk-validator/tree/master/training%20material/2024-05-31%20JRC%20Training)

### INSPIRE Data specifications

* [https://github.com/INSPIRE-MIF/technical-guidelines/tree/main/data/](https://github.com/INSPIRE-MIF/technical-guidelines/tree/main/data/)
* [https://knowledge-base.inspire.ec.europa.eu/publications/inspire-data-specification-protected-sites-technical-guidelines_en](https://knowledge-base.inspire.ec.europa.eu/publications/inspire-data-specification-protected-sites-technical-guidelines_en)

### INSPIRE Data Transformation with HALE

[comment]: <> (ToDo)

### INSPIRE in Practice (Geoportal)

* [https://inspire-geoportal.ec.europa.eu/srv/eng/catalog.search#/home](https://inspire-geoportal.ec.europa.eu/srv/eng/catalog.search#/home)

## OSGeo resources

* [https://www.osgeo.org/](https://www.osgeo.org/)
* [https://www.osgeo.org/projects/deegree/](https://www.osgeo.org/projects/deegree/)
* [https://wiki.osgeo.org/wiki/DockerImages](https://wiki.osgeo.org/wiki/DockerImages)
* [https://wiki.osgeo.org/wiki/INSPIRE](https://wiki.osgeo.org/wiki/INSPIRE)
* [https://wiki.osgeo.org/wiki/INSPIRE_tools_inventory](https://wiki.osgeo.org/wiki/INSPIRE_tools_inventory)

### OpenStreet Map, Open Data and public spatial services

[comment]: <> (ToDo)

# License

This document is published under creative commons license.

[Attribution - Non Commercial - Share Alike -  4.0 International (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en)

