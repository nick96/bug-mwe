require 'sequel'

DB = Sequel.connect(adapter: 'mysql2', user: 'root', password: 'password', host: 'db', database: 'test')

unless DB.table_exists?(:test)
  DB.create_table(:test) do
    primary_key :id
    column :text, String
  end
end

text = {"type"=>"doc", "content"=>[{"type"=>"text", "text"=>"first"}]}
record_id = DB[:test].insert(text: text)
inserted_record = DB[:test].where(id: record_id).first
puts("Inserted record: ", inserted_record.inspect)
