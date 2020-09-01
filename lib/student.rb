require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create(name, grade)
    Student.new(name,grade).tap do |student|
      student.save
    end
  end

  def update
    sql = <<-SQL
    UPDATE students
    SET name = ?, grade = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    LIMIT 1
    SQL
    DB[:conn].execute(sql,name).collect{|row| new_from_db(row)}.first
  end

  def self.new_from_db(row)
    Student.new(row[0],row[1],row[2])
  end

  def save
    if self.id
      update
      else
    sql = <<-SQL
      INSERT INTO students(name,grade)
      VALUES (?, ?)
    SQL
        DB[:conn].execute(sql, self.name, self.grade)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM students
    SQL
    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end
end
