
SELECT
       USER_NAME(memberuid) AS [Role],
       USER_NAME(groupuid) AS [User]
FROM  sysmembers
        