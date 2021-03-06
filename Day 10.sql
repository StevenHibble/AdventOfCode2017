DECLARE @Input VARCHAR(MAX) = '31,2,85,1,80,109,35,63,98,255,0,13,105,254,128,33';
SET NOCOUNT ON;

DROP TABLE IF EXISTS #Lengths, #List;
SELECT ID = ID - 1
     , [Length] = CONVERT(INT, String)
INTO #Lengths
FROM Manage.Tools.SplitString(@Input, ',')

SELECT ID = Number
     , [Value] = Number - 1
INTO #List
FROM Numbers
WHERE Number <= 256;

--SELECT * FROM #Lengths;
--SELECT * FROM #List;

DECLARE @Position INT = 1, @Length INT, @SkipSize INT = 0;
DECLARE @Final INT = (SELECT MAX(ID)
                      FROM #Lengths);

WHILE @SkipSize <= @Final
  BEGIN
    SELECT @Length = [Length]
    FROM #Lengths
    WHERE ID = @SkipSize;

    WITH cte
         AS (SELECT *
             FROM #List
                  CROSS APPLY (SELECT Steps = IIF(ID >= @Position, ID - @Position + 1, ID + 256 - @Position + 1)) sa -- If the block is BEFORE the original block, add 16 to treat as a wrap around
             WHERE Steps BETWEEN 1 AND @Length)
    UPDATE c1
    SET [Value] = c2.[Value]
    FROM cte c1
         JOIN cte c2
           ON c1.Steps = @Length - c2.Steps + 1;


    SET @Position = (@Position + @Length + @SkipSize)%256; 
    SET @SkipSize += 1;
  END;

  SELECT Solution1 = (SELECT [Value] FROM #List WHERE ID = 1) * (SELECT [Value] FROM #List WHERE ID = 2);