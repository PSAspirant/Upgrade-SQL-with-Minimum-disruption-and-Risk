DECLARE @srvname VARCHAR(100)
DECLARE @pub_db VARCHAR(100)
DECLARE @pubname VARCHAR(100)
CREATE TABLE #replmonitor(status    INT NULL,warning    INT NULL,subscriber    sysname NULL,subscriber_db    sysname NULL,publisher_db    sysname NULL,
publication    sysname NULL,publication_type    INT NULL,subtype    INT NULL,latency    INT NULL,latencythreshold    INT NULL,agentnotrunning    INT NULL,
agentnotrunningthreshold    INT NULL,timetoexpiration    INT NULL,expirationthreshold    INT NULL,last_distsync    DATETIME,
distribution_agentname    sysname NULL,mergeagentname    sysname NULL,mergesubscriptionfriendlyname    sysname NULL,mergeagentlocation    sysname NULL,
mergeconnectiontype    INT NULL,mergePerformance    INT NULL,mergerunspeed    FLOAT,mergerunduration    INT NULL,monitorranking    INT NULL,
distributionagentjobid    BINARY(16),mergeagentjobid    BINARY(16),distributionagentid    INT NULL,distributionagentprofileid    INT NULL,
mergeagentid    INT NULL,mergeagentprofileid    INT NULL,logreaderagentname VARCHAR(100))
DECLARE replmonitor CURSOR FOR
SELECT b.srvname,a.publisher_db,a.publication
FROM distribution.dbo.MSpublications a,  master.dbo.sysservers b
WHERE a.publisher_id=b.srvid
OPEN replmonitor 
FETCH NEXT FROM replmonitor INTO @srvname,@pub_db,@pubname
WHILE @@FETCH_STATUS = 0
BEGIN
INSERT INTO #replmonitor
EXEC distribution.dbo.sp_replmonitorhelpsubscription  @publisher = @srvname
     , @publisher_db = @pub_db
     ,  @publication = @pubname
     , @publication_type = 0
FETCH NEXT FROM replmonitor INTO @srvname,@pub_db,@pubname
END
CLOSE replmonitor
DEALLOCATE replmonitor
 
SELECT publication,publisher_db,subscriber,subscriber_db,
        CASE publication_type WHEN 0 THEN 'Transactional publication'
            WHEN 1 THEN 'Snapshot publication'
            WHEN 2 THEN 'Merge publication'
            ELSE 'Not Known' END,
        CASE subtype WHEN 0 THEN 'Push'
            WHEN 1 THEN 'Pull'
            WHEN 2 THEN 'Anonymous'
            ELSE 'Not Known' END,
        CASE status WHEN 1 THEN 'Started'
            WHEN 2 THEN 'Succeeded'
            WHEN 3 THEN 'In progress'
            WHEN 4 THEN 'Idle'
            WHEN 5 THEN 'Retrying'
            WHEN 6 THEN 'Failed'
            ELSE 'Not Known' END,
        CASE warning WHEN 0 THEN 'No Issues in Replication' ELSE 'Check Replication' END,
        latency, latencythreshold, 
        'LatencyStatus'= CASE WHEN (latency > latencythreshold) THEN 'High Latency'
        ELSE 'No Latency' END,
        distribution_agentname,'DistributorStatus'= CASE WHEN (DATEDIFF(hh,last_distsync,GETDATE())>1) THEN 'Distributor has not executed more than n hour'
        ELSE 'Distributor running fine' END
        FROM #replmonitor
DROP TABLE #replmonitor