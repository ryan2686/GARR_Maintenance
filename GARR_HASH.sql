
-- Code to create Hash Table
SELECT DISTINCT bin_sql_server_temp.GROUPID, CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("bin")))', 'VARCHAR(MAX)') Base64Encoding
FROM 
	(
		SELECT S1.GROUPID, CAST(S1.ACCTNUM AS VARBINARY(MAX)) AS bin
		FROM
			(
				SELECT GH.GROUPID, GC.ACCTNUM
				FROM BKUSLP.BKUSLP.dbo.GACC GC, BKUSLP.BKUSLP.dbo.GARH GH, BKUSLP.BKUSLP.dbo.GARR GR
				WHERE GH.GROUPID = GR.GROUPID AND GH.LEDGCODE = 'BK'
					AND (
						(GC.ACCTNUM >= GR.BEGACCT AND GC.ACCTNUM <= GR.ENDACCT)
						AND (
						GR.GROUPID IN  (GH.GROUPID)
	     					)
	    					)
			) AS S1
	) AS bin_sql_server_temp;




-- Code to create table of account numbers included in each account range group
(
	SELECT GH.GROUPID, GC.ACCTNUM, GC.ACCTNAME
	FROM BKUSLP.BKUSLP.dbo.GACC GC, BKUSLP.BKUSLP.dbo.GARH GH, BKUSLP.BKUSLP.dbo.GARR GR
	WHERE GH.GROUPID = GR.GROUPID AND GH.LEDGCODE = 'BK'
		AND (
			(GC.ACCTNUM >= GR.BEGACCT AND GC.ACCTNUM <= GR.ENDACCT)
			AND (
				GR.GROUPID IN  (GH.GROUPID)
	     		)
	    		)
) S1;



-- Code to hashable list string by GroupID from table of account numbers included in each account range group
-- Snippet forked from, https://raresql.com/2012/12/18/sql-server-create-comma-separated-list-from-table/
SELECT GROUPID, 
	STUFF((	SELECT ',' + S1.ACCTNUM
			FROM 
				(
					SELECT GH.GROUPID, GC.ACCTNUM
					FROM BKUSLP.BKUSLP.dbo.GACC GC, BKUSLP.BKUSLP.dbo.GARH GH, BKUSLP.BKUSLP.dbo.GARR GR
					WHERE GH.GROUPID = GR.GROUPID AND GH.LEDGCODE = 'BK'
					AND (
						(GC.ACCTNUM >= GR.BEGACCT AND GC.ACCTNUM <= GR.ENDACCT)
						AND (
							GR.GROUPID IN  (GH.GROUPID)
	     					)
	    					)
				) S1
			WHERE S1.GROUPID=S2.GROUPID FOR XML PATH('')),1,1,'') As AcctList
FROM
(
	SELECT GH.GROUPID, GC.ACCTNUM
	FROM BKUSLP.BKUSLP.dbo.GACC GC, BKUSLP.BKUSLP.dbo.GARH GH, BKUSLP.BKUSLP.dbo.GARR GR
	WHERE GH.GROUPID = GR.GROUPID AND GH.LEDGCODE = 'BK'
		AND (
			(GC.ACCTNUM >= GR.BEGACCT AND GC.ACCTNUM <= GR.ENDACCT)
			AND (
				GR.GROUPID IN  (GH.GROUPID)
	     		)
	    		)
) S2
GROUP BY GROUPID





