DECLARE @Input INT = 289326;

-- Part 1
SELECT TOP 1 
       Solution1 = SpiralLevel + DistanceFromClosestMiddle
FROM Utility.dbo.Numbers
     CROSS APPLY (SELECT SpiralLevel = [Number]
                       , SpiralLength = ([Number]+1)*2 - 2
                       , PreviousHighestNumber = POWER(CONVERT(BIGINT, [Number]*2 - 1), 2)
                       , HighestNumber = POWER(CONVERT(BIGINT, ([Number]+1)*2 - 1), 2)) v
     CROSS APPLY (SELECT TOP 1                       /* Corner - half the spiral length (to get to the middle) - length of side * N (to find each middle)
                                                        Then compare to @Input to get this distance to each middle
                                                        Take the smallest distance */
                         DistanceFromClosestMiddle = ABS((HighestNumber - (SpiralLength)/2 - ((SpiralLength)*([Number]-1))) - @Input)
                  FROM Utility.dbo.Numbers n1
                  WHERE n1.[Number] <= 4
                  ORDER BY DistanceFromClosestMiddle) n
WHERE PreviousHighestNumber < @Input
ORDER BY [Number] DESC;



-- Part 2
-- I'm at a loss for how to do this in a set-based manner
-- So, I'm going to build the spiral point by point
DECLARE @Coordinates TABLE (ID INT IDENTITY(1,1) NOT NULL
                          , X INT NOT NULL
                          , Y INT NOT NULL
                          , [Value] INT NOT NULL);

-- Start at the origin with value 1
INSERT INTO @Coordinates
       (X, Y, [Value])
VALUES (0, 0, 1);

DECLARE @Directions TABLE (CurrentDir CHAR(1)
                         , NextDir CHAR(1)
                         , XChange INT
                         , YChange INT);

-- Log how I'm going to change directions
INSERT INTO @Directions
VALUES ('R', 'U', 1, 0)
     , ('U', 'L', 0, 1)
     , ('L', 'D', -1, 0)
     , ('D', 'R', 0, -1);

-- Initial values
DECLARE @Direction CHAR(1) = 'R' -- R, U, L, D
      , @Length INT = 1
      , @Count INT = 0
      , @X INT = 0
      , @Y INT = 0

-- Loop until the value is bigger than the input
-- This outer loop changes direction
WHILE (SELECT MAX([Value])
       FROM @Coordinates) <= @Input
  BEGIN
    
    SET @Count = 0;

    -- Loop until you change direction
    -- Make sure to exit if the value is tripped here
    WHILE @Count < @Length
          AND (SELECT MAX([Value])
               FROM @Coordinates) <= @Input
      BEGIN
        -- Get a new coordinate
        SELECT @X = @X + XChange
             , @Y = @Y + YChange
        FROM @Directions
        WHERE CurrentDir = @Direction;
        
        -- Insert the new coordinate with it's value (sum of all preexisting neighbors)
        INSERT INTO @Coordinates
              (X
             , Y
             , [Value])
        SELECT @X
             , @Y
             , [Value] = SUM([Value])
        FROM @Coordinates
        WHERE X BETWEEN @X-1 and @X+1
              AND Y BETWEEN @Y-1 and @Y+1;
        
        SET @Count += 1
      END;


    -- Change direction
    SELECT @Direction = NextDir
    FROM @Directions
    WHERE CurrentDir = @Direction

    -- Change @Length
    IF @Direction IN ('L', 'R')
       BEGIN
         SET @Length += 1
       END;
  END;

SELECT Solution2 = MAX([Value])
FROM @Coordinates