Optimized Oracle XE 18c on Docker
=====
Build a Docker image containing Oracle XE 18c with optimized size (4.02 GB instead of 8.7 GB) including Archivelog Mode and Flashback

## Run the Container
Just run following command, which will create your Oracle XE 18c Container, mount the internal directories `/opt/oracle/oradata`, `/opt/oracle/diag`, `/opt/oracle/fast_recovery_area` and `/opt/oracle/tools` to your prior created directories on your Docker host and enables a port forwarding of the Listener Port 1521 to 1521
```
docker run -d --name oraxe18c \
              -p 1521:1521 \
              -e ORACLE_PWD=[your password] \
              -e ORACLE_CHARACTERSET=[your characterset] \
              -e TZ=[your timezone] \
              -v [host directory for oradata]:/opt/oracle/oradata \
              -v [host directory for diag]:/opt/oracle/diag \
              -v [host directory for fast_recovery_area]:/opt/oracle/fast_recovery_area \
              -v [host directory for tools]:/opt/oracle/tools \
              [--network [your bridged network] \
              oracle/database:18.4.0-xe

# For Example
docker run -d --name oraxe18c \
              -p 1521:1521 \
              -e ORACLE_PWD=Oracle18c \
              -e ORACLE_CHARACTERSET=AL32UTF8 \
              -e TZ=Europe/Zurich \
              -v /u01/oradata:/opt/oracle/oradata \
              -v /u01/diag:/opt/oracle/diag \
              -v /u01/fast_recovery_area:/opt/oracle/fast_recovery_area \
              -v /u01/tools:/opt/oracle/tools \
              --network mynet \
              oracle/database:18.4.0-xe
```

After that you can create under [host directory for tools], e.g. `/u01/tools` a simple rman backup script will following content and perform a first full backup with RMAN
```
vi /u01/tools/full_bkp.rman

connect target sys/[your password]@XE
run {
    backup database plus archivelog;
}

# For Example
connect target sys/Oracle18c@XE
run {
    backup database plus archivelog;
}

# Or as compressed backupset plus delete backed up archivelogs
connect target sys/Oracle18c@XE
run {
    backup as compressed backupset database plus archivelog delete input;
}
```

To execute now a full backup simply run following docker command:
```
docker exec -it oraxe18c rman @/opt/oracle/tools/full_bkp.rman
```
In case you want to execute the RMAN Backup job from crontab replace `-it` with `-i`

## License
To download and run Oracle Database, regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page.

All scripts and files hosted in this project and GitHub repository required to build the Docker images are, unless otherwise noted, released under [UPL 1.0](https://oss.oracle.com/licenses/upl/) license.
