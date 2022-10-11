module VectorMath
  def dot(v1, v2)
    (v1[:x] * v2[:x]) + (v1[:y] * v2[:y]) + (v1[:z] * v2[:z])
  end

  def normalize(v)
    length = Math.sqrt(v[:x]**2 + v[:y]**2 + v[:z]**2)
    v[:x] /= length
    v[:y] /= length
    v[:z] /= length
    v
  end

  def sub(v1, v2)
    p v1
    p v2
    {x: v1[:x] - v2[:x], y: v1[:y] - v2[:y], z: v1[:z] - v2[:z]}
  end

  def plus(v1, v2)
    {x: v1[:x] + v2[:x], y: v1[:y] + v2[:y], z: v1[:z] + v2[:z]}
  end

  def mul(v1, v2 = nil, num: nil)
    {x: v1[:x] * num, y: v1[:y] * num, z: v1[:z] * num}
  end

  def cross(v1, v2)
    {
      x: (v1[:y] * v2[:z]) - (v1[:z] * v2[:y]),
      y: (v1[:z] * v2[:x]) - (v1[:x] * v2[:z]),
      z: (v1[:x] * v2[:y]) - (v1[:y] * v2[:x])
    }
  end
end