-- Combining above SQL to now create hast table from hashable list
SELECT DISTINCT GROUPID, CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("AcctList")))', 'VARCHAR(MAX)') Base64Encoding
FROM 
(
	SELECT 	GROUPID, 
			STUFF((	SELECT ',' + S1.ACCTNUM
					FROM 
						(
							SELECT DISTINCT GH.GROUPID, GC.ACCTNUM
							FROM BKUSLP.BKUSLP.dbo.GACC GC, BKUSLP.BKUSLP.dbo.GARH GH, BKUSLP.BKUSLP.dbo.GARR GR
							WHERE GH.GROUPID = GR.GROUPID AND GH.LEDGCODE = 'BK'
							AND (
								(GC.ACCTNUM >= GR.BEGACCT AND GC.ACCTNUM <= GR.ENDACCT)
								AND (
									GR.GROUPID IN  (GH.GROUPID)
	     							)
	    							)
						) S1
					WHERE S1.GROUPID=S2.GROUPID FOR XML PATH('')),1,1,'') As AcctList
	FROM
	(
		SELECT GH.GROUPID, GC.ACCTNUM
		FROM BKUSLP.BKUSLP.dbo.GACC GC, BKUSLP.BKUSLP.dbo.GARH GH, BKUSLP.BKUSLP.dbo.GARR GR
		WHERE GH.GROUPID = GR.GROUPID AND GH.LEDGCODE = 'BK'
			AND (
				(GC.ACCTNUM >= GR.BEGACCT AND GC.ACCTNUM <= GR.ENDACCT)
				AND (
					GR.GROUPID IN  (GH.GROUPID)
	     			)
	    			)
	) S2
	GROUP BY GROUPID
) S3







-- Attempting to use HashBytes instead
HASHBYTES('SHA1', S1.ACCTNUM)

SELECT DISTINCT GROUPID, CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("AcctList")))', 'VARCHAR(MAX)') Base64Encoding
FROM 
(
	SELECT 	GROUPID, 
			HASHBYTES(('SHA1', SELECT S1.ACCTNUM
						FROM 
						(
							SELECT DISTINCT GH.GROUPID, GC.ACCTNUM
							FROM BKUSLP.BKUSLP.dbo.GACC GC, BKUSLP.BKUSLP.dbo.GARH GH, BKUSLP.BKUSLP.dbo.GARR GR
							WHERE GH.GROUPID = GR.GROUPID AND GH.LEDGCODE = 'BK'
							AND (
								(GC.ACCTNUM >= GR.BEGACCT AND GC.ACCTNUM <= GR.ENDACCT)
								AND (
									GR.GROUPID IN  (GH.GROUPID)
	     							)
	    							)
						) S1
					WHERE S1.GROUPID=S2.GROUPID FOR XML PATH('')),1,1,'') As AcctList
	FROM
	(
		SELECT GH.GROUPID, GC.ACCTNUM
		FROM BKUSLP.BKUSLP.dbo.GACC GC, BKUSLP.BKUSLP.dbo.GARH GH, BKUSLP.BKUSLP.dbo.GARR GR
		WHERE GH.GROUPID = GR.GROUPID AND GH.LEDGCODE = 'BK'
			AND (
				(GC.ACCTNUM >= GR.BEGACCT AND GC.ACCTNUM <= GR.ENDACCT)
				AND (
					GR.GROUPID IN  (GH.GROUPID)
	     			)
	    			)
	) S2
	GROUP BY GROUPID
) S3



-- The below code works but due to limitations of current SQL Server version, HASHBYTES function
--	is limited to 8000 bytes.
--		In the next iteration I will strip the BK from the acctnum and attempt some data normalization
--		similar to what would be applied in deep learning.ABORT
-- I would also like to add an instance counter but that would require more subqueries
SELECT DISTINCT S3.GROUPID, HASHBYTES('SHA1', CAST(AcctList AS VarBinary(7999))) As HashValue
FROM 
(
	SELECT 	GROUPID, 
			STUFF((	SELECT ',' + S1.ACCTNUM
					FROM 
						(
							SELECT DISTINCT GR.GROUPID, GC.ACCTNUM
							FROM BKUSLP.BKUSLP.dbo.GACC GC, BKUSLP.BKUSLP.dbo.GARR GR
							WHERE GR.LEDGCODE = 'BK'
							AND (
								(GC.ACCTNUM >= GR.BEGACCT AND GC.ACCTNUM <= GR.ENDACCT)
	    							)
						) S1
					WHERE S1.GROUPID=S2.GROUPID FOR XML PATH('')),1,1,'') As AcctList
	FROM
	(
		SELECT GR.GROUPID, GC.ACCTNUM
		FROM BKUSLP.BKUSLP.dbo.GACC GC, BKUSLP.BKUSLP.dbo.GARR GR
		WHERE GR.LEDGCODE = 'BK'
			AND (
				(GC.ACCTNUM >= GR.BEGACCT AND GC.ACCTNUM <= GR.ENDACCT)
	    			)
	) S2
	GROUP BY GROUPID
) S3