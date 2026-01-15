-- 1. Validating the grain of the dirty data -- 
        SELECT 
            Transaction_ID,
            COUNT(*) AS RowCnt
        FROM                        -- 0 row means 0 duplicates here -- 
            dirty_cafe_sales        -- hypothesis is that TransID values are all unique and can be used to validate the grain -- 
        GROUP BY                  
            Transaction_ID
        HAVING 
            COUNT(*) > 1

-- 1.1 checking for mispellings in items -- 
        SELECT 
            Item,
            COUNT (*) AS Total_Orders
        FROM 
             dirty_cafe_sales  -- 0 mispellings -- 
        GROUP BY
            Item
-- 1.2 checking for correct aggregation-- 
        SELECT 
            SUM(Quantity) as sumq 
        FROM 
            dirty_cafe_sales   
        WHERE 
            Quantity IS NOT NULL
-- 1.2.1 -- both there queries above and below returns the same sum of 28834 which means no rows contain duplicated quantity from the starting table -- 
        SELECT 
            SUM(Quantity) as sumq 
        FROM 
            (
                SELECT 
                DISTINCT 
                    Transaction_ID, 
                    Item, 
                    Quantity 
                FROM dirty_cafe_sales
              ) AS a
-- since there are no mispellings and duplicates, we can standardize now and start cleaning from there -- 
-- grain is 1:1 for transaction_ID and all columns



-- 2. standardization of text and numeric values-- 
        SELECT 
            Transaction_ID,
-- 2.1 NONE NUMERICS (USED UPPER TOO cuz why not) --
      -- None numerics are trimmed and nulled to remove redundancies -- 
        -- Item --
            UPPER(NULLIF
                (NULLIF
                    (NULLIF
                       (NULLIF(TRIM(Item), ''),
                     'NULL'),
                 'UNKNOWN'),
            'ERROR')) AS Item,
        -- Payment Method -- 
            UPPER(NULLIF
                (NULLIF
                    (NULLIF
                      (NULLIF(TRIM(Payment_Method), ''),
                    'NULL'),
                'UNKNOWN'),
            'ERROR')) AS Payment_Method,
        -- Location -- 
            UPPER(NULLIF
                (NULLIF
                    (NULLIF
                       (NULLIF(TRIM(Location), ''),
                    'NULL'),
                  'UNKNOWN'),
              'ERROR')) AS Location,
-- 2.2 NUMERICS (still subject to change) -- 
        -- numerics are checked for having negative and 0 values and casted to appropriate type -- 
        -- PPU -- 
            CASE 
                WHEN Price_Per_Unit <= 0 THEN NULL
                ELSE CAST(Price_Per_Unit AS DECIMAL(10,2)) 
            END AS Price_Per_Unit,
        -- Total Spent -- 
            CASE 
                WHEN Total_Spent <= 0 THEN NULL
                ELSE CAST(Total_Spent AS DECIMAL (10,2))
            END AS Total_Spent,
        -- Quantity -- 
            CASE
                WHEN Quantity <= 0 THEN NULL
                ELSE CAST(Quantity AS smallint) 
            END AS Quantity,

        -- DATE --
            CASE
                WHEN Transaction_Date IS NULL THEN CAST(Transaction_Date AS date)
                ELSE Transaction_Date
            END AS Transaction_Date
        INTO 
            standardizedV -- into a new table -- 
        FROM 
            dirty_cafe_sales 

-- 3. 3-round Imputations and calculations -- 
                
        -- 3.1 1st round of imputations -- 

        WITH 
        PriceItemRef AS (
            SELECT 
                DISTINCT 
                MIN(Item) AS Item,
                Price_Per_Unit
            FROM                        -- to coalesce missing vals from item and ppu --                                           
                standardizedV           -- except those with ambiguous ppu -- 
            WHERE 
                Item IS NOT NULL
            AND Price_Per_Unit IS NOT NULL
            GROUP BY 
               Price_Per_Unit
            HAVING  
                COUNT(DISTINCT(Item)) = 1
            )
        SELECT 
            a.Transaction_ID,
            CASE 
                WHEN a.Item IS NULL
                THEN COALESCE(a.item,b.item) -- items w/ ambiguous prices will be left null --
                ELSE a.Item 
            END AS Item,
            CASE    
                WHEN a.Price_Per_Unit IS NULL
                THEN COALESCE(a.Price_Per_Unit,avc.Price_Per_Unit)  -- to impute prices -- 
                ELSE a.Price_Per_Unit
            END AS Price,
            a.Quantity,
            a.Total_Spent,
            COALESCE(a.Payment_Method,'UNKNOWN') AS Payment_Method, -- standardizing -- 
            COALESCE(a.Location,'UNKNOWN') AS Location,   
            a.Transaction_Date
        INTO imputesV1
        FROM 
            standardizedV AS a
        LEFT JOIN 
            PriceItemRef AS b
        ON a.Price_Per_Unit = b.Price_Per_Unit

        LEFT JOIN 
            PriceItemRef AS avc
        ON a.item = avc.Item 

        -- 3.2 2nd round of imputations -- 

        WITH ItemFix AS (
             SELECT 
                Item,
                MIN(Price_Per_Unit) AS price
             FROM standardizedV
             WHERE 
                Item IS NOT NULL        -- fixing prices with missing values from imputesv1 -- 
                AND Price_Per_Unit BETWEEN 3 AND 4
             GROUP BY 
                Item
             )
        SELECT 
            a.Transaction_ID,
            a.Item, 
            CASE 
                WHEN a.Price IS NULL 
                THEN COALESCE(a.price,b.price) -- this might be redundant but there still are some nulls that can be fixed -- 
                ELSE a.Price                        
                END AS Price,
            CASE 
                WHEN a.Price IS NOT NULL AND a.Total_Spent IS NOT NULL
                THEN CAST(a.Total_Spent/a.Price AS smallint)   -- no quantities should be imputed but we can calculate -- 
                ELSE a.Quantity
                END AS Quantity,
            a.Total_Spent, -- can't calculate yet -- 
            a.Payment_Method,
            a.Location,
            a.Transaction_Date
        INTO imputesv2 -- might need a v3 for prices but i dont think its necessary -- 
        FROM imputesV1 AS a
        LEFT JOIN 
               ItemFix AS b
        ON 
            a.item = b.item
                
        -- 3.3 3rd and hopefully final round (it is)
        SELECT 
            Transaction_ID,
            Item,
            CASE 
                WHEN Quantity IS NOT NULL AND Total_Spent IS NOT NULL 
                THEN CAST(Total_Spent/Quantity AS DECIMAL (10,2)) 
                ELSE Price
            END AS Price,
            CASE 
                WHEN Price IS NOT NULL AND Total_Spent IS NOT NULL
                THEN CAST(Total_Spent/Price AS smallint)   -- imputing again cuz idk why this is happening -- 
                ELSE Quantity
            END AS Quantity, -- this removes every nulls that can be safely imputed -- 
            CASE 
                WHEN Price IS NOT NULL AND Quantity IS NOT NULL 
                THEN Price*Quantity  -- now we can calculate this -- 
                ELSE Total_Spent
            END AS Total_Sale,
            Payment_Method,
            Location,
            Transaction_Date
        INTO imputesV3  -- satisfying --
        FROM 
            imputesv2 
