FROM oraclelinux:7-slim as base

ENV ORACLE_BASE=/opt/oracle \
    ORACLE_HOME=/opt/oracle/product/19c/dbhomeXE \
    ORACLE_SID=XE \
    INSTALL_FILE_1=oracle-database-ee-19c-1.0-1.x86_64.rpm \
    RUN_DB=runOracle.sh \
    PWD_FILE=setPassword.sh \
    CONF_FILE=oracle-xe-19c.conf \
    CHECK_DB_FILE=checkDBStatus.sh \
    ORACLE_DOCKER_INSTALL=true \
    NLS_LANG=AMERICAN_AMERICA.AL32UTF8 \
    PATH=$ORACLE_HOME/bin:$PATH \
    ORACLE_PWD=Admin123

COPY $RUN_DB $PWD_FILE $CHECK_DB_FILE $CONF_FILE ./

RUN yum -y install unzip.x86_64 oracle-database-preinstall-19c file openssl \
    && curl -o $INSTALL_FILE_1 https://s3.amazonaws.com/software.redpillanalytics.io/oracle/xe/${INSTALL_FILE_1} \
    && mkdir -p ${ORACLE_BASE} \
    && chown oracle:oinstall ${ORACLE_BASE} \
    && yum -y install $INSTALL_FILE_1 \
    && rm -rf /var/cache/yum \
    && rm -f $INSTALL_FILE_1 \
    && rm -rf $ORACLE_HOME/demo \
    && rm -rf $ORACLE_HOME/dmu \
    && rm -rf $ORACLE_HOME/javavm \
    && rm -rf $ORACLE_HOME/md \
    && rm -rf $ORACLE_HOME/nls/demo \
    && rm -rf $ORACLE_HOME/odbc \
    && rm -rf $ORACLE_HOME/rdbms/demo \
    && rm -rf $ORACLE_HOME/R \
    && rm -rf $ORACLE_HOME/instantclient \
    && rm -rf $ORACLE_HOME/inventory \
    && rm -rf $ORACLE_HOME/deinstall \
    && rm -r  $ORACLE_HOME/lib/ra_aix_ppc64.zip \
    && rm -r  $ORACLE_HOME/lib/ra_hpux_ia64.zip \
    && rm -r  $ORACLE_HOME/lib/ra_solaris*.zip \
    && rm -f  $ORACLE_HOME/lib/ra_windows64.zip \
    && rm -f  $ORACLE_HOME/lib/ra_zlinux64.zip \
    && rm -rf $ORACLE_HOME/crs \
    && rm -f  $ORACLE_HOME/bin/asmcmd \
    && rm -f  $ORACLE_HOME/bin/asmcmdcore \
    && rm -f  $ORACLE_HOME/bin/bdschecksw \
    && rm -f  £ORACLE_HOME/bin/dbv \
    && rm -f  $ORACLE_HOME/bin/ldap* \
    && rm -f  $ORACLE_HOME/bin/dbfs_client \
    && rm -f  $ORACLE_HOME/bin/afdboot \
    && rm -f  $ORACLE_HOME/bin/exp \
    && rm -f  $ORACLE_HOME/bin/imp \
    && rm -f  $ORACLE_HOME/bin/*.exe \
    && rm -f  $ORACLE_HOME/bin/lcsscan \
    && rm -f  $ORACLE_HOME/bin/dgmgrl \
    && rm -f  $ORACLE_HOME/bin/nid \
    && rm -f  $ORACLE_HOME/bin/orion \
    && rm -f  $ORACLE_HOME/bin/procob \
    && rm -f  $ORACLE_HOME/bin/setasmgid \
    && rm -f  $ORACLE_HOME/bin/wrap \
    && rm -f  $ORACLE_HOME/bin/*0 \
    && rm -f  $ORACLE_HOME/bin/tnsping \
    && rm -f  $ORACLE_HOME/bin/tkprof \
    && rm -f  $ORACLE_HOME/bin/srvctl \
    && rm -f  $ORCALE_HOME/bin/wrc \
    && rm -rf $ORACLE_HOME/sdk \
    && strip --remove-section=.comment $ORACLE_HOME/bin/oracle \
    && strip --remove-section=.comment $ORACLE_HOME/bin/rman \
    && strip --remove-section=.comment $ORACLE_HOME/bin/tnslsnr \
    && $ORACLE_BASE/oraInventory/orainstRoot.sh \
    && $ORACLE_HOME/root.sh \
    && mkdir -p $ORACLE_BASE/scripts/setup \
    && mkdir -p $ORACLE_BASE/scripts/startup \
    && ln -s $ORACLE_BASE/scripts /docker-entrypoint-initdb.d \
    && mkdir -p $ORACLE_BASE/oradata $ORACLE_BASE/diag $ORACLE_BASE/fast_recovery_area $ORACLE_BASE/tools /home/oracle \
    && chown -R oracle:oinstall $ORACLE_BASE /home/oracle \
    && mv $RUN_DB $ORACLE_BASE/ \
    && mv $PWD_FILE $ORACLE_BASE/ \
    && mv $CHECK_DB_FILE $ORACLE_BASE/ \
    && mv $CONF_FILE /etc/sysconfig/ \
    && ln -s $ORACLE_BASE/$PWD_FILE / \
    && target_txt=$(cat /etc/security/limits.d/oracle-database-preinstall-19c.conf | grep -e 'oracle *hard *memlock*') \
    && sed -i "/^$target_txt/ c#$target_txt" /etc/security/limits.d/oracle-database-preinstall-19c.conf \
    && chmod ug+x $ORACLE_BASE/*.sh

# Adding VOLUMES for oradata and diag directory
VOLUME ["$ORACLE_BASE/oradata"]
VOLUME ["$ORACLE_BASE/diag"]
VOLUME ["$ORACLE_BASE/fast_recovery_area"]
VOLUME ["$ORACLE_BASE/tools"]
EXPOSE 1521 
HEALTHCHECK --interval=1m --start-period=5m \
   CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || exit 1

ENTRYPOINT ${ORACLE_BASE}/${RUN_DB} && cat
