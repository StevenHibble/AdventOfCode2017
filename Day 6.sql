DECLARE @Input VARCHAR(MAX) = '10	3	15	10	5	15	5	15	9	2	5	8	5	2	3	6';

DROP TABLE IF EXISTS #Banks;
SELECT BankID = ID
     , BlockCount = CONVERT(INT, String)
INTO #Banks
FROM Utility.Tools.SplitString(@Input, CHAR(9));

DECLARE @Configurations TABLE (ID INT IDENTITY(1,1)
                             , [Configuration] VARCHAR(8000) PRIMARY KEY);

DECLARE @BiggestBank INT
DECLARE @BlockCount INT
DECLARE @Counter INT = 0;

SET NOCOUNT ON;
WHILE 1 = 1
  BEGIN
    
    -- Try to insert a new configuration
    -- If it's already in @Configurations, then don't do anything
    INSERT INTO @Configurations
    SELECT [Configuration]
    FROM (SELECT [Configuration] = STRING_AGG(BlockCount, ',') WITHIN GROUP (ORDER BY BankID)
          FROM #Banks) b
    WHERE NOT EXISTS (SELECT 1
                      FROM @Configurations c
                      WHERE c.[Configuration] = b.[Configuration]);
    
    -- If the configuration didn't insert (it's already been seen), then break
    IF @@ROWCOUNT = 0
      BREAK;

    SELECT TOP 1
           @BiggestBank = BankID
         , @BlockCount = BlockCount
    FROM [#Banks]
    ORDER BY BlockCount DESC
           , BankID;
    
    UPDATE b         
    SET BlockCount = IIF(BankID = @BiggestBank, 0, BlockCount) -- If it's the original block, then reset to 0, else start at the current BlockCount
                   + (@BlockCount / 16) -- Then add to each block the total number of times the original BlockCount would go around 16 (e.g. 1-15 -> 0; 16-31 -> 1; 32-47 -> 2; etc.)
                   + IIF(StepsAway <= @BlockCount % 16, 1, 0) -- Then add the remaining blocks to the first X blocks after the original block
    FROM [#Banks] b                          
         CROSS APPLY (SELECT StepsAway = IIF(BankID > @BiggestBank, BankID - @BiggestBank, BankID + 16 - @BiggestBank)) sa; -- If the block is BEFORE the original block, add 16 to treat as a wrap around

    SET @Counter += 1;
  END;

SELECT Solution1 = @Counter;

SELECT Solution2 = @Counter + 1 - ID
FROM @Configurations
WHERE [Configuration] = (SELECT STRING_AGG(BlockCount, ',') WITHIN GROUP (ORDER BY BankID) FROM #Banks);
