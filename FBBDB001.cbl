IDENTIFICATION DIVISION.
PROGRAM-ID. SimpleDB2WithTable.

ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
SPECIAL-NAMES.
    DB2.

DATA DIVISION.
FILE SECTION.
    * No file section needed, we will use DB2 directly.

WORKING-STORAGE SECTION.
    01  WS-EMP-ID          PIC 9(5).
    01  WS-EMP-NAME        PIC X(30).
    01  WS-EMP-DEPT        PIC X(20).
    01  WS-TABLE-SIZE      PIC 9(2) VALUE 5.
    
    01  WS-EMPLOYEES.
        05  WS-EMPLOYEE OCCURS 5 TIMES INDEXED BY EMP-INDEX.
            10  WS-EMP-ID-TABLE       PIC 9(5).
            10  WS-EMP-NAME-TABLE     PIC X(30).
            10  WS-EMP-DEPT-TABLE     PIC X(20).
    
    01  WS-STATUS          PIC S9(4) COMP.

LINKAGE SECTION.
    01  DB2-SQLCODE        PIC S9(4) COMP.

PROCEDURE DIVISION.

MAIN-LOGIC.
    * Connect to DB2
    EXEC SQL
        CONNECT TO 'MYDB'
    END-EXEC.
    
    * Check if connection is successful
    IF SQLCODE NOT = 0 THEN
        DISPLAY 'ERROR CONNECTING TO DB2.'
        STOP RUN
    END-IF.

    * Declare and open a cursor to retrieve multiple records
    EXEC SQL
        DECLARE C1 CURSOR FOR EMP_CURSOR
        FOR SELECT EMP_ID, EMP_NAME, EMP_DEPT
            FROM EMPLOYEE
            WHERE EMP_ID BETWEEN 1001 AND 1005
    END-EXEC.

    EXEC SQL OPEN C1 END-EXEC.

    * Fetch multiple rows into the table
    PERFORM FETCH-EMPLOYEES UNTIL SQLCODE NOT = 0.

    * Display the employee records stored in the table
    PERFORM DISPLAY-EMPLOYEES.

    * Close the cursor and disconnect from DB2
    EXEC SQL CLOSE C1 END-EXEC.
    EXEC SQL COMMIT END-EXEC.

    DISPLAY 'Program Completed Successfully'.
    
    STOP RUN.

FETCH-EMPLOYEES.
    EXEC SQL FETCH C1 INTO :WS-EMP-ID, :WS-EMP-NAME, :WS-EMP-DEPT END-EXEC.
    
    * Store fetched data into the table
    IF SQLCODE = 0 THEN
        ADD 1 TO EMP-INDEX
        MOVE WS-EMP-ID TO WS-EMP-ID-TABLE (EMP-INDEX)
        MOVE WS-EMP-NAME TO WS-EMP-NAME-TABLE (EMP-INDEX)
        MOVE WS-EMP-DEPT TO WS-EMP-DEPT-TABLE (EMP-INDEX)
    END-IF.
    EXIT.

DISPLAY-EMPLOYEES.
    DISPLAY 'Employee Records:'
    PERFORM VARYING EMP-INDEX FROM 1 BY 1 UNTIL EMP-INDEX > WS-TABLE-SIZE
        DISPLAY 'Employee ID: ' WS-EMP-ID-TABLE (EMP-INDEX)
        DISPLAY 'Employee Name: ' WS-EMP-NAME-TABLE (EMP-INDEX)
        DISPLAY 'Department: ' WS-EMP-DEPT-TABLE (EMP-INDEX)
        DISPLAY '-----------------------------------'
    END-PERFORM.
    EXIT.
