class Shader
  attr_reader :program
  def initialize(vertex_shader_source, fragment_shader_source)
    vertex_shader_source = File.read(vertex_shader_source)
    fragment_shader_source = File.read(fragment_shader_source)
    vertex_shader = GL.CreateShader(GL::VERTEX_SHADER)

    GL.ShaderSource(vertex_shader, 1, [vertex_shader_source].pack("p"), nil)
    GL.CompileShader(vertex_shader)

    success = "    "
    GL.GetShaderiv(vertex_shader, GL::COMPILE_STATUS, success)
    str = " " * 512
    if success.unpack("l")[0].to_i == 0
      GL.GetShaderInfoLog(vertex_shader, 512, 0, str)
      puts str + "\n\n#{vertex_shader_source}"
    end

    fragment_shader = GL.CreateShader(GL::FRAGMENT_SHADER)

    GL.ShaderSource(fragment_shader, 1, [fragment_shader_source].pack("p"), nil)
    GL.CompileShader(fragment_shader)

    success = "    "
    GL.GetShaderiv(fragment_shader, GL::COMPILE_STATUS, success)

    str = " " * 512
    if success.unpack("l")[0].to_i == 0
      GL.GetShaderInfoLog(fragment_shader, 512, 0, str)
      puts str + "\n\n#{fragment_shader_source}"
    end

    @program = GL.CreateProgram

    GL.AttachShader(program, vertex_shader)
    GL.AttachShader(program, fragment_shader)

    GL.LinkProgram(program)


    GL.DeleteShader(vertex_shader)
    GL.DeleteShader(fragment_shader)

    ObjectSpace.define_finalizer(self, self.class.finalize(@program))
  end

  def bind
    GL.UseProgram(@program)
  end

  def get_uniform_location(name)
    GL.GetUniformLocation(@program, name)
  end

  def self.finalize(program)
    proc do
      GL.DeleteProgram(program)
    end
  end
end
