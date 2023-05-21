CREATE OR REPLACE PACKAGE TransposeTable AUTHID CURRENT_USER IS
   PROCEDURE TransposeTbl (tbl_name VARCHAR2, clmTable VARCHAR2); 
   PROCEDURE TransposeTbl (tbl_name VARCHAR2); 
END TransposeTable;
/

CREATE OR REPLACE PACKAGE BODY TransposeTable IS
    PROCEDURE TransposeTbl (tbl_name VARCHAR2, clmTable VARCHAR2) IS
        tb_name VARCHAR2(30000) := UPPER(tbl_name);
        own VARCHAR2(30000);
        columnsTable VARCHAR2(30000) := UPPER(clmTable);
        TYPE cln IS TABLE OF VARCHAR2(30000);
        column_name cln := cln(); /* Список столбцов */
        checkTable NUMBER(20); /* Для проверки нахождения таблицы */
        checkColumn BOOLEAN := TRUE; /* Для проверки нахождения столбцов */
        tempColumn VARCHAR2(30000); /* Для проверки нахождения столбцов */
        cursor_name INTEGER; /* Название курсора */
        querys VARCHAR2(30000); /* Текст запроса */
        tmp VARCHAR2(30000); /* Для определения типа данных */
        countRow NUMBER(20);
        cnt NUMBER(20) := 1;
        maxLength NUMBER(20) := 0;
        result cln := cln();
        res cln := cln();
    BEGIN
        columnsTable := UPPER(columnsTable);
        IF REGEXP_SUBSTR(tb_name, '\.') IS NULL THEN
            own := 'EKAKLI';
            tb_name := tb_name;
        ELSE
            own := SUBSTR(REGEXP_SUBSTR(tb_name, '\w+\.'), 1, LENGTH(REGEXP_SUBSTR(tb_name, '\w+\.')) - 1);
            tb_name := SUBSTR(tb_name, REGEXP_INSTR(tb_name, '\.') + 1);
        END IF;
        
        SELECT COUNT(*)
        INTO checkTable
        FROM all_objects t
        WHERE t.object_name = tb_name
            AND t.owner = own;
            
        IF checkTable = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Таблицы не существует');
        ELSE
            column_name.EXTEND(REGEXP_COUNT(columnsTable, '\s') + 1);
            result.EXTEND(REGEXP_COUNT(columnsTable, '\s') + 1);
            res.EXTEND(REGEXP_COUNT(columnsTable, '\s') + 1);
            
            FOR i IN 1 .. REGEXP_COUNT(columnsTable, '\s') + 1 LOOP
                column_name(i) := REGEXP_SUBSTR(columnsTable, '\w+', 1, i);
                
                SELECT COUNT(t.column_name)
                INTO tempColumn
                FROM all_tab_columns t
                WHERE t.table_name = tb_name
                    AND t.owner = own
                    AND t.column_name = column_name(i);
                    
                IF tempColumn = 0 THEN
                    checkColumn := FALSE;
                END IF;
            END LOOP;
            
            IF checkColumn = FALSE THEN
                DBMS_OUTPUT.PUT_LINE('Не все переданные столбцы существуют');
            ELSE
                cursor_name := DBMS_SQL.OPEN_CURSOR;
                
                querys := 'SELECT ';
                
                FOR i IN 1 .. column_name.LAST - 1 LOOP
                    querys := querys || column_name(i) || ', ' ;
                END LOOP;
                querys := querys ||  column_name(column_name.LAST) || ' FROM ' || tb_name;
                
                DBMS_SQL.PARSE(cursor_name, querys, DBMS_SQL.NATIVE);
                
                FOR i IN 1 .. column_name.LAST LOOP
                    DBMS_SQL.DEFINE_COLUMN(cursor_name, i, tmp, 30000);
                END LOOP;
                
                countRow := DBMS_SQL.EXECUTE(cursor_name);
                
                FOR i IN 1 .. column_name.LAST LOOP
                    IF LENGTH(column_name(i)) > maxLength THEN
                            maxLength := LENGTH(column_name(i));
                        END IF;
                END LOOP;
                
                FOR i IN 1 .. column_name.LAST LOOP
                    result(i) := RPAD(column_name(i), maxLength + 2);
                END LOOP;
                maxLength := 0;
                
                LOOP
                    countRow := DBMS_SQL.FETCH_ROWS(cursor_name);
                    EXIT WHEN countRow = 0;
                    res.DELETE();
                    FOR i IN 1 .. column_name.LAST LOOP
                        DBMS_SQL.COLUMN_VALUE(cursor_name, i, tmp);
                        res.EXTEND();
                        res(i) := tmp;
                    END LOOP;
                    FOR i IN 1 .. res.LAST LOOP
                        IF LENGTH(res(i)) > maxLength THEN
                            maxLength := LENGTH(res(i));
                        END IF;
                    END LOOP;
                        
                    FOR i IN 1 .. res.LAST LOOP
                        result(i) := result(i) || rpad(res(i), maxLength + 2);
                    END LOOP;
                    maxLength := 0;
                END LOOP;
                
                FOR i IN 1 .. column_name.LAST LOOP
                    DBMS_OUTPUT.PUT_LINE(result(i));
                END LOOP;
            END IF;
        END IF;
    END TransposeTbl;
    
    PROCEDURE TransposeTbl (tbl_name VARCHAR2) IS
        tb_name VARCHAR2(30000) := UPPER(tbl_name);
        columns_name VARCHAR2(30000);
        own VARCHAR2(30000);
        cnt NUMBER(20);
        tmp VARCHAR2(30000);
    BEGIN
        IF REGEXP_SUBSTR(tb_name, '\.') IS NULL THEN
            own := 'EKAKLI';
            tb_name := tb_name;
        ELSE
            own := SUBSTR(REGEXP_SUBSTR(tb_name, '\w+\.'), 1, LENGTH(REGEXP_SUBSTR(tb_name, '\w+\.')) - 1);
            tb_name := SUBSTR(tb_name, REGEXP_INSTR(tb_name, '\.') + 1);
        END IF;
        
        SELECT COUNT(t.column_name) 
        INTO cnt
        FROM all_tab_columns t
        WHERE t.table_name = tb_name
            AND t.owner = own;
            
        FOR i IN 1 .. cnt LOOP
            SELECT column_name 
            INTO tmp
            FROM (SELECT ROWNUM AS rn, t.column_name
                FROM all_tab_columns t
                WHERE t.table_name = tb_name
                    AND t.owner = own)
            WHERE rn = i;
                
            columns_name := columns_name || tmp || ' ';
        END LOOP;
        
        TransposeTbl(own || '.' || tb_name, TRIM(BOTH ' ' FROM columns_name));
    END TransposeTbl;
END TransposeTable;
/

BEGIN
    TransposeTable.TransposeTbl('sh.customer');
END;