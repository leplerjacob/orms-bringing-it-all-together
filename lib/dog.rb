class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(attributes = {})
        @id = nil
        attributes.each{|key, value|
            self.class.attr_accessor(key)
            self.send(("#{key}="), value)
        }
    end

    def self.new_from_db(row)
       dog = self.new
       dog.id = row[0]
       dog.name = row[1]
       dog.breed = row[2]
       dog
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")
        self
    end

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL

        row = DB[:conn].execute(sql, id)[0]
        Dog.new_from_db(row)
    end

    def self.find_or_create_by(hash)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL

        dog = DB[:conn].execute(sql, hash[:name], hash[:breed]).first
        if dog
            new_from_db(dog)
        else
            create(hash)
        end
    end
end