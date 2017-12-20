DECLARE @Input VARCHAR(MAX) = '10	3	15	10	5	15	5	15	9	2	5	8	5	2	3	6';

DROP TABLE IF EXISTS #Banks;
SELECT BankID = ID
     , BlockCount = CONVERT(INT, String)
INTO #Banks
FROM Manage.Tools.SplitString(@Input, CHAR(9));

DECLARE @Configurations TABLE ([Configuration] VARCHAR(8000) PRIMARY KEY);

DECLARE @BiggestBank INT
DECLARE @BlockCount INT
DECLARE @Counter INT = 1;

WHILE @Counter <= 4
  BEGIN
    INSERT INTO @Configurations
    SELECT STRING_AGG(@BlockCount, ',') WITHIN GROUP (ORDER BY BankID)
    FROM #Banks;

    SELECT TOP 1
           @BiggestBank = BankID
         , @BlockCount = BlockCount
    FROM [#Banks]
    ORDER BY BlockCount DESC
           , BankID;
    
    UPDATE b
    SET BlockCount = IIF(BankID = @BiggestBank, 0, BlockCount) + (@BlockCount/16) + IIF(StepsAway <= @BlockCount%16, 1, 0)
    FROM [#Banks] b
         CROSS APPLY (SELECT StepsAway = IIF(BankID > @BiggestBank, BankID - @BiggestBank, BankID + 16 - @BiggestBank)) sa;
    SET @Counter += 1
  END;