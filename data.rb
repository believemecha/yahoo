models_info = []
errors = []

# Iterate over all models in the app
Dir.glob(Rails.root.join('app', 'models', '*.rb')).each do |file|
  begin 
    puts "processing #{file}"
    model_name = File.basename(file, '.rb')
    model_class = model_name.classify.constantize

    # Get table name
    table_name = model_class.table_name

    # Get column names with types
    columns = model_class.columns.map { |c| "#{c.name}: #{c.type}" }.join('<br>')

    # Get defined enums
    enums = model_class.defined_enums.map { |name, values| "#{name}: #{values}" }.join('<br><br>')

    # Get associations
    associations = model_class.reflect_on_all_associations.map do |assoc|
      "#{assoc.macro} :#{assoc.name}"
    end.join('<br>')

    # Get defined constants (assuming they're defined as class-level constants)
    constants = model_class.constants(false).map do |name|
      value = model_class.const_get(name)
      "#{name}: #{value.inspect}"
    end.join('<br><br>')

    # Get default values
    defaults = model_class.column_defaults.map { |name, value| "#{name}: #{value.inspect}" }.join('<br>')

    models_info << ["Model:#{model_class.name}", table_name, columns, enums, associations, constants, defaults]
  rescue => e
    errors << "Error processing #{file}: #{e.message}"
  end
end

# Convert to HTML table
html_table = "<style>
              table {
                width: 100%;
                border-collapse: collapse;
              }
              th, td {
                border: 1px solid black;
                padding: 8px;
                text-align: left;
              }
              th {
                background-color: #f2f2f2;
              }
              </style>"
html_table += "<table><thead><tr><th>S.No</th><th>Name</th><th>Table Name</th><th>Columns</th><th>Enums</th><th>Associations</th><th>Constants</th><th>Default Values</th></tr></thead><tbody>"
models_info.each_with_index do |model_info, index|
  html_table += "<tr><td>#{index + 1}</td><td>#{model_info[0]}</td><td>#{model_info[1]}</td><td>#{model_info[2]}</td><td>#{model_info[3]}</td><td>#{model_info[4]}</td><td>#{model_info[5]}</td><td>#{model_info[6]}</td></tr>"
end
html_table += "</tbody></table>"

# Write the HTML content and error list to a file
js = "
<script>
function askBharat(){
    const phoneNumber = '+917321965118'; // Replace with your phone number
    const message = 'Hello *Bharat*!, I was checking the table details with the html you sent. I am having some issues.This is the link for the script as yiu sent earlier. https://workat.tech/codes/reshkqg8';

    const url = `https://wa.me/${phoneNumber}/?text=${encodeURIComponent(message)}`;
    window.location.href = url;
}
</script>
"
File.open('models_info.html', 'w') do |file|
  file.write("<h2>Contact <div onclick='askBharat()' style='color: blue; font-weight: bold; cursor:pointer;'>Bharat Bhushan</div> (click on name to connect) for More Details and any help if you need with this. <br></br>")
  file.write(html_table)
  file.write("<h2>Errors:</h2>")
  file.write("<ul>")
  errors.each do |error|
    file.write("<li>#{error}</li>")
  end
  file.write("</ul>")

  file.write(js)
end

puts "HTML table and error list written to models_info.html"