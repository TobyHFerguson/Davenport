-- patch the system to take care of partitions
alter user sysman account unlock;
alter user sysman identified by Welcome1;
connect sysman/Welcome1
exec gc_interval_partition_mgr.partition_maintenance;
exec mgmt_audit_admin.add_audit_partition;
exit

