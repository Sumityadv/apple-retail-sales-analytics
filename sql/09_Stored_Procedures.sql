/*
============================================================
PROJECT : Apple Retail Sales Analytics
FILE    : 09_stored_procedures.sql
PHASE   : Stored Procedures
PURPOSE : Business operations and reusable database actions
============================================================

SAFETY PROTOCOL
------------------------------------------------------------
1. Backup critical tables before testing data-modifying
   procedures.
2. Use BEGIN before executing a modifying procedure.
3. Verify the result using SELECT statements.
4. Use COMMIT only after successful verification.
5. Use ROLLBACK if the result is incorrect.
6. Add validation and exception handling to procedures
   wherever required.
============================================================
09_stored_procedures.sql

1. Basic procedure                    ← START HERE
2. Procedure with parameters
3. IF / ELSE procedure
4. Validation procedure
5. INSERT procedure
6. UPDATE procedure
7. Warranty processing procedure
8. Error handling
9. Transaction handling
10. Complete sales workflow

*/



SET search_path TO apple;

CREATE OR REPLACE PROCEDURE sp_complete_warranty_claim(p_claim_id VARCHAR)

LANGUAGE plpgsql

AS
$$

	BEGIN

		UPDATE warranty
		SET repair_status = 'Completed'
		WHERE claim_id = p_claim_id;


	END;
$$;

-- CALLING THE PROCEDURE WITH SAFETY TRANSACTION FEATURES (BEGIN,COMMIT,ROLLBACK) FOR SAFETY MEASURES --

BEGIN;																		-------------

CALL sp_complete_warranty_claim('CLM000029');							-- USE THIS PART AT EVERY CALLING --

SELECT * 
FROM warranty WHERE claim_id = 'CLM000029';									-------------



/* HERE WE FACED AN ISSUE AFTER CALLING THE PROCEDURE THEN RUNNING BY SELECT * FROM warranty DIDN'T SHOWING THAT COLUMN THAT DOESNT MEAN ITS DELETED ITS JUST 
   UPDATED NEWLY SO POSTGRESQL DOESNT GAURNATEE ABOUT THE ROWS WHILE THIS CODE. BUT IF YOU USE ORDER BY THEN IT WILL SHOW.
   
Why did a row appear in SELECT * FROM warranty before an
UPDATE, but apparently disappear from the displayed result
after the UPDATE using PROCEDURE?

ANSWER:
SELECT * FROM warranty does NOT guarantee the order in which
rows are returned because there is no ORDER BY clause.

Before the UPDATE, PostgreSQL happened to return the rows in
an order where CLM000023 was visible in the displayed result.

After the UPDATE, PostgreSQL could return the rows in a
different physical/execution order. Therefore, CLM000023
might no longer appear in the portion of rows displayed by
the SQL client. */






ROLLBACK;
-- VERIFYING IT HAS BEEN ROLLED BACK OR NOT

SELECT * FROM warranty ORDER BY claim_id LIMIT 30;

COMMIT;
-- VERIFYING FINAL --

SELECT * FROM warranty ORDER BY claim_id LIMIT 30;


SELECT * FROM warranty;


