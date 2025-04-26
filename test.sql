CREATE EXTENSION IF NOT EXISTS plperl;
CREATE EXTENSION IF NOT EXISTS plpython3u;
CREATE EXTENSION IF NOT EXISTS pltcl;

DROP TABLE IF EXISTS test_data cascade;
CREATE TABLE test_data (
    id serial PRIMARY KEY,
    value integer,
    text_data text
);

INSERT INTO test_data (value, text_data)
SELECT
    i,
    'Data for row ' || i
FROM
    generate_series(1, 10000) AS i;

-- Create functions in different languages that return 42

-- SQL function
CREATE OR REPLACE FUNCTION fn_sql_42(i int)
RETURNS integer AS
$$
    SELECT 42;
$$ LANGUAGE sql;

-- PL/pgSQL function
CREATE OR REPLACE FUNCTION fn_plpgsql_42(i int)
RETURNS integer AS
$$
BEGIN
    RETURN 42;
END;
$$ LANGUAGE plpgsql;

-- Perl function
CREATE OR REPLACE FUNCTION fn_perl_42(i int)
RETURNS integer AS
$$
    return 42;
$$ LANGUAGE plperl;

-- Python function
CREATE OR REPLACE FUNCTION fn_python_42(i int)
RETURNS integer AS
$$
    return 42
$$ LANGUAGE plpython3u;

-- Tcl function
CREATE OR REPLACE FUNCTION fn_tcl_42(i int)
RETURNS integer AS
$$
    return 42
$$ LANGUAGE pltcl;

-- Create functions that select a single row from the test table

-- SQL function
CREATE OR REPLACE FUNCTION fn_sql_select_row(p_id integer)
RETURNS test_data AS
$$
    SELECT * FROM test_data WHERE id = p_id;
$$ LANGUAGE sql;

-- PL/pgSQL function
CREATE OR REPLACE FUNCTION fn_plpgsql_select_row(p_id integer)
RETURNS test_data AS
$$
DECLARE
    result test_data;
BEGIN
    SELECT * INTO result FROM test_data WHERE id = p_id;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Perl function
CREATE OR REPLACE FUNCTION fn_perl_select_row(p_id integer)
RETURNS test_data AS
$$
    my $id = shift;
    my $rv = spi_exec_query("SELECT * FROM test_data WHERE id = $id", 1);
    if ($rv->{processed} > 0) {
        return $rv->{rows}[0];
    }
    return undef;
$$ LANGUAGE plperl;

-- Python function
CREATE OR REPLACE FUNCTION fn_python_select_row(p_id integer)
RETURNS test_data AS
$$
    plan = plpy.prepare("SELECT * FROM test_data WHERE id = $1", ["integer"])
    rv = plpy.execute(plan, [p_id], 1)
    if rv.nrows() > 0:
        return rv[0]
    return None
$$ LANGUAGE plpython3u;

-- Tcl function
CREATE OR REPLACE FUNCTION fn_tcl_select_row(p_id integer)
RETURNS test_data AS
$$
    set result [spi_exec "SELECT * FROM test_data WHERE id = '$1'"]
    if {[llength $result] > 0} {
        return [list id $id value $value text_data $text_data]
    }
    return_null
$$ LANGUAGE pltcl;

-- Create a benchmark function
CREATE OR REPLACE FUNCTION benchmark_languages(n integer)
RETURNS TABLE(test_type text, language text, execution_time_ms numeric) AS
$$
DECLARE
    start_time timestamptz;
    end_time timestamptz;
    iterations int := 10000;
