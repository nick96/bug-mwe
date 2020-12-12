# MWE for bug where "0" is inserted when passing a hash into `insert`

## Setup

Start the database with `docker-compose up -d db`. Then connect to it with
`docker-compose exec db mysql -p` and enter the password "password". To setup
query logging, run the following SQL commands:

``` sql
SET global general_log = 1;
SET global log_output = 'file';
select @@general_log_file;
```

The last command will print the log file that the queries will be written to.
Then you'll want to run `docker-compose exec db tail -f <log-file>` where `log-file`
is the file from the previous command.

To run the app use `docker-compose run app`. This will print out what the app
wants to insert and what was actually inserted into the database.

## Exploration


When `app.rb` is run, it outputs

```
Inserting:
{"type"=>"doc", "content"=>[{"type"=>"text", "text"=>"first"}]}
Inserted record:
{:id=>19, :text=>"0"}
```

So there is clearly something going wrong.


Looking at the query log, we can see the insert statement is not what we expected.

``` sql
SET @@wait_timeout = 2147483
SET SQL_AUTO_IS_NULL=0
SELECT version()
SELECT version()
SELECT NULL AS `nil` FROM `test` LIMIT 1
INSERT INTO `test` (`text`) VALUES ((('type' = 'doc') AND ('content' IN ((('type' = 'text') AND ('text' = 'first'))))))
SELECT * FROM `test` WHERE (`id` = 19) LIMIT 1
```

``` sql
INSERT INTO `test` (`text`) VALUES ((('type' = 'doc') AND ('content' IN ((('type' = 'text') AND ('text' = 'first'))))))
```

Apparently the hash is getting converted into a conditional by `sequel` or `mysql2`
which is then being sent to mysql which evaluates it to 0 or 1. Interestingly it
is then being converted to a string.