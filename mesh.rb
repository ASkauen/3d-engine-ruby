class Mesh
  attr_accessor :vao, :pos, :rot
  def initialize(vertices, indices, normals, shader)
    vertices_grouped = vertices.each_slice(3).to_a
    normals_grouped = normals.each_slice(3).to_a
    vertices = vertices_grouped.zip(normals_grouped).flatten
    @shader = shader
    @pos = {x: 0, y: 0, z: 0}
    @rot = {x: 0, y: 0, z: 0}
    @vao = "    "
    @vbo = "    "
    @ebo = "    "
    @color = [(rand(10) / 10.0), (rand(10) / 10.0), (rand(10) / 10.0)]
    @vertex_count = vertices.length / 3
    @index_count = indices.length
    GL.GenBuffers(1, @vbo)
    GL.GenVertexArrays(1, @vao)
    GL.GenBuffers(1, @ebo)
    @vao = @vao.unpack("l")[0].to_i
    @vbo = @vbo.unpack("l")[0].to_i
    @ebo = @ebo.unpack("l")[0].to_i
    GL.BindVertexArray(@vao)
    GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, @ebo)
    GL.BufferData(GL::ELEMENT_ARRAY_BUFFER, (Fiddle::SIZEOF_INT * indices.length), indices.pack('L*'), GL::STATIC_DRAW)
    GL.BindBuffer(GL::ARRAY_BUFFER, @vbo)
    GL.BufferData(GL::ARRAY_BUFFER, (Fiddle::SIZEOF_FLOAT * vertices.length), vertices.pack('F*'), GL::STATIC_DRAW)
    GL.VertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, 6 * Fiddle::SIZEOF_FLOAT, 0)
    GL.VertexAttribPointer(1, 3, GL::FLOAT, GL::FALSE, 6 * Fiddle::SIZEOF_FLOAT, 3 * Fiddle::SIZEOF_FLOAT)
    GL.EnableVertexAttribArray(0)
    GL.EnableVertexAttribArray(1)
    ObjectSpace.define_finalizer(self, self.class.finalize(@vbo, @vao, @ebo))
  end

  def self.from_file(file_path, shader)
    loaded = ObjLoader.from_file(file_path)
    Mesh.new(loaded[:vertices], loaded[:indices], loaded[:normals], shader)
  end

  def draw(pm, vm)
    # @rot[:x] += 0.01
    # @rot[:y] += 0.01
    # @rot[:z] += 0.01
    mm = Matrix4x4.model(@pos, @rot)
    @shader.bind
    GL.BindVertexArray(@vao)
    color_location = @shader.get_uniform_location("color")
    light_color_location = @shader.get_uniform_location("lightColor")
    pm_location = @shader.get_uniform_location("projection_matrix")
    vm_location = @shader.get_uniform_location("view_matrix")
    mm_location = @shader.get_uniform_location("model_matrix")
    view_pos_location = @shader.get_uniform_location("view_pos")
    light_pos_location = @shader.get_uniform_location("light_pos")
    GL.Uniform3f(view_pos_location, *$camera.pos.values)
    GL.Uniform3f(light_pos_location, *$light_pos.values)
    GL.Uniform3f(color_location, *@color)
    GL.Uniform3f(light_color_location, 1.0, 1.0, 1.0)
    GL.UniformMatrix4fv(pm_location, 1, GL::TRUE, pm.m.pack("F16"))
    GL.UniformMatrix4fv(vm_location, 1, GL::FALSE, vm.m.pack("F16"))
    GL.UniformMatrix4fv(mm_location, 1, GL::TRUE, mm.m.pack("F16"))
    GL.PolygonMode(GL::FRONT_AND_BACK, GL::FILL)
    GL.DrawElements(GL::TRIANGLES, @index_count, GL::UNSIGNED_INT, 0)
  end

  def self.finalize(vbo, vao, ebo)
    proc do
      GL.DeleteBuffers(1, [vbo].pack("l"))
      GL.DeleteVertexArrays(1, [vao].pack("l"))
      GL.DeleteBuffers(1, [ebo].pack("l"))
    end
  end
end