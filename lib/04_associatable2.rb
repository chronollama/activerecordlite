require_relative '03_associatable'
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      through_foreign = self.send(through_options.foreign_key)

      source_table = source_options.model_class.table_name
      through_table = through_options.model_class.table_name
      through_primary = "#{through_table}.#{through_options.primary_key}"
      source_foreign = "#{through_table}.#{source_options.foreign_key}"
      source_primary = "#{source_table}.#{source_options.primary_key}"
      source_class = source_options.model_class

      query = DBConnection.execute(<<-SQL, through_foreign)
        SELECT
          #{source_table}.*
        FROM
          #{source_table}
        JOIN
          #{through_table}
          ON #{source_foreign} = #{source_primary}
        WHERE
          #{through_primary} = ?
      SQL
      query.empty? ? nil : source_class.new(query.first)
    end
  end
end
