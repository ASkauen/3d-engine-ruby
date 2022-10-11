class ObjLoader
  def self.from_file(file_path)
    vertices = []
    indices = []
    normals = []
    File.readlines(file_path).each do |line|
      type = line.split(" ")[0]
      next if type.nil?
      line.sub!(type + " ", "")
      if type == "v"
        vertices << line.split(" ").map(&:to_f)
      elsif type == "vn"
        normals << line.split(" ").map(&:to_f)
      elsif type == "f"
        parts = line.split(" ")
        if !parts[0].include?("/")
          indices << line.split(" ").map {|i| i.to_i - 1}
        else
          parts.each do |part|
            values = part.split("/")
            indices << {v_index: values[0].to_i - 1, t_index: values[1].to_i - 1, n_index: values[2].to_i - 1}
          end
        end
      end
    end
    normals_new = []
    vertices_new = []
    indices_new = []
    indices.each_with_index do |i, index|
      normals_new << normals[i[:n_index]]
      vertices_new << vertices[i[:v_index]]
      indices_new << index
    end
    {vertices: vertices_new.flatten, indices: indices_new.flatten, normals: normals_new.flatten}
  end
end