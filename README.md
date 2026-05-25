# HomeServer docker stack

In this repository I have all the necessary docker compose YAMLs to deploy all the apps needed for my home server

To get these containers up and running fast on a **linux** server, clone the repository onto the server and then run the shell script.

The commands to be executed are something along the lines of:

```
git clone https://github.com/EduardoPereira411/HomeServerDocker.git

cd HomeServerDocker

chmod +x DeployContainers.sh

./DeployContainers.sh
```

# HomeServer Docker Stack

This repository contains the necessary Docker Compose configuration files to deploy and manage applications on a home server.

The directory structure separates applications into categories and application-specific folders (e.g., HwMetrics/prometheus/docker-compose.yml) to keep the configuration organized and maintainable.

## Initial Server Setup and Permissions

Execute these commands on your fresh Linux host before attempting to deploy containers. This configuration ensures Docker can be managed without root privileges and prevents host folder access conflicts.

1. Add your user account to the Docker group to remove the requirement of using 'sudo' for Docker commands:

```
   sudo usermod -aG docker $USER
```

2. Log out and log back in, or run the following command to apply the group changes instantly:

```
   newgrp docker
```

3. Set up group ownership on your persistent data/volume directories so both your user account and the Docker daemon can read and write to them seamlessly:

```
   sudo chgrp -R yourgroup /path/to/volume
   sudo chmod -R g+rwX /path/to/volume
```

(Note: Replace 'yourgroup' with your actual linux username, and use absolute paths for the volume)

## Keeping your configs:

If you are planing to move the containers from one server to another, and want to keep all the configs for the containers, run this on your current server:

```
tar -czvf homeserver_bind_mounts.tar.gz -C ~/ContainerDBs
```

This will zip all the necessary files onto a tar.gz file, you can then export download this file and place it on the new server, where you can run:

```
tar -xzvf homeserver_bind_mounts.tar.gz -C ~/
```

These commands assume all you data is inside the **ContainerDBs** directory, adjust it as needed.

This will also only backup binded mounts, not volume data, to do that run the following command for each volume:

```
docker run --rm -v VOLUME_NAME:/volume -v $(pwd):/backup ubuntu tar -czvf /backup/VOLUME_NAME_backup.tar.gz -C /volume .
```

With **VOLUME_NAME** being changed at will.

Then in the new server, import the tar,gz file and run

```
docker volume create VOLUME_NAME

docker run --rm -v VOLUME_NAME:/volume -v $(pwd):/backup ubuntu tar -xzvf /backup/VOLUME_NAME_backup.tar.gz -C /volume
```

## Preset env variables

In this repo, some compose files are accompanied by a .env file. This means that for the compose files to work, they need the variables present on this file, if you want to have them all set from a different server, and to not have to worry about them when you pass these env files and have to fill them all in, simply add a **env_backups** folder within the **ContainerDBs** and create the same directory structure as the repo, with **.env** files where needed.
This way, when you backup the files with the previous sections steps, they can then be neatly imported into the new server to be used cleanly by the script

## Deployment Instructions

⚠️If you wish to restore all the configs, follow the previous sections first⚠️

To download and deploy the entire server infrastructure across all categories:

1. Clone the repository onto the server, set up the login using ssh since its easier to set up on a server:

```
   git clone git@github.com:EduardoPereira411/HomeServerDocker.git
```

2. Navigate into the repository directory:

```
   cd HomeServerDocker
```

3. Grant execution permissions to the automated deployment script:

```
   chmod +x DeployContainers.sh
```

4. Execute the script to deploy all stacks:

```
   ./DeployContainers.sh   OR   ./DeployContainers.sh --use-envs
```

EXTRA: You should also deploy the **AddCRONJobs.sh** if you want to set up metrics for dirsize of custom directories

## Individual Stack Management

If you need to view or manage a single specific application container instead of using the global script:

1. Navigate directly to that application's folder:
   cd HwMetrics/prometheus

2. Manage the container stack directly using native Docker Compose commands:
   docker compose up -d
   docker compose down
   docker compose restart
