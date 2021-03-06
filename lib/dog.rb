class Dog
  attr_accessor :name, :breed, :id
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
      );
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  
  def self.new_from_db(data)
    id = data[0]
    name = data[1]
    breed = data[2]
    new_dog = self.new(id: id, name: name, breed: breed)
    new_dog
  end
  
  def save
    sql = "INSERT INTO dogs (name, breed)
          VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  
  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, id).collect { |row| self.new_from_db(row) }.first
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    
    DB[:conn].execute(sql, name).collect { |row| self.new_from_db(row) }.first
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    
    if !dog.empty?
      dog_details = dog[0]
      dog = Dog.new(id: dog_details[0], name: dog_details[1], breed: dog_details[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  
  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
end