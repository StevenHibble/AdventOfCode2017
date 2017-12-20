DECLARE @Input INT = 289326;

-- Part 1
SELECT TOP 1 
       Solution = SpiralLevel + DistanceFromClosestMiddle
FROM Utility.dbo.Numbers
     CROSS APPLY (SELECT SpiralLevel = [Number]
                       , SpiralLength = ([Number]+1)*2 - 1
                       , PreviousHighestNumber = POWER(CONVERT(BIGINT, [Number]*2 - 1), 2)
                       , HighestNumber = POWER(CONVERT(BIGINT, ([Number]+1)*2 - 1), 2)) v
     CROSS APPLY (SELECT TOP 1                       /* Corner - half the spiral length (to get to the middle) - length of side * N (to find each middle)
                                                        Then compare to @Input to get this distance to each middle
                                                        Take the smallest distance */
                         DistanceFromClosestMiddle = ABS((HighestNumber - (SpiralLength-1)/2 - ((SpiralLength-1)*([Number]-1))) - @Input)
                  FROM Utility.dbo.Numbers n1
                  WHERE n1.[Number] <= 4
                  ORDER BY DistanceFromClosestMiddle) n
WHERE PreviousHighestNumber < @Input
ORDER BY [Number] DESC;

-- Part 2