-- 4. Adding an Issue column for flagging -- 
        SELECT 
            *,
            CASE 
                WHEN Item IS NULL THEN 'ITEM UNKNOWN' 
                WHEN Quantity IS NULL THEN 'MISSING Q'
                WHEN Price IS NULL THEN 'MISSING P'
                WHEN Total_Sale IS NULL THEN 'MISSING S'
                ELSE 'USABLE'
            END AS Issue
        INTO almostready
        FROM imputesV3
                
        -- 4.1 Validating the results and the grain of the cleaned table 
        SELECT 
            Transaction_ID,
            COUNT(*) AS RowCnt
        FROM almostready       -- 0 duplicates -- 
                            -- same query from the beginning --
        GROUP BY 
            Transaction_ID
        HAVING 
            COUNT(*) > 1
                
        -- 4.2 checking for correct aggregation-- 
        SELECT 
            SUM(Quantity) as sumq 
        FROM 
            almostready             -- 30180 -- 
        WHERE 
            Quantity IS NOT NULL
        -- both there queries above and below returns the same sum of 30180 which means grain of 1:1 was retained throughout the cleaning -- 
        SELECT 
            SUM(Quantity) as sumq 
        FROM 
            (
                SELECT 
                DISTINCT 
                    Transaction_ID, -- 30180 -- 
                    Item,           -- on to the next step
                    Quantity 
                FROM almostready 
              ) AS a
    
-- 5. Final step 
-- 5.1 Making a copy for VALID rows
        SELECT 
            *
        INTO Usable
        FROM 
            almostready    -- 9479 ROWS -- 
        WHERE 
            Issue = 'USABLE'

-- 5.2 Making a copy for INVALID rows
        SELECT 
            *
        INTO Unusable
        FROM
            almostready    -- 521 rows -- 
        WHERE 
            Issue != 'USABLE'

-- This manages to preserve 10000 rows out of 10000 -- 
-- Note that there are still  521 unknowns in item name and was not omitted due to the sales made and other important metrics the rows contain--

-- SOME QnA 
-- 1. total number of orders, quantity bought, and revenue made for each item --
      -- this also tells which is the all-time best selling product -- 
        SELECT 
            Item,
            COUNT(*) AS orders, 
            SUM(Quantity) AS SumQ,
            SUM(Total_Sale ) AS SumTS
        FROM 
            almostready                                 
        GROUP BY 
            Item
        ORDER BY 
            SumTS 
        DESC
        -- This gives us this table 
                Item                                               orders      SumQ        SumTS
                -------------------------------------------------- ----------- ----------- ---------------------------------------
                SALAD                                              1270        3815        19075.00
                SANDWICH                                           1131        3429        13716.00
                SMOOTHIE                                           1096        3336        13344.00
                JUICE                                              1171        3505        10515.00
                CAKE                                               1139        3468        10404.00
                COFFEE                                             1284        3878        7756.00
                TEA                                                1199        3622        5433.00
                NULL                                               501         1542        5268.00
                COOKIE                                             1209        3585        3585.00

-- 2. Sales made from unknown items (this gives $5268.00 which is why NULL Items were not omitted if they had sales values) --

        SELECT SUM(Total_Sale) AS SUMtsnull
        FROM almostready 
        WHERE Item IS NULL

-- much more complex questions like sales made each month will be answered in powerBI -- 
-- With that, we move on to analysis -- 
-- note that there still are nulls in the table but will be filtered further in PowerBI --




   
