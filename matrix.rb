class Matrix4x4
  attr_accessor :m
  def initialize
    @m = [
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      0.0, 0.0, 0.0, 1.0
    ]
  end

  def print_matrix
    print "\n"
    p @m[0..3]
    p @m[4..7]
    p @m[8..11]
    p @m[12..15]
    print "\n"
  end

  def mul(other)
    result = Matrix4x4.new
    4.times do |i|
      4.times do |j|
        result.m[i * 4 + j] = 0.0
        4.times do |k|
          result.m[i * 4 + j] += @m[i * 4 + k] * other.m[k * 4 + j]
        end
      end
    end
    result
  end

  def position(old)
    w = @m[12] * old[:x] + @m[13] * old[:y] + @m[14] * old[:z] + @m[15]
    {
      x: (@m[0] * old[:x] + @m[1] * old[:y] + @m[2] * old[:z] + @m[3]) / w,
      y: (@m[4] * old[:x] + @m[5] * old[:y] + @m[6] * old[:z] + @m[7]) / w,
      z: (@m[8] * old[:x] + @m[9] * old[:y] + @m[10] * old[:z] + @m[11]) / w
    }
  end

  def self.from_translation(vector)
    result = Matrix4x4.new

    result.m[3] = vector[:x]
    result.m[7] = vector[:y]
    result.m[11] = vector[:z]
    result
  end

  def self.from_rotation(rotation)
    x = rotation[:x]
    y = rotation[:y]
    z = rotation[:z]
    rx = Matrix4x4.new
    ry = Matrix4x4.new
    rz = Matrix4x4.new
    rx.m[5] = Math.cos(x)
    rx.m[6] = -Math.sin(x)
    rx.m[9] = Math.sin(x)
    rx.m[10] = Math.cos(x)
    ry.m[0] = Math.cos(y)
    ry.m[2] = -Math.sin(y)
    ry.m[8] = Math.sin(y)
    ry.m[10] = Math.cos(y)
    rz.m[0] = Math.cos(z)
    rz.m[1] = -Math.sin(z)
    rz.m[4] = Math.sin(z)
    rz.m[5] = Math.cos(z)
    rx.mul(ry.mul(rz))
  end

  def self.camera(position, rotation)
    # position.each {|coord, value| position[coord] = value * -1}
    # rotation.each {|coord, value| rotation[coord] = (value - 180) * (Math::PI / 180)}
    # from_translation(position).mul(from_rotation(rotation))
    from_rotation(rotation).mul(from_translation(position))
  end

  def self.look_at(eye, at, up)
    z_axis = VectorMath.normalize(VectorMath.sub(at, eye))
    x_axis = VectorMath.normalize(VectorMath.cross(z_axis, up))
    y_axis = VectorMath.cross(x_axis, z_axis)

    # z_axis[:x] *= -1
    # z_axis[:y] *= -1
    # z_axis[:z] *= -1

    result = Matrix4x4.new
    result.m[0] = x_axis[:x]
    result.m[1] = y_axis[:x]
    result.m[2] = z_axis[:x]
    result.m[4] = x_axis[:y]
    result.m[5] = y_axis[:y]
    result.m[6] = z_axis[:y]
    result.m[8] = x_axis[:z]
    result.m[9] = y_axis[:z]
    result.m[10] = z_axis[:z]
    result.m[12] = -(VectorMath.dot(x_axis, eye))
    result.m[13] = -(VectorMath.dot(y_axis, eye))
    result.m[14] = -(VectorMath.dot(z_axis, eye))
    result.print_matrix
    result
  end

  def self.model(position, rotation)
    from_translation(position).mul(from_rotation(rotation))
  end

  def self.from_perspective(fov, aspect, near, far)
    f = Math.tan((fov * Math::PI / 180) * 0.5)
    range = near - far

    result = Matrix4x4.new
    result.m[0] = 1.0 / (f * aspect)
    result.m[5] = 1.0 / f
    result.m[10] = (-near - far) / range
    result.m[11] = 2 * far * near / range
    result.m[14] = 1.0
    result
  end
end