BEGIN
    -- Benchmark simple functions that return 42

    -- SQL function
    start_time := clock_timestamp();
    FOR i IN 1..iterations LOOP
        PERFORM fn_sql_42(i);
    END LOOP;
    end_time := clock_timestamp();
    test_type := 'Return 42';
    language := 'SQL';
    execution_time_ms := extract(epoch from (end_time - start_time)) * 1000;
    RETURN NEXT;

    -- PL/pgSQL function
    start_time := clock_timestamp();
    FOR i IN 1..iterations LOOP
        PERFORM fn_plpgsql_42(i);
    END LOOP;
    end_time := clock_timestamp();
    test_type := 'Return 42';
    language := 'PL/pgSQL';
    execution_time_ms := extract(epoch from (end_time - start_time)) * 1000;
    RETURN NEXT;

    -- Perl function
    start_time := clock_timestamp();
    FOR i IN 1..iterations LOOP
        PERFORM fn_perl_42(i);
    END LOOP;
    end_time := clock_timestamp();
    test_type := 'Return 42';
    language := 'Perl';
    execution_time_ms := extract(epoch from (end_time - start_time)) * 1000;
    RETURN NEXT;

    -- Python function
    start_time := clock_timestamp();
    FOR i IN 1..iterations LOOP
        PERFORM fn_python_42(i);
    END LOOP;
    end_time := clock_timestamp();
    test_type := 'Return 42';
    language := 'Python';
    execution_time_ms := extract(epoch from (end_time - start_time)) * 1000;
    RETURN NEXT;

    -- Tcl function
    start_time := clock_timestamp();
    FOR i IN 1..iterations LOOP
        PERFORM fn_tcl_42(i);
    END LOOP;
    end_time := clock_timestamp();
    test_type := 'Return 42';
    language := 'Tcl';
    execution_time_ms := extract(epoch from (end_time - start_time)) * 1000;
    RETURN NEXT;

    -- Benchmark functions that select a row from the table

    -- SQL function
    start_time := clock_timestamp();
    FOR i IN 1..iterations LOOP
        PERFORM fn_sql_select_row(i);
    END LOOP;
    end_time := clock_timestamp();
    test_type := 'Select Row';
    language := 'SQL';
    execution_time_ms := extract(epoch from (end_time - start_time)) * 1000;
    RETURN NEXT;

    -- PL/pgSQL function
    start_time := clock_timestamp();
    FOR i IN 1..iterations LOOP
        PERFORM fn_plpgsql_select_row(i);
    END LOOP;
    end_time := clock_timestamp();
    test_type := 'Select Row';
    language := 'PL/pgSQL';
    execution_time_ms := extract(epoch from (end_time - start_time)) * 1000;
    RETURN NEXT;

    -- Perl function
    start_time := clock_timestamp();
    FOR i IN 1..iterations LOOP
        PERFORM fn_perl_select_row(i);
    END LOOP;
    end_time := clock_timestamp();
    test_type := 'Select Row';
    language := 'Perl';
    execution_time_ms := extract(epoch from (end_time - start_time)) * 1000;
    RETURN NEXT;

    -- Python function
    start_time := clock_timestamp();
    FOR i IN 1..iterations LOOP
        PERFORM fn_python_select_row(i);
    END LOOP;
    end_time := clock_timestamp();
    test_type := 'Select Row';
    language := 'Python';
    execution_time_ms := extract(epoch from (end_time - start_time)) * 1000;
    RETURN NEXT;

    -- Tcl function
    start_time := clock_timestamp();
    FOR i IN 1..iterations LOOP
        PERFORM fn_tcl_select_row(i);
    END LOOP;
    end_time := clock_timestamp();
    test_type := 'Select Row';
    language := 'Tcl';
    execution_time_ms := extract(epoch from (end_time - start_time)) * 1000;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

\pset pager off

WITH runs AS (
    SELECT generate_series(1, 5) AS run_number
)
SELECT
    r.run_number,
    b.test_type,
    b.language,
    b.execution_time_ms
INTO temp results
FROM
    runs r
CROSS JOIN LATERAL
    benchmark_languages(r.run_number) b
ORDER BY
    r.run_number, b.test_type, b.execution_time_ms;

SELECT * FROM results;

SELECT
    test_type,
    language,
    round(avg(execution_time_ms), 2) AS avg_execution_time_ms,
    round(min(execution_time_ms), 2) AS min_execution_time_ms,
    round(max(execution_time_ms), 2) AS max_execution_time_ms,
    round(avg(execution_time_ms) / (
        SELECT min(avg_execution_time_ms)
        FROM (
            SELECT test_type, language, avg(execution_time_ms) AS avg_execution_time_ms
            FROM results
            GROUP BY test_type, language
        ) AS min_times
        WHERE min_times.test_type = results.test_type
    ), 2) AS relative_performance
FROM
    results
GROUP BY
    test_type, language
ORDER BY
    test_type, avg_execution_time_ms;
