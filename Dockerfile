FROM oraclelinux:7-slim as base

ENV ORACLE_BASE=/opt/oracle
ENV ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE
ENV ORACLE_SID=XE
ENV INSTALL_FILE_1=oracle-database-xe-18c-1.0-1.x86_64.rpm
ENV RUN_DB=runOracle.sh
ENV PWD_FILE=setPassword.sh
ENV CONF_FILE=oracle-xe-18c.conf
ENV CHECK_DB_FILE=checkDBStatus.sh
ENV ORACLE_DOCKER_INSTALL=true
ENV NLS_LANG=AMERICAN_AMERICA.AL32UTF8
ENV PATH=$ORACLE_HOME/bin:$PATH

COPY $RUN_DB $PWD_FILE $CHECK_DB_FILE $CONF_FILE ./

RUN yum -y install unzip.x86_64 oracle-database-preinstall-18c file openssl
RUN curl -o $INSTALL_FILE_1 https://s3.amazonaws.com/software.redpillanalytics.io/oracle/xe/18.4.0/${INSTALL_FILE_1}

# Install DB software rpm
RUN mkdir -p ${ORACLE_BASE}
RUN chown oracle:oinstall ${ORACLE_BASE}
RUN yum -y install $INSTALL_FILE_1
RUN rm -rf /var/cache/yum
RUN rm -f $INSTALL_FILE_1
RUN rm -rf $ORACLE_HOME/demo
RUN rm -rf $ORACLE_HOME/dmu
RUN rm -rf $ORACLE_HOME/javavm
RUN rm -rf $ORACLE_HOME/md
RUN rm -rf $ORACLE_HOME/nls/demo
RUN rm -rf $ORACLE_HOME/odbc
RUN rm -rf $ORACLE_HOME/rdbms/demo
RUN rm -rf $ORACLE_HOME/R
RUN rm -rf $ORACLE_HOME/instantclient
RUN rm -rf $ORACLE_HOME/inventory
RUN rm -rf $ORACLE_HOME/deinstall
RUN rm -r  $ORACLE_HOME/lib/ra_aix_ppc64.zip
RUN rm -r  $ORACLE_HOME/lib/ra_hpux_ia64.zip
RUN rm -r  $ORACLE_HOME/lib/ra_solaris*.zip
RUN rm -f  $ORACLE_HOME/lib/ra_windows64.zip
RUN rm -f  $ORACLE_HOME/lib/ra_zlinux64.zip
RUN rm -rf $ORACLE_HOME/crs
RUN rm -f  $ORACLE_HOME/bin/asmcmd
RUN rm -f  $ORACLE_HOME/bin/asmcmdcore
RUN rm -f  $ORACLE_HOME/bin/bdschecksw
RUN rm -f  £ORACLE_HOME/bin/dbv
RUN rm -f  $ORACLE_HOME/bin/ldap*
RUN rm -f  $ORACLE_HOME/bin/dbfs_client
RUN rm -f  $ORACLE_HOME/bin/afdboot
RUN rm -f  $ORACLE_HOME/bin/exp
RUN rm -f  $ORACLE_HOME/bin/imp
RUN rm -f  $ORACLE_HOME/bin/*.exe
RUN rm -f  $ORACLE_HOME/bin/lcsscan
RUN rm -f  $ORACLE_HOME/bin/dgmgrl
RUN rm -f  $ORACLE_HOME/bin/nid
RUN rm -f  $ORACLE_HOME/bin/orion
RUN rm -f  $ORACLE_HOME/bin/procob
RUN rm -f  $ORACLE_HOME/bin/setasmgid
RUN rm -f  $ORACLE_HOME/bin/wrap
RUN rm -f  $ORACLE_HOME/bin/*0
RUN rm -f  $ORACLE_HOME/bin/tnsping
RUN rm -f  $ORACLE_HOME/bin/tkprof
RUN rm -f  $ORACLE_HOME/bin/srvctl
RUN rm -f  $ORCALE_HOME/bin/wrc
RUN rm -rf $ORACLE_HOME/sdk
RUN strip --remove-section=.comment $ORACLE_HOME/bin/oracle
RUN strip --remove-section=.comment $ORACLE_HOME/bin/rman
RUN strip --remove-section=.comment $ORACLE_HOME/bin/tnslsnr

RUN $ORACLE_BASE/oraInventory/orainstRoot.sh
RUN $ORACLE_HOME/root.sh
RUN mkdir -p $ORACLE_BASE/scripts/setup
RUN mkdir -p $ORACLE_BASE/scripts/startup
RUN ln -s $ORACLE_BASE/scripts /docker-entrypoint-initdb.d
RUN mkdir -p $ORACLE_BASE/oradata $ORACLE_BASE/diag $ORACLE_BASE/fast_recovery_area $ORACLE_BASE/tools /home/oracle
RUN chown -R oracle:oinstall $ORACLE_BASE /home/oracle
RUN mv $RUN_DB $ORACLE_BASE/
RUN mv $PWD_FILE $ORACLE_BASE/
RUN mv $CHECK_DB_FILE $ORACLE_BASE/
RUN mv $CONF_FILE /etc/sysconfig/
RUN ln -s $ORACLE_BASE/$PWD_FILE /
    # rm -rf $INSTALL_DIR
RUN target_txt=$(cat /etc/security/limits.d/oracle-database-preinstall-18c.conf | grep -e 'oracle *hard *memlock*')
RUN sed -i "/^$target_txt/ c#$target_txt" /etc/security/limits.d/oracle-database-preinstall-18c.conf
RUN chmod ug+x $ORACLE_BASE/*.sh

# Pre-create the database
# RUN ${ORACLE_BASE}/${RUN_DB}

# Adding VOLUMES for oradata and diag directory
VOLUME ["$ORACLE_BASE/oradata"]
VOLUME ["$ORACLE_BASE/diag"]
VOLUME ["$ORACLE_BASE/fast_recovery_area"]
VOLUME ["$ORACLE_BASE/tools"]
EXPOSE 1521 
HEALTHCHECK --interval=1m --start-period=5m \
   CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || exit 1

ENTRYPOINT ${ORACLE_BASE}/${RUN_DB} && cat
