# transpose_table
Create a procedure that will allow you to output data from the specified columns of an arbitrary table (view) in a transposed form. The name of the table (view) and the names of the columns are parameters. Column names are passed as a space-delimited string. 
If the list of columns is not specified, output information for all columns. If at least one of the specified columns is missing in the table, an error message is displayed.
Result for the Departments table and the Department_id, Department_name, Location_id columns
DEPARTMENT_ID            10                         20                        30                        40                                    
DEPARTMENT_NAME     Administration      Marketing           Purchasing          Human Resources     
LOCATION_ID                  1700                     1800                     1700                   1700         
Note:  If the table is in the same schema as the procedure, then the schema name can be omitted when setting the parameter value. Otherwise, the schema name must be specified, except for the situation with system views, when the Sys schema is assumed by default.
