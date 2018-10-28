# == Class proxysql::reload_config
#
# This class is called from proxysql to update config if it changed.
#
class proxysql::reload_config {

  $subscribe = $proxysql::split_config ? {
    true  => [ File['proxysql-config-file'], File['proxysql-proxy-config-file'] ],
    false => File['proxysql-config-file'],
  }

  $mycnf_file_name = $proxysql::mycnf_file_name
    exec {'reload-config':
        command     => "/usr/bin/mysql --defaults-file=${mycnf_file_name} --execute=\"
          LOAD ADMIN VARIABLES FROM CONFIG; \
          LOAD ADMIN VARIABLES TO RUNTIME; \
          SAVE ADMIN VARIABLES TO DISK; \
          DELETE FROM mysql_servers; \
          LOAD MYSQL SERVERS FROM CONFIG; \
          LOAD MYSQL SERVERS TO RUNTIME; \
          SAVE MYSQL SERVERS TO DISK; \
          DELETE FROM mysql_users; \
          LOAD MYSQL USERS FROM CONFIG; \
          LOAD MYSQL USERS TO RUNTIME; \
          SAVE MYSQL USERS TO DISK; \
          LOAD SCHEDULER FROM CONFIG; \
          LOAD SCHEDULER TO RUNTIME; \
          SAVE SCHEDULER TO DISK; \
          LOAD MYSQL QUERY RULES FROM CONFIG; \
          LOAD MYSQL QUERY RULES TO RUNTIME; \
          SAVE MYSQL QUERY RULES TO DISK; \
          LOAD MYSQL VARIABLES FROM CONFIG; \
          LOAD MYSQL VARIABLES TO RUNTIME; \
          SAVE MYSQL VARIABLES TO DISK; \"
        ",
        subscribe   => $subscribe,
        require     => [ Service[$proxysql::service_name] , File['root-mycnf-file'] ],
        refreshonly => true,
    }
}
