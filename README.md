# Upgrade-SQL-with-Minimum-disruption-and-Risk

Upgrading our SQL Server 2017 to SQL Server 2019 with Always On Availability Groups
-----------------------------------------------------------------------------------

Setup for this scenario, we have Availability Group ‘AG1’ with 3 SQL replicas ‘SQL01’, ‘SQL02’, ‘SQL03’

NOTE: Below Pre-Requisites are *MANDATORY* for the Data Recovery and Smooth In-Place upgrade of SQL Server 2017 to SQL Server 2019

        1. Verify that Database Full backups and Log backups exist for all databases (user and system).Verify that these backups are able to be restored.
        2. Make sure you have Admin Rights over the Instances for proper Installation (To avoid Access Denbied issues)
        3. Make sure you script out all important SQL Server Jobs , SQL Server Logins 
        4. Make sure you script out all Transactional Replication Jobs , Distribution , Publishers , Subscribers etc ...
        5. Script out any and all necessary system objects.
        6. Script out any and all necessary SSIS packages (either from MSDB or as flat files).

Before you start be sure to check you have sufficient log drive space for potential log file growth in case the SQL Server installations take longer than expected.

*****************************************************************************************************************************
Series of steps the PowerShell Automatic Programming Code handles for the In Place SQL Server 2017 to SQL Server 2019 upgrade
*****************************************************************************************************************************
--------------------------------------------------
Media getting copied to all the AG Replicas to G:\SQLServer2019\

Below are the files which gets copied:

	a. ConfigurationFile.ini
	b. SQL Server 2019 Install Setup Media
        c. Monitoring SQL Server Transactional Replication Health. 
--------------------------------------------------- 

* Monitor the Disk Status post Upgrade
1. Connecting to the secondary Asynchornous Commit Replica  (SQL03) .
2. Uses the configurationfile.ini with all necessary /ACTION="UPGRADE" steps.
3. During the Upgrade the AG Replica services go down.
4. After Successful Upgrade , Restarts the SQL03 machine .
5. Now *ONLY* the SQL03 AG Secondary Replica is upgraded to SQL Server 2019
6. Now, let’s get the secondary synchronous commit replica  (SQL02) switched from Synchronous mode to Asynchronous mode .
7. Uses the configurationfile.ini with all necessary /ACTION="UPGRADE" steps.
8. After Successful Upgrade , Restarts the SQL02 machine .
9. After Restart of SQL02 , the Secondary Replica (SQL02) switched from Asynchronous mode to Synchronous Commit mode .
10. Now *ONLY* SQL02, SQL03 AG Secondary Replica's are upgraded to SQL Server 2019
11. Failover SQL01 --> SQL02 which will become current Primary Replica.
12. Now, let’s get the secondary synchronous commit replica  (SQL01) switched from Synchronous mode to Asynchronous mode .
13. Uses the configurationfile.ini with all necessary /ACTION="UPGRADE" steps.
14. After Successful Upgrade , Restarts the SQL01 machine .
15. After Restart of SQL01 , the Secondary Replica (SQL01) switched from Asynchronous mode to Synchronous Commit mode .
16. After SQL01 changed to Synchronous Commit mode , once the data is synchronized ,Failback AG1 from SQL02 --> SQL01 AG Replica.
17. After successful Failover of AG1 from SQL02 --> SQL01 , the AG1 Health status should all be in Green.
18. Validate the AOAG Health
19. Validate the Transactional Replication Health
20. Monitor the Disk Status post Upgrade

--------------------------------------------------










